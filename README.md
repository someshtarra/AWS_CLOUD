<div align="center">

# 📚 Mindcircuit Book Store – AWS 3-Tier Architecture
### 🚀 Architectural Design, Formal Specification, and Production Implementation of an Elastic Multi-Tier Infrastructure on Amazon Web Services

[![AWS Architecture](https://img.shields.io/badge/AWS-3--Tier_Architecture-ff9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![AWS Region](https://img.shields.io/badge/AWS_Region-us--east--1-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![High Availability](https://img.shields.io/badge/Availability-99.99%25_Multi--AZ-00d26a?style=for-the-badge&logo=statuspage&logoColor=white)](#high-availability-design)
[![Zero-Trust Security](https://img.shields.io/badge/Security-Zero--Trust_Private_Subnets-red?style=for-the-badge&logo=shield&logoColor=white)](#security-architecture)
[![IaC Ready](https://img.shields.io/badge/IaC-Terraform_&_CloudFormation-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](#infrastructure-as-code)
[![Thesis Monograph](https://img.shields.io/badge/Thesis_Monograph-PDF_%26_Spec-blue?style=for-the-badge&logo=read-the-docs&logoColor=white)](docs/AWS_3_Tier_Architecture_Thesis.md)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

---

### 📋 Monograph & System Metadata
| Property | Specification Value |
| :--- | :--- |
| **Author** | **Tarra Someswararao** |
| **Full Master's Thesis Document** | [📄 AWS_3_Tier_Architecture_Thesis.md](docs/AWS_3_Tier_Architecture_Thesis.md) |
| **AWS System Account ID** | `595028889753` (`us-east-1`) |
| **Target Production Domain** | `rebel7781.xyz` |
| **Application Title** | **Mindcircuit Book Store** |
| **Frontend Endpoint** | `https://virat.rebel7781.xyz` |
| **Backend API Endpoint** | `https://api.rebel7781.xyz` |
| **Internal DB CNAME** | `book.rds.com` (Route 53 Private Zone `rds.com`) |
| **Release Status** | **Approved for Production Release (July 2026)** |

---

</div>

## 📌 Table of Contents
- [📖 Executive Abstract](#-executive-abstract)
- [Key Architectural Contributions](#-key-architectural-contributions)
- [📐 Architecture Diagram & Network Topology](#-architecture-diagram--network-topology)
- [🎯 Architectural Requirements & Constraints](#-architectural-requirements--constraints)
- [🔬 34-Step Procedural Lifecycle Specification](#-34-step-procedural-lifecycle-specification)
  - [Phase 1: Base VPC Network Infrastructure Provisioning](#phase-1-base-vpc-network-infrastructure-provisioning)
  - [Phase 2: Layered Security & Traffic Ingress Management](#phase-2-layered-security--traffic-ingress-management)
  - [Phase 3: Database, Staging Compute & Auto Scaling Infrastructure](#phase-3-database-staging-compute--auto-scaling-infrastructure)
  - [Phase 4: Private DNS Mapping & Dynamic System Validation](#phase-4-private-dns-mapping--dynamic-system-validation)
- [🛠️ AWS Services Inventory & Micro-Segmented Security](#%EF%B8%8F-aws-services-inventory--micro-segmented-security)
- [📜 UserData & Boot Automation Scripts](#-userdata--boot-automation-scripts)
- [🔧 DevOps & Operational Troubleshooting Runbook](#-devops--operational-troubleshooting-runbook)
- [📂 Repository Directory Structure](#-repository-directory-structure)
- [🧠 Enterprise Skills Demonstrated](#-enterprise-skills-demonstrated)

---

## 📖 Executive Abstract

Modern cloud computing paradigms demand highly scalable, fault-tolerant, and securely isolated infrastructure topologies to support mission-critical enterprise workloads. This repository presents the definitive, end-to-end architectural framework and operational implementation of an enterprise-grade **3-Tier Web Architecture hosted on Amazon Web Services (AWS)**. The system is engineered from foundational networking primitives up to an active production state, deploying a dynamic database-driven web application titled **'Mindcircuit Book Store'**.

The architectural lifecycle spans **34 distinct operational steps** grouped into four primary phases:
1. **Base VPC Network Infrastructure Provisioning**
2. **Layered Security & Traffic Ingress Management**
3. **Automated Compute Fleet & Database Provisioning via Immutable Golden AMIs and Auto Scaling Groups**
4. **Abstracted Private DNS Interconnectivity and End-to-End Dynamic System Validation**

Through rigorous isolation of public web ingress, private application compute, and non-routable relational database subnets across multiple Availability Zones, the architecture achieves zero public exposure of database endpoints while guaranteeing automated self-healing and horizontal elasticity under load.

---

## ✨ Key Architectural Contributions

- 📋 **Formal 34-Step Lifecycle Specification**: Complete procedural blueprint detailing exact subnet allocations, route table associations, security group rules, load balancer target groups, and Route 53 DNS mappings.
- 🛡️ **Zero-Trust Network Isolation**: Network Access Control Lists (NACLs) and stateful Security Group chaining restricting lateral movement between tiers.
- 🗺️ **Abstracted Internal Service Discovery**: Deployment of Route 53 Private Hosted Zones (`rds.com`) mapping human-readable CNAME records (`book.rds.com`) to dynamic RDS endpoints, eliminating hardcoded infrastructure strings.
- 🔄 **Automated Elastic Compute Lifecycle**: Immutable image creation pipelines (Golden AMIs `frontend-AMI` & `backend-AMI`) backing Auto Scaling Launch Templates to maintain identical state across dynamic scale-out events.
- 🧪 **Empirical Verification**: End-to-end live testing validating full CRUD operations from browser clients (`virat.rebel7781.xyz`) down to persistent MySQL database tables.

---

## 📐 Architecture Diagram & Network Topology

```
                                      +--------------------------------------------------------+
                                      |                     INTERNET USERS                     |
                                      +---------------------------+----------------------------+
                                                                  |
                                                                  | HTTPS (Port 443)
                                                                  v
                                      +--------------------------------------------------------+
                                      |            AMAZON ROUTE 53 PUBLIC HOSTED ZONE          |
                                      |                  Domain: rebel7781.xyz                 |
                                      |   • virat.rebel7781.xyz  ==> Frontend ALB (React+Apache)|
                                      |   • api.rebel7781.xyz    ==> Backend ALB (Node.js+PM2) |
                                      +---------------------------+----------------------------+
                                                                  |
                                                                  v
                                      +--------------------------------------------------------+
                                      |               INTERNET GATEWAY (3tier-igw)             |
                                      +---------------------------+----------------------------+
                                                                  |
  ================================================================|===============================================================
  VPC: 3tier-vpc (10.20.0.0/16 | vpc-00d8d6beb7dcedcc4)            v
  ================================================================================================================================
  
        +----------------------------------------------------+        +----------------------------------------------------+
        | AVAILABILITY ZONE A (us-east-1a)                   |        | AVAILABILITY ZONE B (us-east-1b)                   |
        +----------------------------------------------------+        +----------------------------------------------------+
        
  --- [ PUBLIC SUBNET 10.20.1.0/24 (pub-sn-1a) ] -------------        --- [ PUBLIC SUBNET 10.20.2.0/24 (pub-sn-2b) ] -------------
  |                                                          |        |                                                          |
  |   +-------------------+          +-------------------+   |        |   +-------------------+                                  |
  |   | Frontend ALB      |          | 3tier-NAT Gateway |   |        |   | Frontend ALB      |                                  |
  |   +---------+---------+          +---------+---------+   |        |   +---------+---------+                                  |
  ----------------|----------------------------|--------------        --------------|---------------------------------------------
                  |                            |                                    |
                  v                            v                                    v
  --- [ PRESENTATION TIER PRIVATE SUBNETS ] ------------------        --- [ PRESENTATION TIER PRIVATE SUBNETS ] ------------------
  | Private Subnet: 10.20.3.0/24 (pvt-sn-3a)                 |        | Private Subnet: 10.20.4.0/24 (pvt-sn-4b)                 |
  |                                                          |        |                                                          |
  |   +--------------------------------------------------+   |        |   +--------------------------------------------------+   |
  |   | FE-ASG Instances (React + Apache Golden AMI)     |   |        |   | FE-ASG Instances (React + Apache Golden AMI)     |   |
  |   +------------------------+-------------------------+   |        |   +------------------------+-------------------------+   |
  -----------------------------|------------------------------        -----------------------------|------------------------------
                               | Internal Backend Traffic                                          |
                               v                                                                   v
  --- [ APPLICATION TIER PRIVATE SUBNETS ] -------------------        --- [ APPLICATION TIER PRIVATE SUBNETS ] -------------------
  | Private Subnet: 10.20.5.0/24 (pvt-sn-5a)                 |        | Private Subnet: 10.20.6.0/24 (pvt-sn-6b)                 |
  |                                                          |        |                                                          |
  |   +--------------------------------------------------+   |        |   +--------------------------------------------------+   |
  |   | BE-ASG Instances (Node.js + Express + PM2)       |   |        |   | BE-ASG Instances (Node.js + Express + PM2)       |   |
  |   +------------------------+-------------------------+   |        |   +------------------------+-------------------------+   |
  -----------------------------|------------------------------        -----------------------------|------------------------------
                               | Private MySQL Traffic (Port 3306 -> book.rds.com)                 |
                               +-----------------------------+-------------------------------------+
                                                             |
                                                             v
  --- [ DATABASE TIER PRIVATE SUBNETS (project-3tier-sn-group) ] ------------------------------------------------------------------
  | Private Subnet: 10.20.7.0/24 (pvt-sn-7a)                | Private Subnet: 10.20.8.0/24 (pvt-sn-8b)                         |
  |                                                          |                                                                  |
  |   +---------------------------------------------------------------------------------------------------------------------+   |
  |   |                        AMAZON RDS MYSQL 8.0 (MULTI-AZ) DB INSTANCE (somesh-db-1)                                   |   |
  |   |                        DB Name: test  |  Private CNAME: book.rds.com (rds.com Private Zone)                        |   |
  |   +---------------------------------------------------------------------------------------------------------------------+   |
  --------------------------------------------------------------------------------------------------------------------------------
```

---

## 🎯 Architectural Requirements & Constraints

| Requirement Metric | Target Specification | Architectural Mechanism |
| :--- | :--- | :--- |
| **High Availability (HA)** | 99.99% Uptime across Availability Zone outages | Multi-AZ deployment (`us-east-1a`, `us-east-1b`) with redundant ALBs and ASGs. |
| **Security Isolation** | Zero direct internet accessibility to Database and Backend layers | Private subnets with strictly managed NAT Gateway egress and chained Security Groups. |
| **Horizontal Scalability** | Automated capacity expansion under CPU/Memory spikes | EC2 Auto Scaling Groups (`FE-ASG`, `BE-ASG`) utilizing Launch Templates backed by Golden AMIs. |
| **Domain Abstraction** | Zero hardcoded IP addresses or AWS-generated DNS in codebases | Public Route 53 zones for frontend/API; Private Route 53 hosted zones (`rds.com`) for internal DB routing. |
| **Data Integrity** | ACID-compliant storage with Multi-AZ failover capability | Amazon RDS MySQL instance (`somesh-db-1`) isolated in dedicated DB Subnet Group (`project-3tier-sn-group`). |

---

## 🔬 34-Step Procedural Lifecycle Specification

### Phase 1: Base VPC Network Infrastructure Provisioning

1. **VPC Creation**: Allocate Virtual Private Cloud `3tier-vpc` with IPv4 CIDR `10.20.0.0/16` in `us-east-1` (`vpc-00d8d6beb7dcedcc4`).
2. **DNS Enabling**: Enable DNS Hostnames and DNS Resolution options within `3tier-vpc`.
3. **Internet Gateway Provisioning**: Create Internet Gateway `3tier-igw` (`igw-0cefa1aeac9dc78bf`).
4. **IGW Attachment**: Attach `3tier-igw` explicitly to `3tier-vpc`.
5. **Subnet 1 Allocation (`pub-sn-1a`)**: Create Public Subnet `10.20.1.0/24` in `us-east-1a`.
6. **Subnet 2 Allocation (`pub-sn-2b`)**: Create Public Subnet `10.20.2.0/24` in `us-east-1b`.
7. **Subnet 3 Allocation (`pvt-sn-3a`)**: Create Private Application Subnet `10.20.3.0/24` in `us-east-1a`.
8. **Subnet 4 Allocation (`pvt-sn-4b`)**: Create Private Application Subnet `10.20.4.0/24` in `us-east-1b`.
9. **Subnet 5 Allocation (`pvt-sn-5a`)**: Create Private Database Subnet `10.20.5.0/24` in `us-east-1a`.
10. **Subnet 6 Allocation (`pvt-sn-6b`)**: Create Private Database Subnet `10.20.6.0/24` in `us-east-1b`.
11. **Subnet 7 Allocation (`pvt-sn-7a`)**: Create Private Auxiliary Subnet `10.20.7.0/24` in `us-east-1a`.
12. **Subnet 8 Allocation (`pvt-sn-8b`)**: Create Private Auxiliary Subnet `10.20.8.0/24` in `us-east-1b`.
13. **Public Route Table Allocation**: Create route table `3tier-pub-rt` (`rtb-03d97e0a2a90a1d5d`).
14. **Public Route Rule Insertion**: Add default route `0.0.0.0/0` targeting Internet Gateway `3tier-igw`.
15. **Public Subnet Associations**: Bind `pub-sn-1a` and `pub-sn-2b` to `3tier-pub-rt`.
16. **NAT Gateway Elastic IP Allocation**: Allocate Elastic IPs (`44.219.12.60`, `34.196.224.75`).
17. **NAT Gateway Provisioning**: Deploy Managed NAT Gateway `3tier-NAT` (`nat-1a6de1fc802c628cb`) inside `pub-sn-1a`.
18. **Private Route Table Allocation**: Create private route table `3tier-pvt-rt` (`rtb-06ac5e2ec32235e6b`).
19. **Private Egress Route Rule Insertion**: Add default route `0.0.0.0/0` targeting NAT Gateway `3tier-NAT`.
20. **Private Subnet Associations**: Bind `pvt-sn-3a` through `pvt-sn-8b` to `3tier-pvt-rt`.

---

### Phase 2: Layered Security & Traffic Ingress Management

21. **Layered Security Group Chaining (`3tier-SG` / `sg-0f303e0d9127a694d`)**:
    - `frontend-alb-sg`: Permits HTTP (80) & HTTPS (443) from `0.0.0.0/0`.
    - `frontend-ec2-sg`: Permits HTTP (80) strictly from `frontend-alb-sg`.
    - `backend-alb-sg`: Permits HTTP (80) & API traffic strictly from `frontend-ec2-sg`.
    - `backend-ec2-sg`: Permits Node API traffic (8080) strictly from `backend-alb-sg`.
    - `db-sg`: Permits MySQL traffic (port 3306) strictly from `backend-ec2-sg` and `backend-alb-sg`.
22. **Target Group Allocation (`frontend-TG` & `backend-TG`)**: Configure active HTTP health checks targeting path `/` with status code `200`.
23. **Application Load Balancers Provisioning**:
    - `frontend-ALB`: Internet-facing ALB in `pub-sn-1a` & `pub-sn-2b`.
    - `backend-ALB`: Internal ALB in `pvt-sn-3a` & `pvt-sn-4b`.
24. **ACM SSL Certificate Provisioning**: Issue wildcard TLS 1.3 certificate `*.rebel7781.xyz` (`arn:aws:acm:us-east-1:595028889753:certificate/efc8d6a9-e71a-4f73-8296-30f75be1651a`).
25. **Public Route 53 Zone Setup**: Provision public hosted zone `rebel7781.xyz`.
26. **Public Record Mapping**:
    - `virat.rebel7781.xyz` $\rightarrow$ A Record Alias to `frontend-ALB` (`dualstack.frontend-alb-568472738.us-east-1.elb.amazonaws.com`).
    - `api.rebel7781.xyz` $\rightarrow$ A Record Alias to `backend-ALB` (`dualstack.backend-alb-1878050688.us-east-1.elb.amazonaws.com`).

---

### Phase 3: Database, Staging Compute & Auto Scaling Infrastructure

27. **RDS DB Subnet Group Provisioning**: Create DB Subnet Group `project-3tier-sn-group` spanning private database subnets.
28. **Amazon RDS MySQL Provisioning**: Provision RDS MySQL 8.0 instance `somesh-db-1` (`db.t3.micro`, Master User `admin`, Password `"Somesh12345"`, DB `test`).
29. **Staging Build EC2 Fleet Provisioning**: Launch temporary build instances (`frontend-server` `i-0a60510b98916840f`, `backend-server` `i-04d547ca31ba9125a`).
30. **Staging Automation & Golden AMI Creation**: Execute staging UserData scripts to compile React frontend and Node backend runtimes, then create immutable Golden AMIs `frontend-AMI` (`ami-0e826fcb0c13a348`) and `backend-AMI` (`ami-0cf2ba10137800b5a`).
31. **EC2 Launch Templates Provisioning**: Configure versioned Launch Templates `frontend-LT` (`lt-043b4c9f97cde6ab`) and `backend-LT` (`lt-0ds8df3cee792a2b6`).
32. **Auto Scaling Groups Deployment**: Deploy `FE-ASG` and `BE-ASG` across `us-east-1a` and `us-east-1b` with health checks bound to respective ALBs.

---

### Phase 4: Private DNS Mapping & Dynamic System Validation

33. **Route 53 Private Hosted Zone Abstraction**: Create Private Hosted Zone `rds.com` attached to `3tier-vpc` with CNAME `book.rds.com` pointing to `somesh-db-1.c41ks4oo8yhh.us-east-1.rds.amazonaws.com`.
34. **End-to-End System Validation**: Access web storefront at `https://virat.rebel7781.xyz`, execute full CRUD operations, and verify real-time relational persistence in MySQL DB.

---

## 🛠️ AWS Services Inventory & Micro-Segmented Security

| AWS Service | Category | Purpose in Architecture | Real-World Production Specification |
| :--- | :--- | :--- | :--- |
| **Amazon VPC** | Networking | Virtual private cloud enclosure | Dedicated `3tier-vpc` (`10.20.0.0/16`) spanning `us-east-1a` and `us-east-1b`. |
| **Public Subnets** | Networking | Ingress for Load Balancers & NAT | `pub-sn-1a` (`10.20.1.0/24`) & `pub-sn-2b` (`10.20.2.0/24`). |
| **Private Subnets** | Networking | Private workload isolation | Presentation (`10.20.3.0/24`, `10.20.4.0/24`), Application (`10.20.5.0/24`, `10.20.6.0/24`), DB (`10.20.7.0/24`, `10.20.8.0/24`). |
| **Internet Gateway** | Networking | Public Internet Entrypoint | `3tier-igw` (`igw-0cefa1aeac9dc78bf`) attached to `3tier-vpc`. |
| **NAT Gateway** | Networking | Private subnet egress updates | `3tier-NAT` (`nat-1a6de1fc802c628cb`) in `pub-sn-1a` with Elastic IPs (`44.219.12.60`, `34.196.224.75`). |
| **Application Load Balancers** | Load Balancing | Layer-7 Ingress Management | **frontend-ALB** (`virat.rebel7781.xyz`) & **backend-ALB** (`api.rebel7781.xyz`). |
| **EC2 Golden AMIs** | Compute | Immutable Instance State | `frontend-AMI` (`ami-0e826fcb0c13a348`) & `backend-AMI` (`ami-0cf2ba10137800b5a`). |
| **Launch Templates** | Compute | Standardized Compute Spec | `frontend-LT` (`lt-043b4c9f97cde6ab`) & `backend-LT` (`lt-0ds8df3cee792a2b6`). |
| **Auto Scaling Groups** | Compute | Elastic Compute Capacity | `FE-ASG` and `BE-ASG` operating across multiple Availability Zones. |
| **Amazon RDS MySQL** | Relational DB | Multi-AZ Relational Data Tier | `somesh-db-1` (MySQL 8.0, DB: `test`) in `project-3tier-sn-group`. |
| **Route 53 Public Zone** | Edge / DNS | Public Domain Routing | `rebel7781.xyz` mapping `virat` and `api` endpoints. |
| **Route 53 Private Zone** | Edge / DNS | Internal DB Abstraction | `rds.com` zone mapping `book.rds.com` to dynamic RDS endpoint. |
| **AWS ACM** | Security | TLS 1.3 Certificate Manager | Wildcard certificate `*.rebel7781.xyz`. |
| **Security Groups** | Security | Stateful Micro-Segmentation | `3tier-SG` (`sg-0f303e0d9127a694d`) chaining tier-to-tier ingress. |

---

## 📜 UserData & Boot Automation Scripts

### 1. Staging Frontend UserData Script (`user_data_web.sh`)
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

# Clone repository & set API Base URL
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

### 2. Staging Backend UserData Script (`user_data_app.sh`)
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

### 3. Frontend Launch Template UserData Script (ASG Boot Automation)
```bash
#!/bin/bash
sudo apt update -y
sleep 90
sudo systemctl start apache2.service
```

### 4. Backend Launch Template UserData Script (ASG Boot Automation)
```bash
#!/bin/bash
sudo apt update -y
sudo pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo systemctl start pm2-root
sudo systemctl enable pm2-root
sudo apt install mysql-server -y
cd /home/ubuntu/aws_three_tier_code/backend
sudo pm2 start index.js --name "backendapi"
mysql -h book.rds.com -u admin -pSomesh12345 test < test.sql
```


---

## 🔧 DevOps & Operational Troubleshooting Runbook

| # | Issue | Observed Symptoms | Root Cause | Resolution Strategy |
| :---: | :--- | :--- | :--- | :--- |
| 1 | **RDS Connection Timeout** | Backend API logs `ETIMEDOUT` connection error | `db-sg` missing ingress rule for `backend-ec2-sg` on port `3306`. | Update `db-sg` to allow port `3306` strictly from `backend-ec2-sg`. |
| 2 | **502 Bad Gateway** | `virat.rebel7781.xyz` returns 502 Bad Gateway | Apache2 service stopped on frontend EC2 instance. | Execute `sudo systemctl restart apache2.service` via AWS SSM. |
| 3 | **Private DNS Resolution Failure** | Backend cannot resolve `book.rds.com` | Private Hosted Zone `rds.com` not attached to VPC `3tier-vpc`. | Associate `rds.com` Private Hosted Zone with VPC `3tier-vpc` (`vpc-00d8d6beb7dcedcc4`). |
| 4 | **NAT Egress Failure** | Private EC2 cannot perform `apt update` | Route table `3tier-pvt-rt` missing route `0.0.0.0/0` $\rightarrow$ `3tier-NAT`. | Add route `0.0.0.0/0` targeting `3tier-NAT` (`nat-1a6de1fc802c628cb`) in `3tier-pvt-rt`. |

---

## 📂 Repository Directory Structure

```
AWS_CLOUD/
├── assets/
│   └── aws_banner.png                 # Mindcircuit Book Store 3-Tier Architecture Diagram
├── app/
│   ├── api/
│   │   ├── package.json               # Mindcircuit Book Store Express API dependencies
│   │   └── server.js                  # Express API server connecting to book.rds.com
│   ├── web/
│   │   ├── nginx.conf                 # Nginx/Apache presentation proxy routing
│   │   └── index.html                 # Mindcircuit Book Store React UI presentation page
│   └── db/
│       └── schema.sql                 # MySQL schema & initial seed data for test database
├── infrastructure/
│   ├── scripts/
│   │   ├── user_data_web.sh           # Automated frontend staging build script
│   │   └── user_data_app.sh           # Automated backend staging build script
│   ├── vpc/
│   │   └── main.tf                    # 3tier-vpc (10.20.0.0/16) layout IaC
│   ├── alb/
│   │   └── alb.tf                     # frontend-ALB & backend-ALB Terraform module
│   ├── ec2/
│   │   └── auto_scaling.tf            # Launch Templates (frontend-LT/backend-LT) & ASGs
│   └── rds/
│       └── rds_multi_az.tf            # Amazon RDS MySQL somesh-db-1 & project-3tier-sn-group
├── monitoring/
│   └── cloudwatch_dashboard.json      # CloudWatch metrics dashboard for FE-ASG & BE-ASG
├── docs/
│   └── runbooks/
│       ├── incident_response.md       # Incident response runbook
│       └── disaster_recovery.md        # RDS failover & PITR runbook
└── README.md                          # Master Enterprise Monograph Documentation
```

---

## 🧠 Enterprise Skills Demonstrated

- ☁️ **AWS Cloud Networking**: VPC design (`10.20.0.0/16`), multi-AZ subnet partitioning, route table associations, IGW, and Managed NAT Gateway egress routing.
- 🔒 **Zero-Trust Security**: Stateful Security Group chaining, stateless NACLs, and private subnet isolation preventing public access to databases.
- ⚖️ **Traffic Engineering**: Dual Layer-7 Load Balancers (`frontend-ALB` & `backend-ALB`), ACM SSL certificate management, and Route 53 public/private DNS routing.
- 🔄 **Elasticity & Automation**: Immutable Golden AMIs (`frontend-AMI`, `backend-AMI`), Launch Templates, Auto Scaling Groups, and bash UserData bootstrap scripts.
- 🗄️ **Relational Database Administration**: Amazon RDS MySQL Multi-AZ provisioning, DB Subnet Groups, Private Hosted Zone CNAME abstraction (`book.rds.com`), and SQL schema restoration.
- 🐧 **Linux Systems & Process Management**: Systemd service management, PM2 process administration, Node.js API development, and Nginx/Apache reverse proxy configuration.

---

<div align="center">

### 👨‍💻 Maintained & Authored by Tarra Someswararao
*Designed and implemented following AWS Well-Architected Framework best practices.*

</div>
