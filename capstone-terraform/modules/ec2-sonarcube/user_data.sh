#!/bin/bash

dnf update -y

dnf install -y docker

systemctl enable docker
systemctl start docker

# Wait until Docker is ready
until docker info >/dev/null 2>&1; do
    sleep 2
done

usermod -aG docker ec2-user

docker pull sonarqube:lts-community

docker run -d \
  --name sonarqube \
  --restart unless-stopped \
  -p 9000:9000 \
  sonarqube:lts-community