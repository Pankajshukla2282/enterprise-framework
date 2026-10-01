FROM node:22-alpine AS build
WORKDIR /app
COPY package.json ./
COPY core ./core
COPY domains/realestate-service ./domains/realestate-service
RUN npm install --include=dev --ignore-scripts --no-audit --no-fund \
 && npm run build --workspace=@emtaf/core \
 && npm run build --workspace=@emtaf/realestate-service \
 && npm prune --omit=dev
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/core ./core
COPY --from=build /app/domains/realestate-service/dist ./domains/realestate-service/dist
COPY --from=build /app/domains/realestate-service/package.json ./domains/realestate-service/package.json
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
USER node
CMD ["node","domains/realestate-service/dist/main.js"]
