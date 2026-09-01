# Azure Hub-Spoke Infrastructure with Bicep

> **Status:** Code Validated | **Role:** Cloud Engineer | **Certification:** AZ-104

This repository contains the Infrastructure as Code (IaC) implementation for a secure, scalable, and observable **Azure Hub-Spoke network topology**. The solution was designed and deployed using **Bicep** to demonstrate best practices in modular architecture, network security, and Azure monitoring.

##  Architecture Overview

The solution deploys:
- **Hub VNet:** Hosts Azure Bastion for secure, public-IP-free management.
- **Spoke VNet:** Contains workload subnets for application servers.
- **Interconnectivity:** Bidirectional VNet peering between Hub and Spoke.
- **Compute:** Ubuntu 24.04 VMs distributed across Availability Zones (optional) behind a Standard Load Balancer.
- **Security:** NSGs restricting SSH access exclusively to the Bastion subnet.
- **Observability:** Azure Monitor, Log Analytics, and Data Collection Rules for metrics and syslog.

##  Key Features

| Component | Technology | Description |
| :--- | :--- | :--- |
| **IaC** | **Bicep** | Modular deployment (`network`, `bastion`, `compute`, `monitoring` modules). |
| **Security** | **Azure Bastion** | Eliminates public IPs on VMs; secure access via restricted NSG rules. |
| **High Availability** | **Availability Zones** | VMs distributed across zones for fault tolerance. |
| **Load Balancing** | **Azure LB (Standard)** | Distributes HTTP traffic across VM instances. |
| **Monitoring** | **Azure Monitor** | Automated diagnostic settings and Data Collection Rules. |

##  Project Structure

```text

.
├── main.bicep              # Entry point; orchestrates module deployment
├── dev.bicepparam          # Environment-specific parameters
├── modules/
│   ├── network.bicep       # Hub/Spoke VNets, Subnets, and Peerings
│   ├── bastion.bicep       # Bastion Host and Public IP
│   ├── compute.bicep       # VMs, NICs, Load Balancer, and NSGs
│   └── monitoring.bicep    # Log Analytics, Diagnostics, and DCRs
└── README.md

```

##  Validation & Testing

This codebase was **validated** using:
- **Bicep CLI** (`bicep build`) for syntax and dependency resolution
- **Azure CLI** (`az bicep build --file main.bicep`) for ARM template generation
- **Static code review** for security best practices (NSG rules, `@secure()` parameters)

> **Note:** This solution was developed and validated during active Azure subscription access. Deployment commands are provided for reference purposes.

##  Security Highlights

- **Zero Public IPs on VMs:** All management traffic routed via Azure Bastion.
- **Least Privilege NSGs:** SSH (Port 22) allowed *only* from the Bastion subnet CIDR.
- **Secure Parameters:** Passwords and SSH keys handled via `@secure()` in Bicep.
- **Audit Trails:** All NSG flow logs and LB metrics streamed to Log Analytics.

##  Monitoring & Observability

- **Log Analytics Workspace:** Centralized log storage with 30-day retention.
- **Data Collection Rules (DCR):** Collects CPU/Memory performance counters and Syslog levels (Warning, Error, Critical).
- **Azure Monitor Agent (AMA):** Deployed automatically to VMs via extension.
- **Diagnostic Settings:** NSG flow logs and Load Balancer metrics streamed to Log Analytics.

##  About This Project

This project was built to demonstrate practical application of skills validated by the **Microsoft Azure Administrator (AZ-104)** certification, specifically:
- Implementing and managing Azure Virtual Networks (Hub-Spoke topology)
- Configuring Network Security Groups and Azure Bastion
- Deploying and managing Azure Compute resources
- Managing Azure Monitor and Log Analytics

---
*Built by Ennio | AZ-104 Certified Cloud Engineer*
