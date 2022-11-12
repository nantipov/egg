FROM node:lts-slim

RUN mkdir /web

COPY build/src/*.* /web

ENTRYPOINT [ "node", "/web/index.ts" ]
