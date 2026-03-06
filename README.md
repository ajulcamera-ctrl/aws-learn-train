# aws-learn-train

# 30 Day AWS + Terraform Roadmap (Locked Scope)

This roadmap defines the official learning path.
No topic changes unless explicitly approved.

---

## App Overview
- **Backend**: FastAPI (Python) with full CRUD for workouts/hikes, DynamoDB storage.
- **Frontend**: React app for managing data.
- **Infra**: Complete AWS setup with all Phase 3-4 features (CloudWatch, autoscaling, CI/CD, etc.).

## Getting Started
### Local Development
- Backend: `cd app/backend`, `pip install -r requirements.txt`, `uvicorn main:app --reload`
- Frontend: `cd app/frontend`, `npm install`, `npm start`

### Deployment
1. Build app (Docker + ECR push).
2. `cd infrastructure`
3. `./deploy.sh` (terraform apply full infra).
4. `./test.sh` (curl APIs).
5. `./verify.sh` (check all infra).
6. `./destroy.sh` (terraform destroy).

Days 14-30: Deploy full system, focus on learning one feature per day (e.g., Day 14: CloudWatch monitoring).

---

## Completed Phases (Reference)
### Phase 1 – Foundations
Day 1  – AWS basics  
Day 2  – Terraform basics  
Day 3  – VPC networking  
Day 4  – EC2 + security groups  
Day 5  – Docker  
Day 6  – ECR  
Day 7  – ECS Fargate  

### Phase 2 – Application Deployment
Day 8  – Application Load Balancer  
Day 9  – DynamoDB integration  
Day 10 – Frontend (S3 static site)  
Day 11 – Custom domain + HTTPS (ACM)  
Day 12 – Private subnets + NAT Gateway  
Day 13 – IAM least privilege  

### Phase 3 – Production Architecture
Day 14 – Logging + CloudWatch  
Day 15 – ECS autoscaling  
Day 16 – Multi-environment (dev/staging/prod)  
Day 17 – Remote state (S3 + DynamoDB locking)  
Day 18 – CI/CD (GitHub Actions)  
Day 19 – Blue/Green deployment  
Day 20 – Secrets Manager  
Day 21 – WAF  

### Phase 4 – Advanced Topics
Day 22 – Route53 DNS  
Day 23 – CloudFront CDN  
Day 24 – Multi-region architecture  
Day 25 – Cost optimization  
Day 26 – Terraform modules  
Day 27 – Infrastructure testing  
Day 28 – Monitoring + alarms  
Day 29 – Security review  
Day 30 – Final teardown + architecture recap

## Phase 2 – Application Deployment

Day 8  – Application Load Balancer  
Day 9  – DynamoDB integration  
Day 10 – Frontend (S3 static site)  
Day 11 – Custom domain + HTTPS (ACM)  
Day 12 – Private subnets + NAT Gateway  
Day 13 – IAM least privilege  
Day 14 – Logging + CloudWatch  

---

## Phase 3 – Production Architecture

Day 15 – ECS autoscaling  
Day 16 – Multi-environment (dev/staging/prod)  
Day 17 – Remote state (S3 + DynamoDB locking)  
Day 18 – CI/CD (GitHub Actions)  
Day 19 – Blue/Green deployment  
Day 20 – Secrets Manager  
Day 21 – WAF  

---

## Phase 4 – Advanced Topics

Day 22 – Route53 DNS  
Day 23 – CloudFront CDN  
Day 24 – Multi-region architecture  
Day 25 – Cost optimization  
Day 26 – Terraform modules  
Day 27 – Infrastructure testing  
Day 28 – Monitoring + alarms  
Day 29 – Security review  
Day 30 – Final teardown + architecture recap  

---

Scope changes must be intentional and committed.