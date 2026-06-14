package model;

public class LeastUsedSubscription {

    private String subscriptionName;
    private String planName;
    private String billingCycle;
    private double amount;
    private int usageCount;
    private String mostUsedMonth;

    public String getSubscriptionName() {
        return subscriptionName;
    }

    public void setSubscriptionName(
    String subscriptionName) {

        this.subscriptionName =
        subscriptionName;
    }

    public String getPlanName() {
        return planName;
    }

    public void setPlanName(
    String planName) {

        this.planName =
        planName;
    }

    public String getBillingCycle() {
        return billingCycle;
    }

    public void setBillingCycle(
    String billingCycle) {

        this.billingCycle =
        billingCycle;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(
    double amount) {

        this.amount =
        amount;
    }

    public int getUsageCount() {
        return usageCount;
    }

    public void setUsageCount(
    int usageCount) {

        this.usageCount =
        usageCount;
    }

    public String getMostUsedMonth() {
        return mostUsedMonth;
    }

    public void setMostUsedMonth(
    String mostUsedMonth) {

        this.mostUsedMonth =
        mostUsedMonth;
    }
}