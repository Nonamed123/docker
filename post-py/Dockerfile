FROM python:3.7.2-alpine
RUN pip install flask pymongo
WORKDIR /app
ADD . /app
ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts
ENTRYPOINT ["python3", "post_app.py"]
