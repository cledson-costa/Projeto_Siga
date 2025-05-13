# Projeto Siga

Este repositório contém todas as instruções de como foram efetuados os procedimentos solicitados da ativade requisitada.

## Sumário

- [Pré-requisitos](#pré-requisitos)
- [Construção da Máquina Operacional](#contrução-máquina-operacional)
- [Criação da máquina para Servidor](#criação-maquina-para-servidor)
- [Execução Docker do Serviço](#execução-docker-do-serviço)

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
    Feita a instalação é necessário adicionar a chave de acesso que nos garantirá o uso dentro do AWS a integração com o sistema AWS e uso do Terraform. Para isso, dentro da AWS acessemos a parte IAM (Identity and Access Manager) e na opção Usuários cliquemos no     usuário de acesso atual e dentro da aba "Credenciais de Segurança" vamos executar a integração da AWS com a máquina informada criando uma nova chave de acesso.
   
   É importante manter as duas informações guardadas após a criação da chave de acesso: *Chave AWS* e *chave secreta*.
   Com a criação da credencial, resta na máquina principal executar:
   ```
   aws configure
   ```
   Após a adição é feita então a solicitação das duas chaves da credencial, a pública e a secreta. As demais opções podem ser deixadas em branco.
   


5. Também devemos instalar o Terraform na máquina informada:
    ```bash
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
    ```
6. E por fim, precisamos instalar o Ansible para as configurações internas na máquina:
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

## Execução Docker do Serviço

### Montagem do ambiente

1. É Criado o arquivo *Dockerfile* com a versão tomcat 9 para uso do container que já existe na biblioteca Docker.
2. É criado uma imagem usando o comando *docker build -t tomcat:1.0 .* onde é marcado a versão e execução na pasta do comando
3. É executada a imagem com *docker run -d -p 8080:8080 --name tomcat tomcat:1.0*
4. Fica disponibilizada a imagem com Jenkins disponível para uso.

---

## Instalação e controle via Kubernetes

### Montagem do Serviço

1. Primeiramente é necessário adicionar o serviço Kubernetes dentro da máquina operacional. Para utilização de um cluster integrado ao sistema operacional, também usaremos o Minikube para aplicação usando como driver o Docker instalado anteriormente.
2. Para instalação e uso da ferramenta Kubernetes iremos usar o kubectl que pode ser instalado pelos seguintes comandos:
 ```
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
3. Em seguida precisaremos instalar o Minikube com configuração do driver para uso do docker na máquina em questão:
 ```
 curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
 sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
 ```
 Com o docker já instalado de versões anteriores vamos utilizar o próprio driver do Docker para uso do minikube no serviço
 Antes de executar o serviço é importante fazer que o usuário atual que vá rodar o minikube tenha adesão ao grupo docker durante a implementação do minikube, é possível usar o comando:

 ```
sudo usermod -aG docker $USER && newgrp docker
```
E então iniciar o serviço minikube digitando:
 ```
 minikube start --driver=docker
 ```
O processo de criação do container do Minikube irá iniciar e então será possível ter o Kubernetes em funcionamento.


## Execução do serviço Kubernetes

...

Para verificar o IP interno usado no Minikube é possível usar o comando
```
kubectl get nodes -o wide
```
