# ERMS-SRL
Employee record management system (ERMS) built with Python-Flask and MySQL is a web-based application designed to efficiently manage and track employee data within an organization.
---
## 1. Database Setup :
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
---
## Task 2. Dockerize App Setup:
### Step 1: Clone/Fork the repository to make use of it.

```bash
git clone https://github.com/xrootms/ERMS-SRL.git

cd ERMS-SRL
cat EmpApp.py
```

### Step 2: Create a requirements.txt file in the project directory.
    nano requirements.txt

```bash
flask
pymysql
boto3
gunicorn
cryptograph
```
Dockerfile explanation.
cat Dockerfile

1.	Python Slim                                                        # Its base image. Which is a minimal image.
2.	ENV PYTHONDONTWRITEBYTECODE=1                                      # Smaller container size and Cleaner fs
3.	ENV PYTHONUNBUFFERED=1                                             # Forces stdout/stderr streams to be unbuffered, Real- time logs
4.	/app                                                               # Set the /app directory as the working directory.
5.	&&                                                                 # Combining RUNs commands (which means smaller image.)
6.	--no-install-recommends                                            # keeps the image smaller by avoiding extra suggested packages
7.	rm -rf /var/lib/apt/lists/*                                        # To keep image size small: clean the apt cache in the same layer
8.	python -m pip                                                      # use the correct pip for this Python (avoid mismatch)
9.	--no-cache-dir                                                     # Pip will NOT save downloaded files in the cache, images smaller 
10.	-r                                                                 # Tells pip to install dependencies from a file
11.	CMD                                                                # Default command that runs when the container starts.
12.	"--access-logfile", "-"                                            # Send access logs to stdout
13.	"--error-logfile", "-"                                             # Send error logs to stderr
14.	"EmpApp:app"                                                       # Import app object from EmpApp.py
15.	 USER appuser                                                      # Run application as a non-root user called appuser.”


**Build Docker Image**

```bash
docker build -t <image-name> .
```
**Run the Docker Image**
```bash
docker run -d -p 5000:5000  -- name <container-name>  <image-name> .
```
Now, check your application on the browser using <ip:5000>

---
## Optimizing Docker Images
Optimizing Docker images is very important. We can use **SlimToolkit** to reduce the size of your  Docker image.
  *Install SlimToolkit :*
  
```bash
  curl -sL https://raw.githubusercontent.com/slimtoolkit/slim/master/scripts/install-slim.sh | sudo bash
```

Reload your shell & Verify:

```bash
exec bash
slim –version
```

Create a File preserved-paths.txt  with the file name or file path you don’t want to get removed during the slim process.

#nano preserved-paths.txt 

```bash
 /app
/usr/local/bin/python3
/usr/local/bin/flask
```

Run your command

```bash
slim build \
  --http-probe=false \
  --preserve-path-file preserved-paths.txt \
  --tag slimmed-emp-srl04-flask-app \ 
emp-srl04-flask-app
```

This command will slim the Docker images without affecting the file or file path mentioned in the txt file with a new name you specify in the --tag flag.

**Now if you you check the docker image size, it will be considerably reduced as shown below.**

image

You can see the size of the Docker image has been reduced from 106MB to 19.8MB and it works properly without any issue.

---
## 2.2. Without Docker App Setup:
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

if [ -d "ERMS-SRL" ]; then cd ERMS-SRL
  git pull
else
  git clone https://github.com/xrootms/ERMS-SRL.git
  cd ERMS-SRL
fi

#edit port 5000, 
#edit config.py (add s3 and rds url)
```

### Option:a (testing)

```bash
cd /home/ubuntu/ERMS-SRL
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
WorkingDirectory=/home/ubuntu/ERMS-SRL
ExecStart=/usr/bin/python3 /home/ubuntu/ERMS-SRL/EmpApp.py
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





