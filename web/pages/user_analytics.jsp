<%@ page contentType="text/html;charset=UTF-8"%>

<%@ page import="model.User"%>
<%@ page import="dao.AnalyticsDAO"%>
<%@ page import="model.LeastUsedSubscription"%>
<%@ page import="java.util.*"%>

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
User user = (User) session.getAttribute("user");

if (user == null) {
    response.sendRedirect(request.getContextPath() + "/pages/signin.jsp");
    return;
}

AnalyticsDAO dao = new AnalyticsDAO();
List<LeastUsedSubscription> leastUsedSubscriptions =
dao.getLeastUsedSubscriptions(
user.getUserId()
);

Map<String, Double> services =
dao.getServiceCosts(
user.getUserId()
);

Map<String, Integer> renewalData =
dao.getRenewalDistribution(
user.getUserId()
);

if (services == null) {
    services = new LinkedHashMap<String, Double>();
}

double totalMonthlySpend = dao.getTotalMonthlySpend(user.getUserId());
boolean hasAnalytics = !services.isEmpty();
%>

<html>

<head>
    <%@ include file="../components/site_tab.jsp" %>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="../css/user_dashboard.css">
    <link rel="stylesheet" href="../css/user_analytics.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

    
    <link rel="stylesheet" href="../css/responsive.css">
</head>

<body>

<jsp:include page="../components/user_sidebar.jsp"/>
<jsp:include page="../components/user_navbar.jsp"/>

<div class="content">
    <div class="analytics-header">
        <div class="analytics-title-block">
            <h1>Analytics</h1>

            <p class="analytics-subtitle">
                Understand where your money goes.
            </p>
        </div>

        <button class="analytics-download" type="button" id="downloadAnalyticsPdf">
            <i class="fa-solid fa-file-arrow-down" aria-hidden="true"></i>
            <span>Download PDF</span>
        </button>
    </div>

    <div class="analytics-grid">
        <div class="card analytics-card">
            <div class="card-header">
                <h3>Renewal distribution</h3>
