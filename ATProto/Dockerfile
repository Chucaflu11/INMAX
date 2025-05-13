
FROM node:20-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache python3 make g++

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy server files
COPY pds-server.js ./
COPY .env ./

# Create directory for blob storage
RUN mkdir -p ./data/blocks

# Expose the port
EXPOSE 3000

# Start the server
CMD ["node", "pds-server.js"]