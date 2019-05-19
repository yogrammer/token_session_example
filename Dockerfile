FROM ruby:2.6.3-alpine

RUN apk add --update build-base postgresql-dev postgresql-client tzdata nano less
RUN gem install rails -v '5.2.3'

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
CMD ["puma"]
