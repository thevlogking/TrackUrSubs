package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class PersistentLoginDAO {

    private static volatile boolean tableReady;

    private void ensureTable() throws SQLException {

        if (tableReady) {
            return;
        }

        synchronized (PersistentLoginDAO.class) {

            if (tableReady) {
                return;
            }

            String sql =
                    "CREATE TABLE IF NOT EXISTS user_session (" +
                    "token_hash CHAR(64) PRIMARY KEY, " +
                    "user_id BIGINT NOT NULL, " +
                    "expires_at TIMESTAMP NOT NULL, " +
                    "created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, " +
                    "INDEX idx_user_session_user_id (user_id), " +
                    "INDEX idx_user_session_expires_at (expires_at)" +
                    ")";

            try (
                    Connection connection = DBConnection.getConnection();
                    PreparedStatement statement = connection.prepareStatement(sql)
            ) {
                statement.execute();
                tableReady = true;
            }
        }
    }

    public void save(
            String tokenHash,
            long userId,
            Timestamp expiresAt)
            throws SQLException {

        ensureTable();

        String sql =
                "INSERT INTO user_session " +
                "(token_hash, user_id, expires_at) VALUES (?, ?, ?)";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, tokenHash);
            statement.setLong(2, userId);
            statement.setTimestamp(3, expiresAt);
            statement.executeUpdate();
        }
    }

    public Long findUserId(String tokenHash)
            throws SQLException {

        ensureTable();

        String sql =
                "SELECT user_id FROM user_session " +
                "WHERE token_hash = ? AND expires_at > CURRENT_TIMESTAMP";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, tokenHash);

            try (ResultSet result = statement.executeQuery()) {
                return result.next()
                        ? result.getLong("user_id")
                        : null;
            }
        }
    }

    public void delete(String tokenHash)
            throws SQLException {

        ensureTable();

        String sql =
                "DELETE FROM user_session WHERE token_hash = ?";

        try (
                Connection connection = DBConnection.getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, tokenHash);
            statement.executeUpdate();
        }
    }
}
