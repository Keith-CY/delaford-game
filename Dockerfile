# syntax=docker/dockerfile:1
# Delaford (visual MUD-like) - Dockerfile for Coolify
# Notes:
# - Repo expects Node ~10 + npm ~6.
# - Uses node-sass@4 => requires python2 + build toolchain.

FROM node:10-buster

WORKDIR /app

# Build deps for node-sass and other native modules
RUN apt-get update \
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
