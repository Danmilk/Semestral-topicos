# ── Stage 1: build y tests ──────────────────────
FROM node:20-alpine AS builder

WORKDIR /app
COPY app/package*.json ./
RUN npm install
COPY app/ .

# Los tests se ejecutan durante el build; si fallan, la imagen no se crea
RUN npm test

# ── Stage 2: imagen de producción ───────────────
FROM node:20-alpine AS production

WORKDIR /app
COPY --from=builder /app/package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/src ./src

EXPOSE 3000
USER node

ARG APP_VERSION=1.0.0
ENV APP_VERSION=${APP_VERSION}

CMD ["node", "src/index.js"]
