FROM node:22-alpine AS build
WORKDIR /workspace
COPY package.json ./package.json
COPY core ./core
COPY domains/hospital-service ./domains/hospital-service
COPY packages ./packages
RUN npm install --ignore-scripts
RUN npm run build --workspace=@emtaf/core && npm run build --workspace=@emtaf/hospital-service
RUN npm prune --omit=dev
FROM node:22-alpine
WORKDIR /app
COPY --from=build /workspace/node_modules ./node_modules
COPY --from=build /workspace/core/dist ./core/dist
COPY --from=build /workspace/core/package.json ./core/package.json
COPY --from=build /workspace/domains/hospital-service/dist ./service/dist
COPY --from=build /workspace/domains/hospital-service/package.json ./service/package.json
ENV NODE_ENV=production PORT=3000
USER node
WORKDIR /app/service
CMD ["node","dist/main.js"]
