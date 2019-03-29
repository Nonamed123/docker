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
