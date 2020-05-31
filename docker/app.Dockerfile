FROM bitwalker/alpine-elixir-phoenix:1.10.3

RUN apk add --update build-base \
                     git \
                     bash

RUN mkdir -p /app
WORKDIR /app

COPY . ./

# in case of slow internet:
# RUN mix hex.config http_timeout 120
# RUN mix hex.config http_concurrency 1

RUN mix local.hex --force
RUN mix deps.get
RUN mix do compile

# CMD sh ./docker/startup.sh
