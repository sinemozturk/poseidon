FROM nginx:alpine

# Custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy app files
RUN mkdir -p /usr/share/nginx/html/poseidon-app
COPY index.html /usr/share/nginx/html/poseidon-app/
COPY style.css /usr/share/nginx/html/poseidon-app/
COPY static/ /usr/share/nginx/html/poseidon-app/static/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
