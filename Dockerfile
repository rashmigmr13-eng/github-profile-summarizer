# ---------- Stage 1: Build React app ----------
FROM node:20-alpine AS build
WORKDIR /app

# 1. Define build arguments to accept values from the 'docker build' command
ARG VITE_GITHUB_TOKEN
ARG VITE_MAX_REPOS=50

# 2. Set the arguments as environment variables for the build process.
# This is CRUCIAL for Vite to pick them up during 'npm run build'.
ENV VITE_GITHUB_TOKEN=$VITE_GITHUB_TOKEN
ENV VITE_MAX_REPOS=$VITE_MAX_REPOS


# Install dependencies
COPY package*.json ./
RUN npm install


# Copy app source and build
COPY . .
# 'npm run build' will now embed the token value into the final JavaScript bundle
RUN npm run build


# ---------- Stage 2: Serve with Nginx ----------
FROM nginx:alpine


# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*


# Copy built app from build stage
COPY --from=build /app/dist /usr/share/nginx/html


# Custom Nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf


EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
