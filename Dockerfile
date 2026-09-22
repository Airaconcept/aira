FROM node:alpine3.22 AS builder

WORKDIR /build

# Download pre-built binaries at build time
RUN apk add --no-cache wget unzip

# Download cloudflared
RUN wget -q https://github.com/cloudflare/cloudflared/releases/download/2026.9.1/cloudflared-linux-amd64 -O /build/bot && chmod +x /build/bot

# Download xray-core
RUN wget -q https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip -O /build/xray.zip && \
    unzip -o /build/xray.zip -d /build/xray && \
    cp /build/xray/xray /build/web && \
    chmod +x /build/web && \
    rm -rf /build/xray.zip /build/xray

FROM node:alpine3.22

WORKDIR /tmp

COPY index.js index.html package.json ./

COPY --from=builder /build/bot /usr/local/bin/bot
COPY --from=builder /build/web /usr/local/bin/web

EXPOSE 3000/tcp

RUN apk update && apk upgrade && \
    apk add --no-cache openssl curl gcompat iproute2 coreutils && \
    apk add --no-cache bash && \
    chmod +x index.js && \
    chmod +x /usr/local/bin/bot /usr/local/bin/web && \
    npm install

CMD ["node", "index.js"]
