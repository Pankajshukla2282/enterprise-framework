# EMTAF v0.7 Architecture

## Platform service boundaries

### Notification Service
Owns notification requests, templates, delivery attempts and provider adapters.

### Document Service
Owns document metadata, object-storage references, versions, checksums and access policies.

### Configuration Service
Provides hierarchical configuration with platform -> tenant -> organization -> facility -> user precedence.

### Feature Flag Service
Evaluates feature flags by product, tenant, organization, facility and user.

### Scheduler Service
Owns durable scheduled jobs and dispatches work through the event platform.

### Workflow Service
Owns workflow definitions, states, transitions, instances and actions.

## Domain services
Hospital, School, College and Hotel are separate bounded contexts. They may consume common services but must not directly access another domain service's database.

## Kubernetes
Every independently deployable service receives a Deployment, Service and configuration. Stateless workloads should be horizontally scalable. Stateful infrastructure should normally be external/managed in production.
