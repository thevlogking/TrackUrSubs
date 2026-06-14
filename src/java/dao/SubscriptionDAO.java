package dao;

import model.Subscription;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.List;

public class SubscriptionDAO {

    /* =========================
       ADD SUBSCRIPTION
       ========================= */

    public boolean addSubscription(
            Subscription sub) {

        boolean inserted = false;

        String sql =

        "INSERT INTO user_subscriptions " +

        "(user_id, subscription_name, " +

        "plan_name, amount, billing_cycle, " +

        "next_renewal_date, last_used_date, " +

        "status, last_login, created_at, updated_at) " +

        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try(

            Connection conn =
            DBConnection.getConnection();

            PreparedStatement ps =
            conn.prepareStatement(sql)

        ){

            java.sql.Timestamp currentTime =
            new java.sql.Timestamp(
            System.currentTimeMillis());

            ps.setLong(1,
                    sub.getUserId());

            ps.setString(2,
                    sub.getSubscriptionName());

            ps.setString(3,
                    sub.getPlanName());

            ps.setDouble(4,
                    sub.getAmount());

            ps.setString(5,
                    sub.getBillingCycle());

            ps.setDate(6,
                    sub.getRenewalDate());

            ps.setDate(7,
                    sub.getLastUsedDate());

            ps.setString(8,
                    sub.getStatus());

            ps.setTimestamp(9,
                    currentTime);

            ps.setTimestamp(10,
                    currentTime);

            ps.setTimestamp(11,
                    currentTime);

            inserted =
            ps.executeUpdate() > 0;
            
            if(inserted){

    String analyticsSql =

    "INSERT INTO analytics " +

    "(subscription_id,user_id,subscription_name," +

    "amount,updated_at,last_used_date) " +

    "SELECT subscription_id,user_id,subscription_name," +

    "amount,updated_at,last_used_date " +

    "FROM user_subscriptions " +

    "WHERE subscription_id=(" +

    "SELECT MAX(subscription_id) " +

    "FROM user_subscriptions" +

    ")";

    PreparedStatement analyticsPs =
    conn.prepareStatement(
    analyticsSql
    );

    analyticsPs.executeUpdate();

}
            
            

        }catch(Exception e){

            System.out.println(
            "ADD ERROR -> "
            + e.getMessage());

            e.printStackTrace();
        }

        return inserted;
    }

    /* =========================
       GET SUBSCRIPTIONS
       ========================= */

    public List<Subscription>
    getSubscriptionsByUserId(
            long userId){

        List<Subscription> list =
        new ArrayList<>();

        String sql =

        "SELECT * FROM user_subscriptions " +

        "WHERE user_id=? " +

        "ORDER BY next_renewal_date ASC";

        try(

            Connection conn =
            DBConnection.getConnection();

            PreparedStatement ps =
            conn.prepareStatement(sql)

        ){

            String statusSql =
            "UPDATE user_subscriptions " +
            "SET status=CASE " +
            "WHEN next_renewal_date<CURDATE() " +
            "THEN 'Expired' ELSE 'Active' END " +
            "WHERE user_id=? " +
            "AND next_renewal_date IS NOT NULL " +
            "AND (status IS NULL OR status<>CASE " +
            "WHEN next_renewal_date<CURDATE() " +
            "THEN 'Expired' ELSE 'Active' END)";

            try(PreparedStatement statusPs =
                    conn.prepareStatement(statusSql)){

                statusPs.setLong(1,userId);
                statusPs.executeUpdate();
            }

            ps.setLong(1,
                    userId);

            ResultSet rs =
            ps.executeQuery();

            while(rs.next()){

                Subscription sub =
                new Subscription();

                sub.setSubscriptionId(
                rs.getInt(
                "subscription_id"));

                sub.setUserId(
                rs.getLong(
                "user_id"));

                sub.setSubscriptionName(
                rs.getString(
                "subscription_name"));

                sub.setPlanName(
                rs.getString(
                "plan_name"));

                sub.setAmount(
                rs.getDouble(
                "amount"));

                sub.setBillingCycle(
                rs.getString(
                "billing_cycle"));

                sub.setRenewalDate(
                rs.getDate(
                "next_renewal_date"));

                sub.setLastUsedDate(
                rs.getDate(
                "last_used_date"));

                sub.setStatus(
                rs.getString(
                "status"));

                list.add(sub);
            }

        }catch(Exception e){

            e.printStackTrace();
        }

        return list;
    }

    /* =========================
       UPCOMING RENEWALS
       ========================= */

