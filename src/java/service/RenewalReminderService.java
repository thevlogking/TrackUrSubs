package service;

import dao.SubscriptionDAO;
import dao.UserDAO;
import dao.ReminderDAO;

import model.Subscription;
import model.User;

import util.EmailSender;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

public class RenewalReminderService {

    public void runDailyCheck() {

        SubscriptionDAO subscriptionDAO =
        new SubscriptionDAO();

        UserDAO userDAO =
        new UserDAO();

        ReminderDAO reminderDAO =
        new ReminderDAO();

        try {

            List<Subscription> subscriptions =

            subscriptionDAO
            .getAllActiveSubscriptions();

            for(Subscription sub : subscriptions){

                LocalDate today =
                LocalDate.now();

                LocalDate renewalDate =

                sub.getRenewalDate()
                .toLocalDate();

                long daysLeft =

                ChronoUnit.DAYS
                .between(
                today,
                renewalDate
                );

                String reminderType =

                getReminderType(
                sub.getBillingCycle(),
                daysLeft
                );

                if(reminderType == null){

                    continue;
                }

                if(reminderDAO.alreadySent(

                        sub.getSubscriptionId(),

                        reminderType)){

                    continue;
                }

                User user =

                userDAO.findById(
                sub.getUserId()
                );

                if(user == null){

                    continue;
                }

String subject =
"Subscription Renewal Reminder";

String body =

"<html>" +

"<body style='margin:0;padding:32px 16px;background:#f3f6fb;font-family:Arial,Helvetica,sans-serif;color:#1f2937;'>" +

"<div style='max-width:600px;margin:0 auto;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #e2e8f0;box-shadow:0 8px 24px rgba(15,23,42,0.08);'>" +

"<div style='background:#1d4ed8;padding:32px 24px;text-align:center;border-bottom:4px solid #60a5fa;'>" +

"<h1 style='color:#ffffff;margin:0;font-size:30px;line-height:1.2;letter-spacing:-0.5px;'>TrackUrSubs</h1>" +

"<p style='color:#dbeafe;margin:8px 0 0;font-size:14px;line-height:1.5;'>Subscription Renewal Reminder</p>" +

"</div>" +

"<div style='padding:32px;'>" +

"<h2 style='margin:0 0 12px;color:#0f172a;font-size:22px;line-height:1.35;'>Hello " +

user.getFullName() +

",</h2>" +

"<p style='margin:0 0 24px;color:#475569;font-size:15px;line-height:1.6;'>Your subscription is renewing soon.</p>" +

"<div style='background:#f8fafc;padding:24px;border-radius:10px;border:1px solid #e2e8f0;'>" +

"<h3 style='margin:0 0 18px;color:#0f172a;font-size:18px;line-height:1.4;'>" +

sub.getSubscriptionName() +

"</h3>" +

"<p style='margin:0 0 10px;color:#475569;font-size:14px;line-height:1.5;'><b style='color:#1e293b;'>Plan:</b> " +

sub.getPlanName() +

"</p>" +

"<p style='margin:0 0 10px;color:#475569;font-size:14px;line-height:1.5;'><b style='color:#1e293b;'>Billing Cycle:</b> " +

sub.getBillingCycle() +

"</p>" +

"<p style='margin:0;color:#475569;font-size:14px;line-height:1.5;'><b style='color:#1e293b;'>Renewal Date:</b> " +

renewalDate +

"</p>" +

"<p style='margin:20px 0 0;padding-top:18px;border-top:1px solid #e2e8f0;font-size:28px;line-height:1;color:#1d4ed8;font-weight:700;'>₹" +

sub.getAmount() +

"</p>" +

"</div>" +

"<div style='margin-top:20px;padding:14px 16px;background:#eff6ff;border:1px solid #bfdbfe;border-radius:8px;color:#1e3a8a;font-size:14px;line-height:1.5;'>" +

"⚡ Your subscription renews in <b>" +

daysLeft +

" day(s)</b>" +

"</div>" +

"<div style='text-align:center;margin-top:28px;'>" +

"<a href='http://localhost:8081/TrackUrSubs' " +

"style='display:inline-block;background:#1d4ed8;color:#ffffff;padding:13px 28px;text-decoration:none;border-radius:8px;font-size:14px;line-height:1.2;font-weight:700;box-shadow:0 4px 10px rgba(29,78,216,0.2);'>Open TrackUrSubs</a>" +

"</div>" +

"</div>" +

"<div style='background:#f8fafc;padding:20px 24px;text-align:center;color:#94a3b8;font-size:12px;line-height:1.6;border-top:1px solid #e2e8f0;'>" +

"TrackUrSubs © 2026<br>" +

"Manage all your subscriptions in one place." +

"</div>" +

"</div>" +

"</body>" +

"</html>";

                EmailSender.sendEmail(

                user.getEmail(),

                subject,

                body);

                reminderDAO.markSent(

                sub.getSubscriptionId(),

                reminderType);

                System.out.println(

                "Reminder sent to: " +

                user.getEmail());
            }

        } catch(Exception e){

            e.printStackTrace();
        }
    }

    private String getReminderType(

            String cycle,

            long daysLeft){

        if(cycle.equalsIgnoreCase(
                "Weekly")){

            if(daysLeft == 1)
                return "1_DAY";
        }

        if(cycle.equalsIgnoreCase(
                "Monthly")){

            if(daysLeft == 7)
                return "7_DAY";

            if(daysLeft == 1)
                return "1_DAY";
        }

        if(cycle.equalsIgnoreCase(
                "Quarterly")){

            if(daysLeft == 30)
                return "30_DAY";

            if(daysLeft == 7)
                return "7_DAY";

            if(daysLeft == 1)
                return "1_DAY";
        }

        if(cycle.equalsIgnoreCase(
                "Yearly")){

            if(daysLeft == 30)
                return "30_DAY";

            if(daysLeft == 7)
                return "7_DAY";

            if(daysLeft == 1)
                return "1_DAY";
        }

        return null;
    }
}
