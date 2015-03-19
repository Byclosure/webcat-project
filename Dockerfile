FROM ubuntu:14.04

EXPOSE 3000
ENV RAILS_ENV production

RUN apt-get update

RUN apt-get install -y ruby1.9.3 bundler

RUN apt-get install -y git pkg-config libgit2-dev libsqlite3-dev \
  cmake libmysqlclient-dev mysql-client libicu-dev \
  libxslt-dev libxml2-dev

RUN apt-get install -y nodejs --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /webcat && \
  cd webcat && \
  git clone https://github.com/gitlabhq/gitlab-shell.git && \
  cd gitlab-shell && \
  git checkout v1.7.0 && \
  cd / && \
  mkdir /webcat/repositories && \
  mkdir /webcat/gitlab-shell-hooks

RUN mkdir -p /webcat/app
RUN mkdir -p /root/.ssh
WORKDIR /webcat/app

ADD Gemfile /webcat/app/
ADD Gemfile.lock /webcat/app/
RUN bundle install --system

ADD . /webcat/app

ADD ./config/gitlab-shell.yml.deployment /webcat/gitlab-shell/config.yml
ADD ./config/application.yml.deployment /webcat/app/config/application.yml

CMD	rake lifecycle:update &&\
 rails server
