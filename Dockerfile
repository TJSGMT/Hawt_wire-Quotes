# Stage 1 - Builder Image
FROM ruby:3.1.2-slim AS builder

# Install dependencies for Rails, Node.js, Yarn, PostgreSQL, and others
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  curl \
  && apt-get clean

# Install Node.js 14.x (compatible version)
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /myapp

# Copy Gemfile and Gemfile.lock and install gems
COPY Gemfile Gemfile.lock ./

# Install bundler, required gems, and rails
RUN gem install bundler:2.3.25 && \
    bundle install --jobs 4 --retry 3

# Copy the rest of the application code
COPY . .

# Install Yarn dependencies
RUN yarn install

# Precompile assets (this will trigger jsbundling)
RUN bundle exec rake assets:precompile

# Stage 2 - Final Image
FROM ruby:3.1.2-slim AS final

# Set working directory
WORKDIR /app

# Copy gems and precompiled assets from the builder stage
COPY --from=builder /myapp /app

# Expose port for Rails server
EXPOSE 3000

# Set environment variables (example for PostgreSQL and Rails secret key)
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Run migrations and start the server by default
CMD ["bash", "-c", "rails db:migrate && rails s -b '0.0.0.0'"]
