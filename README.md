# Infraestrutura EKS + Kubernetes com Terraform

Este repositório provê a infraestrutura necessária para:

1. Criar um cluster Kubernetes usando **Amazon EKS** via Terraform
2. Aplicar recursos Kubernetes (manifests YAML)

---

## 📁 Estrutura do Projeto

```bash
.
├── .github/
│   └── workflows/
│       ├── infra-deploy.yml       # Pipeline CI/CD para criação/atualização do EKS (disparado ao alterar `eks-cluster/`)
│       ├── k8s-deploy.yml         # Pipeline CI/CD para aplicar manifests Kubernetes (disparado ao alterar `k8s/`)
│       └── grant-access.yml       # Pipeline CI/CD para conceder acesso RBAC no cluster
├── eks-cluster/                   # Terraform para criação do cluster EKS
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── k8s/                          # Manifests Kubernetes (YAML)
│   ├── app/                      # Deployments/Services da aplicação principal
│   ├── base/                     # Namespace, ConfigMaps, etc.
│   ├── redis/                    # Redis e serviços relacionados
│   └── webhook/                  # Recurso de Webhook
├── .gitignore
```

---

## ✅ Funcionalidades

* Criação de um cluster EKS na AWS via Terraform
* Geração automática do kubeconfig para conexão com o cluster
* Aplicação dos manifests Kubernetes diretamente via kubectl no pipeline CI/CD
* Pipeline de RBAC para conceder acesso a usuários no cluster
* Automatização e controle de deploys via GitHub Actions com disparos condicionais por pastas alteradas

---

## 🚀 Pipelines CI/CD GitHub Actions

### infra-deploy.yml

* Executa somente quando arquivos na pasta `eks-cluster/` são alterados
* Cria ou atualiza o cluster EKS via Terraform

### k8s-deploy.yml

* Executa somente quando arquivos na pasta `k8s/` são alterados
* Aplica os manifests Kubernetes diretamente no cluster via `kubectl`

### grant-access.yml

* Executa manualmente via workflow\_dispatch
* Concede acesso RBAC para usuários adicionados no ConfigMap `aws-auth`

---

## 🛠️ Como executar localmente

### Pré-requisitos

* Terraform ≥ 1.6.6
* AWS CLI configurado com credenciais válidas
* Permissões para criar recursos EKS e aplicar manifests Kubernetes

### Criar/atualizar o cluster EKS

```bash
cd eks-cluster
terraform init
terraform apply -auto-approve
```

### Gerar o kubeconfig localmente

```bash
aws eks update-kubeconfig --region <sua-região> --name <nome-do-cluster>
```

### Aplicar manifests Kubernetes manualmente (alternativa ao pipeline)

```bash
kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/app/
kubectl apply -f k8s/redis/
kubectl apply -f k8s/webhook/
```

---

## 🔐 Secrets esperados no GitHub Actions

* `AWS_REGION`: Região AWS (ex: `us-east-1`)
* `AWS_ROLE_TO_ASSUME`: Role ARN que o GitHub assume via OIDC para autenticação
* `DB_PASS`: Senha do banco de dados (usada nos secrets Kubernetes)
* `ACCESS_TOKEN_SECRET`: Secret para tokens de acesso
* `REFRESH_TOKEN_SECRET`: Secret para tokens de refresh

---

## 📦 Providers Utilizados no Terraform

* `hashicorp/aws`
* `hashicorp/kubernetes`
* `gavinbunney/kubectl` (usado no pipeline antigo, mas não mais na aplicação dos manifests)

---

## 📄 Licença

Este projeto é parte de um desafio técnico e possui fins educacionais.