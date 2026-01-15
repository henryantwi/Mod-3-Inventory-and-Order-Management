# MySQL Query Logs

This directory contains MySQL query logs from the Docker container.

## Log Files

- **general.log** - Contains all SQL queries executed against the database
- **slow.log** - Contains queries that exceed the `LONG_QUERY_TIME` threshold (currently set to 0, so all queries are logged)

## Configuration

Logging is enabled via environment variables in `docker-compose.yml`:
- `GENERAL_LOG=1` - Enables general query log
- `SLOW_QUERY_LOG=1` - Enables slow query log
- `LONG_QUERY_TIME=0` - Logs all queries (set to a number in seconds to only log slow queries)