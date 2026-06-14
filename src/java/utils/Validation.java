package utils;

public class Validation {

    public static boolean isValidEmail(String email) {
        // Simple placeholder validation
        return email != null && email.contains("@");
    }

    public static boolean isNonEmpty(String s) {
        return s != null && !s.trim().isEmpty();
    }
}

