FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY core ./core
COPY services/tenant-service ./services/tenant-service
RUN npm install && npm run build --workspace=@emtaf/core && npm run build --workspace=@emtaf/tenant-service
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/core/dist ./core/dist
COPY --from=build /app/services/tenant-service/dist ./services/tenant-service/dist
USER node
ENV NODE_ENV=production PORT=3000
CMD ["node","services/tenant-service/dist/main.js"]
