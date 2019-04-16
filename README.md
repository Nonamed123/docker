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

# Homework 20 Gitlab-CI-2
## 20.1 Что было сделано

    создан новый проект в gitlab-ci
    добавлен новый remote в _microservices:

git checkout -b gitlab-ci-2
git remote add gitlab2 http://<your-vm-ip>/homework/example2.git
git push gitlab2 gitlab-ci-2

    для нового проекта активирован сущестующий runner
    пайплайн изменен таким образом, чтобы job deploy стал определением окружения dev, на которое условно будет выкатываться каждое изменение в коде проекта
    определены два новых этапа: stage и production, первый будет содержать job имитирующий выкатку на staging окружение, второй на production окружение
    staging и production запускаются с кнопки (when: manual)
    в описание pipeline добавлена директива, которая не позволит нам выкатить на staging и production код, не помеченный с помощью тэга в git:

...
staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com
...

    в описание pipeline добавлены динамические окружения, теперь на каждую ветку в git отличную от master Gitlab CI будет определять новое окружение

## 20.2 Как запустить проект

на машине с gitlab-ci в каталоге /srv/gitlab/:

docker-compose up -d

## 20.3 Как проверить

перейти в браузере по ссылке http://docker-host_ip

# Homework 19 Gitlab-CI-1
## 19.1 Что было сделано
создана ВМ в GCP, установлен docker-ce, docker-compose
в каталоге /srv/gitlab/ создан docker-compose.yml с описанием gitlab-ci:
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://35.187.88.136'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
    
запущен gitlab-ci:
docker-compose up -d 
созданы группа и проект в gitlab-ci

добавлен remote в _microservices:
git checkout -b gitlab-ci-1
git remote add gitlab http://<your-vm-ip>/homework/example.git
git push gitlab gitlab-ci-1
создан файл .gitlab-ci.yml с описанием пайплайна
создан и зарегистрирован runner:
docker run -d --name gitlab-runner --restart always \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest 
docker exec -it gitlab-runner gitlab-runner register
добавлен исходный код reddit в репозиторий:
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m “Add reddit app”
git push gitlab gitlab-ci-1
в описание pipeline добавлен вызов теста в файле simpletest.rb
добавлена библиотека для тестирования в reddit/Gemfile приложения
теперь на каждое изменение в коде приложения будет запущен тест
Интеграция со slack чатом:

Project Settings > Integrations > Slack notifications. Нужно установить active, выбрать события и заполнить поля с URL Slack webhook
ссылка на тестовый канал https://nonamed-hq.slack.com/archives/CF2BB9CHG/p1554983084000200

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
# Homework 15-16 Docker-4
## 15.1 Что было сделано
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
базовое имя проекта задется переменной COMPOSE_PROJECT_NAME
работа docker-compose проверена:
docker-compose up -d
docker ps
## 15-16.2 Как запустить проект
в каталоге src:

docker kill $(docker ps -q)
docker-compose up -d
## 15-16 .3 Как проверить
перейти в браузере по ссылке http://docker-host_ip:9292

# Homework 14 Docker-3
## 14.1 Что было сделано
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
## 14.2 Как запустить проект
### 14.2.1 Base
в каталоге src:

docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:2.0
### 14.2.2 *
в каталоге src:

docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post statusxt/post:1.0
docker run -d --network=reddit --network-alias=comment statusxt/comment:1.0
docker run -d --network=reddit -p 9292:9292 statusxt/ui:5.0
## 14.3 Как проверить
перейти в браузере по ссылке http://docker-host_ip:9292
