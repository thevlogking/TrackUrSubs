package controller;

import dao.SubscriptionDAO;
import model.Subscription;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import model.User;

@WebServlet("/UpdateSubscriptionServlet")

public class UpdateSubscriptionServlet
extends HttpServlet {

    @Override
    protected void doPost(

            HttpServletRequest request,

            HttpServletResponse response)

            throws ServletException,
            IOException {

        try{

            HttpSession session =
            request.getSession(false);

            User user = session == null
                    ? null
                    : (User) session.getAttribute("user");

            if(user == null){

                response.sendRedirect(
                request.getContextPath()
                + "/pages/signin.jsp");

                return;
            }

            Subscription sub =
            new Subscription();

            sub.setSubscriptionId(

            Integer.parseInt(

            request.getParameter(
            "subscriptionId"
            )));

            boolean expiredEdit =
            Boolean.parseBoolean(
            request.getParameter(
            "expiredEdit"));

            String lastUsedDate =
            request.getParameter(
            "lastUsedDate");

            if(lastUsedDate != null
                    && !lastUsedDate.trim().isEmpty()){

                sub.setLastUsedDate(
                java.sql.Date.valueOf(
                lastUsedDate));
            }

            if(expiredEdit){

                String planName =
                request.getParameter(
                "planName");

                String billingCycle =
                request.getParameter(
                "billingCycle");

                String amount =
                request.getParameter(
                "amount");

                String renewalDate =
                request.getParameter(
                "renewalDate");

                if(planName == null
                        || planName.trim().isEmpty()
                        || billingCycle == null
                        || billingCycle.trim().isEmpty()
                        || amount == null
                        || amount.trim().isEmpty()
                        || renewalDate == null
                        || renewalDate.trim().isEmpty()){

                    throw new IllegalArgumentException(
                    "Plan, amount, billing cycle and renewal date are required.");
                }

                sub.setPlanName(
                planName.trim());

                double parsedAmount =
                Double.parseDouble(
                amount.trim());

                if(parsedAmount < 0){

                    throw new IllegalArgumentException(
                    "Amount cannot be negative.");
                }

                sub.setAmount(
                parsedAmount);

                sub.setBillingCycle(
                billingCycle.trim());

                java.time.LocalDate parsedRenewalDate =
                java.time.LocalDate.parse(
                renewalDate);

                if(parsedRenewalDate.isBefore(
                        java.time.LocalDate.now())){

                    throw new IllegalArgumentException(
                    "Renewal date cannot be in the past.");
                }

                sub.setRenewalDate(
                java.sql.Date.valueOf(
                parsedRenewalDate));
            }

            SubscriptionDAO dao =
            new SubscriptionDAO();

            boolean updated =
            dao.updateSubscription(
            sub,
            user.getUserId(),
            expiredEdit
            );

            if(!updated){

                response.sendRedirect(
                request.getContextPath()
                + "/pages/user_subscriptions.jsp?error=update");

                return;
            }

            response.sendRedirect(

            request.getContextPath()

            +

            "/pages/user_subscriptions.jsp"

            );

        }catch(Exception e){

            e.printStackTrace();

            response.sendRedirect(

            request.getContextPath()

            +

            "/pages/user_subscriptions.jsp?error"

            );

        }

    }

}
