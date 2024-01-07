FROM nginx:alpine-slim
#Deploy landing page
COPY index.html /usr/share/nginx/html
COPY images /usr/share/nginx/html/images