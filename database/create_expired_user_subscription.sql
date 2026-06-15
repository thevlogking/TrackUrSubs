CREATE TABLE IF NOT EXISTS expired_user_subscription (
    subscription_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    subscription_name VARCHAR(100) NOT NULL,
    plan_name VARCHAR(100) DEFAULT NULL,
    amount DECIMAL(10,2) NOT NULL,
    billing_cycle ENUM(
        'Weekly',
        'Monthly',
        'Quarterly',
        'Yearly'
    ) DEFAULT NULL,
    next_renewal_date DATE NOT NULL,
    status ENUM('Expired') NOT NULL DEFAULT 'Expired',
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    last_login DATETIME DEFAULT NULL,
    last_used_date DATE DEFAULT NULL,
    expired_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (subscription_id),
    KEY idx_expired_subscription_user_id (user_id),
    KEY idx_expired_subscription_expired_at (expired_at),
    CONSTRAINT fk_expired_subscription_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_bin;

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