    public List<Subscription>
    getUpcomingRenewals(
            long userId){

        List<Subscription> list =
        new ArrayList<>();

        String sql =

        "SELECT * FROM user_subscriptions " +

        "WHERE user_id=? " +

        "AND next_renewal_date " +

        "BETWEEN CURDATE() " +

        "AND DATE_ADD(CURDATE(),INTERVAL 30 DAY) " +

        "ORDER BY next_renewal_date";

        try(

            Connection conn =
            DBConnection.getConnection();

            PreparedStatement ps =
            conn.prepareStatement(sql)

        ){

            ps.setLong(1,
                    userId);

            ResultSet rs =
            ps.executeQuery();

            while(rs.next()){

                Subscription sub =
                new Subscription();

                sub.setSubscriptionName(
                rs.getString(
                "subscription_name"));

                sub.setPlanName(
                rs.getString(
                "plan_name"));

                sub.setAmount(
                rs.getDouble(
                "amount"));

                sub.setBillingCycle(
                rs.getString(
                "billing_cycle"));

                sub.setRenewalDate(
                rs.getDate(
                "next_renewal_date"));

                list.add(sub);
            }

        }catch(Exception e){

            e.printStackTrace();
        }

        return list;
    }

    /* =========================
       MONTHLY SPEND
       Monthly + (Yearly/12)
       ========================= */

    public double getMonthlySpend(
            long userId){

        double total = 0;

        String sql =

        "SELECT amount,billing_cycle " +

        "FROM user_subscriptions " +

        "WHERE user_id=?";

        try(

            Connection conn =
            DBConnection.getConnection();

            PreparedStatement ps =
            conn.prepareStatement(sql)

        ){

            ps.setLong(1,userId);

            ResultSet rs =
            ps.executeQuery();

            while(rs.next()){

                double amount =
                rs.getDouble(
                "amount");

                String cycle =
                rs.getString(
                "billing_cycle");

                if(cycle.equalsIgnoreCase(
                        "Yearly")){

                    total +=
                    amount / 12;

                }else{

                    total += amount;
                }
            }

        }catch(Exception e){

            e.printStackTrace();
        }

        return total;
    }

    /* =========================
       YEARLY PROJECTION
       Yearly + Monthly*12
       ========================= */

    public double getYearlyProjection(
            long userId){

        double total = 0;

        String sql =

        "SELECT amount,billing_cycle " +

        "FROM user_subscriptions " +

        "WHERE user_id=?";

        try(

            Connection conn =
            DBConnection.getConnection();

            PreparedStatement ps =
            conn.prepareStatement(sql)

        ){

            ps.setLong(1,userId);

            ResultSet rs =
            ps.executeQuery();

            while(rs.next()){

                double amount =
                rs.getDouble(
                "amount");

                String cycle =
                rs.getString(
                "billing_cycle");

                if(cycle.equalsIgnoreCase(
                        "Monthly")){

                    total +=
                    amount * 12;

                }else{

                    total += amount;
                }
            }

        }catch(Exception e){

            e.printStackTrace();
        }

        return total;
    }

    /* =========================
       RENEWING THIS WEEK
       ========================= */

    public int renewingThisWeek(
            long userId){

        int total = 0;

        String sql =

        "SELECT COUNT(*) total " +

        "FROM user_subscriptions " +

        "WHERE user_id=? " +

        "AND next_renewal_date " +

        "BETWEEN CURDATE() " +

        "AND DATE_ADD(CURDATE(),INTERVAL 7 DAY)";

        try(

            Connection conn =
            DBConnection.getConnection();

            PreparedStatement ps =
            conn.prepareStatement(sql)

        ){

            ps.setLong(1,userId);

            ResultSet rs =
            ps.executeQuery();

            if(rs.next()){

                total =
                rs.getInt(
                "total");
            }

        }catch(Exception e){

            e.printStackTrace();
        }

        return total;
    }

    /* =========================
       AVG SPEND / SERVICE
       ========================= */

    public double avgSpendPerService(
            long userId){

        List<Subscription> list =
        getSubscriptionsByUserId(
        userId);

        if(list.isEmpty()){

            return 0;
        }

        return getMonthlySpend(
                userId)

                /

                list.size();
    }

    /* =========================
       TOP 3 HIGHEST PAID
       ========================= */

    public List<Subscription> getTopSubscriptions(
        long userId){

    List<Subscription> list =
    new ArrayList<>();

    String sql =

    "SELECT us.*, " +

    "COUNT(a.last_used_date) AS usage_count " +

    "FROM user_subscriptions us " +

    "LEFT JOIN analytics a " +

    "ON us.subscription_id = a.subscription_id " +

    "WHERE us.user_id=? " +

    "GROUP BY us.subscription_id " +

    "ORDER BY usage_count DESC, " +

    "MAX(a.last_used_date) DESC " +

    "LIMIT 3";

    try(

        Connection conn =
        DBConnection.getConnection();

        PreparedStatement ps =
        conn.prepareStatement(sql)

    ){

        ps.setLong(
        1,
        userId
        );

        ResultSet rs =
        ps.executeQuery();

        while(rs.next()){

            Subscription sub =
            new Subscription();

            sub.setSubscriptionId(
            rs.getInt(
            "subscription_id"
            ));

            sub.setSubscriptionName(
            rs.getString(
            "subscription_name"
            ));

            sub.setAmount(
            rs.getDouble(
            "amount"
            ));

            sub.setBillingCycle(
            rs.getString(
            "billing_cycle"
            ));

            sub.setPlanName(
            rs.getString(
            "plan_name"
            ));

            list.add(sub);

        }

    }catch(Exception e){

        e.printStackTrace();

    }

    return list;

}

