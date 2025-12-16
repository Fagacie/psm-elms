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
- If you already have data, the script won’t drop tables; it only creates missing ones and adds the `RegNumber` unique index.
- Ensure your app DB config (`db.properties`) points to `psm_elearning`.
