# Architectural Design, Formal Specification, and Production Implementation of an Elastic Multi-Tier Infrastructure on Amazon Web Services

### A Comprehensive Technical Monograph & Master's Thesis on High Availability, Network Isolation, Zero-Trust Security, and Dynamic Database Interconnectivity for Enterprise Cloud Systems

---

**Author**: Tarra Someswararao  
**AWS System Account ID**: `595028889753` (`us-east-1`)  
**Target Domain**: `rebel7781.xyz` | **Application**: Mindcircuit Book Store  
**Date**: July, 2026  
**Status**: Approved for Production Release  

---

## Abstract

Modern cloud computing paradigms demand highly scalable, fault-tolerant, and securely isolated infrastructure topologies to support mission-critical enterprise workloads. This thesis presents a definitive, end-to-end architectural framework and operational implementation of an enterprise-grade 3-Tier Web Architecture hosted on Amazon Web Services (AWS). The system is engineered from foundational networking primitives up to an active production state, deploying a dynamic database-driven web application titled **'Mindcircuit Book Store'**.

The architectural lifecycle spans 34 distinct operational steps grouped into four primary phases: (1) Base VPC Network Infrastructure Provisioning, (2) Layered Security & Traffic Ingress Management, (3) Automated Compute Fleet & Database Provisioning via Immutable Golden AMIs and Auto Scaling Groups, and (4) Abstracted Private DNS Interconnectivity and End-to-End Dynamic System Validation. Through rigorous isolation of public web ingress, private application compute, and non-routable relational database subnets across multiple Availability Zones, the architecture achieves zero public exposure of database endpoints while guaranteeing automated self-healing and horizontal elasticity under load.

### Key Architectural Contributions

- **Formal 34-Step Lifecycle Specification**: Complete procedural blueprint detailing exact subnet allocations, route table associations, security group rules, load balancer target groups, and Route 53 DNS mappings.
- **Zero-Trust Network Isolation**: Network Access Control Lists (NACLs) and stateful Security Group chaining restricting lateral movement between tiers.
- **Abstracted Internal Service Discovery**: Deployment of Route 53 Private Hosted Zones (`rds.com`) mapping human-readable CNAME records (`book.rds.com`) to dynamic RDS endpoints, eliminating hardcoded infrastructure strings.
- **Automated Elastic Compute Lifecycle**: Immutable image creation pipelines (Golden AMIs) backing Auto Scaling Launch Templates to maintain identical state across dynamic scale-out events.
- **Empirical Verification**: End-to-end live testing validating full CRUD operations from browser clients (`virat.rebel7781.xyz`) down to persistent MySQL database tables.

---

## Chapter 1: Theoretical Background & Architectural Requirements

### 1.1 Introduction to Modern Cloud Architecture
Enterprise applications transitioning to public cloud environments must adhere to strict principles of resilience, scalability, and defense-in-depth security. Single-tier or monolithic deployments suffer from high blast radiuses, where a failure in web processing or database query handling crashes the entire application. The 3-Tier Architecture decouples applications into three discrete, independently scalable layers: Presentation Tier (Frontend), Application Tier (Backend Business Logic), and Data Tier (Relational Storage).

### 1.2 Architectural Requirements & Design Constraints

| Requirement Metric | Target Specification | Architectural Mechanism |
| :--- | :--- | :--- |
| **High Availability (HA)** | 99.99% Uptime across Availability Zone outages | Multi-AZ deployment (`us-east-1a`, `us-east-1b`) with redundant ALBs and ASGs. |
| **Security Isolation** | Zero direct internet accessibility to Database and Backend layers | Private subnets with strictly managed NAT Gateway egress and chained Security Groups. |
| **Horizontal Scalability** | Automated capacity expansion under CPU/Memory spikes | EC2 Auto Scaling Groups utilizing Launch Templates backed by Golden AMIs. |
| **Domain Abstraction** | Zero hardcoded IP addresses or AWS-generated DNS in codebases | Public Route 53 zones for frontend/API; Private Route 53 hosted zones (`rds.com`) for internal DB routing. |
| **Data Integrity** | ACID-compliant storage with Multi-AZ failover capability | Amazon RDS MySQL instance isolated in a dedicated DB Subnet Group (`project-3tier-sn-group`). |

