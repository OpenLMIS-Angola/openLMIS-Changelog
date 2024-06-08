# Project Changelog

This project provides a Dockerized solution for capturing incremental data changes in a PostgreSQL database using a changelog mechanism. The changelog setup captures changes (INSERT, UPDATE, DELETE) in specified tables and stores them in a dedicated schema, making it easier to sync data with an external data warehouse.

## Table of Contents

- [Project Changelog](#project-changelog)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Setup](#setup)
    - [Environment Variables](#environment-variables)
    - [Directory Structure](#directory-structure)
  - [Usage](#usage)
    - [Building the Docker Image](#building-the-docker-image)
    - [Running the Changelog Setup](#running-the-changelog-setup)
  - [Scripts](#scripts)
  - [Contributing](#contributing)
  - [License](#license)

## Features

- Captures incremental changes in specified tables
- Stores change in a dedicated schema and table
- Easy configuration using environment variables
- Automated setup using Docker and Docker Compose

## Requirements

- Docker
- Docker Compose
- PostgreSQL

## Setup

1. Clone the repository:

```sh
git clone https://github.com/yourusername/project_changelog.git
cd project_changelog
```

2. Create and configure the environment variables files:
    - `changelog.env`: Contains the database connection details.
    - `settings.env`: Contains the list of tables to track and additional configurations.

### Environment Variables

Create `changelog.env` with the following content:

```env
DB_HOST=db
DB_PORT=5432
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_database_name
CHANGELOG_SCHEMA=changelog
DB_TIMEOUT=300  # Timeout in seconds, default to 5 minutes
```

Create `settings.env` with the following content:

```env
TABLES='facilities,geographic_levels,geographic_zones,lots,orders,order_line_items,orderables,orderable_children,orderable_display_categories,orderable_identifiers,orderable_units_assignment,programs,program_orderables,proofs_of_delivery,proof_of_delivery_line_items,requisitions,requisition_line_items,stock_cards,stock_card_line_items,stock_events,stock_event_line_items,physical_inventory_line_items,users'
```

### Directory Structure

Ensure your directory structure looks like this:

```
project_changelog/
├── Dockerfile
├── entrypoint.sh
├── create_changelog.sql
└── manage_changelog.sh
├── changelog.env
└── settings.env
```

## Usage

### Building the Docker Image

Build the Docker image using the following command:

```sh
docker build -t project_changelog:latest .
```

### Running the Changelog Setup

Use Docker Compose to run the changelog setup:

```sh
docker-compose up
```

This will:
- Wait for the PostgreSQL service to be ready.
- Create the changelog schema and table.
- Create triggers on the specified tables to capture changes.

## Scripts

- `manage_changelog.sh`: Script to create triggers on specified tables or schemas.
- `entrypoint.sh`: entry point script to wait for PostgreSQL readiness and execute the SQL script to create the changelog schema and table.
- `create_changelog.sql`: SQL script to create the changelog schema and table.
