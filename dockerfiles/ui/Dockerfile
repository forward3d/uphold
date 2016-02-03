FROM ruby:2.3-slim

RUN apt-get update

WORKDIR /opt/uphold
COPY Gemfile /opt/uphold/Gemfile
COPY Gemfile.lock /opt/uphold/Gemfile.lock

RUN \
  apt-get install -y build-essential && \
  bundle install --without tester development && \
  apt-get remove -y build-essential && \
  apt-get autoremove -y && apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY lib /opt/uphold/lib
COPY public /opt/uphold/public
COPY views /opt/uphold/views
COPY config.ru environment.rb ui.rb /opt/uphold/

EXPOSE 8079
CMD ["bundle", "exec", "rackup", "config.ru", "-p", "8079", "-s", "thin", "-o", "0.0.0.0"]
