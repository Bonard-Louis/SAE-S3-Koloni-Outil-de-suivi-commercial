FROM postgres:16-alpine

ENV POSTGRES_DB=koloni
ENV POSTGRES_USER=koloni_app

COPY *.sql /docker-entrypoint-initdb.d/

EXPOSE 5432 
