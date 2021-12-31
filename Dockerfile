FROM nginx
RUN mkdir -p /home/arde

#TODO install curl in docker image
RUN apt-get update && apt-get install -y curl

#Deploy landing page
COPY index.html /usr/share/nginx/html
COPY images /usr/share/nginx/html/images

# TODO Deploy Audio guessing game and associated resources
COPY AudioClipGuess/ /usr/share/nginx/html/

#replace nginx default conf with our custom config with proxy pass directives for minesweeper API
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx-default.conf /etc/nginx/conf.d/default.conf