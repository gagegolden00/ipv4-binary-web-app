############### ▼ Build Stage ▼ ###############

FROM ruby:3.2.2-slim-bookworm AS assets

WORKDIR /app

ARG ENV="production"
ENV RAILS_ENV="${ENV}"
ENV DOCKER_BUILD=true

RUN bash -c "set -o pipefail \
  && apt-get update \
  && apt-get install -y --no-install-recommends build-essential libpq-dev gnupg curl git \
  && curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends nodejs yarn \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean"

COPY package.json *yarn* ./
RUN yarn install

COPY Gemfile* ./
RUN if [ "${ENV}" != "development" ]; then \
  bundle config set --local without 'development:test'; fi
RUN bundle install --jobs `getconf _NPROCESSORS_ONLN` --retry 3

COPY . .
RUN if [ "${ENV}" != "development" ]; then \
  rails assets:precompile; fi

CMD ["bash"]

############### ▼ Run Stage ▼ ###############

FROM ruby:3.2.2-slim-bookworm AS app

WORKDIR /app

ARG ENV="production"
ENV RAILS_ENV="${ENV}"

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential libpq-dev gnupg curl git imagemagick \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean

COPY --from=assets /usr/local/bundle /usr/local/bundle
COPY --from=assets /app/public /app/public
COPY . .

EXPOSE 3000

CMD ["rails", "s"]
