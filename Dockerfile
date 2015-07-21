FROM ruby:latest
MAINTAINER zchee <zcheeee@gmail.com>

WORKDIR /usr/src/app

RUN bundle config --global jobs 8
COPY Gemfile /usr/src/app/
RUN bundle install

COPY . /usr/src/app
CMD ruby web.rb -p $PORT
