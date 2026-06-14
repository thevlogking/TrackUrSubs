package utils;

public class GoogleConfig {

    public static final String CLIENT_ID =
    System.getenv("GOOGLE_CLIENT_ID");

    public static final String CLIENT_SECRET =
    System.getenv("GOOGLE_CLIENT_SECRET");

    public static final String REDIRECT_URI =
    System.getenv("GOOGLE_REDIRECT_URI");

}