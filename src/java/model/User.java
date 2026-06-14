package model;

import java.sql.Timestamp;
import java.util.Date;

public class User {

    private long userId;

    private String fullName;

    private String email;

    private String passwordHash;

    private String profilePicture;

    private String accountStatus;
    
    private String googleId;

    private Date lastLogin;

    private Timestamp createdAt;

    private Timestamp updatedAt;

    public long getUserId() {

        return userId;

    }

    public void setUserId(long userId) {

        this.userId = userId;

    }

    public String getFullName() {

        return fullName;

    }

    public void setFullName(String fullName) {

        this.fullName = fullName;

    }

    public String getEmail() {

        return email;

    }

    public void setEmail(String email) {

        this.email = email;

    }

    public String getPasswordHash() {

        return passwordHash;

    }

    public void setPasswordHash(String passwordHash) {

        this.passwordHash = passwordHash;

    }

    public String getProfilePicture() {

        return profilePicture;

    }

    public void setProfilePicture(String profilePicture) {

        this.profilePicture = profilePicture;

    }

    public String getAccountStatus() {

        return accountStatus;

    }

    public void setAccountStatus(String accountStatus) {

        this.accountStatus = accountStatus;

    }
    public String getGoogleId() {

    return googleId;

}

public void setGoogleId(String googleId) {

    this.googleId = googleId;

}

    public Date getLastLogin() {

        return lastLogin;

    }

    public void setLastLogin(Date lastLogin) {

        this.lastLogin = lastLogin;

    }

    public Timestamp getCreatedAt() {

        return createdAt;

    }

    public void setCreatedAt(Timestamp createdAt) {

        this.createdAt = createdAt;

    }

    public Timestamp getUpdatedAt() {

        return updatedAt;

    }

    public void setUpdatedAt(Timestamp updatedAt) {

        this.updatedAt = updatedAt;

    }

}