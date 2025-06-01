# Infraestrutura EKS + Kubernetes com Terraform

Este repositório provê a infraestrutura necessária para:

1. Criar um cluster Kubernetes usando **Amazon EKS**
2. Aplicar automaticamente os recursos do Kubernetes (manifests YAML) usando Terraform e o provider `kubectl`

---

## 📁 Estrutura do Projeto

```bash
.
├── .github/
│   └── workflows/
│       └── main.yml            # Pipeline CI/CD GitHub Actions
├── eks-cluster/                # Terraform para criação do EKS
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── k8s/                        # Manifests Kubernetes (YAML)
│   ├── app/                    # Deployments/Services da aplicação principal
│   ├── base/                   # Namespace, ConfigMaps, etc.
│   ├── redis/                  # Redis e serviços relacionados
│   └── webhook/                # Recurso de Webhook
├── main.tf                     # Aplica os YAMLs da pasta k8s via Terraform
├── outputs.tf
├── providers.tf
├── variables.tf
├── .gitignore
````

---

## ✅ Funcionalidades

* Criação de um cluster EKS na AWS via Terraform
* Geração automática do `kubeconfig`
* Aplicação de todos os manifests Kubernetes via Terraform + Provider `kubectl`
* Automatização completa via GitHub Actions

---

## 🚀 CI/CD com GitHub Actions

O workflow (`.github/workflows/main.yml`) é disparado a cada `push` na branch `main` e executa:

1. **Criação do cluster EKS** com os arquivos em `eks-cluster/`
2. **Geração do kubeconfig** via AWS CLI
3. **Aplicação dos manifests YAML** da pasta `k8s/` com o provider `gavinbunney/kubectl`

---

## 🛠️ Como executar localmente

### Pré-requisitos

* Terraform ≥ 1.6.6
* AWS CLI configurado
* Permissões para criar recursos EKS e aplicar manifests

### Etapas

1. Criar o cluster EKS:

   ```bash
   cd eks-cluster
   terraform init
   terraform apply -auto-approve
   ```

2. Gerar o kubeconfig:

   ```bash
   aws eks update-kubeconfig --region <sua-região> --name <nome-do-cluster>
   ```

3. Aplicar os manifests Kubernetes:

   ```bash
   cd ..
   terraform init
   terraform apply -auto-approve
   ```

---

## 🔐 Secrets esperados no GitHub

* `AWS_REGION`: Região AWS (ex: `us-east-1`)
* `AWS_ROLE_TO_ASSUME`: Role que o GitHub assume via OIDC

---

## 📦 Providers Utilizados

* `hashicorp/aws`
* `hashicorp/kubernetes`
* `gavinbunney/kubectl`

---

## 📄 Licença

Este projeto é parte de um desafio técnico e possui fins educacionais.
