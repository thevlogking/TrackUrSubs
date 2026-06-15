package dao;

import model.Subscription;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.List;

public class SubscriptionDAO {

    public boolean archiveExpiredSubscriptions(long userId) {

        return archiveExpiredSubscriptions(Long.valueOf(userId));
    }

    private boolean archiveExpiredSubscriptions(Long userId) {

        String userFilter =
                userId == null ? "" : "AND user_id=? ";

        String archiveSql =
                "INSERT INTO expired_user_subscription " +
                "(subscription_id, user_id, subscription_name, " +
                "plan_name, amount, billing_cycle, next_renewal_date, " +
                "status, created_at, updated_at, last_login, " +
                "last_used_date, expired_at) " +
                "SELECT subscription_id, user_id, subscription_name, " +
                "plan_name, amount, billing_cycle, next_renewal_date, " +
                "'Expired', created_at, updated_at, last_login, " +
                "last_used_date, CURRENT_TIMESTAMP " +
                "FROM user_subscriptions " +
                "WHERE next_renewal_date<CURDATE() " +
                "AND status='Active' " +
                userFilter +
                "ON DUPLICATE KEY UPDATE " +
                "user_id=VALUES(user_id), " +
                "subscription_name=VALUES(subscription_name), " +
                "plan_name=VALUES(plan_name), " +
                "amount=VALUES(amount), " +
                "billing_cycle=VALUES(billing_cycle), " +
                "next_renewal_date=VALUES(next_renewal_date), " +
                "status='Expired', " +
                "created_at=VALUES(created_at), " +
                "updated_at=VALUES(updated_at), " +
                "last_login=VALUES(last_login), " +
                "last_used_date=VALUES(last_used_date), " +
                "expired_at=CURRENT_TIMESTAMP";

        String notificationSql =
                "DELETE FROM renewal_notifications " +
                "WHERE subscription_id IN (" +
                "SELECT subscription_id FROM user_subscriptions " +
                "WHERE next_renewal_date<CURDATE() " +
                "AND status='Active' " +
                userFilter +
                ")";

        String statusSql =
                "UPDATE user_subscriptions " +
                "SET status='Expired', " +
                "updated_at=CURRENT_TIMESTAMP " +
                "WHERE next_renewal_date<CURDATE() " +
                "AND status='Active' " +
                userFilter;

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement archivePs =
                    conn.prepareStatement(archiveSql)) {

                if (userId != null) {
                    archivePs.setLong(1, userId);
                }

                archivePs.executeUpdate();
            }

            try (PreparedStatement notificationPs =
                    conn.prepareStatement(notificationSql)) {

                if (userId != null) {
                    notificationPs.setLong(1, userId);
                }

                notificationPs.executeUpdate();
            }

