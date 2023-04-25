#!/bin/bash
sudo mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent
rm amazon-ssm-agent.deb

# prefect agent 
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get install python3.9 -y
sudo apt install python3-pip -y
sudo ln -s /usr/bin/python3 /usr/bin/python
PATH="$HOME/.local/bin:$PATH"
sudo apt install -y jq
sudo apt-get install unzip
export PATH
pip3 install prefect==2.7.7 prefect-gcp[cloud_storage]==0.2.4 supervisor s3fs


sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
result=$(aws secretsmanager get-secret-value --secret-id prefect-api-key --region us-east-2)
secret=$(echo $result | jq -r '.SecretString')
PREFECT_API_KEY=$(echo $secret | jq -r '.key')

prefect cloud login -k $PREFECT_API_KEY -w "bajajnakulgmailcom/data-engineering"
prefect work-queue create -t ubuntu ubuntu
prefect agent start ubuntu