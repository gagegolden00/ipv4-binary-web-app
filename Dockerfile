# Use the official Ruby image with the desired version as a base image
FROM ruby:3.2.2

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Copy the application code into the container
COPY . .

# Expose port 6969 custom for Rails
EXPOSE 6969

# Start the Rails application
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "6969"]

