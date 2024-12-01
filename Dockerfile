# Base image
FROM ruby:3.1.2-slim

# Set environment variables
ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/bundle \
    GEM_HOME=/bundle \
    PATH=/app/bin:/bundle/bin:$PATH

# Install necessary packages
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the application code
COPY . ./

# Precompile assets
RUN bundle exec rake assets:precompile

# Expose the default Rails port
EXPOSE 3000

# Command to start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]

