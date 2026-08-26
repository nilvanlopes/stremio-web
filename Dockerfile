# the node version for running Stremio Web
ARG NODE_VERSION=22-alpine
ARG PNPM_VERSION=11.24.0
ARG COMMIT_HASH=local
FROM node:$NODE_VERSION AS base
ARG PNPM_VERSION
ARG COMMIT_HASH

# Setup pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV COMMIT_HASH="${COMMIT_HASH}"

RUN corepack enable && corepack prepare "pnpm@${PNPM_VERSION}" --activate
RUN apk add --no-cache git

# Meta
LABEL Description="Stremio Web" Vendor="Smart Code OOD" Version="1.0.0"

RUN mkdir -p /var/www/stremio-web
WORKDIR /var/www/stremio-web

# Setup app
FROM base AS app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml /var/www/stremio-web
RUN pnpm i --frozen-lockfile

COPY . /var/www/stremio-web
RUN pnpm build

# Setup server
FROM base AS server

RUN pnpm i express@4

# Finalize
FROM base

COPY http_server.js /var/www/stremio-web
COPY --from=server /var/www/stremio-web/node_modules /var/www/stremio-web/node_modules
COPY --from=app /var/www/stremio-web/build /var/www/stremio-web/build

EXPOSE 8080
CMD ["node", "http_server.js"]
