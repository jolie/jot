FROM jolielang/jolie:edge-dev AS Build
USER root
WORKDIR /app

RUN npm install -g @jolie/jot

ENTRYPOINT ["jot", "jot.json"]