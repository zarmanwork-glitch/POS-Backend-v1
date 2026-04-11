# ---------- build stage ----------
FROM oven/bun:1 AS builder
WORKDIR /app

COPY package.json bun.lock* ./
RUN bun install

COPY . .
RUN node_modules/.bin/tsc -p tsconfig.build.json && ls dist/src/main.js

# ---------- production stage ----------
FROM node:20-alpine
WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public

EXPOSE 5001
CMD ["node", "dist/src/main"]
