# microservices

    скачан архив с микросервисами и распакован в src
    созданы Dockerfile для сборки post-py, comment, ui

docker build -t statusxt/post:1.0 ./post-py
docker build -t statusxt/comment:1.0 ./comment
docker build -t statusxt/ui:1.0 ./ui

    создана сеть для приложения

docker network create reddit

    запущены контейнеры:

docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:1.0

    создан docker volume для mongodb

 docker volume create reddit_db 

    контейнеры перезапущены с новыми парметрами, теперь данные в базе не зависят о перезапуска контейнеров

docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0

В рамках задания со *:

    запущены контейнеры с другими сетевыми алиасами, при запуске контейнеров (docker run) заданы переменные окружения соответствующие новым сетевым алиасам:

docker run -d --network=reddit --network-alias=post_db_1 \
              --network-alias=comment_db_1 mongo:latest
docker run -d --network=reddit --network-alias=post_1 \
              -e POST_DATABASE_HOST=post_db_1 andywow/post:1.0
docker run -d --network=reddit --network-alias=comment_1 \
              -e COMMENT_DATABASE_HOST=comment_db_1 andywow/comment:1.0
docker run -d --network=reddit -p 9292:9292 --network-alias=ui \
              -e COMMENT_SERVICE_HOST=comment_1 \
              -e POST_SERVICE_HOST=post_1 andywow/ui:1.0

    собран образ на основе alpine linux
    произведены оптимизации ui образа - удаление кэша, приложений для сборки

statusxt/ui    5.0    521a666364d1    23 hours ago    58.5MB
statusxt/ui    4.0    223d64bf1a3a    23 hours ago    209MB
statusxt/ui    3.0    c4c2f1396a5b    24 hours ago    58.4MB
statusxt/ui    2.0    8e8787069c58    25 hours ago    460MB
statusxt/ui    1.0    8c6d705411e2    25 hours ago    778MB
