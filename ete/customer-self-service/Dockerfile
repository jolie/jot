FROM jolielang/jolie:edge

COPY /customer-core /customer-core

WORKDIR /app
COPY /customer-self-service .

CMD ["jolie", "--params", "/config/params.json", "main.ol"]