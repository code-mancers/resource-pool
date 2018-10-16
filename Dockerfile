# ================================================================================
# Compile node assets as a separate stage
FROM node:9 AS staticassets

RUN apt-get update && apt-get install -y build-essential
RUN mkdir -p /resource-pool/assets
WORKDIR /resource-pool/assets
COPY ./resource-pool/assets/package*.json ./
RUN npm install
COPY ./resource-pool/assets .
RUN npm run deploy

# ================================================================================
# Compile elixir app as a separate stage
FROM elixir:1.6.6-alpine AS application

# RUN apt-get update && apt-get install -y build-essential
RUN apk --update upgrade && apk add --no-cache build-base git
RUN mix local.hex --force && mix local.rebar --force
RUN mkdir -p /resource-pool
WORKDIR /resource-pool
COPY mix.exs .
COPY mix.lock .
RUN mix deps.get --force --only prod
COPY . ./
COPY --from=staticassets \
     resource-pool/priv/static
ENV MIX_ENV prod
RUN mix deps.get --only prod && \
    mix phx.digest && \
    mix release --env prod

# ================================================================================
# Start from alpine and copy binaries
FROM alpine
MAINTAINER Codemancers <team@codemancers.com>

RUN apk add --no-cache bash libssl1.0 git openssh
COPY --from=application /resource-pool/_build /resource-pool/_build
COPY --from=application /resource-pool/scripts /resource-pool/scripts

ENV MIX_ENV prod
ENV PORT 4000

EXPOSE 4000
CMD /resource-pool/scripts/run_release
