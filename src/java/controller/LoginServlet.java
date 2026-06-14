package controller;

import dao.UserDAO;
import model.User;
import utils.PasswordUtil;
import utils.PersistentLoginUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            String email =
                    request.getParameter("email");

            String password =
                    request.getParameter("password");

            UserDAO dao =
                    new UserDAO();

            User user =
                    dao.findByEmail(email);

            String hashedPassword =
                    PasswordUtil.hashPassword(password);

if (user != null &&
        user.getPasswordHash()
                .equals(hashedPassword)) {

    // Check account status
    if ("suspended".equalsIgnoreCase(
            user.getAccountStatus())) {

        request.setAttribute(
                "error",
                "Your account is suspended. Please contact the administrator."
        );

        request.getRequestDispatcher(
                "/pages/signin.jsp")
                .forward(
                        request,
                        response);

        return;
    }

    // Account is active
    System.out.println(
            "Device Time = "
            + java.time.LocalDateTime.now());

    dao.updateLastLogin(
            user.getUserId());

    HttpSession session =
            request.getSession();

    request.changeSessionId();

    session.setAttribute(
            "user",
            user);

    try {
        PersistentLoginUtil.remember(
                request,
                response,
                user.getUserId()
        );
    } catch (Exception exception) {
        getServletContext().log(
                "Could not create persistent login",
                exception
        );
    }

    response.sendRedirect(
            request.getContextPath()
            + "/pages/user_dashboard.jsp");

} else {

    request.setAttribute(
            "error",
            "Incorrect email or password."
    );

    request.getRequestDispatcher(
            "/pages/signin.jsp")
            .forward(
                    request,
                    response);
}

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Something went wrong. Please try again."
            );

            request.getRequestDispatcher(
                    "/pages/signin.jsp")
                    .forward(
                            request,
                            response);
        }
    }
}
