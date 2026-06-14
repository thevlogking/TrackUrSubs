package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;
import model.LeastUsedSubscription;

public class AnalyticsDAO {

    public Map<String, Double> getServiceCosts(long userId) {

        Map<String, Double> data =
        new LinkedHashMap<>();

        String sql =
        "SELECT subscription_name, amount, billing_cycle " +
        "FROM user_subscriptions " +
        "WHERE user_id=? " +
        "AND status='Active'";

        try (

            Connection con =
            DBConnection.getConnection();

            PreparedStatement ps =
            con.prepareStatement(sql)

        ) {

            ps.setLong(1, userId);

            ResultSet rs =
            ps.executeQuery();

            while (rs.next()) {

                String subscriptionName =
                rs.getString("subscription_name");

                double amount =
                rs.getDouble("amount");

                String cycle =
                rs.getString("billing_cycle");

                double monthlyAmount = amount;

                if (cycle != null) {

                    switch (cycle) {

                        case "Weekly":

                            monthlyAmount =
                            amount * 4;

                            break;

                        case "Monthly":

                            monthlyAmount =
                            amount;

                            break;

                        case "Quarterly":

                            monthlyAmount =
                            amount / 3;

                            break;

                        case "Yearly":

                            monthlyAmount =
                            amount / 12;

                            break;
                    }
                }

                data.put(
                    subscriptionName,
                    monthlyAmount
                );
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return data;
    }

    public double getTotalMonthlySpend(
    long userId) {

        double total = 0;

        String sql =
        "SELECT amount,billing_cycle " +
        "FROM user_subscriptions " +
        "WHERE user_id=? " +
        "AND status='Active'";

        try (

            Connection con =
            DBConnection.getConnection();

            PreparedStatement ps =
            con.prepareStatement(sql)

        ) {

            ps.setLong(1, userId);

            ResultSet rs =
            ps.executeQuery();

            while (rs.next()) {

                double amount =
                rs.getDouble("amount");

                String cycle =
                rs.getString(
                "billing_cycle"
                );

                switch (cycle) {

                    case "Weekly":

                        total +=
                        amount * 4;

                        break;

                    case "Monthly":

                        total +=
                        amount;

                        break;

                    case "Quarterly":

                        total +=
                        amount / 3;

                        break;

                    case "Yearly":

                        total +=
                        amount / 12;

                        break;
                }
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return total;
    }

    public int getTotalSubscriptions(
    long userId) {

        int total = 0;

        String sql =
        "SELECT COUNT(*) " +
        "FROM user_subscriptions " +
        "WHERE user_id=? " +
        "AND status='Active'";

        try (

            Connection con =
            DBConnection.getConnection();

            PreparedStatement ps =
            con.prepareStatement(sql)

        ) {

            ps.setLong(1, userId);

            ResultSet rs =
            ps.executeQuery();

            if (rs.next()) {

                total =
                rs.getInt(1);
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return total;
    }

    public double getHighestSubscriptionCost(
    long userId) {

        double highest = 0;

        String sql =
        "SELECT MAX(amount) " +
        "FROM user_subscriptions " +
        "WHERE user_id=? " +
        "AND status='Active'";

        try (

            Connection con =
            DBConnection.getConnection();

            PreparedStatement ps =
            con.prepareStatement(sql)

        ) {

            ps.setLong(1, userId);

            ResultSet rs =
            ps.executeQuery();

            if (rs.next()) {

                highest =
                rs.getDouble(1);
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return highest;
    }

    public Map<String, Integer> getRenewalDistribution(
    long userId) {

        Map<String, Integer> data =
        new LinkedHashMap<>();

        String sql =

        "SELECT " +
        "DATE_FORMAT(next_renewal_date, '%b %Y') AS month_name, " +
        "COUNT(*) AS total " +
        "FROM user_subscriptions " +
        "WHERE user_id=? " +
        "AND status='Active' " +
        "AND next_renewal_date>=CURDATE() " +
        "GROUP BY YEAR(next_renewal_date), " +
        "MONTH(next_renewal_date), " +
        "DATE_FORMAT(next_renewal_date, '%b %Y') " +
        "ORDER BY YEAR(next_renewal_date), " +
        "MONTH(next_renewal_date)";

        try (

            Connection con =
            DBConnection.getConnection();

            PreparedStatement ps =
            con.prepareStatement(sql)

        ) {

            ps.setLong(1, userId);

            ResultSet rs =
            ps.executeQuery();

            while (rs.next()) {

                data.put(
                    rs.getString("month_name"),
                    rs.getInt("total")
                );
            }

        } catch (Exception e) {

            e.printStackTrace();
        }

        return data;
    }
public List<LeastUsedSubscription>
getLeastUsedSubscriptions(long userId) {

    List<LeastUsedSubscription> list =
    new ArrayList<>();

String sql =

"SELECT " +
"us.subscription_name, " +
"us.plan_name, " +
"us.billing_cycle, " +
"us.amount, " +

"COUNT(a.analytics_id) AS usage_count, " +

"CASE " +
"WHEN MAX(a.last_used_date) IS NULL THEN NULL " +
"WHEN MONTH(MAX(a.last_used_date)) BETWEEN 1 AND 3 THEN 'JAN-MAR' " +
"WHEN MONTH(MAX(a.last_used_date)) BETWEEN 4 AND 6 THEN 'APR-JUN' " +
"WHEN MONTH(MAX(a.last_used_date)) BETWEEN 7 AND 9 THEN 'JUL-SEP' " +
"WHEN MONTH(MAX(a.last_used_date)) BETWEEN 10 AND 12 THEN 'OCT-DEC' " +
"ELSE NULL " +
"END AS most_used_month " +

"FROM user_subscriptions us " +

"LEFT JOIN analytics a " +
"ON us.subscription_id = a.subscription_id " +

"WHERE us.user_id=? " +
"AND us.status='Active' " +

"GROUP BY " +
"us.subscription_id, " +
"us.subscription_name, " +
"us.plan_name, " +
"us.billing_cycle, " +
"us.amount " +

"ORDER BY usage_count ASC " +
"LIMIT 3";

    try (

        Connection con =
        DBConnection.getConnection();

        PreparedStatement ps =
        con.prepareStatement(sql)

    ) {

        ps.setLong(1, userId);

        ResultSet rs =
        ps.executeQuery();

        while (rs.next()) {

            LeastUsedSubscription item =
            new LeastUsedSubscription();

            item.setSubscriptionName(
            rs.getString(
            "subscription_name"));

            item.setPlanName(
            rs.getString(
            "plan_name"));

            item.setBillingCycle(
            rs.getString(
            "billing_cycle"));

            item.setAmount(
            rs.getDouble(
            "amount"));

            item.setUsageCount(
            rs.getInt(
            "usage_count"));

            item.setMostUsedMonth(
            rs.getString(
            "most_used_month"));

            list.add(item);
        }

    } catch (Exception e) {

        e.printStackTrace();
    }

    return list;
}
}
