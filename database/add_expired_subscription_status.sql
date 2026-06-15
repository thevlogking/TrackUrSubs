ALTER TABLE user_subscriptions
    MODIFY COLUMN status
        ENUM('Active', 'Paused', 'Cancelled', 'Expired')
        NOT NULL DEFAULT 'Active';

INSERT INTO user_subscriptions (
    subscription_id,
    user_id,
    subscription_name,
    plan_name,
    amount,
    billing_cycle,
    next_renewal_date,
    status,
    created_at,
    updated_at,
    last_login,
    last_used_date
)
SELECT
    expired.subscription_id,
    expired.user_id,
    expired.subscription_name,
    expired.plan_name,
    expired.amount,
    expired.billing_cycle,
    expired.next_renewal_date,
    'Expired',
    expired.created_at,
    expired.updated_at,
    expired.last_login,
    expired.last_used_date
FROM expired_user_subscription expired
LEFT JOIN user_subscriptions active
    ON active.subscription_id = expired.subscription_id
WHERE active.subscription_id IS NULL;
