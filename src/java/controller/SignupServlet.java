package controller;

import dao.UserDAO;
import model.User;
import utils.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try {

            String fullName =
                    request.getParameter("fullName");

            String email =
                    request.getParameter("email");

            String password =
                    request.getParameter("password");

            String confirmPassword =
                    request.getParameter("confirmPassword");

            if (!password.equals(confirmPassword)) {

                request.setAttribute(
                        "error",
                        "Passwords do not match."
                );

                request.getRequestDispatcher(
                        "/pages/signup.jsp")
                        .forward(
                                request,
                                response);

                return;
            }

            UserDAO dao =
                    new UserDAO();

            User existingUser =
                    dao.findByEmail(email);

            if (existingUser != null) {

                request.setAttribute(
                        "error",
                        "An account with this email already exists."
                );

                request.getRequestDispatcher(
                        "/pages/signup.jsp")
                        .forward(
                                request,
                                response);

                return;
            }

            String hashedPassword =
                    PasswordUtil.hashPassword(password);

            User user =
                    new User();

            user.setFullName(fullName);
            user.setEmail(email);
            user.setPasswordHash(hashedPassword);

            boolean success =
                    dao.createUser(user);

            if (success) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/pages/signin.jsp");

            } else {

                request.setAttribute(
                        "error",
                        "Unable to create account."
                );

                request.getRequestDispatcher(
                        "/pages/signup.jsp")
                        .forward(
                                request,
                                response);
            }

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Something went wrong."
            );

            request.getRequestDispatcher(
                    "/pages/signup.jsp")
                    .forward(
                            request,
                            response);
        }
    }
}