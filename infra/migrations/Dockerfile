FROM postgres:16-alpine
WORKDIR /app
COPY infra/postgres /app/infra/postgres
COPY domains /app/domains
COPY infra/migrations/migrate.sh /app/migrate.sh
RUN chmod +x /app/migrate.sh
ENTRYPOINT ["/app/migrate.sh"]
