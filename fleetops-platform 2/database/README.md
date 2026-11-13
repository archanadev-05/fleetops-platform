# Migrations

Every change to the database structure after `schema.sql` goes here as a numbered file:

    002_add_tyre_size_to_vehicles.sql
    003_create_parts_table.sql

Rules
1. Back up first (MySQL Workbench: Server > Data Export).
2. One change set per file; run files in numeric order.
3. Never edit a migration that has already been applied: add a new one.
4. Commit the file together with the code that needs it.
