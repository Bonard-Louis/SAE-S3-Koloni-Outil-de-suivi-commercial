FROM postgres:16-alpine

COPY --chown=postgres:postgres *.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
