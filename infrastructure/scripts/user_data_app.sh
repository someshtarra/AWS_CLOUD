#!/bin/bash
# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Backend UserData Script
# Component: Backend Application Tier (Node.js API + PM2 + MySQL Client)
# DB Endpoint: book.rds.com (Private Hosted Zone rds.com)
# Process Name: backendapi | Author: Tarra Someswararao
# ==============================================================================

set -euo pipefail
exec > >(tee /var/log/user-data-app.log|logger -t user-data-app -s 2>/dev/console) 2>&1

echo "[INFO] Executing Backend Application Tier UserData Script at $(date)..."

# 1. Update OS Package Index
sudo apt update -y

# 2. Install Node.js 18.x Runtime Environment
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt update -y

# 3. Enable Corepack & Install PM2 Process Manager
sudo npm install -g corepack
corepack enable
corepack prepare yarn@stable --activate
sudo npm install -g pm2

# 4. Clone Application Repository
cd /tmp
git clone https://github.com/jadalaramani/aws_three_tier_code.git
cd aws_three_tier_code/backend

# 5. Inject Database Connection Environment Variables (.env)
cat << 'EOF' > .env
DB_HOST=book.rds.com
DB_USERNAME=admin
DB_PASSWORD="Somesh12345"
PORT=3306
EOF

# 6. Install Node.js Dependencies & Database Drivers
npm install
npm install dotenv
npm install mysql2

# 7. Install MySQL Client for Database Management
sudo apt install mysql-server -y

# 8. Start Backend Service via PM2 Process Manager
pm2 start index.js --name "backendapi"
pm2 startup || true
sudo env PATH=$PATH:/usr/bin /usr/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu || true
pm2 save

# 9. Seed/Restore Initial Database Schema to Private RDS Instance
mysql -h book.rds.com -u admin -pSomesh12345 test < test.sql || echo "[WARN] Database seeding pending private endpoint binding"

echo "[SUCCESS] Backend Service (backendapi) Successfully Provisioned at $(date)!"
