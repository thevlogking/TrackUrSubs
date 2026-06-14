package utils;

import dao.PersistentLoginDAO;
import dao.UserDAO;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Base64;

public final class PersistentLoginUtil {

    private static final String COOKIE_NAME = "trackursubs_login";
    private static final int COOKIE_MAX_AGE = 10 * 365 * 24 * 60 * 60;
    private static final SecureRandom RANDOM = new SecureRandom();

    private PersistentLoginUtil() {
    }

    public static void remember(
            HttpServletRequest request,
            HttpServletResponse response,
            long userId)
            throws SQLException {

        String oldToken = getCookieValue(request);

        if (oldToken != null) {
            new PersistentLoginDAO().delete(hash(oldToken));
        }

        byte[] tokenBytes = new byte[32];
        RANDOM.nextBytes(tokenBytes);

        String token = Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(tokenBytes);

        long expiresAt =
                System.currentTimeMillis()
                + (COOKIE_MAX_AGE * 1000L);

        new PersistentLoginDAO().save(
                hash(token),
                userId,
                new Timestamp(expiresAt)
        );

        response.addCookie(createCookie(
                request,
                token,
                COOKIE_MAX_AGE
        ));
    }

    public static User restoreUser(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException {

        String token = getCookieValue(request);

        if (token == null) {
            return null;
        }

        PersistentLoginDAO loginDAO =
                new PersistentLoginDAO();

        Long userId =
                loginDAO.findUserId(hash(token));

        if (userId == null) {
            clearCookie(request, response);
            return null;
        }

        User user =
                new UserDAO().findById(userId);

        if (user == null
                || "suspended".equalsIgnoreCase(
                        user.getAccountStatus())) {

            loginDAO.delete(hash(token));
            clearCookie(request, response);
            return null;
        }

        return user;
    }

    public static void forget(
            HttpServletRequest request,
            HttpServletResponse response)
            throws SQLException {

        String token = getCookieValue(request);

        try {
            if (token != null) {
                new PersistentLoginDAO().delete(hash(token));
            }
        } finally {
            clearCookie(request, response);
        }
    }

    private static Cookie createCookie(
            HttpServletRequest request,
            String value,
            int maxAge) {

        Cookie cookie =
                new Cookie(COOKIE_NAME, value);

        String contextPath =
                request.getContextPath();

        cookie.setPath(
                contextPath == null
                || contextPath.isEmpty()
                        ? "/"
                        : contextPath
        );

        cookie.setHttpOnly(true);
        cookie.setSecure(request.isSecure());
        cookie.setMaxAge(maxAge);
        cookie.setAttribute("SameSite", "Lax");

        return cookie;
    }

    private static void clearCookie(
            HttpServletRequest request,
            HttpServletResponse response) {

        response.addCookie(createCookie(
                request,
                "",
                0
        ));
    }

    private static String getCookieValue(
            HttpServletRequest request) {

        Cookie[] cookies = request.getCookies();

        if (cookies == null) {
            return null;
        }

        for (Cookie cookie : cookies) {
            if (COOKIE_NAME.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }

        return null;
    }

    private static String hash(String token) {

        try {
            MessageDigest digest =
                    MessageDigest.getInstance("SHA-256");

            byte[] hash =
                    digest.digest(
                            token.getBytes(
                                    StandardCharsets.UTF_8
                            )
                    );

            StringBuilder result =
                    new StringBuilder(hash.length * 2);

            for (byte value : hash) {
                result.append(
                        String.format("%02x", value)
                );
            }

            return result.toString();

        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException(
                    "SHA-256 is not available",
                    exception
            );
        }
    }
}
