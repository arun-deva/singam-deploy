FROM nginx
RUN mkdir -p /home/arde

#Deploy minesweeper ui
COPY ui-dist/minesweeper-ui.tgz /home/arde
WORKDIR /home/arde
RUN tar xzvf minesweeper-ui.tgz
RUN pwd
RUN ls -l
RUN mv /home/arde/minesweeper-ui /usr/share/nginx/html/minesweeper
RUN rm -rf minesweeper-ui.tgz