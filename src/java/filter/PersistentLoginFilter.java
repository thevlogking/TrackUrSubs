package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import utils.PersistentLoginUtil;

import java.io.IOException;

@WebFilter("/*")
public class PersistentLoginFilter implements Filter {

    @Override
    public void doFilter(
            ServletRequest servletRequest,
            ServletResponse servletResponse,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request =
                (HttpServletRequest) servletRequest;

        HttpServletResponse response =
                (HttpServletResponse) servletResponse;

        String requestPath =
                request.getRequestURI().substring(
                        request.getContextPath().length()
                );

        if (!isStaticResource(requestPath)) {
            response.setHeader(
                    "Cache-Control",
                    "no-store, no-cache, must-revalidate, max-age=0"
            );
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
        }

        HttpSession session =
                request.getSession(false);

        User authenticatedUser =
                session == null
                        ? null
                        : (User) session.getAttribute("user");

        if (authenticatedUser == null) {

            try {
                authenticatedUser =
                        PersistentLoginUtil.restoreUser(
                                request,
                                response
                        );

                if (authenticatedUser != null) {
                    request.getSession(true)
                            .setAttribute(
                                    "user",
                                    authenticatedUser
                            );
                }

            } catch (Exception exception) {
                request.getServletContext().log(
                        "Could not restore persistent login",
                        exception
                );
            }
        }

        if (authenticatedUser != null
                && "GET".equalsIgnoreCase(request.getMethod())
                && isGuestPage(requestPath)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/pages/user_dashboard.jsp"
            );
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isGuestPage(String requestPath) {

        return "/".equals(requestPath)
                || "/index.jsp".equals(requestPath)
                || "/pages/signin.jsp".equals(requestPath)
                || "/pages/signup.jsp".equals(requestPath)
                || "/pages/landingpage.jsp".equals(requestPath);
    }

    private boolean isStaticResource(String requestPath) {

        return requestPath.startsWith("/css/")
                || requestPath.startsWith("/js/")
                || requestPath.startsWith("/images/")
                || requestPath.endsWith(".ico");
    }
}
