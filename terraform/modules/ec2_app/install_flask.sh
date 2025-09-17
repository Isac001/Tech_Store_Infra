#!/bin/bash

# Atualiza e instala dependências
yum update -y
yum install -y git python3 python3-pip
sudo dnf install mariadb105 -y

# Cria o diretório onde o repositório será clonado
mkdir -p /home/ec2-user/TechStore2
cd /home/ec2-user/TechStore2

# Clona o repositório do GitHub
git clone https://github.com/HebertonGeovane/TechStore2.git .

# Instala as dependências do Python
pip3 install -r requirements.txt
pip3 install flask_sqlalchemy pymysql

# Exporta a variável de ambiente com o endpoint do RDS
export DATABASE_URL="mysql+pymysql://admin:SuaSenha@SeuEndpointRDS/techstore" # Aqui você deve substituir 'SuaSenha', 'SeuEndpointRDS' e 'techstore' com as informações corretas do seu banco de dados.

# Cria o arquivo de configuração do Systemd
echo "[Unit]
Description=Flask Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/TechStore2
ExecStart=/usr/bin/python3 /home/ec2-user/TechStore2/app.py
Restart=always
Environment=\"DATABASE_URL=mysql+pymysql://admin:SuaSenha@SeuEndpointRDS/techstore\" # Aqui você deve substituir 'SuaSenha', 'SeuEndpointRDS' e 'techstore' com as informações corretas do seu banco de dados.

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/flaskapp.service

# Habilita o serviço para iniciar automaticamente
sudo systemctl enable flaskapp

# Inicia o serviço
sudo systemctl start flaskapp
