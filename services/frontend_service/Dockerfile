# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# ---------- BUILD STAGE ----------
FROM base AS build

# Install build tools and Node.js + Yarn
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libyaml-dev \
    pkg-config \
    curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install --no-install-recommends -y nodejs yarn && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy app code
COPY . .

# Precompile bootsnap for app
RUN bundle exec bootsnap precompile app/ lib/

# Install JS dependencies and precompile all assets
RUN yarn install --frozen-lockfile && \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile && \
    ./bin/rails javascript:build && \
    ./bin/rails css:build

# ---------- FINAL IMAGE ----------
FROM base

# Copy built app from build stage
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails
COPY --from=build /rails/public /rails/public

# Setup non-root user and correct file permissions
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p tmp log storage && \
    chown -R rails:rails db log storage tmp
USER rails

# Set entrypoint and port
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 4000

CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "4000"]