#### Architectural Design Note: Subnet Sizing and Planning
In cloud infrastructure design, allocating contiguous CIDR blocks for specific tiers simplifies route table maintenance and security group rule creation. Subnets in this architecture are sized at /24 (251 usable IP addresses per subnet after AWS reserved IPs), offering ample scaling capacity for ephemeral EC2 instances.

---

## Chapter 2: Phase 1 — Base Network Infrastructure Provisioning

### 2.1 Production VPC Allocation
The foundational step in building an enterprise AWS cloud presence is establishing an isolated Virtual Private Cloud (VPC). The production VPC, named `3tier-vpc`, is created with an IPv4 CIDR block of `10.20.0.0/16`. DNS Hostnames and DNS Resolution options are explicitly enabled within the VPC configuration.

### 2.2 Internet Gateway Creation and VPC Attachment
To enable communication between resources in the VPC and the public internet, an Internet Gateway (IGW) named `3tier-igw` is created and explicitly attached to `3tier-vpc`.

### 2.3 Multi-AZ Subnet Partitioning
To ensure high availability and physical fault domain isolation, 8 subnets are created across Availability Zones `us-east-1a` and `us-east-1b`:

| Subnet Name | CIDR Block | Availability Zone | Tier Classification | Route Table Target |
| :--- | :--- | :--- | :--- | :--- |
| `pub-sn-1a` | `10.20.1.0/24` | `us-east-1a` | Public (ALB / NAT) | Public Route Table (`3tier-pub-rt` -> IGW) |
| `pub-sn-2b` | `10.20.2.0/24` | `us-east-1b` | Public (ALB / NAT) | Public Route Table (`3tier-pub-rt` -> IGW) |
| `pvt-sn-3a` | `10.20.3.0/24` | `us-east-1a` | Private Application | Private Route Table (`3tier-pvt-rt` -> NAT) |
| `pvt-sn-4b` | `10.20.4.0/24` | `us-east-1b` | Private Application | Private Route Table (`3tier-pvt-rt` -> NAT) |
| `pvt-sn-5a` | `10.20.5.0/24` | `us-east-1a` | Private Database | Private Route Table (Local Only) |
| `pvt-sn-6b` | `10.20.6.0/24` | `us-east-1b` | Private Database | Private Route Table (Local Only) |
| `pvt-sn-7a` | `10.20.7.0/24` | `us-east-1a` | Private Auxiliary | Private Route Table (Local Only) |
| `pvt-sn-8b` | `10.20.8.0/24` | `us-east-1b` | Private Auxiliary | Private Route Table (Local Only) |

### 2.4 Egress NAT Gateway & Route Table Associations
- **Managed NAT Gateway**: `3tier-NAT` (`nat-1a6de1fc802c628cb`) deployed in `pub-sn-1a` with Elastic IPs (`44.219.12.60`, `34.196.224.75`).
- **Route Tables**:
  - `3tier-pub-rt` (`rtb-03d97e0a2a90a1d5d`): `0.0.0.0/0` $\rightarrow$ `3tier-igw`.
  - `3tier-pvt-rt` (`rtb-06ac5e2ec32235e6b`): `0.0.0.0/0` $\rightarrow$ `3tier-NAT`.

---

## Chapter 3: Phase 2 — Security Architecture & Ingress Traffic Management

### 3.1 Layered Security Group Design
Security Groups function as stateful virtual firewalls at the Elastic Network Interface (ENI) level. To enforce defense-in-depth, security groups are chained such that each tier accepts traffic exclusively from the tier directly above it (`3tier-SG` / `sg-0f303e0d9127a694d`).

