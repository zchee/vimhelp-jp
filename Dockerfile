FROM ruby:2.3.0
MAINTAINER zchee <k@zchee.io>

# Change current to application directory
WORKDIR /usr/src/app

# Workaround bundle cache
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends cmake libgit2-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& git clone https://github.com/libgit2/rugged.git \
	&& cd rugged \
	&& bundle install \
	&& rake compile \
	&& cd ../ \
	&& bundle install --jobs $(nproc) \
	&& mkdir /usr/src/app/log && touch /usr/src/app/log/dev.log

# Copy all file
COPY . /usr/src/app

EXPOSE 80

CMD ["/usr/local/bundle/bin/foreman", "start", "-d","/usr/src/app", "-p", "80"]
