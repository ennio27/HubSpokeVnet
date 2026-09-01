# Azure Hub-Spoke Infrastructure with Bicep


This repository contains the Infrastructure as Code (IaC) implementation for a secure, scalable, and observable **Azure Hub-Spoke network topology**. The solution was designed and deployed using **Bicep** to demonstrate best practices in modular architecture, network security, and Azure monitoring.

## Architecture Overview

The solution deploys:
- **Hub VNet:** Hosts Azure Bastion for secure, public-IP-free management.
- **Spoke VNet:** Contains workload subnets for application servers.
- **Interconnectivity:** Bidirectional VNet peering between Hub and Spoke.
- **Compute:** Ubuntu 24.04 VMs distributed across Availability Zones (optional) behind a Standard Load Balancer.
- **Security:** NSGs restricting SSH access exclusively to the Bastion subnet.
- **Observability:** Azure Monitor, Log Analytics, and Data Collection Rules for metrics and syslog.

## Key Features

| Component | Technology | Description |
| :--- | :--- | :--- |
| **IaC** | **Bicep** | Modular deployment (`network`, `bastion`, `compute`, `monitoring` modules). |
| **Security** | **Azure Bastion** | Eliminates public IPs on VMs; secure access via restricted NSG rules. |
| **High Availability** | **Availability Zones** | VMs distributed across zones for fault tolerance. |
| **Load Balancing** | **Azure LB (Standard)** | Distributes HTTP traffic across VM instances. |
| **Monitoring** | **Azure Monitor** | Automated diagnostic settings and Data Collection Rules. |

## Project Structure

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
