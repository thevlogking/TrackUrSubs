package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ReminderDAO {

    public boolean alreadySent(
            int subscriptionId,
            String reminderType) {

        String sql =

        "SELECT 1 " +

        "FROM renewal_notifications " +

        "WHERE subscription_id=? " +

        "AND reminder_type=?";

        try(

            Connection conn =
            DBConnection.getConnection();

            PreparedStatement ps =
            conn.prepareStatement(sql)

        ){

            ps.setInt(
            1,
            subscriptionId);

            ps.setString(
            2,
            reminderType);

            ResultSet rs =
            ps.executeQuery();

            return rs.next();

        }catch(Exception e){

            e.printStackTrace();
        }

        return false;
    }

    public void markSent(
            int subscriptionId,
            String reminderType) {

        String sql =

        "INSERT INTO renewal_notifications" +

        "(subscription_id,reminder_type) " +

        "VALUES(?,?)";

        try(

            Connection conn =
            DBConnection.getConnection();

            PreparedStatement ps =
            conn.prepareStatement(sql)

        ){

            ps.setInt(
            1,
            subscriptionId);

            ps.setString(
            2,
            reminderType);

            ps.executeUpdate();

        }catch(Exception e){

            e.printStackTrace();
        }
    }
}