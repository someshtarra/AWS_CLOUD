# 🚑 Disaster Recovery & Failover Runbook
## Amazon RDS Multi-AZ & Private Zone Failover (somesh-db-1)
**Author**: Tarra Someswararao | **DB Subnet Group**: project-3tier-sn-group

---

### 1. Initiating Manual RDS Multi-AZ Failover
In the event of Availability Zone degradation in primary AZ (`us-east-1a`):

```bash
aws rds reboot-db-instance \
  --db-instance-identifier somesh-db-1 \
  --force-failover
```

#### Verification Steps:
1. Monitor DNS resolution shift for internal endpoint: `dig +short book.rds.com`.
2. Confirm standby instance status in secondary AZ (`us-east-1b`):
   ```bash
   aws rds describe-db-instances \
     --db-instance-identifier somesh-db-1 \
     --query "DBInstance.[DBInstanceIdentifier,DBInstanceStatus,AvailabilityZone,SecondaryAvailabilityZone]"
   ```

### 2. Point-in-Time Restoration (PITR)
To restore `somesh-db-1` database state prior to a corrupt transaction:

```bash
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier somesh-db-1 \
  --target-db-instance-identifier somesh-db-1-restored \
  --restore-time 2026-07-26T14:30:00.000Z \
  --db-subnet-group-name project-3tier-sn-group
```
