# Use an official PostgreSQL image as a parent image
FROM postgres:latest

# Install bash and wait-for-it
RUN apt-get update && apt-get install -y bash curl

# Create app directory and set as working directory
RUN mkdir /app
WORKDIR /app

# Add the manage_changelog.sh script to the container
COPY manage_changelog.sh ./manage_changelog.sh
RUN chmod +x ./manage_changelog.sh

# Add the entrypoint script to the container
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Add the create_changelog.sql script to the container
COPY create_changelog.sql ./create_changelog.sql

ENTRYPOINT ["./entrypoint.sh"]
