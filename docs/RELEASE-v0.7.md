# EMTAF v0.7 Release

## Objectives
1. Establish reusable platform services.
2. Move deployment from Docker Compose toward Kubernetes.
3. Keep industry-specific logic outside the core framework.
4. Provide independent domain service drafts for Hospital, School, College and Hotel.

## Architecture rule
Platform services are domain-neutral. Industry services consume platform capabilities and own their own data.

## Kubernetes
The `infra/kubernetes` directory contains a baseline namespace, ConfigMap, Secrets template, PostgreSQL/Redis/Redpanda dependencies for development, API gateway and service deployments, services, ingress and autoscaling examples.

Production environments should replace development secrets, persistence assumptions and local broker/storage configuration with managed infrastructure where appropriate.
