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
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
rel="stylesheet">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<link rel="stylesheet"
href="${pageContext.request.contextPath}/css/style.css">

</head>

<body>

<!-- NAVBAR -->

<nav class="navbar">

<div class="logo">
Track<span>Ur</span>Subs
</div>

<ul class="nav-links">

<li><a href="#features">Features</a></li>

<li><a href="#dashboard">Dashboard</a></li>

<li><a href="#about">About</a></li>

</ul>

<div class="nav-buttons">

<a href="${pageContext.request.contextPath}/pages/signin.jsp"
class="signin">

Sign In

</a>

<a href="${pageContext.request.contextPath}/pages/signup.jsp"
class="getstarted">

Get Started →

</a>

</div>

</nav>

<!-- HERO -->

<section class="hero">

<div class="badge">

✨ New • Smart renewal reminders

</div>

<h1>

Track <span>every</span>
subscription.
Save more every month.

</h1>

<p>

A beautiful dashboard for Netflix,
Prime Video, Hotstar, Sony LIV
and dozens of other services quietly
draining your wallet.

</p>

<div class="hero-buttons">

<a href="${pageContext.request.contextPath}/pages/signup.jsp"
class="primary-btn">

Start free →

</a>

<a href="${pageContext.request.contextPath}/pages/signin.jsp"
class="secondary-btn">

I already have an account

</a>

</div>

</section>

<!-- FEATURES -->

<section id="features" class="features">

<div class="feature-card">

<div class="feature-icon blue">

<i class="fa-solid fa-chart-line"></i>

</div>

<h3>Spend analytics</h3>

<p>

See monthly totals,
trends and service
breakdowns.

</p>

</div>

<div class="feature-card">

<div class="feature-icon cyan">

<i class="fa-solid fa-bell"></i>

</div>

<h3>Renewal reminders</h3>

<p>

Know what renews this week
before payments hit.

</p>

</div>

<div class="feature-card">

<div class="feature-icon green">

<i class="fa-solid fa-shield"></i>

</div>

<h3>Private & Secure</h3>

<p>

Encrypted,
isolated,
and only yours.

</p>

</div>

</section>

<!-- DASHBOARD -->

<section id="dashboard" class="dashboard">

<div class="dashboard-left">

<div class="badge savings-badge">

<i class="fa-solid fa-chart-line"></i>
Users save an average of &#8377;312 annually

</div>

<h2>

One dashboard.
Every recurring charge.

</h2>

<p>

Track subscriptions,
renewals and spending
from one place.

</p>

<a href="${pageContext.request.contextPath}/pages/signup.jsp"
class="primary-btn">

Create dashboard →

</a>

</div>

<div class="dashboard-card">

<div class="service-row">

<div class="service-left">

<div class="service-dot netflix"></div>

Netflix

</div>

₹199

</div>

<div class="service-row">

<div class="service-left">

<div class="service-dot hotstar"></div>

Jio Hotstar

</div>

₹149

</div>

<div class="service-row">

<div class="service-left">

<div class="service-dot sony"></div>

Sony LIV

</div>

₹299

</div>

<hr>

<div class="total">

<span>Monthly total</span>

<span>₹647</span>

</div>

</div>

</section>

<!-- ABOUT -->

<section id="about" class="about">

<div class="about-card">

<div class="about-intro">

<div class="about-copy">

<span class="section-eyebrow">Why TrackUrSubs</span>

<h2>A clearer way to manage recurring spending.</h2>

<p>
TrackUrSubs brings subscriptions, renewal dates and spending
insights together so you can make informed decisions without
sorting through statements or missing another charge.
</p>

</div>

<div class="about-benefits">

<div class="about-benefit">

<span class="about-benefit-icon">
<i class="fa-solid fa-bell"></i>
</span>

<div>
<h3>Stay ahead of renewals</h3>
<p>See upcoming payments before they reach your account.</p>
</div>

</div>

<div class="about-benefit">

<span class="about-benefit-icon">
<i class="fa-solid fa-chart-pie"></i>
</span>

<div>
<h3>Understand your spending</h3>
<p>Turn recurring expenses into clear, useful insights.</p>
</div>

</div>

<div class="about-benefit">

<span class="about-benefit-icon">
<i class="fa-solid fa-shield-halved"></i>
</span>

<div>
<h3>Keep your data private</h3>
<p>Your account information stays secure and under your control.</p>
</div>

</div>

</div>

</div>

<div class="about-grid">

<div class="about-stat">

<span>50+</span>

<p>Services supported</p>

</div>

<div class="about-stat">

<span>10K+</span>

<p>Expenses being tracked</p>

</div>

<div class="about-stat">

<span>99.9%</span>

<p>Reliable experience</p>

</div>

</div>

</div>

</section>

<!-- FOOTER -->

<footer class="site-footer">

<div class="footer-shell">

<div class="footer-main">

<div class="footer-brand">

<a href="#" class="footer-logo">
Track<span>Ur</span>Subs
</a>

<p>
Keep every subscription, renewal and recurring expense
organized in one simple dashboard.
</p>

<div class="footer-trust">

<i class="fa-solid fa-shield-halved"></i>

<span>Private and secure by design</span>

</div>

</div>

<div class="footer-navigation">

<div class="footer-column">

<h3>Product</h3>

<a href="#features">Features</a>

<a href="#dashboard">Dashboard</a>

<a href="#about">About</a>

</div>

<div class="footer-column">

<h3>Account</h3>

<a href="${pageContext.request.contextPath}/pages/signin.jsp">
Sign In
</a>

<a href="${pageContext.request.contextPath}/pages/signup.jsp">
Create Account
</a>

</div>

</div>

<div class="footer-contact">

<span class="footer-eyebrow">Contact</span>

<h3>Questions or feedback?</h3>

<p>
Our support team is here to help with your account
and answer questions about TrackUrSubs.
</p>

<a href="https://mail.google.com/mail/?view=cm&fs=1&to=trackursubs26%40gmail.com"
class="footer-email"
target="_blank"
rel="noopener noreferrer">

<i class="fa-solid fa-envelope"></i>

<span>
<small>Email us</small>
trackursubs26@gmail.com
</span>

</a>

</div>

</div>

<div class="footer-bottom">

<p>&copy; 2026 TrackUrSubs. All rights reserved.</p>

<p>Built for smarter subscription decisions.</p>

</div>

</div>

</footer>

</body>

</html>
