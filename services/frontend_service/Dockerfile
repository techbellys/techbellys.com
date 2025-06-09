# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
  curl libjemalloc2 libvips sqlite3 nodejs npm git build-essential \
  libyaml-dev pkg-config && rm -rf /var/lib/apt/lists

RUN npm install -g yarn

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test"

# -------- Build Layer --------
FROM base AS build

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.6.9 && \
    bundle install && \
    bundle exec bootsnap precompile --gemfile

COPY . .

# Precompile JS + CSS + assets
RUN yarn install && \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

RUN ls -la /rails/public/

RUN ls -la /rails/public/assets/
# -------- Final Runtime Layer --------
FROM base

# Copy built gems and app code
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails
COPY --from=build /rails/public /rails/public

# Set proper permissions
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p tmp/pids tmp/cache log storage && \
    chown -R rails:rails db log storage tmp public
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 4000
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "4000"]
