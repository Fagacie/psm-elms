import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.Properties;

public class ApplyDbFixes {
    public static void main(String[] args) throws Exception {
        String propsPath = "src/conf/db.properties";
        Properties props = new Properties();
        try (FileInputStream in = new FileInputStream(propsPath)) {
            props.load(in);
        }

        String url = props.getProperty("db.url");
        String user = props.getProperty("db.username");
        String pass = props.getProperty("db.password", "");
        String passOverride = System.getProperty("db.password.override");
        if (passOverride != null) {
            pass = passOverride;
        }

        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement st = conn.createStatement()) {

            st.executeUpdate("CREATE TABLE IF NOT EXISTS InstructorApplication ("
                + "ApplicationID INT AUTO_INCREMENT PRIMARY KEY,"
                + "FullName VARCHAR(100) NOT NULL,"
                + "Email VARCHAR(150) NOT NULL,"
                + "Phone VARCHAR(30) NOT NULL,"
                + "Specialization VARCHAR(150) NOT NULL,"
                + "YearsOfExperience INT NULL,"
                + "Qualification VARCHAR(150) NOT NULL,"
                + "CoverMessage TEXT NULL,"
                + "CvPath VARCHAR(1024) NOT NULL,"
                + "Status ENUM('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',"
                + "ReviewedBy INT NULL,"
                + "ReviewedAt TIMESTAMP NULL DEFAULT NULL,"
                + "AdminNotes TEXT NULL,"
                + "CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                + "KEY idx_instructor_application_email (Email),"
                + "KEY idx_instructor_application_status (Status),"
                + "CONSTRAINT fk_instructor_application_reviewer FOREIGN KEY (ReviewedBy) REFERENCES User(UserID) ON DELETE SET NULL ON UPDATE CASCADE"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            st.executeUpdate("CREATE TABLE IF NOT EXISTS Notification ("
                    + "NotificationID INT AUTO_INCREMENT PRIMARY KEY,"
                    + "RecipientUserID INT NULL,"
                    + "RecipientEmail VARCHAR(150) NULL,"
                    + "RecipientName VARCHAR(100) NULL,"
                    + "Title VARCHAR(200) NOT NULL,"
                    + "Message TEXT NOT NULL,"
                    + "NotificationType VARCHAR(80) NOT NULL,"
                    + "RelatedEntityType VARCHAR(80) NULL,"
                    + "RelatedEntityID INT NULL,"
                    + "Channel VARCHAR(20) NOT NULL DEFAULT 'InApp',"
                    + "IsRead TINYINT(1) NOT NULL DEFAULT 0,"
                    + "ReadAt TIMESTAMP NULL DEFAULT NULL,"
                    + "CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,"
                    + "KEY idx_notification_recipient_user (RecipientUserID),"
                    + "KEY idx_notification_recipient_email (RecipientEmail),"
                    + "KEY idx_notification_read (IsRead),"
                    + "KEY idx_notification_related (RelatedEntityType, RelatedEntityID),"
                    + "CONSTRAINT fk_notification_recipient_user FOREIGN KEY (RecipientUserID) REFERENCES User(UserID) ON DELETE SET NULL ON UPDATE CASCADE"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            st.executeUpdate("ALTER TABLE InstructorApplication MODIFY COLUMN CvPath VARCHAR(1024) NOT NULL");

            System.out.println("DB migration applied successfully.");
        }
    }
}
