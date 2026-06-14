package dao;

import model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    /* ======================
       CREATE USER
       ====================== */

    public boolean createUser(User user)
    throws SQLException {

        String sql =
"INSERT INTO users(full_name,email,password_hash,profile_picture,created_at,updated_at) VALUES(?,?,?,?,?,?)";
        try(

            Connection con =
            DBConnection.getConnection();

            PreparedStatement ps =
            con.prepareStatement(sql)

        ){

            ps.setString(
            1,
            user.getFullName()
            );

            ps.setString(
            2,
            user.getEmail()
            );

            ps.setString(
            3,
            user.getPasswordHash()
            );

            ps.setString(
            4,
            user.getProfilePicture()
            );
            java.sql.Timestamp now =
new java.sql.Timestamp(
System.currentTimeMillis()
);

ps.setTimestamp(
5,
now
);

ps.setTimestamp(
6,
now
);

            return ps.executeUpdate() > 0;
            

        }

    }

    /* ======================
       FIND USER BY EMAIL
       ====================== */

    public User findByEmail(String email)
    throws SQLException {

        String sql =
        "SELECT * FROM users WHERE email=?";

        try(

            Connection con =
            DBConnection.getConnection();

            PreparedStatement ps =
            con.prepareStatement(sql)

        ){

            ps.setString(
            1,
            email
            );

            try(

                ResultSet rs =
                ps.executeQuery()

            ){

                if(rs.next()){

                    User user =
                    new User();

                    user.setUserId(
                    rs.getLong(
                    "user_id"
                    ));

                    user.setFullName(
                    rs.getString(
                    "full_name"
                    ));

                    user.setEmail(
                    rs.getString(
                    "email"
                    ));

                    user.setPasswordHash(
                    rs.getString(
                    "password_hash"
                    ));

                    user.setProfilePicture(
                    rs.getString(
                    "profile_picture"
                    ));

                    user.setAccountStatus(
                    rs.getString(
                    "account_status"
                    ));

                    user.setGoogleId(
rs.getString(
"google_id"
));

                    user.setLastLogin(
                    rs.getTimestamp(
                    "last_login"
                    ));

                    user.setCreatedAt(
                    rs.getTimestamp(
                    "created_at"
                    ));

                    user.setUpdatedAt(
                    rs.getTimestamp(
                    "updated_at"
                    ));

                    return user;

                }

            }

        }

        return null;

    }

    public User findById(long userId)
    throws SQLException {

        String sql =
        "SELECT * FROM users WHERE user_id=?";

        try(

            Connection con =
            DBConnection.getConnection();

            PreparedStatement ps =
            con.prepareStatement(sql)

        ){

            ps.setLong(
            1,
            userId
            );

            try(

                ResultSet rs =
                ps.executeQuery()

            ){

                if(rs.next()){

                    User user =
                    new User();

                    user.setUserId(
                    rs.getLong(
                    "user_id"
                    ));

                    user.setFullName(
                    rs.getString(
                    "full_name"
                    ));

                    user.setEmail(
                    rs.getString(
                    "email"
                    ));

                    user.setPasswordHash(
                    rs.getString(
                    "password_hash"
                    ));

                    user.setProfilePicture(
                    rs.getString(
                    "profile_picture"
                    ));

                    user.setAccountStatus(
                    rs.getString(
                    "account_status"
                    ));

                    user.setGoogleId(
                    rs.getString(
                    "google_id"
                    ));

                    user.setLastLogin(
                    rs.getTimestamp(
                    "last_login"
                    ));

                    user.setCreatedAt(
                    rs.getTimestamp(
                    "created_at"
                    ));

                    user.setUpdatedAt(
                    rs.getTimestamp(
                    "updated_at"
                    ));

                    return user;

                }

            }

        }

        return null;

    }

    /* ======================
       UPDATE USER
       ====================== */

    public boolean updateUser(User user)
throws SQLException {

    String sql =

    "UPDATE users SET full_name=?, password_hash=?, profile_picture=?, updated_at=? WHERE user_id=?";

    try(

        Connection con =
        DBConnection.getConnection();

        PreparedStatement ps =
        con.prepareStatement(sql)

    ){

        ps.setString(
        1,
        user.getFullName()
        );

        ps.setString(
        2,
        user.getPasswordHash()
        );

        ps.setString(
        3,
        user.getProfilePicture()
        );

        java.sql.Timestamp currentTime =
        new java.sql.Timestamp(
        System.currentTimeMillis()
        );

        ps.setTimestamp(
        4,
        currentTime
        );

        ps.setLong(
        5,
        user.getUserId()
        );

        return ps.executeUpdate() > 0;

    }

}


/* ======================
   UPDATE LAST LOGIN
   ====================== */

public void updateLastLogin(long userId)
throws SQLException {

    java.sql.Timestamp currentTime =
    new java.sql.Timestamp(
    System.currentTimeMillis()
    );

    try(

        Connection con =
        DBConnection.getConnection()

    ){

        /* Update users table */

        String userSql =
        "UPDATE users " +
        "SET last_login = ?, " +
        "updated_at = ? " +
        "WHERE user_id = ?";

        PreparedStatement userPs =
        con.prepareStatement(userSql);

        userPs.setTimestamp(
        1,
        currentTime
        );

        userPs.setTimestamp(
        2,
        currentTime
        );

        userPs.setLong(
        3,
        userId
        );

        userPs.executeUpdate();

        /* Update user_subscriptions table */

        String subSql =
        "UPDATE user_subscriptions " +
        "SET last_login = ? " +
        "WHERE user_id = ?";

        PreparedStatement subPs =
        con.prepareStatement(subSql);

        subPs.setTimestamp(
        1,
        currentTime
        );

        subPs.setLong(
        2,
        userId
        );

        subPs.executeUpdate();

    }

}
public boolean createGoogleUser(
        String fullName,
        String email,
        String picture,
        String googleId)
throws SQLException {

    String sql =
    "INSERT INTO users(" +
    "full_name," +
    "email," +
    "password_hash," +
    "profile_picture," +
    "google_id," +
    "auth_provider," +
    "account_status," +
    "created_at," +
    "updated_at" +
    ") VALUES(?,?,?,?,?,?,?,?,?)";

    try(

        Connection con =
        DBConnection.getConnection();

        PreparedStatement ps =
        con.prepareStatement(sql)

    ){

        java.sql.Timestamp now =
        new java.sql.Timestamp(
        System.currentTimeMillis()
        );

        ps.setString(
        1,
        fullName
        );

        ps.setString(
        2,
        email
        );

        ps.setString(
        3,
        ""
        );

        ps.setString(
        4,
        picture
        );

        ps.setString(
        5,
        googleId
        );

        ps.setString(
        6,
        "GOOGLE"
        );

        ps.setString(
        7,
        "Active"
        );

        ps.setTimestamp(
        8,
        now
        );

        ps.setTimestamp(
        9,
        now
        );

        return ps.executeUpdate() > 0;

    }

}
public String getEmailByUserId(long userId)
throws SQLException {

    String sql =
    "SELECT email FROM users WHERE user_id=?";

    try(

        Connection con =
        DBConnection.getConnection();

        PreparedStatement ps =
        con.prepareStatement(sql)

    ){

        ps.setLong(
        1,
        userId
        );

        ResultSet rs =
        ps.executeQuery();

        if(rs.next()){

            return rs.getString(
            "email"
            );
        }

    }

    return null;
}

}
