<%@ page contentType="text/html;charset=UTF-8"%>

<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>

<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="model.Subscription" %>
<%@ page import="model.User" %>

<%

User user =
(User)session.getAttribute("user");

if(user==null){

response.sendRedirect(
request.getContextPath()
+ "/pages/signin.jsp");

return;

}

SubscriptionDAO dao =
new SubscriptionDAO();

List<Subscription> allSubscriptions =
dao.getSubscriptionsByUserId(
user.getUserId());

List<Subscription> renewals =
dao.getUpcomingRenewals(
user.getUserId());

%>

<html>

<head>

<%@ include file="../components/site_tab.jsp" %>

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="stylesheet"
href="../css/user_dashboard.css">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<link rel="preconnect"
href="https://fonts.googleapis.com">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
rel="stylesheet">

<link rel="stylesheet" href="../css/user_renewals.css">
<link rel="stylesheet" href="../css/responsive.css">

</head>

<body>

<jsp:include page="../components/user_sidebar.jsp"/>

<jsp:include page="../components/user_navbar.jsp"/>

<div class="content">

<h1>Renewals</h1>

<p class="renewals-subtitle">Next 30 days of recurring charges.</p>

<div class="renewal-grid">

<%

if(renewals.isEmpty()){

%>

<%

if(allSubscriptions.isEmpty()){

%>

<div class="empty-state empty-state-new">

<div class="empty-icon">
<i class="fa-solid fa-credit-card"></i>
</div>

<div class="empty-eyebrow">
Get started
</div>

<div class="empty-title">
No subscriptions added yet
</div>

<div class="empty-text">
Add a subscription to begin tracking renewal dates
and upcoming recurring charges.
</div>

</div>

<%

}else{

%>

<div class="empty-state empty-state-clear">

<div class="empty-icon">
<i class="fa-solid fa-calendar-check"></i>
</div>

<div class="empty-eyebrow">
All clear
</div>

<div class="empty-title">
No renewals in the next 30 days
</div>

<div class="empty-text">
Your subscriptions are active, but no recurring charges
are scheduled within the upcoming 30-day period.
</div>

</div>

<%

}

%>

<%

}

for(Subscription sub : renewals){

long daysLeft =
ChronoUnit.DAYS.between(

LocalDate.now(),

sub.getRenewalDate()
.toLocalDate()

);

String logoPath =
"../images/default.png";

String name =
sub.getSubscriptionName()
.toLowerCase();

if(name.contains("youtube"))
logoPath="../images/youtubepremium.png";

else if(name.contains("apple"))
logoPath="../images/appletv+.png";

else if(name.contains("hotstar"))
logoPath="../images/jiohotstar.png";

else if(name.contains("fancode"))
logoPath="../images/fancode.png";

else if(name.contains("hoichoi"))
logoPath="../images/hoichoi.png";

else if(name.contains("mx player"))
logoPath="../images/mxplayer.png";

else if(name.contains("netflix"))
logoPath="../images/netflix.png";

else if(name.contains("amazon prime video"))
logoPath="../images/amazonprimevideo.png";

else if(name.contains("sony liv"))
logoPath="../images/sonyliv.png";

else if(name.contains("zee5"))
logoPath="../images/zee5.png";

%>

<div class="renew-card">

<div>

<div class="logo-circle">

<img src="<%=logoPath%>"

class="subscription-logo">

</div>

<div class="renew-title">

<%= sub.getSubscriptionName() %>

</div>

<div class="plan">

<%= sub.getPlanName() %>

</div>

<div class="price">

<div class="currency">₹</div>

<div class="amount">

<%= (int)sub.getAmount() %>

</div>

</div>

<div class="billing">

<%= sub.getBillingCycle() %>

</div>

</div>

<div class="card-footer">

<div class="info-row">

<span>Renewal</span>

<span>

<%= sub.getRenewalDate() %>

</span>

</div>

<div class="days-left">

<%= daysLeft %> days left

</div>

</div>

</div>

<%

}

%>

</div>

</div>

<%@ include file="../components/manage_account.jsp"%>

</body>

</html>
