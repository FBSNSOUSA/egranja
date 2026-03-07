# Dashboard web eGranja - desenvolvimento com hot reload
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
# Proxy para a API será definido via VITE_PROXY_TARGET no compose
ENV VITE_PROXY_TARGET=http://backend:8080

EXPOSE 3000
CMD ["npm", "run", "dev"]
