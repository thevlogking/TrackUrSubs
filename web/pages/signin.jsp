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

<title>TrackUrSubs Login</title>

<link rel="preconnect" href="https://fonts.googleapis.com">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
rel="stylesheet">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<style>

*{
margin:0;
padding:0;
box-sizing:border-box;
font-family:'Inter',sans-serif;
}
/* ===================================
   ERROR MESSAGE
=================================== */

.error-message{

    width:100%;

    background:rgba(255,82,82,.12);

    border:1px solid rgba(255,82,82,.25);

    color:#ffb3b3;

    padding:14px 16px;

    border-radius:14px;

    margin-bottom:18px;

    font-size:14px;

    font-weight:500;

    display:flex;

    align-items:center;

    gap:10px;

    backdrop-filter:blur(8px);

    animation:fadeIn .25s ease;
}

.error-message i{

    color:#ff6b6b;

    font-size:16px;

    flex-shrink:0;
}

@keyframes fadeIn{

    from{

        opacity:0;

        transform:translateY(-6px);
    }

    to{

        opacity:1;

        transform:translateY(0);
    }
}

body{
height:100vh;
display:flex;
justify-content:center;
align-items:center;
overflow:hidden;

background:
radial-gradient(circle at top left,#1b2d74 0%,#020617 35%),
radial-gradient(circle at top right,#340046 0%,#020617 30%),
#020617;
}

.wrapper{
width:100%;
max-width:820px;
padding:20px;
}

.card{
display:flex;
gap:60px;
align-items:center;
padding:50px;
border-radius:32px;

background:rgba(255,255,255,.05);

border:1px solid rgba(255,255,255,.08);

backdrop-filter:blur(35px);

box-shadow:
0 25px 70px rgba(0,0,0,.45);

transform-origin:center;

will-change:transform,opacity;
}

.card.card-entering{

animation:cardEnter .45s cubic-bezier(.22,1,.36,1) both;
}

@keyframes cardEnter{

from{
opacity:0;
transform:translateY(18px) scale(.985);
}

to{
opacity:1;
transform:translateY(0) scale(1);
}
}

.card.card-leaving{

animation:cardLeave .18s ease-out forwards;

pointer-events:none;
}

@keyframes cardLeave{

from{
opacity:1;
transform:translateY(0) scale(1);
}

to{
opacity:0;
transform:translateY(-10px) scale(.99);
}
}

.left-side{
flex:1;
}

.left-side h1{
font-size:58px;
font-weight:800;
line-height:1;
margin-bottom:16px;
color:white;
}

.subtitle{
font-size:17px;
line-height:1.7;
color:rgba(255,255,255,.72);
max-width:300px;
}

.right-side{
flex:1;
}

.group{
margin-bottom:18px;
}

.group label{
display:block;
margin-bottom:8px;
font-size:14px;
font-weight:600;
color:white;
}

.input-box{
position:relative;
}

.input-box i{
position:absolute;
left:18px;
top:50%;
transform:translateY(-50%);
color:#94a2bd;
}

.input-box input{

width:100%;

padding:16px 16px 16px 50px;

border-radius:14px;

border:1px solid rgba(255,255,255,.08);

background:rgba(255,255,255,.05);

outline:none;

font-size:15px;

color:white;
}

.google-btn{

    width:100%;

    padding:16px;

    margin-top:12px;

    margin-bottom:12px;

    display:flex;

    justify-content:center;

    align-items:center;

    gap:10px;

    border:1px solid #ddd;

    border-radius:16px;

    background:#fff;

    color:#333;

    text-decoration:none;

    font-weight:600;

    cursor:pointer;

    transition:
    transform .3s ease,
    box-shadow .3s ease,
    filter .3s ease;
}

.google-btn:hover{

    transform:translateY(-4px) scale(1.02);

    box-shadow:0 14px 28px rgba(0,0,0,.25);

    filter:brightness(1.08);
}

.google-btn svg{

    width:20px;

    height:20px;

    flex-shrink:0;
}

.or-divider{

display:flex;

align-items:center;

gap:12px;

margin:2px 0 12px;

color:rgba(255,255,255,.55);

font-size:12px;

font-weight:600;
}

.or-divider::before,
.or-divider::after{

content:"";

flex:1;

height:1px;

background:rgba(255,255,255,.12);
}

.sign-btn{

width:100%;

padding:16px;

border:none;

border-radius:16px;

cursor:pointer;

font-size:20px;

font-weight:700;

color:white;

background:
linear-gradient(
90deg,
#7a4dff,
#20d6ff
);

transition:
transform .3s ease,
box-shadow .3s ease,
filter .3s ease;
}

.sign-btn:hover{

transform:translateY(-4px) scale(1.02);

box-shadow:0 14px 28px rgba(32,214,255,.28);

filter:brightness(1.08);
}

.google-btn:active,
.sign-btn:active{

transform:translateY(-1px) scale(.99);
}

.bottom{

margin-top:22px;

text-align:center;

font-size:16px;

color:rgba(255,255,255,.75);
}

.bottom a{
font-weight:700;
text-decoration:none;
color:white;
}

@media(max-width:768px){

body{
height:auto;
min-height:100vh;
min-height:100dvh;
padding:20px;
overflow:auto;
}

.wrapper{
padding:0;
margin:auto;
}

.card{
flex-direction:column;
gap:30px;
padding:35px;
}

.left-side{
text-align:center;
}

.left-side h1{
font-size:44px;
}
}

@media(max-width:480px){

body{
padding:14px;
}

.card{
gap:24px;
padding:26px 22px;
border-radius:24px;
}

.left-side h1{
font-size:38px;
}

.subtitle{
font-size:15px;
}

.sign-btn{
font-size:17px;
}

.bottom{
font-size:14px;
}

}

</style>

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

<script>
const loginCard = document.querySelector(".card");
const loginForm = document.querySelector("form");

function playCardEntrance(){
    loginCard.classList.remove("card-leaving");
    loginCard.classList.remove("card-entering");
    void loginCard.offsetWidth;
    loginCard.classList.add("card-entering");
}

playCardEntrance();

window.addEventListener("pageshow", function(event){
    if (event.persisted) {
        playCardEntrance();
    }
});

document.querySelectorAll("a").forEach(function(link){
    link.addEventListener("click", function(event){
        if (
            event.ctrlKey ||
            event.metaKey ||
            event.shiftKey ||
            event.altKey ||
            link.target === "_blank"
        ) {
            return;
        }

        event.preventDefault();
        loginCard.classList.remove("card-entering");
        loginCard.classList.add("card-leaving");

        setTimeout(function(){
            window.location.href = link.href;
        }, 160);
    });
});

loginForm.addEventListener("submit", function(event){
    event.preventDefault();
    loginCard.classList.remove("card-entering");
    loginCard.classList.add("card-leaving");

    setTimeout(function(){
        loginForm.submit();
    }, 160);
});
</script>

</body>

</html>
