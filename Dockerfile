FROM nginx
RUN mkdir -p /home/arde

#TODO install curl in docker image
RUN apt-get update && apt-get install -y curl

#Deploy minesweeper ui
COPY ui-dist/minesweeper-ui.tgz /home/arde
WORKDIR /home/arde
RUN tar xzvf minesweeper-ui.tgz
RUN pwd
RUN ls -l
RUN mv /home/arde/minesweeper-ui /usr/share/nginx/html/minesweeper
RUN rm -rf minesweeper-ui.tgz

#Deploy aadupuli ui
COPY ui-dist/aadupuli-ui.tgz /home/arde
WORKDIR /home/arde
RUN tar xzvf aadupuli-ui.tgz
RUN pwd
RUN ls -l
RUN mv /home/arde/aadupuli-ui /usr/share/nginx/html/aadupuli
RUN rm -rf aadupuli-ui.tgz

#Deploy landing page
COPY index.html /usr/share/nginx/html
COPY images /usr/share/nginx/images

# TODO Deploy Audio guessing game and associated resources
#COPY AudioClipGuess.html /usr/share/nginx/html

#replace nginx default conf with our custom config with proxy pass directives for minesweeper API
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx-default.conf /etc/nginx/conf.d/default.conf