# Project Changelog

This project provides a Dockerized solution for capturing incremental data changes in a PostgreSQL database using a changelog mechanism. The changelog setup captures changes (INSERT, UPDATE, DELETE) in specified tables and stores them in a dedicated schema, making it easier to sync data with an external data warehouse.

It's meant to be used as a service complementing the openLMIS Instance and requires existing database definition. 

## Table of Contents

- [Project Changelog](#project-changelog)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Setup](#setup)
  - [Usage](#usage)
  - [Scripts](#scripts)

## Features

- Captures incremental changes in specified tables
- Stores change in a dedicated schema and table
- Easy configuration using environment variables
- Automated setup using Docker and Docker Compose

## Setup

1. Clone the repository:

```sh
git clone https://github.com/OpenLMIS-Angola/openLMIS-Changelog
cd openLMIS-Changelog
```

2. Configure .env file  

### Environment Variables

Create `.env` with the following content:

```env
DB_HOST=db
DB_PORT=5432
DB_USER=your_db_user
PGPASSWORD=your_db_password
DB_NAME=your_database_name
CHANGELOG_SCHEMA=changelog
DB_TIMEOUT=300  # Timeout in seconds, default to 5 minutes
```

Optional .env variable with predefined changelog tables:

```env
TABLES='referencedata.facilities,referencedata.geographic_levels,referencedata.geographic_zones,referencedata.lots,fulfillment.orders,fulfillment.order_line_items,referencedata.orderables,referencedata.orderable_children,referencedata.orderable_display_categories,referencedata.orderable_identifiers,referencedata.orderable_units_assignment,referencedata.programs,referencedata.program_orderables,fulfillment.proofs_of_delivery,fulfillment.proof_of_delivery_line_items,requisition.requisitions,requisition.requisition_line_items,stockmanagement.stock_cards,stockmanagement.stock_card_line_items,stockmanagement.stock_events,stockmanagement.stock_event_line_items,stockmanagement.physical_inventory_line_items,referencedata.users,referencedata.supported_programs'

```

### Building the Docker Image

Build the Docker image using the following command:

```sh
docker build -t openLMIS-Changelog:latest .
```

## Usage

Add service to existing openLMIS docker-compose.yml. 
Ensure that env_file is pointing to the created valid .env file. 
Add command for creating changelog

Example: 

```yml
  changelog-configuration:
    image: openLMIS-Changelog:latest
    env_file:
      - ./.env
    depends_on:
      - db
    command: ["./manage_changelog.sh", "create_changelog", "--envtables"]
```

#### Commands 
- `["./manage_changelog.sh", "create_changelog", "--envtables"]` - create changelog for tables defined in `.env`.

- `["./manage_changelog.sh", "create_changelog", "--tables", "schema1.table1 schema2.table2 schema1.table3]` - create changelog for explicitly provided tables.

- `["./manage_changelog.sh", "create_changelog", "--schema", "schema1 schema2"]` - create changelog for all tables in provided schemas. 


### Running the Changelog Setup

This will:
- Wait for the PostgreSQL service to be ready.
- Create the changelog schema and table.
- Create triggers on the specified tables to capture changes.

Warning: Changing the command will not erase previously created change log triggers. 

## Scripts

- `manage_changelog.sh`: Script to create triggers on specified tables or schemas.
- `entrypoint.sh`: entry point script to wait for PostgreSQL readiness and execute the SQL script to create the changelog schema and table.
- `create_changelog.sql`: SQL script to create the changelog schema and table.
