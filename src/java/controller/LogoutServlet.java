package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import utils.PersistentLoginUtil;

import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        try {
            PersistentLoginUtil.forget(
                    request,
                    response
            );
        } catch (Exception exception) {
            getServletContext().log(
                    "Could not revoke persistent login",
                    exception
            );
        }

        HttpSession session =
                request.getSession(false);

        if (session != null) {
            session.invalidate();
        }

        response.sendRedirect(
                request.getContextPath()
                + "/pages/signin.jsp"
        );
    }
}
