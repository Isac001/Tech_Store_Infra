# Ambiente AWS Automatizado com TerraForm

Este repositório é uma demonstração prática de como provisionar uma infraestrutura web completa na AWS, aplicando os princípios de Infraestrutura como Código (IaC). Como caso de uso, criamos a arquitetura para a "TechStore", uma aplicação fictícia de e-commerce. Todo o ambiente é gerenciado via Terraform para garantir automação, consistência e governança dos recursos.

## Passo 1 | Pré-requisitos

**Instalar o Terraform em sua máquina**

**Possuir conta AWS, seja conta própria ou conta IAM com permissões para o uso desses serviços:**

- EC2
- RDS
- Lambda
- SNS
- VPC

**Possuir o Python instalado em sua máquina, versão 3.9 ou supeior**

**Instalar em sua máquina o AWS CLI**

**Utilize de preferência a região us-west-2, pois é nela onde o projeto será compilado em caso que você não altere ela nos arquivos**

## Passo 2 | Instalar o terraform em seu computador.

* **Download:** [https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)

Após o download, siga as instruções para instalar o Terraform e garantir que o executável esteja no seu PATH.


## Passo 3 | Configurar as credenciais da AWS

O Terraform precisa de credenciais para se conectar à sua conta da AWS. A forma mais simples de fazer isso é usando o AWS CLI.

1. Instale o **AWS CLI** em seu terminal no Link: [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)

2. Após instalar o **AWS CLI** execute o comando 'aws configure' e insira suas chaves de acesso (Access Key ID e Secret Access Key), a região padrão e o tipo de saída (escolha o tipo Json). Exemplo:

```bash
$ aws configure
AWS Access Key ID [None]: SUA_ACCESS_KEY_ID
AWS Secret Access Key [None]: SUA_SECRET_ACCESS_KEY
Default region name [None]: us-west-2
Default output format [None]: json
```

3. Oberservação: caso sua conta sejam uma IAM, será necessário que você modifique o arquivo em:

```bash
nano ~/.aws/credentials
```

Com as suas chaves e o token o aquivo deve ser modificado usando a ferramenta de editor de texto e deve seguir esse formato:

```bash
[default]
aws_access_key_id= *access key*
aws_secret_access_key *scret key*
aws_session_token= *token* 
```

## Passo 4 | Arquivos a Serem Modificados

No projeto há aquivos que necessitam ser customizados para cada interessado em utilziar esse repositório, são eles:

* Criar o **terraform.tfvars** na pasta **terraform/environments/dev**, com o seguinte conteúdo:

```bash
notification_email = "<endereço de email para receber as mensagens do SNS>"
```

Será necessário para você receber emails do SNS.

* Na pasta **terraform/environments/dev** no arquivo **main.tf** busque por essa váriavel:

```bash
key_name = "vockey"
```

Subistutua ela por uma chave de acesso real de seu ambiente.


## Passo 5 | Comandos Terraform

Após configurar seu AWS CLI, entre na pasta 'main_terraform' e rode os seguintes comandos para criar sua infraestrutura.

1. Terraform Init | Comando para iniciar seu ambiente terraform.

```bash
terraform init 
```

2. Terraform Plan | Comando para planejar sua infraestrutura em nuvem, ele fará algumas validações e retornará erros caso existam no seu código terraform.

```bash
terraform plan 
``` 

3. Terraform Apply | Comando que dá executa a criação do seu ambiente na nuvem.

```bash
terraform apply
```

4. Terraform Destory | Comando para remover a infraestrutura após a conclusão do laboratorio.

```bash
terraform destroy
```

# FIM