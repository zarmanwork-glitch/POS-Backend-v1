# ---------- build stage ----------
FROM node:20 AS builder
WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .
RUN npx nest build --webpack && ls dist/main.js

# ---------- production stage ----------
FROM node:20-alpine
WORKDIR /app

# Install Chromium and its dependencies for Puppeteer
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Tell Puppeteer to use the installed Chromium instead of downloading its own
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public

EXPOSE 5001
CMD ["node", "dist/main"]
