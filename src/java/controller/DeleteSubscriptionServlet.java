package controller;

import dao.SubscriptionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/DeleteSubscriptionServlet")
public class DeleteSubscriptionServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)

            throws ServletException,
            IOException {

        try{

            int subscriptionId =

            Integer.parseInt(
            request.getParameter(
            "subscriptionId"
            ));

            SubscriptionDAO dao =
            new SubscriptionDAO();

            boolean deleted =

            dao.deleteSubscription(
            subscriptionId
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