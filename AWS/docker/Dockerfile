FROM nginx:latest
RUN apt-get update && apt-get install git -y
RUN rm -rf /usr/share/nginx/html/*
RUN git clone https://github.com/yusuforzibekov/burger.git /usr/share/nginx/html
EXPOSE 80