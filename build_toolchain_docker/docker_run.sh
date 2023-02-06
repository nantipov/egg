#!/bin/sh

#docker run -v "$(pwd)"\:/build --workdir /build --user $(id -u):$(id -g) nantipov/egg-build:latest $@
docker run -v "$(pwd)"\:/build --workdir /build nantipov/egg-build:latest $@