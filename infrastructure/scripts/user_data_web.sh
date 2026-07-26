#!/bin/bash
# ==============================================================================
# Enterprise AWS Three-Tier Architecture - Frontend UserData Script
# Component: Frontend Presentation Tier (React + Apache2 Web Server)
# Target Application: Mindcircuit Book Store (https://virat.rebel7781.xyz)
# OS: Ubuntu Linux | Author: Tarra Someswararao
# ==============================================================================

set -euo pipefail
exec > >(tee /var/log/user-data-web.log|logger -t user-data-web -s 2>/dev/console) 2>&1

echo "[INFO] Executing Frontend Automated UserData Script at $(date)..."

# 1. Update OS package repository index
sudo apt update -y

# 2. Install Apache2 Web Server
sudo apt install apache2 -y

# 3. Install Node.js 18.x Runtime Environment
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt update -y

# 4. Enable Package Managers & PM2
sudo npm install -g corepack
corepack enable
corepack prepare yarn@stable --activate
sudo npm install -g pm2

# 5. Clone Application Codebase
cd /tmp
git clone https://github.com/jadalaramani/aws_three_tier_code.git
cd aws_three_tier_code/client

# 6. Configure API Base URL pointing to Backend ALB domain (api.rebel7781.xyz)
cat << 'EOF' > src/pages/config.js
export const API_BASE_URL = "https://api.rebel7781.xyz";
EOF

# 7. Install Dependencies & Build Frontend Application Assets
npm install
npm run build

# 8. Deploy Built Static Assets to Apache Web Root
sudo rm -rf /var/www/html/*
sudo cp -r build/* /var/www/html/

# 9. Enable & Restart Apache Web Service
sudo systemctl enable apache2
sudo systemctl restart apache2

echo "[SUCCESS] Frontend Presentation Tier (Mindcircuit Book Store) Successfully Deployed at $(date)!"
