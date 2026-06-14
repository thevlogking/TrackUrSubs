package controller;

import dao.SubscriptionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Subscription;
import model.User;

import java.io.IOException;

@WebServlet("/subscriptions")
public class SubscriptionServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            HttpSession session =
                    request.getSession();

            User user =
                    (User) session.getAttribute("user");

            if(user == null){

                response.sendRedirect(
                        request.getContextPath()
                        + "/pages/signin.jsp");

                return;
            }

            Subscription sub =
                    new Subscription();

            sub.setUserId(
                    user.getUserId());

            sub.setSubscriptionName(
                    request.getParameter(
                            "subscription_name"));

            sub.setPlanName(
                    request.getParameter(
                            "plan_name"));

            sub.setAmount(
                    Double.parseDouble(
                            request.getParameter(
                                    "amount")));

            sub.setBillingCycle(
                    request.getParameter(
                            "billing_cycle"));

sub.setRenewalDate(
java.sql.Date.valueOf(
request.getParameter(
"renewal_date")));

            sub.setStatus("Active");

            SubscriptionDAO dao =
                    new SubscriptionDAO();

            boolean inserted =
                    dao.addSubscription(sub);

            if(inserted){

                response.sendRedirect(
                        request.getContextPath()
                        + "/pages/user_subscriptions.jsp");

            } else {

                response.getWriter().println(
"Insert Failed<br>" +
"User ID = " + sub.getUserId() + "<br>" +
"Service = " + sub.getSubscriptionName() + "<br>" +
"Plan = " + sub.getPlanName() + "<br>" +
"Amount = " + sub.getAmount() + "<br>" +
"Billing = " + sub.getBillingCycle() + "<br>" +
"Renewal = " + sub.getRenewalDate()
);
            }

        } catch(Exception e){

            e.printStackTrace();

            response.getWriter()
                    .println(e.getMessage());
        }
    }
}