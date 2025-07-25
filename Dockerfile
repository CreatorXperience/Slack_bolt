# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7



FROM node:iron-slim AS firststage

WORKDIR /usr/src/app



# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into
# into this layer.
COPY package*.json .
RUN npm ci 


# Copy the rest of the source files into the image.
COPY . .


# Build
RUN npx tsc


FROM node:iron-slim

WORKDIR /usr/src/app

COPY --from=firststage /usr/src/app/dist ./dist
COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

RUN apt-get update -y && apt-get install -y  openssl

RUN npx prisma generate


# Expose the port that the application listens on.
EXPOSE 5000

# Run the application.
CMD ["node", "./dist/main.js"]
