#!/bin/bash

set -e

DB_NAME=${DB_NAME:-your_database_name}
CHANGELOG_SCHEMA=${CHANGELOG_SCHEMA:-changelog}
TRIGGER_FUNCTION="log_changes"

create_changelog_for_table() {
    local schema_table=$1
    local schema=$(echo $schema_table | cut -d '.' -f 1)
    local table=$(echo $schema_table | cut -d '.' -f 2)

    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
    DROP TRIGGER IF EXISTS trg_log_${schema}_${table}_changes ON ${schema_table};

    CREATE TRIGGER trg_log_${schema}_${table}_changes
    AFTER INSERT OR UPDATE OR DELETE ON $schema_table
    FOR EACH ROW EXECUTE PROCEDURE $CHANGELOG_SCHEMA.$TRIGGER_FUNCTION();"
    echo "Trigger created for table: $schema_table"
}

create_changelog_for_schema() {
    local schema=$1
    tables=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = '$schema';")
    for table in $tables; do
        create_changelog_for_table "$schema.$table"
    done
    echo "Triggers created for all tables in schema: $schema"
}

create_changelog_for_tables_env() {
    IFS=',' read -ra ADDR <<< "$TABLES"
    for table in "${ADDR[@]}"; do
        create_changelog_for_table "$table"
    done
}

show_help() {
    echo "Usage: ./manage_changelog.sh create_changelog --tables table1 table2 ... | --schema schema1 schema2 ... | --envtables"
}

main() {
    if [[ "$#" -lt 2 ]]; then
        show_help
        exit 1
    fi

    local command=$1
    shift

    case $command in
        create_changelog)
            local option=$1
            shift
            case $option in
                --tables)
                    for table in "$@"; do
                        create_changelog_for_table "$table"
                    done
                    ;;
                --envtables)
                    create_changelog_for_tables_env
                    ;;
                --schema)
                    for schema in "$@"; do
                        create_changelog_for_schema "$schema"
                    done
                    ;;
                *)
                    echo "OPTION: $option"
                    show_help
                    exit 1
                    ;;
            esac
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

main "$@"
