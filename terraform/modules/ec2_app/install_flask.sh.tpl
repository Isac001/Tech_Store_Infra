#!/bin/bash
# Startup script to configure the TechStore application and connect it to RDS.

# 1. UPDATE AND INSTALLATION OF DEPENDENCIES
echo "Atualizando o sistema e instalando dependências..."
yum update -y
yum install -y git python3 python3-pip
# Installs the MariaDB/MySQL client for Amazon Linux 2023
dnf install -y mariadb105

# 2. CLONE THE APPLICATION REPOSITORY
echo "Clonando o repositório da aplicação..."
# Creates the directory, standardizing the name
mkdir -p /home/ec2-user/TechStore
cd /home/ec2-user/TechStore
# Clones the repository into the current directory
git clone https://github.com/HebertonGeovane/TechStore2.git .

# 3. INSTALLATION OF PYTHON DEPENDENCIES
echo "Instalando as dependências do Python..."
pip3 install -r requirements.txt
# Ensures that the main dependencies are installed with the correct PyPI name
pip3 install Flask-SQLAlchemy pymysql

# 4. CREATION OF TABLES IN THE DATABASE
# This is the crucial step that automates the creation of the database schema.
echo "Criando as tabelas no banco de dados RDS..."
# Executes a non-interactive Python command to call the db.create_all() function from the application
/usr/bin/python3 -c "from app import app, db; app.app_context().push(); db.create_all()"

# 5. CREATION OF THE APPLICATION SERVICE (SYSTEMD)
echo "Configurando o serviço da aplicação (systemd)..."
# Creates the Systemd configuration file.
# The DATABASE_URL environment variable is dynamically populated by Terraform.
echo "[Unit]
Description=Flask Application for TechStore
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/TechStore
ExecStart=/usr/bin/python3 app.py
Restart=always
Environment=\"DATABASE_URL=mysql+pymysql://${db_username}:${db_password}@${db_endpoint}/${db_name}\"

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/flaskapp.service

# 6. SERVICE INITIALIZATION
echo "Habilitando e iniciando o serviço da aplicação..."
# Reloads systemd to read the new service file
sudo systemctl daemon-reload
# Enables the service to start automatically on machine boot
sudo systemctl enable flaskapp.service
# Starts the service immediately
sudo systemctl start flaskapp.service