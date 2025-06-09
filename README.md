```source ~/.zprofile

rbenv install ruby-3.4.2 # Or whatever the latest stable version is
rbenv global ruby-3.4.2

gem install bundler
gem install rails
rbenv rehash

mkdir auth_service && cd auth_service

bundle init

bundle exec rails new . --api -d mysql --skip-bundle

bundle config --local build.mysql2 \
  "--with-ldflags=-L/opt/homebrew/opt/zstd/lib \
   --with-cppflags=-I/opt/homebrew/opt/zstd/include \
   --with-mysql-config=$(brew --prefix mysql)/bin/mysql_config"

bundle install
```

* update the config/database.yml

```
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV.fetch("DB_USERNAME", "root") %>
  password: <%= ENV.fetch("DB_PASSWORD", "password") %>
  host: <%= ENV.fetch("DB_HOST", "127.0.0.1") %>
  
development:
  <<: *default
  database: <%= ENV.fetch("DB_NAME", "auth_service_development") %>

test:
  <<: *default
  database: auth_service_test

production:
  primary: &primary_production
    <<: *default
    database: auth_service_production
    username: auth_service
    password: <%= ENV["AUTH_SERVICE_DATABASE_PASSWORD"] %>
  cache:
    <<: *primary_production
    database: auth_service_production_cache
    migrations_paths: db/cache_migrate
  queue:
    <<: *primary_production
    database: auth_service_production_queue
    migrations_paths: db/queue_migrate
  cable:
    <<: *primary_production
    database: auth_service_production_cable
    migrations_paths: db/cable_migrate

```

```
bundle exec rails db:create

bundle exec rails s
```

✅ Features to Include

User Registration

User Login with JWT

Authenticated User Info (Profile)

Token-based Auth with Authorization: Bearer <token>

Basic validations and error handling

🚀 Gems to Add to Gemfile

```
# Gemfile

gem 'bcrypt', '~> 3.1.7'
gem 'jwt'

```

run 

```
bundle install

```

🏗️ Generate User Model and Controller

```
rails g model User name:string email:string password_digest:string
rails g controller Api::V1::Auth

```
update app/models/user.rb

Then run:

```
rails db:migrate
```

```
ruby -rsecurerandom -e 'puts SecureRandom.hex(64)'

```

```
EDITOR="nano" rails credentials:edit
```

update app/controllers/api/v1/auth_controller.rb
app/controllers/application_controller.rb
app/lib/json_web_token.rb
config/routes.rb


for logs similar to python print as "Rails.logger.info("Decoded token: #{decoded}")"



incase no db required

bundle exec rails new . --api --skip-active-record --skip-bundle


* frontend
```
rails new frontend_service --css=tailwind

bin/dev
```

docker-compose --env-file .env up --build -d


* will automate it later 
```
bundle lock --add-platform x86_64-linux

docker-compose exec auth_service bundle exec rails db:create db:migrate

```
