```mermaid
graph LR
    %% Base Styling
    classDef tf fill:#5C4EE5,stroke:#fff,stroke-width:2px,color:#fff;
    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    classDef k8s fill:#326CE5,stroke:#fff,stroke-width:2px,color:#fff;
    classDef storage fill:#3F8624,stroke:#fff,stroke-width:2px,color:#fff;

    %% Left Side: Management & Automation
    subgraph Management [Automation & State]
        TF[Terraform CLI]:::tf
        subgraph State_Management [State Management]
            TF_State[Terraform State]:::storage -->|Stores & Locks State| S3[S3 Backend]:::storage
        end
    end

    %% Main Flow to Infrastructure
    TF -->|Deploys| VPC[AWS VPC]:::aws

    %% Cloud Infrastructure
    subgraph AWS_Cloud [AWS Cloud Infrastructure]
        VPC -->|Hosts| EKS[Amazon EKS Control Plane]:::aws
        
        subgraph EKS_Cluster [EKS Cluster Internals]
            EKS --> OIDC[OIDC Provider]:::aws
            OIDC -->|Enables| IRSA[IRSA: IAM Roles]:::aws
            IRSA -->|Grants Perms| LBC[AWS Load Balancer Controller]:::k8s
            
            EKS --> MNG[Managed Node Group]:::aws
            MNG -->|Runs Pods| LBC
        end
    end

    %% Right Side: Traffic Flow
    LBC -->|Provisions| ALB[Application Load Balancer]:::aws
    ALB -->|Routes via| Ingress[Kubernetes Ingress]:::k8s
    Ingress -->|Forwards to| Pods[Application Pods]:::k8s
```



# Terraform EKS Infrastructure

Infrastructure as Code project for provisioning an AWS EKS cluster using Terraform.

## Components

* VPC
* Public and Private Subnets
* NAT Gateway
* Amazon EKS
* Managed Node Groups
* EKS Addons (CoreDNS, kube-proxy, VPC CNI)
* OIDC Provider
* IRSA (IAM Roles for Service Accounts)
* AWS Load Balancer Controller
* Remote Terraform State in Amazon S3

## Architecture

AWS: VPC, Public Subnets, Private Subnets, NAT Gateway, EKS, Managed Node Group, CoreDNS, kube-proxy, VPC CNI, AWS Load Balancer Controller

## Usage

terraform init

terraform plan

terraform apply

## Related Project

Application deployment repository:

helm-test

This repository provides the infrastructure layer used by the application deployment project.
