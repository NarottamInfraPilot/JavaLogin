#!/bin/bash

set -e

TOMCAT_VERSION=9.0.113

echo "=== Installing Java 11 ==="
sudo apt update -y
sudo apt install -y openjdk-11-jdk

echo "=== Creating Tomcat Directory ==="
sudo mkdir -p /opt/tomcat

echo "=== Downloading Apache Tomcat ==="
cd /tmp
sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.113/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

echo "=== Extracting Tomcat ==="
sudo tar xzvf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat --strip-components=1

echo "=== Setting Permissions ==="
sudo chown -R azureuser:azureuser /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

echo "=== Creating systemd Service ==="
sudo bash -c 'cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=azureuser
Group=azureuser

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

echo "=== Reloading & Starting Tomcat ==="
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl restart tomcat

echo "=== Checking Tomcat Status ==="
sudo systemctl status tomcat --no-pager
