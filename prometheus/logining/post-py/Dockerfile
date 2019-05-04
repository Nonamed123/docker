FROM python:3.6.0-alpine

RUN apk add --no-cache --virtual .build gcc \
                                        musl-dev

WORKDIR /app
ADD . /app

RUN pip install -r /app/requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

EXPOSE 5000

ENTRYPOINT ["python3", "post_app.py"]
