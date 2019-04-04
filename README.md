# docker
## dangling - удаление "висячих" отсатков образов а также томов
Remove dangling volumes - Docker 1.9 and later
Since the point of volumes is to exist independent from containers, when a container is removed, a volume is not automatically removed at the same time. When a volume exists and is no longer connected to any containers, it's called a dangling volume. To locate them to confirm you want to remove them, you can use the docker volume ls command with a filter to limit the results to dangling volumes. When you're satisfied with the list, you can remove them all with docker volume prune:

List:

docker volume ls -f dangling=true
Remove:

docker volume prune
Неиспользуемое изображение означает, что оно не было назначено или использовано в контейнере. Например, при запуске docker ps -a- в нем будут перечислены все ваши вышедшие и запущенные в данный момент контейнеры. Любые изображения, показанные как используемые внутри любого из контейнеров, являются «использованным изображением».

С другой стороны, висящее изображение просто означает, что вы создали новую сборку изображения, но ему не дали новое имя. Таким образом, старые образы, которые у вас есть, становятся «висячим образом». Эти старые изображения являются непомеченными и отображают " <none>" на своем имени при запуске docker images.

При запуске docker system prune -aон удалит неиспользуемые и свисающие изображения. Поэтому любые изображения, используемые в контейнере, вне зависимости от того, были ли они завершены или запущены в данный момент, НЕ будут затронуты.

# Homework 17 Docker-4#

## 17.1 Что было сделано

    протестирована работа контейнера с использованием none и host драйвера

docker run --network none --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
docker ps
docker run --network host --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
docker-machine ssh docker-host ifconfig
docker run --network host -d nginx
docker run --network host -d nginx

    nginx запустить несколько раз не получится, потому что порт будет занят первым запущенным экземпляром
    при запуске контейнера с none драйвером создается новый namespace, при запуске с host драйвером используется namespace хоста
    создана bridge-сеть в docker, запущен проект с использоваением этой сети:

docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment  statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0

    созданы 2 bridge-сети в docker, запущен проект с использоваением этих сетей:

docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
docker run -d --network=front_net -p 9292:9292 --name ui  statusxt/ui:1.0
docker run -d --network=back_net --name comment  statusxt/comment:1.0
docker run -d --network=back_net --name post  statusxt/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
docker network connect front_net post
docker network connect front_net comment

    установлен docker-compose

pip install docker-compose 

    создан файл dockercompose.yml с описанием проекта
    в dockercompose.yml добавлены 2 сети, сетевые алиасы, параметризованы порт публикации, версии сервисов
    переменные задаются в файле .env
    базовое имя проета задется переменной COMPOSE_PROJECT_NAME
    работа docker-compose проверена:

docker-compose up -d
docker ps

## 17.2 Как запустить проект

в каталоге src:

docker kill $(docker ps -q)

## 17.3 Как проверить

перейти в браузере по ссылке http://docker-host_ip:9292
