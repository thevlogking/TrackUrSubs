<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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

<link rel="stylesheet" href="../css/signup.css">

</head>

<body>

<div class="wrapper">

<div class="card">

<div class="left">

<h1>Join Us.</h1>

<p>
Create your account and start tracking smarter.
</p>

</div>

<div class="right">

<h2>Create Account</h2>

<p class="subtitle">
Only takes a minute.
</p>
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
<form action="${pageContext.request.contextPath}/signup"
      method="post">

<div class="group">

<label>Full Name</label>

<div class="input-box">

<i class="fa-solid fa-user"></i>

<input type="text"
       name="fullName"
       placeholder="Full Name"
       required>

</div>

</div>

<div class="group">

<label>Email</label>

<div class="input-box">

<i class="fa-solid fa-envelope"></i>

<input type="email"
       name="email"
       placeholder="Email"
       required>

</div>

</div>

<div class="group">

<label>Password</label>

<div class="input-box">

<i class="fa-solid fa-lock"></i>

<input type="password"
       name="password"
       placeholder="Password"
       required>

</div>

</div>

<div class="group">

<label>Confirm Password</label>

<div class="input-box">

<i class="fa-solid fa-shield"></i>

<input type="password"
       name="confirmPassword"
       placeholder="Confirm Password"
       required>

</div>

</div>

<button type="submit"
        class="signup-btn">

Create Account

</button>

</form>

<div class="bottom">

Already have an account?

<a href="${pageContext.request.contextPath}/pages/signin.jsp">
    Sign In
</a>
</div>

</div>

</div>

</div>

</body>

</html>
