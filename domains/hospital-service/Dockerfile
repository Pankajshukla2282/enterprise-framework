FROM node:22-alpine AS build
WORKDIR /app
COPY package.json ./
COPY core ./core
COPY domains/hospital-service ./domains/hospital-service
COPY packages ./packages
RUN npm install --include=dev --ignore-scripts --no-audit --no-fund \
 && npm run build --workspace=@emtaf/core \
 && npm run build --workspace=@emtaf/hospital-service \
 && npm prune --omit=dev
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/core ./core
COPY --from=build /app/domains/hospital-service/dist ./domains/hospital-service/dist
COPY --from=build /app/domains/hospital-service/package.json ./domains/hospital-service/package.json
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
USER node
CMD ["node","domains/hospital-service/dist/main.js"]
