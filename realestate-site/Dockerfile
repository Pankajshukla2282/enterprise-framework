FROM node:22-alpine
WORKDIR /app
COPY package.json server.mjs ./
COPY public ./public
EXPOSE 3002
CMD ["node","server.mjs"]
