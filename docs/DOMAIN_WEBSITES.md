# EMTAF Domain Web Applications

EMTAF now includes independently runnable web applications for all five business domains:

- `hospital-site` — clinical, patient, appointments, encounters, wards/beds, admissions, prescriptions, laboratory, radiology, insurance and billing workflows.
- `school-site` — students, teachers, classes, enrollments and attendance.
- `college-site` — students, faculty, departments, courses, enrollments, attendance, fees and examinations/results.
- `hotel-site` — guests, room types, rooms, bookings, check-in/out, payments and housekeeping.
- `realestate-site` — properties, units, listings, leads, viewings, offers, leases and payments.

## Architecture

Each site is an independent Node static-file server with a same-origin `/api/*` proxy. The browser supplies the JWT; the proxy forwards the authorization header to the corresponding EMTAF domain service.

This preserves the platform's tenant and RBAC boundary: the website does not implement a second authorization system and cannot bypass backend permissions.

For Kubernetes, each site has a Dockerfile and a Deployment/Service manifest. `scripts/build.ps1 -Target all` builds the five web images along with the platform images, and the dev Kustomize overlay references those same local image names.

## Local ports

| Domain | Site | Default port | API service |
|---|---|---:|---|
| Hospital | `hospital-site` | 3001 | `hospital-service` |
| Real estate | `realestate-site` | 3002 | `realestate-service` |
| School | `school-site` | 3003 | `school-service` |
| College | `college-site` | 3004 | `college-service` |
| Hotel | `hotel-site` | 3005 | `hotel-service` |

## Local development

Port-forward the corresponding API service, then run the site:

```powershell
kubectl -n emtaf port-forward svc/hospital-service 8080:80
cd .\hospital-site
npm run token
$env:JWT_TOKEN = "<token>"
npm start
```

The UI also accepts a JWT directly through the **Connect** control. `API_BASE` can be changed when the API is exposed on a different address.

## Kubernetes

The site deployments use the domain service's Kubernetes DNS name as `API_BASE`, for example:

```text
http://hospital-service
http://school-service
http://college-service
http://hotel-service
http://realestate-service
```

A dedicated NetworkPolicy permits the web pods to reach only the five domain services on TCP/3000 plus cluster DNS.

## Functional design

The web applications use the API surface already implemented by the domain services. They provide:

- tenant/user identity display
- dashboard metrics
- searchable operational tables
- create forms
- state-changing workflow actions
- idempotency-key support for operations that require it
- API error feedback
- role/permission enforcement through the backend
- responsive desktop/mobile layout

The backend remains the source of truth for authorization and tenant isolation.