    /* =========================
       DELETE
       ========================= */

    public boolean deleteSubscription(
        int subscriptionId){

    try(

        Connection conn =
        DBConnection.getConnection()

    ){

        String analyticsSql =

        "DELETE FROM analytics " +

        "WHERE subscription_id=?";

        PreparedStatement analyticsPs =
        conn.prepareStatement(
        analyticsSql
        );

        analyticsPs.setInt(
        1,
        subscriptionId
        );

        analyticsPs.executeUpdate();

        String subscriptionSql =

        "DELETE FROM user_subscriptions " +

        "WHERE subscription_id=?";

        PreparedStatement subscriptionPs =
        conn.prepareStatement(
        subscriptionSql
        );

        subscriptionPs.setInt(
        1,
        subscriptionId
        );

        return subscriptionPs.executeUpdate() > 0;

    }catch(Exception e){

        e.printStackTrace();
    }

    return false;
}

    /* =========================
       UPDATE
       ========================= */

    public boolean updateSubscription(
        Subscription sub,
        long userId,
        boolean renewExpired){

    String sql;

    if(renewExpired){

        sql =
        "UPDATE user_subscriptions " +
        "SET plan_name=?, " +
        "billing_cycle=?, " +
        "next_renewal_date=?, " +
        "last_used_date=?, " +
        "status=CASE " +
        "WHEN ?<CURDATE() " +
        "THEN 'Expired' ELSE 'Active' END, " +
        "updated_at=CURRENT_TIMESTAMP " +
        "WHERE subscription_id=? " +
        "AND user_id=? " +
        "AND next_renewal_date<CURDATE()";

    }else{

        sql =
        "UPDATE user_subscriptions " +
        "SET last_used_date=?, " +
        "updated_at=CURRENT_TIMESTAMP " +
        "WHERE subscription_id=? " +
        "AND user_id=?";
    }

    try(

        Connection conn =
        DBConnection.getConnection();

        PreparedStatement ps =
        conn.prepareStatement(sql)

    ){

        if(renewExpired){

            ps.setString(
            1,
            sub.getPlanName());

            ps.setString(
            2,
            sub.getBillingCycle());

            ps.setDate(
            3,
            sub.getRenewalDate());

            ps.setDate(
            4,
            sub.getLastUsedDate());

            ps.setDate(
            5,
            sub.getRenewalDate());

            ps.setInt(
            6,
            sub.getSubscriptionId());

            ps.setLong(
            7,
            userId);

        }else{

            ps.setDate(
            1,
            sub.getLastUsedDate());

            ps.setInt(
            2,
            sub.getSubscriptionId());

            ps.setLong(
            3,
            userId);
        }

        boolean updated =
        ps.executeUpdate() > 0;

        if(updated){

            String analyticsSql =

            "INSERT INTO analytics " +

            "(subscription_id," +

            "user_id," +

            "subscription_name," +

            "amount," +

            "updated_at," +

            "last_used_date) " +

            "SELECT subscription_id," +

            "user_id," +

            "subscription_name," +

            "amount," +

            "updated_at," +

            "last_used_date " +

            "FROM user_subscriptions " +

            "WHERE subscription_id=?";

            PreparedStatement analyticsPs =
            conn.prepareStatement(
            analyticsSql
            );

            analyticsPs.setInt(
            1,
            sub.getSubscriptionId()
            );

            analyticsPs.executeUpdate();
        }

        return updated;

    }catch(Exception e){

        e.printStackTrace();
    }

    return false;
}
public List<Subscription>
getAllActiveSubscriptions(){

    List<Subscription> list =
    new ArrayList<>();

    String sql =

    "SELECT * FROM user_subscriptions " +

    "WHERE status='Active'";

    try(

        Connection conn =
        DBConnection.getConnection();

        PreparedStatement ps =
        conn.prepareStatement(sql)

    ){

        ResultSet rs =
        ps.executeQuery();

        while(rs.next()){

            Subscription sub =
            new Subscription();

            sub.setSubscriptionId(
            rs.getInt(
            "subscription_id"));

            sub.setUserId(
            rs.getLong(
            "user_id"));

            sub.setSubscriptionName(
            rs.getString(
            "subscription_name"));

            sub.setPlanName(
            rs.getString(
            "plan_name"));

            sub.setAmount(
            rs.getDouble(
            "amount"));

            sub.setBillingCycle(
            rs.getString(
            "billing_cycle"));

            sub.setRenewalDate(
            rs.getDate(
            "next_renewal_date"));

            sub.setStatus(
            rs.getString(
            "status"));

            list.add(sub);
        }

    }catch(Exception e){

        e.printStackTrace();
    }

    return list;
}
}
