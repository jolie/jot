FROM jolielang/jolie:edge-dev AS Build

USER root

WORKDIR /app
COPY . .
RUN jpm install

FROM jolielang/jolie:edge
WORKDIR /app
COPY --from=Build /app .

CMD ["jolie", "--params", "/config/params.json", "main.ol"]