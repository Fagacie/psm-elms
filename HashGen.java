import com.psm.elearning.util.PasswordUtil;

public class HashGen {
    public static void main(String[] args) {
        System.out.println(PasswordUtil.hashPassword("password123"));
    }
}
