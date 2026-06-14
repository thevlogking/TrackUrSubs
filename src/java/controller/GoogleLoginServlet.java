package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import utils.GoogleConfig;

@WebServlet("/google-login")
public class GoogleLoginServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String googleUrl =
            "https://accounts.google.com/o/oauth2/v2/auth"
            + "?client_id=" + GoogleConfig.CLIENT_ID
            + "&redirect_uri="
            + URLEncoder.encode(
                    GoogleConfig.REDIRECT_URI,
                    StandardCharsets.UTF_8)
            + "&response_type=code"
            + "&scope=email profile";

        response.sendRedirect(
                googleUrl);
    }
}