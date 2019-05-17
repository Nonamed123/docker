FROM python:3.6.0-alpine

LABEL \
    maintainer="justdewil@gmail.com" \
    name="Reddit App Post service " \
    image="vstaf/post"

WORKDIR /app
COPY . /app

RUN set -x \
    && apk update \
    && apk add --no-cache gcc musl-dev \
    && rm -rf /usr/lib/ruby/gems/*/cache/* /var/cache/apk/* /tmp/* /var/tmp/*

RUN pip install --no-cache-dir -r /app/requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
