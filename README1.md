# Projeto Siga

Este repositório contém todas as instruções de como foram efetuados os procedimentos solicitados da ativade requisitada.

## Sumário

- [Pré-requisitos](#pré-requisitos)
- [Construção da Máquina Operacional](#contrução-máquina-operacional)
- [Criação da máquina para servidor](#criação-maquina-para-servidor)
- [Versão Docker do Serviço](#versão-docker-do-serviço)
- [](#)
- [](#)
- [](#)
- [](#)

## Pré-requisitos

1. Conta AWS
2. Máquina EC2 para operação de serviço

---

## Construção da Máquina Operacional

Para executar a criação do servidor será necessário criar uma máquina EC2 para controle dos serviços internos do sistema. Assim como sistema Terraform e Ansible para criação e configuração das máquinas.

### Passos:

1. Criar uma infraestrutura básica na AWS com as seguintes propriedades
    - OS: ubuntu 22.04
    - região: us-east-1 (mas pode ser qualquer outra)
    - Tipo de Instância: t2.micro
    - Armazenamento: 8 Gb
    - Criar par de chaves para uso
    - Grupo de Segurança: Liberação das portas ssh (22) e TCP (80 e 8080)
    - Criar e vincular IP elástico para facilitar conexões futuras
    
2. Primeiramente é necessário adicionar uma pasta para execução do projeto, a mesma pode se ter o próprio nome do repositório

3. Adicionar no sistema a AWS CLI para execução dos comandos Ansible e Terraform: (Para poder descompactar adicionaremos também a instalação do programa unzip)
    ```bash
    apt-get install unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    ```

4. Também devemos instalar o Terraform na máquina informada:
    ```bash
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
    ```
5. E por fim, precisamos instalar o Ansible para as configurações internas na máquina:
    ```bash
    sudo apt install software-properties-common
   sudo add-apt-repository --yes --update ppa:ansible/ansible
   sudo apt-get install ansible
    ```
---

## Criação da máquina para servidor
1. Usando o arquivo main.tf do Terraform iniciando o procedimento com os comandos:
```
terraform init
terraform plan
```
Os comandos darão inicio na execução do terraform e na criação das variáveis dentro da pasta para manutenção do terraform, além de mostrar o planejamento para execução do terraform. Verificada todas as mudanças cabe então o último comando para criação:

```
terraform apply --auto-approve
```

2. Efetuada a criação da máquina onde também através do comando [remote-exec] foi efetuada a atualização do sistema operacional e atualizado o arquivo do Ansible com o IP criado através do [local-exec]

3. Agora cabe a utilização do Ansible para execução da atividade, mas antes é necessário alterar no caminho */etc/ansible/ansible.cfg* uma configuração que pode não reconhecer o sistema durante a execução SSH na máquina informada.

   ```
   [defaults]
   host_key_checking = False
   ```
   
4. Então é só executar o comando que utilizará o playbook no sistema com o IP já recém-modificado:
   ```
   ansible-playbook -i hosts.ini playbook.yml
   ```
5. Efetuada a instalação do playbook serão executados os seguintes procedimentos:

  - Instalação do Java como dependência do Tomcat
  - Criação do diretório Tomcat
  - Download Extração e adaptação dos scripts do Apache Tomcat
  - Criação de diretório no systemd para configuração de variáveis de ambiente
  - Teste de conexão e desligamento do servidor
  - Configuração da variável do jenkins no stenv.sh
  - Download do jenkins.war e jolokia.war
  - Novo start no servidor

Efetuado os procedimentos já estarão disponíveis Tomcat, aplicação Jenkins e Jolokia para leitura de métricas.
   
---

## Versão Docker do Serviço



---



---

## 

---

## 

---

## 

---

## 