<span class="chart-caption">
Upcoming renewals by month
</span>
            </div>

            <% if (hasAnalytics) { %>
            <div class="chart-wrap">
                <canvas id="trendChart"></canvas>
            </div>
            <% } else { %>
            <div class="analytics-empty">
                <div class="analytics-empty-icon">
                    <i class="fa-solid fa-calendar-days"></i>
                </div>
                <div class="analytics-empty-title">No renewal data yet</div>
                <div class="analytics-empty-text">
                    Renewal trends will appear here after subscriptions are added.
                </div>
            </div>
            <% } %>
        </div>

        <div class="card analytics-card">
            <div class="card-header">
                <h3>Cost per service</h3>
                <span class="chart-caption"></span>
            </div>

            <% if (hasAnalytics) { %>
            <div class="pie-service-layout">
                <div class="chart-wrap donut-wrap">
                    <canvas id="serviceChart"></canvas>
                </div>
                <div class="service-legend" id="serviceLegend"></div>
            </div>
            <% } else { %>
            <div class="analytics-empty">
                <div class="analytics-empty-icon">
                    <i class="fa-solid fa-chart-pie"></i>
                </div>
                <div class="analytics-empty-title">No service costs yet</div>
                <div class="analytics-empty-text">
                    Add subscription records to compare how your spending is distributed.
                </div>
            </div>
            <% } %>
        </div>

        <div class="card analytics-card full-width">
            <div class="card-header">
                <h3>Cost by service</h3>
                <span class="chart-caption">Monthly equivalent</span>
            </div>

            <% if (hasAnalytics) { %>
            <div class="chart-wrap">
                <canvas id="costChart"></canvas>
            </div>
            <% } else { %>
            <div class="analytics-empty">
                <div class="analytics-empty-icon">
                    <i class="fa-solid fa-chart-column"></i>
                </div>
                <div class="analytics-empty-title">No spending data yet</div>
                <div class="analytics-empty-text">
                    Monthly service costs will be visualized here once data is available.
                </div>
            </div>
            <% } %>
        </div>

        <div class="card analytics-card full-width least-used-card">
            <div class="card-header">
                <h3>Least used subscriptions</h3>
                <span class="chart-caption">Review services you may only watch occasionally</span>
            </div>

            <% if (hasAnalytics && !leastUsedSubscriptions.isEmpty()) { %>
<div class="least-used-grid">

<%
for(
LeastUsedSubscription sub :
leastUsedSubscriptions
){
%>

<button
class="least-used-item"
type="button"
data-subscription-modal
data-subscription-name="<%=sub.getSubscriptionName()%>"
data-plan-name="<%=sub.getPlanName()%>"
data-billing-cycle="<%=sub.getBillingCycle()%>"
data-usage-count="<%=sub.getUsageCount()%>"
data-most-used-month="<%=sub.getMostUsedMonth()%>">

<%
String imageName =
sub.getSubscriptionName()
.toLowerCase()
.replace(" ", "");
%>

<img
src="../images/<%=imageName%>.png"
alt="<%=sub.getSubscriptionName()%>"
class="least-used-logo">

<span>

<span class="least-used-name">
<%=sub.getSubscriptionName()%>
</span>

<span class="least-used-meta">

₹<%=sub.getAmount()%>

•

<%=sub.getBillingCycle()%>

<br>

Used
<%=sub.getUsageCount()%>
time(s)

</span>

</span>

</button>

<%
}
%>

</div>            <% } else { %>
            <div class="analytics-empty">
                <div class="analytics-empty-icon">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                </div>
                <div class="analytics-empty-title">No usage insights yet</div>
                <div class="analytics-empty-text">
                    Subscription usage insights will appear after services are tracked.
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<div class="subscription-modal" id="subscriptionModal" aria-hidden="true">
    <div class="subscription-dialog" role="dialog" aria-modal="true" aria-labelledby="subscriptionModalTitle">
        <div class="subscription-dialog-header">
            <h3 class="subscription-dialog-title" id="subscriptionModalTitle">Subscription review</h3>
            <button class="subscription-modal-close" type="button" id="subscriptionModalClose" aria-label="Close">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <p class="subscription-dialog-copy" id="subscriptionModalCopy"></p>
        <p class="subscription-dialog-tip" id="subscriptionModalTip"></p>
    </div>
</div>

<%@ include file="../components/manage_account.jsp"%>

<template id="analyticsData">
{
"serviceLabels":[
<%
int i = 0;

for (String key : services.keySet()) {
    if (i++ > 0) {
        out.print(",");
    }

    out.print(jsonString(key));
}
%>
],
"serviceValues":[
<%
i = 0;

for (Double value : services.values()) {
    if (i++ > 0) {
        out.print(",");
    }

    out.print(value == null ? 0 : value);
}
%>
],
"trendLabels":[
<%
int renewalPdfIndex = 0;

for(String month : renewalData.keySet()){

    if(renewalPdfIndex++ > 0){
        out.print(",");
    }

    out.print(jsonString(month));
}
%>
],
"trendValues":[
<%
renewalPdfIndex = 0;

for(Integer count : renewalData.values()){

    if(renewalPdfIndex++ > 0){
        out.print(",");
    }

    out.print(count);
}
%>
],
"totalMonthlySpend":<%= totalMonthlySpend %>,
"leastUsedRecords":[
<%
int leastPdfIndex = 0;

for (LeastUsedSubscription sub : leastUsedSubscriptions) {
    if (leastPdfIndex++ > 0) {
        out.print(",");
    }

    out.print("{");
    out.print("\"name\":" + jsonString(sub.getSubscriptionName()));
    out.print(",\"plan\":" + jsonString(sub.getPlanName()));
    out.print(",\"cycle\":" + jsonString(sub.getBillingCycle()));
    out.print(",\"amount\":" + sub.getAmount());
    out.print(",\"usageCount\":" + sub.getUsageCount());
    out.print(",\"mostUsedMonth\":" + jsonString(sub.getMostUsedMonth()));
    out.print("}");
}
%>
]
}
</template>
<script src="../js/user_analytics.js"></script>

</body>

</html>
