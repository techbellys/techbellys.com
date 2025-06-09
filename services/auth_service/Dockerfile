# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.2
FROM ruby:$RUBY_VERSION-slim AS base

# Set working directory
WORKDIR /rails

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Set environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# ----------------------------------------
# BUILD STAGE
# ----------------------------------------
FROM base AS build

# Install build dependencies (MySQL + native extensions)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libyaml-dev \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libmariadb-dev \
    libmariadb-dev-compat \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Ensure matching bundler version
RUN gem install bundler -v 2.6.9

# Copy Gemfiles and install
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap and assets (if needed)
RUN bundle exec bootsnap precompile app/ lib/

# Optional: skip asset precompile if not required for API-only
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile || echo "Skipping assets precompile"

# ----------------------------------------
# FINAL IMAGE
# ----------------------------------------
FROM base

# Copy gems and app from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create and switch to non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p tmp/pids log storage && \
    chown -R rails:rails /rails /usr/local/bundle

USER rails

# Set entrypoint and command
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 4001
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
