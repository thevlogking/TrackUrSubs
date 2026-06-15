package controller;

import dao.SubscriptionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import model.User;

@WebServlet("/DeleteSubscriptionServlet")
public class DeleteSubscriptionServlet extends HttpServlet {

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

            int subscriptionId =

            Integer.parseInt(
            request.getParameter(
            "subscriptionId"
            ));

            boolean expiredSubscription =
            Boolean.parseBoolean(
            request.getParameter(
            "expiredSubscription"
            ));

            SubscriptionDAO dao =
            new SubscriptionDAO();

            boolean deleted =

            dao.deleteSubscription(
            subscriptionId,
            user.getUserId(),
            expiredSubscription
            );

            if(deleted){

                response.sendRedirect(

                request.getContextPath()
                +
                "/pages/user_subscriptions.jsp"

                );

            }else{

                response.sendRedirect(

                request.getContextPath()
                +
                "/pages/user_subscriptions.jsp?error"

                );

            }

        }catch(Exception e){

            e.printStackTrace();

            response.sendRedirect(

            request.getContextPath()
            +
            "/pages/user_subscriptions.jsp"

            );

        }

    }

}
