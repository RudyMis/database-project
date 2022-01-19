FROM node:lts-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install
RUN npm install -g serve

EXPOSE 8080

COPY public public
COPY .env* ./
COPY src src

RUN npm run build

ENTRYPOINT [ "serve", "-s", "dist" ]
