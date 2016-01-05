FROM ruby:2.3.0
MAINTAINER zchee <zcheeee@gmail.com>

# Change current to application directory
WORKDIR /usr/src/app

# Workaround bundle cache
COPY Gemfile /usr/src/app/
RUN bundle install --jobs $(nproc)

# Copy all file
COPY . /usr/src/app
RUN mkdir /usr/src/app/log && touch /usr/src/app/log/development.log

EXPOSE 80
ENV PORT 80

CMD ["/usr/local/bundle/bin/foreman", "start", "-d","/usr/src/app", "-p", "80"]
