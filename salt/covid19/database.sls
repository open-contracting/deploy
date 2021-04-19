# Databases

covid19:
  postgres_database.present:
    - name: covid19
    - owner: postgres
    - require:
      - service: postgresql

# GRANT privileges
# https://www.postgresql.org/docs/11/sql-grant.html
# https://www.postgresql.org/docs/11/ddl-priv.html

grant covid19 schema privileges:
  postgres_privileges.present:
    - name: covid19
    - privileges:
      - ALL
    - object_type: schema
    - object_name: public
    - maintenance_db: covid19
    - require:
      - postgres_user: sql-user-covid19
      - postgres_database: covid19

grant covid19 table privileges:
  postgres_privileges.present:
    - name: covid19
    - privileges:
      - ALL
    - object_type: table
    - object_name: ALL
    - maintenance_db: covid19
    - require:
      - postgres_user: sql-user-covid19
      - postgres_database: covid19
