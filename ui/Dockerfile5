FROM ruby:2.6.2
#RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
#RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list
#RUN apt-get -o Acquire::Check-Valid-Until=false update
RUN apt-get update -qq && apt-get install -y build-essential
FROM ubuntu:16.04
RUN apt-get update \
&& apt-get install -y ruby-full ruby-dev build-essential \
&& gem install bundler --no-ri --no-rdoc
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
CMD ["puma"]

#FROM alpine:3.7
#ENV APP_HOME /app
#RUN mkdir $APP_HOME
#WORKDIR $APP_HOME
#COPY . $APP_HOME/

#RUN apk --update add --no-cache \
#    ruby \
#    ruby-dev \
#    ruby-bundler \
#    ruby-json \
#    build-base \
#    && bundle install \
#    && rm -rf /var/cache/apk

#ENV POST_SERVICE_HOST post \
#    POST_SERVICE_PORT 5000 \
#    COMMENT_SERVICE_HOST comment \
#    COMMENT_SERVICE_PORT 9292

#CMD ["puma"]

#FROM alpine:3.7
#ENV APP_HOME /app
#RUN mkdir $APP_HOME
#WORKDIR $APP_HOME
#COPY . $APP_HOME/

#RUN apk --update add --no-cache \
#    ruby \
#    ruby-dev \
#    ruby-bundler \
#    build-base \
#    && bundle install \
#    && apk del \
#    ruby-bundler \
#    build-base \
#    ruby-dev \
#    && rm -rf /var/cache/apk

#ENV POST_SERVICE_HOST post \
#    POST_SERVICE_PORT 5000 \
#    COMMENT_SERVICE_HOST comment \
#    COMMENT_SERVICE_PORT 9292

#CMD ["puma"]
