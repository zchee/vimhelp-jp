# rugged need libssh2-1-dev
# cf: https://github.com/jbox-web/redmine_git_hosting/issues/440
FROM ruby:2.3.0
MAINTAINER zchee <k@zchee.io>

# Change current to application directory
WORKDIR /usr/src/app

# Workaround bundle cache
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN set -ex \
	&& sed -i 's/httpredir/ftp.jp/g' /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y vim cmake openssl libssh2-1-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& bundle install --jobs $(nproc) \
	&& mkdir -p /usr/src/app/log && touch /usr/src/app/log/development.log \
	&& git config --global user.name 'Koichi Shiraishi' \
	&& git config --global user.email 'k@zchee.io' \
	&& git config --global push.default 'current'


# Copy all file
COPY . /usr/src/app
COPY .ssh/config /root/.ssh/config

EXPOSE 80

CMD ["/usr/local/bundle/bin/foreman", "start", "-d","/usr/src/app", "-p", "80"]
