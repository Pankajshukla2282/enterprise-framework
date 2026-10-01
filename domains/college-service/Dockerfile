FROM node:22-alpine AS build
WORKDIR /app
COPY package.json ./
COPY core ./core
COPY domains/college-service ./domains/college-service
RUN npm install --include=dev --ignore-scripts --no-audit --no-fund \
 && npm run build --workspace=@emtaf/core \
 && npm run build --workspace=@emtaf/college-service \
 && npm prune --omit=dev
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/core ./core
COPY --from=build /app/domains/college-service/dist ./domains/college-service/dist
COPY --from=build /app/domains/college-service/package.json ./domains/college-service/package.json
ENV NODE_ENV=production PORT=3000
USER node
CMD ["node","domains/college-service/dist/main.js"]
