FROM node:22-alpine AS build
WORKDIR /app
COPY package.json ./
COPY core/package.json core/package.json
COPY domains/realestate-service/package.json domains/realestate-service/package.json
COPY core core
COPY domains/realestate-service domains/realestate-service
RUN npm install --ignore-scripts && npm run build --workspace=@emtaf/core && npm run build --workspace=@emtaf/realestate-service
FROM node:22-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/core/dist ./core/dist
COPY --from=build /app/core/package.json ./core/package.json
COPY --from=build /app/domains/realestate-service/dist ./domains/realestate-service/dist
COPY --from=build /app/domains/realestate-service/package.json ./domains/realestate-service/package.json
ENV NODE_ENV=production PORT=3000
EXPOSE 3000
USER node
CMD ["node","domains/realestate-service/dist/main.js"]