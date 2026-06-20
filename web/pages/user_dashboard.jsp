<%@ page contentType="text/html;charset=UTF-8"%>

<%@ page import="model.User" %>
<%@ page import="model.Subscription" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="java.util.*" %>

<%!
private String jsonString(String value) {
    if (value == null) {
        return "null";
    }

    return "\"" + value
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\r", "\\r")
        .replace("\n", "\\n") + "\"";
}
%>

<%

User user =
(User)session.getAttribute(
"user");

if(user==null){

response.sendRedirect(

request.getContextPath()

+ "/pages/signin.jsp"

);

return;
}

SubscriptionDAO dao =
new SubscriptionDAO();

List<Subscription> allSubscriptions =
dao.getSubscriptionsByUserId(
user.getUserId());

double monthlySpend = 0;
double yearlyProjection = 0;

Map<String, Double> subscriptionMonthlySpend =
new LinkedHashMap<>();

for(Subscription subscription : allSubscriptions){

double amount = subscription.getAmount();
double monthlyAmount = amount;
double yearlyAmount = amount * 12;

String billingCycle =
subscription.getBillingCycle() == null
? ""
: subscription.getBillingCycle()
.trim()
.toLowerCase();

if("weekly".equals(billingCycle)){

monthlyAmount = amount * 4;
yearlyAmount = amount * 52;

}else if("yearly".equals(billingCycle)){

monthlyAmount = amount / 12;
yearlyAmount = amount;

}else if("quarterly".equals(billingCycle)){

monthlyAmount = amount / 3;
yearlyAmount = amount * 4;

}else{

monthlyAmount = amount;
yearlyAmount = amount * 12;

}

monthlySpend += monthlyAmount;
yearlyProjection += yearlyAmount;

String subscriptionName =
subscription.getSubscriptionName();

if(subscriptionName == null ||
subscriptionName.trim().isEmpty()){

subscriptionName = "Subscription";

}

subscriptionMonthlySpend.put(
subscriptionName,
subscriptionMonthlySpend.getOrDefault(
subscriptionName,
0.0
) + monthlyAmount
);

}

int renewingWeek =
dao.renewingThisWeek(
user.getUserId());

double avgService =
allSubscriptions.isEmpty()
? 0
: monthlySpend / allSubscriptions.size();

List<Subscription> topSubs =
dao.getTopSubscriptions(
user.getUserId());

List<Subscription> displayedSubs =
topSubs.subList(
0,
Math.min(3, topSubs.size())
);

boolean hasSubs =
!displayedSubs.isEmpty();

%>

<html>

<head>

<%@ include file="../components/site_tab.jsp" %>

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link rel="stylesheet"
href="../css/user_dashboard.css"/>

<link rel="stylesheet"
href="../css/add_subscription.css"/>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
rel="stylesheet"/>

<script src=
"https://cdn.jsdelivr.net/npm/chart.js">
</script>

<link rel="stylesheet" href="../css/user_dashboard_page.css">
<link rel="stylesheet" href="../css/responsive.css"/>
</head>

<body>

<jsp:include page="../components/user_sidebar.jsp"/>

<jsp:include page="../components/user_navbar.jsp"/>

<div class="content">

<div class="page-head dashboard-animate">

<div>

<h1>Dashboard</h1>

<p>

An overview of your subscription spend.

</p>

</div>

<button class="add-btn"

data-open-subscription-modal>

<i class="fa-solid fa-plus"></i>

Add subscription

</button>

</div>

<div class="stats-grid">

<a class="card stat-card dashboard-animate"
href="../pages/user_analytics.jsp">

<p>MONTHLY SPEND</p>

<h2 class="stat-amount"
data-target="<%= Math.round(monthlySpend) %>"
data-currency="true">

&#8377;0

</h2>

<span>

Current monthly cost

</span>

</a>

<a class="card stat-card dashboard-animate"
href="../pages/user_analytics.jsp">

<p>YEARLY PROJECTION</p>

