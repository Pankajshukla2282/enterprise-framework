FROM node:22-alpine AS build
WORKDIR /app
COPY package.json ./
COPY core ./core
COPY services/tenant-service ./services/tenant-service
RUN npm install --include=dev --ignore-scripts --no-audit --no-fund \
 && npm run build --workspace=@emtaf/core \
 && npm run build --workspace=@emtaf/tenant-service \
 && npm prune --omit=dev
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/core ./core
COPY --from=build /app/services/tenant-service/dist ./services/tenant-service/dist
COPY --from=build /app/services/tenant-service/package.json ./services/tenant-service/package.json
USER node
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
CMD ["node","services/tenant-service/dist/main.js"]
