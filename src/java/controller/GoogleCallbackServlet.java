package controller;

import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeTokenRequest;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

import dao.UserDAO;
import model.User;
import utils.GoogleConfig;
import utils.PersistentLoginUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;

@WebServlet("/google-callback")
public class GoogleCallbackServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        try {

            String code =
            request.getParameter("code");

            if(code == null){

                response.getWriter().println(
                "Google authorization code not found");

                return;
            }

            GoogleTokenResponse tokenResponse =
            new GoogleAuthorizationCodeTokenRequest(

                    GoogleNetHttpTransport
                    .newTrustedTransport(),

                    GsonFactory.getDefaultInstance(),

                    GoogleConfig.CLIENT_ID,

                    GoogleConfig.CLIENT_SECRET,

                    code,

                    GoogleConfig.REDIRECT_URI

            ).execute();

            String idTokenString =
            tokenResponse.getIdToken();

            GoogleIdTokenVerifier verifier =
            new GoogleIdTokenVerifier.Builder(

                    GoogleNetHttpTransport
                    .newTrustedTransport(),

                    GsonFactory.getDefaultInstance()

            )
            .setAudience(
                    Collections.singletonList(
                    GoogleConfig.CLIENT_ID))
            .build();

            GoogleIdToken idToken =
            verifier.verify(idTokenString);

            if(idToken == null){

                response.getWriter().println(
                "Invalid Google Login");

                return;
            }

            GoogleIdToken.Payload payload =
            idToken.getPayload();

            String googleId =
            payload.getSubject();

            String email =
            payload.getEmail();

            String name =
            (String) payload.get("name");

            String picture =
            (String) payload.get("picture");

            UserDAO dao =
            new UserDAO();

            User user =
            dao.findByEmail(email);

            if(user == null){

                dao.createGoogleUser(
                        name,
                        email,
                        picture,
                        googleId
                );

                user =
                dao.findByEmail(email);
            }

            if("Suspended".equalsIgnoreCase(
                    user.getAccountStatus())){

                request.setAttribute(
                        "error",
                        "Your account is suspended."
                );

                request.getRequestDispatcher(
                        "/pages/signin.jsp")
                        .forward(
                                request,
                                response);

                return;
            }

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
                    +
                    "/pages/user_dashboard.jsp");

        }
        catch(Exception e){

            e.printStackTrace();

            response.setContentType(
                    "text/plain");

            e.printStackTrace(
                    response.getWriter());
        }
    }
}
