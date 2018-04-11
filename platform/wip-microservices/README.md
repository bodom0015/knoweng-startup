# WIP - KnowEnG Platform Microservices
An attempt at running the KnowEnG Platform as a set of distributed microservices

# Blockers
The biggest blocker here seemed to be the implicit assumption within our SQLAlchemy configuration that the Postgres database would always run on `localhost`.

This prevents us from splitting the current monolithic pods out into smaller pieces.
