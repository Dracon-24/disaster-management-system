# ============================
# Stage 1: Build React/Vite App
# ============================
FROM node:20-alpine AS build

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci --force --prefer-offline --no-audit

COPY . .

# Detect and build depending on the tool
RUN if [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then \
      npm run build && mv dist build; \
    else \
      npm run build; \
    fi

# ============================
# Stage 2: Serve Built App
# ============================
FROM nginx:stable-alpine

# Copy build output from previous stage
COPY --from=build /usr/src/app/build /usr/share/nginx/html

# Optional React Router support
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
