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

                String renewalDate =
                request.getParameter(
                "renewalDate");

                if(planName == null
                        || planName.trim().isEmpty()
                        || billingCycle == null
                        || billingCycle.trim().isEmpty()
                        || renewalDate == null
                        || renewalDate.trim().isEmpty()){

                    throw new IllegalArgumentException(
                    "Plan, billing cycle and renewal date are required.");
                }

                sub.setPlanName(
                planName.trim());

                sub.setBillingCycle(
                billingCycle.trim());

                sub.setRenewalDate(
                java.sql.Date.valueOf(
                renewalDate));
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
