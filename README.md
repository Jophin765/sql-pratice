# SQL Practice (MySQL / MariaDB)

Hands-on SQL practice covering database design, querying, transactions and joins.
All data is fictional. Scripts were tested on MariaDB, which is MySQL-compatible.

## Files

| File | Database | What it covers |
|------|----------|----------------|
| `01_course_management.sql` | `course_management` | CREATE, ALTER (add, drop, modify, rename), UPDATE, WHERE with AND / OR / NOT / BETWEEN / IN / LIKE / IS NULL, DISTINCT, aliases, ORDER BY, LIMIT / OFFSET |
| `02_hospital_db.sql` | `hospital_db` | PRIMARY KEY, AUTO_INCREMENT, NOT NULL, UNIQUE, DEFAULT, CHECK and FOREIGN KEY constraints, plus tests of each constraint error |
| `03_food_delivery.sql` | `food_delivery` | Aggregate functions, GROUP BY / HAVING, CASE, transactions (COMMIT, ROLLBACK, SAVEPOINT), INNER / LEFT / RIGHT / FULL joins, UNION / UNION ALL, EXISTS, TRUNCATE / DROP |

## How to run

```bash
mysql -u root -p < 01_course_management.sql
mysql -u root -p < 02_hospital_db.sql
mysql -u root -p < 03_food_delivery.sql
```

Each script creates its own database. Statements that are meant to fail
(constraint tests) are commented out. Uncomment them one at a time to see the error.

## Skills demonstrated

- Database and table design with constraints
- Filtering, sorting and pattern matching
- Aggregation and grouping
- Transactions and savepoints
- Joins and set operations
- Subqueries with EXISTS
