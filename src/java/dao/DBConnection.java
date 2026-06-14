package dao;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

   private static final String URL =
"jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/trackursubs?sslMode=REQUIRED&connectionTimeZone=LOCAL";

    private static final String USER =
        "hbAWn6HuPdE5LM5.root";

    private static final String PASSWORD =
        "6X31b9vMqeMLHGxN";

    public static Connection getConnection() {

        try {

            Class.forName(
                "com.mysql.cj.jdbc.Driver"
            );

            return DriverManager.getConnection(
                URL,
                USER,
                PASSWORD
            );

        } catch(Exception e) {

            e.printStackTrace();
        }

        return null;
    }
}