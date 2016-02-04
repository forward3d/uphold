FROM ruby:2.3-slim

RUN apt-get update
RUN apt-get -y install libmysqlclient-dev mysql-client libpq-dev libsqlite3-dev mongodb-clients postgresql-client

WORKDIR /opt/uphold
COPY Gemfile /opt/uphold/Gemfile
COPY Gemfile.lock /opt/uphold/Gemfile.lock

RUN \
  apt-get install -y build-essential && \
  bundle install --without ui development && \
  apt-get remove -y build-essential && \
  apt-get autoremove -y && apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY lib /opt/uphold/lib
COPY environment.rb tester.rb /opt/uphold/

ENTRYPOINT ["ruby", "tester.rb"]
