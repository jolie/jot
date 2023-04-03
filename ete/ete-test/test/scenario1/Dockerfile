FROM jolielang/jolie:edge-dev AS Build

USER root

COPY /assertions /assertions
COPY /customer-core /customer-core
COPY /customer-management /customer-management
COPY /customer-self-service /customer-self-service
WORKDIR /app/test
COPY ete-test/test/scenario1 .
RUN npm install -g @jolie/jot
RUN jpm install
ENTRYPOINT ["jot", "jot.json"]
