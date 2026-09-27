Build the migration image independently from repository root:
`docker build -f infra/migrations/Dockerfile -t ghcr.io/YOUR_ORG/emtaf-migrations:0.9.0 .`

Run the migration Job before enabling domain deployments.
