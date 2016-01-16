FROM ruby:2.3.0
MAINTAINER zchee <k@zchee.io>

# Change current to application directory
WORKDIR /usr/src/app

# Workaround bundle cache
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --jobs $(nproc)

# Copy all file
COPY . /usr/src/app
RUN mkdir /usr/src/app/log && touch /usr/src/app/log/dev.log

EXPOSE 80
ENV PORT 80

CMD ["/usr/local/bundle/bin/foreman", "start", "-d","/usr/src/app", "-p", "80"]
