# 🌤️ Cloud Resume Challenge – Frontend

This repository contains the **frontend** portion of my Cloud Resume Challenge project.  
It includes my HTML/CSS resume, the visitor counter JavaScript, and all Terraform needed to deploy the static site to Azure using a fully cloud-native approach.

---

## 🚀 Features

### **Frontend**
- Static HTML resume
- Custom CSS styling
- JavaScript visitor counter (connected to backend API)

### **Infrastructure (Terraform)**
- Azure Resource Group
- Azure DNS Zone for custom domain (`carlpadilla.com`)
- Azure Storage Account (static website hosting)
- Azure CDN Profile + Endpoint
- DNS records for root + www
- HTTPS via CDN-managed certificate
- Output of Azure nameservers for domain delegation

### **CI/CD (GitHub Actions)**
- Automatic deployment of static site artifacts to Azure Storage
- CDN cache purge to ensure fresh content
- Infrastructure deployment pipeline using Terraform

---

## 📁 Repository Structure

```

crc-frontend/
├── src/
│   ├── index.html
│   ├── styles.css
│   ├── script.js
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
│
└── .github/
└── workflows/
├── deploy-frontend.yml
└── terraform-frontend.yml

```

---

## 📦 Prerequisites

- Azure CLI  
- Terraform (>= 1.6)  
- GitHub CLI (optional)  
- An Azure subscription  
- A custom domain (`carlpadilla.com`) on Namecheap  
- `az login` authentication  

---

## 🔧 Deployment

### **1. Deploy infrastructure**
```

cd terraform
terraform init
terraform plan
terraform apply

```

### **2. Deploy frontend site**
Pushing to `main` triggers GitHub Actions to:
- Upload site artifacts to Azure Storage
- Purge CDN endpoint

---

## 🧭 Roadmap

- Add analytics (optional mod)
- Add Open Graph / social metadata
- Add Lighthouse performance optimizations
- Integrate advanced caching rules

---

## 📄 License
MIT License  


