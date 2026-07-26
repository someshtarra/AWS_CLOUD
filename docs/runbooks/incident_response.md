# 🚨 Incident Response & Troubleshooting Runbook
## Mindcircuit Book Store - AWS 3-Tier Architecture
**Author**: Tarra Someswararao | **VPC**: 3tier-vpc (`10.20.0.0/16`)

---

### 🔴 Severity 1: Application Unavailable (HTTP 502 / 503)

#### Step 1: ALB Target Group Verification
Inspect health status for `frontend-TG` and `backend-TG`:
```bash
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:us-east-1:595028889753:targetgroup/frontend-TG \
  --output table

aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:us-east-1:595028889753:targetgroup/backend-TG \
  --output table
```
If targets report `Unhealthy`:
1. Connect to private compute nodes via AWS SSM Session Manager.
2. Check Apache2 status: `sudo systemctl status apache2.service`.
3. Check PM2 Node.js backend status: `pm2 status` and `pm2 logs backendapi`.

#### Step 2: Auto Scaling Fleet Inspection
Verify desired capacity and instance health across `FE-ASG` and `BE-ASG`:
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names FE-ASG BE-ASG
```

#### Step 3: Database Connectivity Auditing
Verify connection to Amazon RDS MySQL (`somesh-db-1`) using internal private DNS CNAME (`book.rds.com`):
```bash
nc -zv book.rds.com 3306
mysql -h book.rds.com -u admin -pSomesh12345 test -e "SELECT COUNT(*) FROM books;"
```
If connection fails, check `db-sg` security group rules to ensure port `3306` is open from `backend-ec2-sg`.
