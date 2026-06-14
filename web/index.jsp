<%
if (session.getAttribute("user") != null) {
    response.sendRedirect("pages/user_dashboard.jsp");
} else {
    response.sendRedirect("pages/landingpage.jsp");
}
%>
