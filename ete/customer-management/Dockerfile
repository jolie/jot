FROM jolielang/jolie:edge

COPY /customer-core /customer-core

WORKDIR /app
COPY /customer-management .

CMD ["jolie", "--params", "/config/params.json", "main.ol"]