<h2 class="stat-amount"
data-target="<%= Math.round(yearlyProjection) %>"
data-currency="true">

&#8377;0

</h2>

<span>

Based on billing cycle

</span>

</a>

<a class="card stat-card dashboard-animate"
href="../pages/user_renewals.jsp">

<p>RENEWING THIS WEEK</p>

<h2 class="stat-amount"
data-target="<%= renewingWeek %>">

0

</h2>

<span>

Next 7 days

</span>

</a>

<a class="card stat-card dashboard-animate"
href="../pages/user_analytics.jsp">

<p>AVG / SERVICE</p>

<h2 class="stat-amount"
data-target="<%= Math.round(avgService) %>"
data-currency="true">

&#8377;0

</h2>

<span>

Per month

</span>

</a>

</div>

<div class="card graph-card dashboard-animate">

<div class="graph-card-header">

<div>

<h3>

Monthly spending

</h3>

<p>

Monthly equivalent by subscription

</p>

</div>

</div>

<div class="spend-chart-wrap">

    <canvas id="spendChart"></canvas>

</div>

</div>

<div class="card subs-card">

<div class="subs-header">

<h3>Your subscriptions</h3>

<p>Manage your active subscription plans</p>

</div>

<%

if(hasSubs){

%>

<div class="top-subs">

<%

for(Subscription s : displayedSubs){

String logoPath =
"../images/default.png";

String subName =
s.getSubscriptionName().toLowerCase();

if(subName.contains("youtube"))
logoPath="../images/youtubepremium.png";

else if(subName.contains("apple tv+"))
logoPath="../images/appletv+.png";

else if(subName.contains("hotstar"))
logoPath="../images/jiohotstar.png";

else if(subName.contains("hoichoi"))
logoPath="../images/hoichoi.png";

else if(subName.contains("fancode"))
logoPath="../images/fancode.png";

else if(subName.contains("zee5"))
logoPath="../images/zee5.png";

else if(subName.contains("netflix"))
logoPath="../images/netflix.png";

else if(subName.contains("amazon prime video"))
logoPath="../images/amazonprimevideo.png";

else if(subName.contains("mx player"))
logoPath="../images/mxplayer.png";

else if(subName.contains("sony liv"))
logoPath="../images/sonyliv.png";

%>

<div class="sub-item">

<div>

<div class="sub-top">

<div class="sub-logo">

<img src="<%=logoPath%>">

</div>

<div>

<div class="sub-name">

<%= s.getSubscriptionName() %>

</div>

<div class="sub-plan">

<%= s.getPlanName() %>

</div>

</div>

</div>

<div class="sub-price">

₹<%= (int)s.getAmount() %>

</div>

</div>

<div class="sub-footer">

<div class="billing">

<%= s.getBillingCycle() %>

</div>

</div>

</div>

<%

}

%>

</div>

<div class="view-all-wrap">

<a class="view-all"

href="<%=request.getContextPath()%>/pages/user_subscriptions.jsp">

View All

</a>

</div>

<%

}else{

%>

<div class="empty-state subs-empty-state">

<div class="empty-sub-icon">

<i class="fa-solid fa-credit-card"></i>

</div>

<h2>No subscriptions yet</h2>

<p>

Your active subscriptions will appear here once they are added.

</p>

</div>

<%

}

%>

</div>
<%@ include file="../components/add_subscription.jsp"%>

<%@ include file="../components/manage_account.jsp"%>

<template id="dashboardSpendData">
{
"labels":[

<%
int animatedChartIndex = 0;

for(String name : subscriptionMonthlySpend.keySet()){

if(animatedChartIndex++ > 0)
out.print(",");

out.print(jsonString(name));

}
%>

],
"values":[

<%
animatedChartIndex = 0;

for(Double value : subscriptionMonthlySpend.values()){

if(animatedChartIndex++ > 0)
out.print(",");

out.print(value == null ? 0 : Math.round(value));

}
%>

]
}
</template>
<script src="../js/user_dashboard.js"></script>

</body>

</html>
