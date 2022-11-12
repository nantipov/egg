FROM debian:buster-slim

RUN mkdir /server
RUN mkdir /client

COPY target/release/server /server
COPY ../client/build/*.mpy /client

ENTRYPOINT [ "/server/server" ]
