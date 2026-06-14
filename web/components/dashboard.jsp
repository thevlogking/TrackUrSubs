<%@ page import="model.User" %>

<%
User user =
(User)session.getAttribute("user");

if(user == null){

    response.sendRedirect(
        request.getContextPath()
        + "/signin.jsp");

    return;
}
%>
<section id="dashboard" class="dashboard">

<div class="dashboard-left">

<div class="small-badge">

<i class="fa-solid fa-arrow-trend-up"></i>

Average user saves ₹312/yr

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

<a class="primary-btn">

Create dashboard →

</a>

</div>

<div class="dashboard-card">

<div class="service-row">

<div class="service-left">

<div class="service-dot netflix"></div>

Netflix

</div>

<span>₹15.99/mo</span>

</div>

<div class="service-row">

<div class="service-left">

<div class="service-dot hotstar"></div>

Jio Hotstar

</div>

<span>₹4.99/mo</span>

</div>

<div class="service-row">

<div class="service-left">

<div class="service-dot sony"></div>

Sony LIV

</div>

<span>₹6.49/mo</span>

</div>

<hr>

<div class="total">

Monthly total

<span>₹27.47</span>

</div>

</div>

</section>