            try (PreparedStatement statusPs =
                    conn.prepareStatement(statusSql)) {

                if (userId != null) {
                    statusPs.setLong(1, userId);
                }

                statusPs.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (Exception e) {

            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            e.printStackTrace();
            return false;

        } finally {

            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception closeError) {
                    closeError.printStackTrace();
                }
            }
        }
    }

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

        if (!archiveExpiredSubscriptions(userId)) {
            return list;
        }

        String sql =

        "SELECT * FROM user_subscriptions " +

        "WHERE user_id=? " +

        "AND status='Active' " +

        "ORDER BY next_renewal_date ASC";

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

    public List<Subscription>
    getExpiredSubscriptionsByUserId(
            long userId){

        List<Subscription> list =
        new ArrayList<>();

        if (!archiveExpiredSubscriptions(userId)) {
            return list;
        }

        String sql =
        "SELECT * FROM expired_user_subscription " +
        "WHERE user_id=? " +
        "ORDER BY next_renewal_date DESC";

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

                sub.setStatus("Expired");

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

        "AND status='Active' " +

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

        "WHERE user_id=? " +

        "AND status='Active'";

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

        "WHERE user_id=? " +

        "AND status='Active'";

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

        "AND status='Active' " +

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

    "AND us.status='Active' " +

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
        int subscriptionId,
        long userId,
        boolean expiredSubscription){

    Connection conn = null;

    try{

        conn =
        DBConnection.getConnection();

        conn.setAutoCommit(false);

        String analyticsSql =

        "DELETE FROM analytics " +

        "WHERE subscription_id=? " +

        "AND user_id=?";

        PreparedStatement analyticsPs =
        conn.prepareStatement(
        analyticsSql
        );

        analyticsPs.setInt(
        1,
        subscriptionId
        );

        analyticsPs.setLong(
        2,
        userId
        );

        analyticsPs.executeUpdate();

        String notificationSql =

        "DELETE FROM renewal_notifications " +

        "WHERE subscription_id=?";

        PreparedStatement notificationPs =
        conn.prepareStatement(
        notificationSql
        );

        notificationPs.setInt(
        1,
        subscriptionId
        );

        notificationPs.executeUpdate();

        if(expiredSubscription){

            String expiredSql =
            "DELETE FROM expired_user_subscription " +
            "WHERE subscription_id=? " +
            "AND user_id=?";

            try(PreparedStatement expiredPs =
                    conn.prepareStatement(expiredSql)){

                expiredPs.setInt(
                1,
                subscriptionId);

                expiredPs.setLong(
                2,
                userId);

                expiredPs.executeUpdate();
            }
        }

        String subscriptionSql =

        "DELETE FROM user_subscriptions " +

        "WHERE subscription_id=? " +

        "AND user_id=? " +

        "AND status" +

        (expiredSubscription ? "='Expired'" : "<>'Expired'");

        PreparedStatement subscriptionPs =
        conn.prepareStatement(
        subscriptionSql
        );

        subscriptionPs.setInt(
        1,
        subscriptionId
        );

        subscriptionPs.setLong(
        2,
        userId
        );

        boolean deleted =
        subscriptionPs.executeUpdate() > 0;

        if(deleted){
            conn.commit();
        }else{
            conn.rollback();
        }

        return deleted;

    }catch(Exception e){

        if(conn != null){
            try{
                conn.rollback();
            }catch(Exception rollbackError){
                rollbackError.printStackTrace();
            }
        }

        e.printStackTrace();

    }finally{

        if(conn != null){
            try{
                conn.setAutoCommit(true);
                conn.close();
            }catch(Exception closeError){
                closeError.printStackTrace();
            }
        }
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

    if(renewExpired){

        return renewExpiredSubscription(
                sub,
                userId);
    }

    String sql =
    "UPDATE user_subscriptions " +
    "SET last_used_date=?, " +
    "updated_at=CURRENT_TIMESTAMP " +
    "WHERE subscription_id=? " +
    "AND user_id=? " +
    "AND status='Active'";

    try(

        Connection conn =
        DBConnection.getConnection();

        PreparedStatement ps =
        conn.prepareStatement(sql)

    ){

        ps.setDate(
        1,
        sub.getLastUsedDate());

        ps.setInt(
        2,
        sub.getSubscriptionId());

        ps.setLong(
        3,
        userId);

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

private boolean renewExpiredSubscription(
        Subscription sub,
        long userId){

    String restoreSql =
    "UPDATE user_subscriptions " +
    "SET plan_name=?, " +
    "amount=?, " +
    "billing_cycle=?, " +
    "next_renewal_date=?, " +
    "status='Active', " +
    "last_used_date=COALESCE(?, last_used_date), " +
    "updated_at=CURRENT_TIMESTAMP " +
    "WHERE subscription_id=? " +
    "AND user_id=? " +
    "AND status='Expired' " +
    "AND ?>=CURDATE()";

    String deleteExpiredSql =
    "DELETE FROM expired_user_subscription " +
    "WHERE subscription_id=? " +
    "AND user_id=?";

    String deleteNotificationsSql =
    "DELETE FROM renewal_notifications " +
    "WHERE subscription_id=?";

    String analyticsSql =
    "INSERT INTO analytics " +
    "(subscription_id, user_id, subscription_name, " +
    "amount, updated_at, last_used_date) " +
    "SELECT subscription_id, user_id, subscription_name, " +
    "amount, updated_at, last_used_date " +
    "FROM user_subscriptions " +
    "WHERE subscription_id=? " +
    "AND user_id=?";

    Connection conn = null;

    try{

        conn = DBConnection.getConnection();
        conn.setAutoCommit(false);

        int restored;

        try(PreparedStatement restorePs =
                conn.prepareStatement(restoreSql)){

            restorePs.setString(
            1,
            sub.getPlanName());

            restorePs.setDouble(
            2,
            sub.getAmount());

            restorePs.setString(
            3,
            sub.getBillingCycle());

            restorePs.setDate(
            4,
            sub.getRenewalDate());

            restorePs.setDate(
            5,
            sub.getLastUsedDate());

            restorePs.setInt(
            6,
            sub.getSubscriptionId());

            restorePs.setLong(
            7,
            userId);

            restorePs.setDate(
            8,
            sub.getRenewalDate());

            restored =
            restorePs.executeUpdate();
        }

        if(restored == 0){

            conn.rollback();
            return false;
        }

        try(PreparedStatement deleteExpiredPs =
                conn.prepareStatement(deleteExpiredSql)){

            deleteExpiredPs.setInt(
            1,
            sub.getSubscriptionId());

            deleteExpiredPs.setLong(
            2,
            userId);

            deleteExpiredPs.executeUpdate();
        }

        try(PreparedStatement notificationPs =
                conn.prepareStatement(deleteNotificationsSql)){

            notificationPs.setInt(
            1,
            sub.getSubscriptionId());

            notificationPs.executeUpdate();
        }

        try(PreparedStatement analyticsPs =
                conn.prepareStatement(analyticsSql)){

            analyticsPs.setInt(
            1,
            sub.getSubscriptionId());

            analyticsPs.setLong(
            2,
            userId);

            analyticsPs.executeUpdate();
        }

        conn.commit();
        return true;

    }catch(Exception e){

        if(conn != null){
            try{
                conn.rollback();
            }catch(Exception rollbackError){
                rollbackError.printStackTrace();
            }
        }

        e.printStackTrace();
        return false;

    }finally{

        if(conn != null){
            try{
                conn.setAutoCommit(true);
                conn.close();
            }catch(Exception closeError){
                closeError.printStackTrace();
            }
        }
    }
}

public List<Subscription>
getAllActiveSubscriptions(){

    List<Subscription> list =
    new ArrayList<>();

    if (!archiveExpiredSubscriptions(null)) {
        return list;
    }

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
