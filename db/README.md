# Database Schema Management

Store your database schema here and version control it alongside the app. Edit `schema.sql` as your source of truth.

## Apply the schema

You can use either phpMyAdmin (Import) or the MySQL CLI.

### Option A: phpMyAdmin
1. Open phpMyAdmin.
2. Select (or create) the database `psm_elearning`.
3. Go to Import.
4. Choose `db/schema.sql` from this project and execute.

### Option B: MySQL CLI (Windows PowerShell)
Make sure `mysql.exe` is on PATH (from XAMPP or MySQL installation).

```
# If XAMPP, adjust the path to mysql.exe as needed
# This will create the DB (if missing) and create/alter tables
mysql -u root -p < "c:\Users\ACER\Desktop\FYP\elearning\PSME\db\schema.sql"
```

## Notes
- The script uses `CREATE TABLE IF NOT EXISTS` and creates the unique index on `Student.RegNumber`.
- Column names match the Java DAO code exactly (e.g., `UserID`, `RegNumber`, `RegistrationDate`).
- If you already have data, the script won't drop tables; it only creates missing ones and adds the `RegNumber` unique index.
- Ensure your app DB config (`db.properties`) points to `psm_elearning`.
- During an Ant build, `db/schema.sql` is also packaged into the WAR so `AppInitializer` can apply it from the classpath at startup.

## Incremental migrations

If your environment already has data, use this order:

1. Apply `db/schema.sql` first (safe baseline).
2. Apply all incremental migrations using `db/migrations.sql`.
3. If needed, run only specific migration files from `db/` for targeted updates.

The bundled migration runner currently executes:

- `migration_align_schema.sql`
- `migration_admin_settings.sql`
- `migration_instructor_application_storage.sql`
- `migration_assessment_placement.sql`
- `migration_assessment_grading_mode.sql`
- `migration_assessment_submission_mode.sql`
- `migration_assessment_grade_audit.sql`
- `migration_paystack.sql`

How to run the full migration set:

```sql
SOURCE db/migrations.sql;
```

## Certificate eligibility test matrix

Use `db/certificate_eligibility_matrix.sql` to validate the certificate gate end-to-end using live state:
- payment confirmed,
- all materials viewed,
- all required assessments passed.

What it gives you:
- per-enrollment eligibility result (`READY`/`BLOCKED`),
- missing requirement list (`payment`, `materials`, `assessments`),
- matrix bucket classification for state combinations,
- anomaly detection (certificate exists for ineligible enrollment).

How to run:

```sql
SOURCE db/certificate_eligibility_matrix.sql;
```

Optional scoping (inside the script):
- set `@target_enrollment_id` to validate one enrollment,
- set `@target_user_id` to validate one student.
