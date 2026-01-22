## Step 1. Database Setup :
$ nano setup_db.sh

```bash
#!/bin/bash

sudo apt update
sudo apt install mysql-server mysql-client -y
sudo systemctl start mysql

sudo mysql -u root <<EOF
CREATE USER IF NOT EXISTS 'apk'@'%' IDENTIFIED BY '@1111';
GRANT ALL PRIVILEGES ON *.* TO 'apk'@'%';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS employee;
USE employee;

CREATE TABLE IF NOT EXISTS employee (
    empid VARCHAR(20),
    fname VARCHAR(20),
    lname VARCHAR(20),
    pri_skill VARCHAR(20),
    location VARCHAR(20)
);
EOF
```
### Varify

```bash
sudo mysql -u root
show databases;
use employee;
show tables;
DESCRIBE employee;
SELECT * FROM employee LIMIT 10;
```

## Step 2. Without Docker App Setup:
$ nano setup_app.sh

```bash
#!/bin/bash
set -e

cd /home/ubuntu

sudo apt-get update -y
sudo apt-get install -y \
 mysql-client \
  python3 \
  python3-pip \
  python3-flask \
  python3-pymysql \
  python3-boto3 \
  git

if [ -d "Dockerize-Flask-App-With-Logging" ]; then cd Dockerize-Flask-App-With-Logging
  git pull
else
  git clone https://github.com/xrootms/Dockerize-Flask-App-With-Logging.git
  cd Dockerize-Flask-App-With-Logging
fi

#edit port 5000, 
#edit config.py (add s3 and rds url)
```

### Option:a (testing)

```bash
cd /home/ubuntu/Dockerize-Flask-App-With-Logging
sudo python3 EmpApp.py
```

### Option:b (with logs)
$ nano setup_empapp_service.sh

```bash
#!/bin/bash

SERVICE_FILE="/etc/systemd/system/empapp.service"

echo "Creating systemd service..."

sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Employee Flask Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/Dockerize-Flask-App-With-Logging
ExecStart=/usr/bin/python3 /home/ubuntu/Dockerize-Flask-App-With-Logging/EmpApp.py
Restart=always
RestartSec=10
StandardOutput=append:/var/log/empapp.log
StandardError=append:/var/log/empapp.log

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sleep 5
sudo systemctl enable empapp
sudo systemctl start empapp

sudo systemctl status empapp --no-pager
```

### Varify

```bash
sudo netstat -tlnp | grep :5000
ps aux | grep EmpApp.py

sudo tail -f /var/log/empapp.log   $#View in Real-Time
sudo tail -n 50 /var/log/empapp.log
sudo grep -i error /var/log/empapp.log
sudo grep "500" /var/log/empapp.log
```

**Stop**

```bash
sudo systemctl stop empapp
sudo systemctl disable empapp

sudo rm /etc/systemd/system/empapp.service
sudo systemctl daemon-reload
```







