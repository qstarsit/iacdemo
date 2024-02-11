#! /bin/bash
sudo yum install -y docker
sudo systemctl enable docker --now
sudo docker run -d --name godutch -p 80:8080 -e LOVE=mills pa3hcm/godutch:0.1