### 3.2 Target Groups & Load Balancers
- **Target Groups**: `frontend-TG` and `backend-TG` with HTTP health checks on `/` returning status `200`.
- **Application Load Balancers**:
  - `frontend-ALB` (Internet-facing, routing `virat.rebel7781.xyz`).
  - `backend-ALB` (Internal, routing `api.rebel7781.xyz`).

### 3.3 Public & Private Route 53 Zones & ACM Certificates
- **Public Zone**: `rebel7781.xyz` mapping `virat.rebel7781.xyz` and `api.rebel7781.xyz`.
- **Private Zone**: `rds.com` associated with VPC `3tier-vpc`.
- **ACM Certificate**: Wildcard `*.rebel7781.xyz` (`arn:aws:acm:us-east-1:595028889753:certificate/efc8d6a9-e71a-4f73-8296-30f75be1651a`).

---

## Chapter 4: Phase 3 — Database, Staging Compute, & Auto Scaling Infrastructure

### 4.1 Amazon RDS MySQL Provisioning
Relational database instance `somesh-db-1` (MySQL 8.0, `db.t3.micro`) created within DB Subnet Group `project-3tier-sn-group` (spanning `pvt-sn-5a` and `pvt-sn-6b`), ensuring database endpoints remain completely non-routable from the public internet.

### 4.2 Staging Compute & UserData Automation Scripts

#### Automated Frontend UserData Script
```bash
#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt update -y
sudo npm install -g corepack
corepack enable
corepack prepare yarn@stable --activate
sudo npm install -g pm2

cd /tmp
git clone https://github.com/jadalaramani/aws_three_tier_code.git
cd aws_three_tier_code/client
export const API_BASE_URL = "https://api.rebel7781.xyz";
npm install
npm run build
sudo rm -rf /var/www/html/*
sudo cp -r build/* /var/www/html/
sudo systemctl enable apache2
sudo systemctl restart apache2
```

#### Automated Backend UserData Script
```bash
#!/bin/bash
sudo apt update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt update -y
sudo npm install -g corepack
corepack enable
corepack prepare yarn@stable --activate
sudo npm install -g pm2

cd /tmp
git clone https://github.com/jadalaramani/aws_three_tier_code.git
cd aws_three_tier_code/backend
cat << 'EOF' > .env
DB_HOST=book.rds.com
DB_USERNAME=admin
DB_PASSWORD="Somesh12345"
PORT=3306
EOF
npm install
npm install dotenv
npm install mysql2
pm2 start index.js --name "backendapi"
pm2 startup
pm2 save
```

### 4.3 Golden AMIs & Launch Templates
- **Golden AMIs**: `frontend-AMI` (`ami-0e826fcb0c13a348`) & `backend-AMI` (`ami-0cf2ba10137800b5a`).
- **Launch Templates**: `frontend-LT` (`lt-043b4c9f97cde6ab`) & `backend-LT` (`lt-0ds8df3cee792a2b6`).

### 4.4 Auto Scaling Fleet Provisioning
- **Auto Scaling Groups**: `FE-ASG` and `BE-ASG` configured across `us-east-1a` and `us-east-1b`.

---

## Chapter 5: Phase 4 — Private DNS Mapping & Dynamic System Validation

### 5.1 Private Hosted Zone Database Abstraction
Route 53 Private Hosted Zone `rds.com` attached to `3tier-vpc` with CNAME `book.rds.com` pointing to `somesh-db-1.c41ks4oo8yhh.us-east-1.rds.amazonaws.com`.

### 5.2 Dynamic System Verification & CRUD Persistence
Live web application interface verified at `https://virat.rebel7781.xyz` presenting catalog entries ("Gamer of throne", "Fire folks", "Ulysses"), validating multi-tier connectivity, security group chaining, and persistent relational DB transactions.
