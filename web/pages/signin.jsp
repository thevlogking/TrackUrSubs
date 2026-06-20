<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
if (session.getAttribute("user") != null) {
    response.sendRedirect(
            request.getContextPath()
            + "/pages/user_dashboard.jsp"
    );
    return;
}
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<%@ include file="../components/site_tab.jsp" %>

<link rel="preconnect" href="https://fonts.googleapis.com">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
rel="stylesheet">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<link rel="stylesheet" href="../css/signin.css">

</head>

<body>

<div class="wrapper">

<div class="card">

<div class="left-side">

<h1>
Welcome Back!
</h1>

<p class="subtitle">
Track subscriptions smarter, control recurring expenses and never miss renewals.
</p>

</div>

<div class="right-side">
    <%
String error =
(String)request.getAttribute("error");

if(error != null){
%>

<div class="error-message">

    <i class="fa-solid fa-circle-exclamation"></i>

    <%= error %>

</div>

<%
}
%>

<form action="${pageContext.request.contextPath}/login"
      method="post">

<div class="group">

<label>Email</label>

<div class="input-box">

<i class="fa-solid fa-envelope"></i>

<input
type="email"
name="email"
placeholder="Enter your email"
required>

</div>

</div>

<div class="group">

<label>Password</label>

<div class="input-box">

<i class="fa-solid fa-lock"></i>

<input
type="password"
name="password"
placeholder="Enter password"
required>

</div>

</div>

<button
type="submit"
class="sign-btn">

Sign In

</button>

<div class="or-divider">
    <span>OR</span>
</div>

<a href="${pageContext.request.contextPath}/google-login"
   class="google-btn">

    <svg viewBox="0 0 24 24" aria-hidden="true">
        <path fill="#4285F4" d="M21.6 12.23c0-.71-.06-1.4-.18-2.07H12v3.92h5.38a4.6 4.6 0 0 1-2 3.02v2.54h3.24c1.9-1.75 2.98-4.33 2.98-7.41Z"/>
        <path fill="#34A853" d="M12 22c2.7 0 4.98-.9 6.64-2.36l-3.24-2.54c-.9.6-2.05.96-3.4.96-2.61 0-4.82-1.76-5.61-4.13H3.04v2.62A10 10 0 0 0 12 22Z"/>
        <path fill="#FBBC05" d="M6.39 13.93A6.02 6.02 0 0 1 6.07 12c0-.67.12-1.32.32-1.93V7.45H3.04A10 10 0 0 0 2 12c0 1.61.38 3.14 1.04 4.55l3.35-2.62Z"/>
        <path fill="#EA4335" d="M12 5.94c1.47 0 2.79.5 3.82 1.5l2.88-2.88A9.65 9.65 0 0 0 12 2a10 10 0 0 0-8.96 5.45l3.35 2.62C7.18 7.7 9.39 5.94 12 5.94Z"/>
    </svg>
    Continue with Google

</a>

</form>

<div class="bottom">

<p>
    No account?
    <a href="${pageContext.request.contextPath}/pages/signup.jsp">
        Sign Up
    </a>
</p>
</div>

</div>

</div>

</div>

<script src="../js/signin.js"></script>

</body>

</html>
