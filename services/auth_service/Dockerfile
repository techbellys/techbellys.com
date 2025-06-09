# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.4.2
FROM ruby:$RUBY_VERSION-slim AS base

# Set working directory
WORKDIR /rails

# Install only runtime dependencies in the base image
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    libmariadb3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# ---- Build stage ----
FROM base AS build

# Install build tools and MariaDB client headers (needed for mysql2 gem)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libyaml-dev \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libmariadb-dev \
    libmariadb-dev-compat && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Ensure correct bundler version
RUN gem install bundler -v 2.6.9

# Copy Gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy the rest of the app
COPY . .

# Precompile bootsnap code
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets (optional for API-only apps)
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile || echo "Skipping assets:precompile"

# ---- Final runtime image ----
FROM base

# Copy built assets and dependencies from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create a non-root user for security and fix permissions
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /rails/tmp/pids /rails/tmp/cache /rails/log /rails/storage && \
    chown -R rails:rails /rails/tmp /rails/log /rails/storage

USER rails

# Entrypoint handles DB setup and PID cleanup
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 4001

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

