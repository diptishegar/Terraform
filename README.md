# 🧩 Terraform Resource Import & Cleanup (AWS)

This project demonstrates **migrating existing AWS resources into Terraform** using `import.tf`, enabling **centralized management, tracking, and controlled teardown** — instead of manual console operations.

---

## 🔧 Resources Managed
- 🖥️ EC2
- 📦 ECR
- 🌐 VPC
- 🔐 IAM roles & policies
- 🔑 GitHub OIDC provider

All resources were **imported into Terraform state** and later **cleanly destroyed using `terraform destroy`**, proving safe and auditable infrastructure lifecycle management.

---

## 🎯 What This Demonstrates
- Centralized IaC control over existing resources
- Zero manual clicks for cleanup
- Full resource visibility & dependency tracking
- Safe teardown without configuration drift
- Foundation for refactoring into modules

---

## 💡 Key Benefits Shown
- Infrastructure as Code adoption without recreation
- Improved governance & auditability
- Faster, error-free resource cleanup
- Easier scaling and future automation

---

📌 A small project showcasing a **real-world Terraform migration pattern** used in production environments.
