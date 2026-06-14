package model;

import java.sql.Date;

public class Subscription {

    private int subscriptionId;

    private long userId;

    private String subscriptionName;

    private String planName;

    private double amount;

    private String billingCycle;

    private Date renewalDate;

    private Date lastUsedDate;

    private String status;

    public Subscription() {
    }

    public int getSubscriptionId() {

        return subscriptionId;

    }

    public void setSubscriptionId(
            int subscriptionId) {

        this.subscriptionId =
                subscriptionId;

    }

    public long getUserId() {

        return userId;

    }

    public void setUserId(
            long userId) {

        this.userId =
                userId;

    }

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

    public double getAmount() {

        return amount;

    }

    public void setAmount(
            double amount) {

        this.amount =
                amount;

    }

    public String getBillingCycle() {

        return billingCycle;

    }

    public void setBillingCycle(
            String billingCycle) {

        this.billingCycle =
                billingCycle;

    }

    public Date getRenewalDate() {

        return renewalDate;

    }

    public void setRenewalDate(
            Date renewalDate) {

        this.renewalDate =
                renewalDate;

    }

    public Date getLastUsedDate() {

        return lastUsedDate;

    }

    public void setLastUsedDate(
            Date lastUsedDate) {

        this.lastUsedDate =
                lastUsedDate;

    }

    public String getStatus() {

        return status;

    }

    public void setStatus(
            String status) {

        this.status =
                status;

    }

}