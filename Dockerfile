# First stage: install dependencies
FROM node:20.14.0-bullseye-slim as build

# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json files to the working directory
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Second stage: create a smaller final image
FROM node:20.14-alpine3.20 as build2

# Set the working directory
WORKDIR /app

# Copy the node_modules and application files from the build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app .

RUN npm run build 

FROM nginx

# Copy your NGINX configuration file to the container
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build2 /app/build /usr/share/nginx/html

EXPOSE 80