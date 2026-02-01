# syntax=docker/dockerfile:1
# Delaford (visual MUD-like) - Dockerfile for Coolify
# Notes:
# - Repo expects Node ~10 + npm ~6.
# - Uses node-sass@4 => requires python2 + build toolchain.

FROM node:10-buster

WORKDIR /app

# Build deps for node-sass and other native modules.
# Debian buster is EOL; default mirrors may 404. Switch to archive.debian.org.
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
  && sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
  && apt-get -o Acquire::Check-Valid-Until=false update \
  && apt-get install -y --no-install-recommends python2 make g++ \
  && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Build server transpilation + client bundle
# (postinstall also does this, but we do it explicitly for clarity)
RUN npm run build-server && npm run build

ENV NODE_ENV=production
ENV PORT=6500
EXPOSE 6500

CMD ["npm", "run", "server:prod"]
