FROM ruby:alpine

ENV APP_ROOT=/app  \
    USER=trustvox  \
    GROUP=trustvox \
    BUNDLE_PATH=/usr/local/bundle

RUN addgroup -g 1000 -S $GROUP && \
    adduser -u 1000 -S $USER -G $GROUP

RUN mkdir $APP_ROOT && \
    chown 1000:1000 $APP_ROOT

USER $USER

WORKDIR $APP_ROOT

# Make sure your dependecies are fetched only if they change
COPY Gemfile* $APP_ROOT/
RUN gem install bundler --no-document && bundle

COPY --chown=1000:1000 . .
