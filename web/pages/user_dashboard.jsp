<%@ page contentType="text/html;charset=UTF-8"%>

<%@ page import="model.User" %>
<%@ page import="model.Subscription" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="java.util.*" %>

<%!
private String jsString(String value) {
    if (value == null) {
        return "''";
    }

    return "'" + value
        .replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\r", "")
        .replace("\n", "\\n") + "'";
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

<style>

.dashboard-animate{

animation:
dashboardFadeUp .72s cubic-bezier(.22,1,.36,1) both;

}

.stat-card{

will-change:transform,opacity;

}

.stats-grid .stat-card:nth-child(1){

animation-delay:.05s;

}

.stats-grid .stat-card:nth-child(2){

animation-delay:.13s;

}

.stats-grid .stat-card:nth-child(3){

animation-delay:.21s;

}

.stats-grid .stat-card:nth-child(4){

animation-delay:.29s;

}

.stat-card h2,
.stat-amount{

display:inline-flex;
align-items:baseline;
min-width:max-content;
animation:
amountGlow 1.65s ease both;
transition:
transform .24s ease,
text-shadow .24s ease;

}

.stat-card.is-counting h2,
.stat-card:hover h2{

transform:translateY(-2px);
text-shadow:0 0 22px rgba(124,92,255,.32);

}

.graph-card{

overflow:hidden;

}

.graph-card{

animation-delay:.38s;
overflow:hidden;

}

.graph-card canvas{

opacity:0;
transform:translateY(14px) scale(.985);

}

.graph-card canvas{

animation:
chartFadeIn .85s cubic-bezier(.22,1,.36,1) .62s both;

}

@keyframes dashboardFadeUp{

from{
opacity:0;
transform:translateY(22px) scale(.985);
}

to{
opacity:1;
transform:translateY(0) scale(1);
}

}

@keyframes chartFadeIn{

to{
opacity:1;
transform:translateY(0) scale(1);
}

}

@keyframes amountGlow{

0%{
opacity:.35;
transform:translateY(10px) scale(.92);
text-shadow:none;
}

60%{
opacity:1;
transform:translateY(-2px) scale(1.08);
text-shadow:0 0 24px rgba(124,92,255,.55);
}

100%{
opacity:1;
transform:translateY(0) scale(1);
text-shadow:none;
}

}

.subs-card{

padding:36px;

margin-top:34px;

width:100%;

height:auto !important;

min-height:0;

display:flex;

flex-direction:column;

align-items:center;

justify-content:flex-start !important;

overflow:visible;

box-sizing:border-box;

}

.subs-header{

width:100%;

text-align:left;

margin-bottom:32px;

}

.subs-header h3{

font-size:30px;

font-weight:700;

margin:0;

}

.subs-header p{

margin:8px 0 0;

opacity:.7;

}

.top-subs{

width:100%;

display:grid;

grid-template-columns:
repeat(3,minmax(0,1fr));

gap:24px;

}

.sub-item{

position:relative;

padding:28px;

border-radius:28px;

background:

linear-gradient(
145deg,
rgba(8,12,40,.98),
rgba(3,6,24,.98)
);

border:
1px solid rgba(255,255,255,.06);

overflow:hidden;

min-height:240px;

display:flex;

flex-direction:column;

justify-content:space-between;

transition:.25s ease;

}

.sub-item:hover{

transform:translateY(-4px);

border:
1px solid rgba(124,92,255,.22);

box-shadow:
0 12px 30px rgba(0,0,0,.25);

}

.sub-item::after{

content:"";

position:absolute;

right:-50px;

top:-50px;

width:140px;

height:140px;

border-radius:50%;

background:

rgba(124,92,255,.08);

filter:blur(60px);

}

.sub-top{

display:flex;

align-items:center;

gap:16px;

position:relative;

z-index:2;

}

.sub-logo{

width:64px;

height:64px;

border-radius:18px;

background:
rgba(255,255,255,.06);

display:flex;

justify-content:center;

align-items:center;

overflow:hidden;

flex-shrink:0;

}

.sub-logo img{

width:42px;

height:42px;

object-fit:contain;

}

.sub-name{

font-size:26px;

font-weight:700;

line-height:1.1;

}

.sub-plan{

margin-top:5px;

font-size:13px;

opacity:.65;

}

.sub-price{

margin-top:28px;

font-size:52px;

font-weight:800;

line-height:1;

position:relative;

z-index:2;

}

.sub-footer{

margin-top:28px;

display:flex;

justify-content:flex-start;

align-items:flex-end;

position:relative;

z-index:2;

}

.billing{

padding:8px 14px;

border-radius:18px;

font-size:12px;

font-weight:600;

background:

rgba(124,92,255,.18);

}

.view-all-wrap{

width:100%;

display:flex;

justify-content:center;

margin-top:34px;

}

.view-all{

padding:12px 28px;

border-radius:22px;

background:

linear-gradient(
90deg,
#7c5cff,
#9d6dff
);

color:white;

font-weight:600;

text-decoration:none;

box-shadow:
0 8px 20px rgba(124,92,255,.25);

transition:
transform .3s ease,
box-shadow .3s ease,
filter .3s ease;

}

.view-all:hover{

transform:
translateY(-4px)
scale(1.06);

box-shadow:
0 14px 32px rgba(124,92,255,.55);

filter:brightness(1.12);

}

.subs-empty-state{

position:relative;

width:100%;

min-height:260px;

padding:38px 28px;

display:flex;

flex-direction:column;

justify-content:center;

align-items:center;

text-align:center;

border:
1px dashed rgba(124,92,255,.24);

border-radius:24px;

background:
radial-gradient(
circle at 50% 0%,
rgba(124,92,255,.1),
transparent 45%
),
rgba(255,255,255,.018);

overflow:hidden;

box-sizing:border-box;

}

.subs-empty-state::before{

content:"";

position:absolute;

top:-90px;

left:50%;

width:220px;

height:220px;

border-radius:50%;

background:
rgba(34,211,238,.08);

filter:blur(70px);

transform:translateX(-50%);

pointer-events:none;

}

.empty-sub-icon{

position:relative;

z-index:1;

width:72px;

height:72px;

margin-bottom:20px;

display:flex;

justify-content:center;

align-items:center;

border:
1px solid rgba(255,255,255,.1);

border-radius:22px;

background:
linear-gradient(
145deg,
rgba(124,92,255,.24),
rgba(34,211,238,.12)
);

box-shadow:
0 16px 36px rgba(0,0,0,.2),
inset 0 1px 0 rgba(255,255,255,.08);

}

.subs-empty-state .empty-sub-icon i{

margin:0;

color:#73e4ff;

font-size:28px;

}

.subs-empty-state h2{

position:relative;

z-index:1;

margin:0 0 10px;

font-size:30px;

font-weight:750;

letter-spacing:-.6px;

}

.subs-empty-state p{

position:relative;

z-index:1;

max-width:470px;

margin:0 0 24px;

color:rgba(255,255,255,.62);

font-size:15px;

line-height:1.65;

opacity:1;

}

@media(max-width:1350px){

.top-subs{

grid-template-columns:
repeat(2,1fr);

}

}

@media(max-width:850px){

.top-subs{

grid-template-columns:
1fr;

}

.sub-item{

min-height:220px;

}

.subs-empty-state{

min-height:240px;

padding:34px 20px;

}

}
</style>
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

onclick="openModal()">

<i class="fa-solid fa-plus"></i>

Add subscription

</button>

</div>

<div class="stats-grid">

<div class="card stat-card dashboard-animate">

<p>MONTHLY SPEND</p>

<h2 class="stat-amount"
data-target="<%= Math.round(monthlySpend) %>"
data-currency="true">

&#8377;0

</h2>

<span>

Current monthly cost

</span>

</div>

<div class="card stat-card dashboard-animate">

<p>YEARLY PROJECTION</p>

<h2 class="stat-amount"
data-target="<%= Math.round(yearlyProjection) %>"
data-currency="true">

&#8377;0

</h2>

<span>

Based on billing cycle

</span>

</div>

<div class="card stat-card dashboard-animate">

<p>RENEWING THIS WEEK</p>

<h2 class="stat-amount"
data-target="<%= renewingWeek %>">

0

</h2>

<span>

Next 7 days

</span>

</div>

<div class="card stat-card dashboard-animate">

<p>AVG / SERVICE</p>

<h2 class="stat-amount"
data-target="<%= Math.round(avgService) %>"
data-currency="true">

&#8377;0

</h2>

<span>

Per month

</span>

</div>

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

<script>

var dashboardReduceMotion = false;

function formatDashboardNumber(value){

return Math.round(value).toLocaleString(
"en-IN"
);

}

function findDashboardCard(element){

while(element && !element.classList.contains("stat-card")){

element =
element.parentElement;

}

return element;

}

function animateDashboardAmount(amountElement){

var target =
Number(
amountElement.getAttribute("data-target") || 0
);

var isCurrency =
amountElement.getAttribute("data-currency") === "true";

var prefix =
isCurrency
? "\u20B9"
: "";

var parentCard =
findDashboardCard(amountElement);

if(dashboardReduceMotion){

amountElement.textContent =
prefix + formatDashboardNumber(target);

return;

}

var duration = 1350;
var startTime =
performance.now();

if(parentCard){

parentCard.classList.add(
"is-counting"
);

}

function step(now){

var progress =
Math.min(
(now - startTime) / duration,
1
);

var eased =
1 - Math.pow(
1 - progress,
3
);

amountElement.textContent =
prefix + formatDashboardNumber(
target * eased
);

if(progress < 1){

requestAnimationFrame(
step
);

}else{

amountElement.textContent =
prefix + formatDashboardNumber(target);

if(parentCard){

parentCard.classList.remove(
"is-counting"
);

}

}

}

requestAnimationFrame(
step
);

}

function runDashboardAnimations(){

var animatedElements =
document.querySelectorAll(
".page-head, .stat-card, .graph-card"
);

for(var i = 0; i < animatedElements.length; i++){

animatedElements[i].classList.add(
"dashboard-animate"
);

}

requestAnimationFrame(function(){

for(var i = 0; i < animatedElements.length; i++){

animatedElements[i].classList.add(
"is-visible"
);

}

});

var amountElements =
document.querySelectorAll(
".stat-amount"
);

setTimeout(function(){

for(var i = 0; i < amountElements.length; i++){

animateDashboardAmount(
amountElements[i]
);

}

}, 180);

}

if(document.readyState === "loading"){

document.addEventListener(
"DOMContentLoaded",
runDashboardAnimations
);

}else{

runDashboardAnimations();

}

var dashboardSpendLabels = [

<%
int animatedChartIndex = 0;

for(String name : subscriptionMonthlySpend.keySet()){

if(animatedChartIndex++ > 0)
out.print(",");

out.print(jsString(name));

}
%>

];

var dashboardSpendValues = [

<%
animatedChartIndex = 0;

for(Double value : subscriptionMonthlySpend.values()){

if(animatedChartIndex++ > 0)
out.print(",");

out.print(value == null ? 0 : Math.round(value));

}
%>

];

var dashboardSinglePoint =
dashboardSpendValues.length === 1;

var dashboardChartLabels =
dashboardSinglePoint
? ["", dashboardSpendLabels[0], ""]
: dashboardSpendLabels;

var dashboardChartValues =
dashboardSinglePoint
? [
dashboardSpendValues[0],
dashboardSpendValues[0],
dashboardSpendValues[0]
]
: dashboardSpendValues;

var dashboardRealPoints =
dashboardSinglePoint
? [false,true,false]
: dashboardSpendValues.map(function(){
return true;
});

var spendChart =
new Chart(

document.getElementById(
"spendChart"),

{

type:"line",

data:{

labels:dashboardChartLabels,

datasets:[{

data:dashboardChartValues.map(function(){
return 0;
}),

fill:true,

backgroundColor:function(context){

var chart =
context.chart;

var area =
chart.chartArea;

if(!area){

return "#7c5cff";
}

var gradient =
chart.ctx.createLinearGradient(
0,
area.top,
0,
area.bottom
);

gradient.addColorStop(
0,
"rgba(34,211,238,.30)"
);

gradient.addColorStop(
1,
"rgba(124,92,255,.03)"
);

return gradient;

},

borderColor:"#7c5cff",

borderWidth:3,

pointBackgroundColor:"#22d3ee",

pointBorderColor:"#ffffff",

pointBorderWidth:2,

pointRadius:function(context){

return dashboardRealPoints[
context.dataIndex
]
? 6
: 0;

},

pointHoverRadius:function(context){

return dashboardRealPoints[
context.dataIndex
]
? 8
: 0;

},

pointHitRadius:18,

tension:.38,

spanGaps:true

}]

},

options:{

responsive:true,

maintainAspectRatio:false,

interaction:{

mode:"nearest",

intersect:true

},

animation:{

duration:dashboardReduceMotion ? 0 : 1200,

easing:"easeOutQuart",

delay:function(context){

return context.type === "data"
&& context.mode === "default"
? context.dataIndex * 90
: 0;

}

},

animations:{

tension:{

duration:dashboardReduceMotion ? 0 : 900,

easing:"easeOutQuart",

from:.1,

to:.38

}

},

plugins:{

legend:{

display:false

},

tooltip:{

displayColors:false,

backgroundColor:"#090d19",

borderColor:"rgba(148,163,184,.18)",

borderWidth:1,

padding:12,

cornerRadius:10,

filter:function(context){

return dashboardRealPoints[
context.dataIndex
];

},

callbacks:{

title:function(items){

if(!items.length){

return "";
}

return dashboardSpendLabels[
dashboardSinglePoint
? 0
: items[0].dataIndex
];

},

label:function(context){

return "Monthly spend: \u20B9" +
formatDashboardNumber(
context.parsed.y
);

}

}

},

},

layout:{

padding:{

left:28,

right:28,

top:18

}

},

scales:{

x:{

offset:true,

grid:{

display:false

},

ticks:{

autoSkip:false,

maxRotation:0,

callback:function(value){

var label =
this.getLabelForValue(value);

if(!label){

return "";
}

var words =
String(label).split(" ");

return words.length > 1
? words
: label;

}

}

},

y:{

beginAtZero:true,

suggestedMax:Math.max(
100,
Math.ceil(
Math.max.apply(
null,
dashboardSpendValues.concat([0])
) * 1.2 / 50
) * 50
),

grid:{

color:"rgba(148,163,184,.10)",

borderDash:[3,4],

drawBorder:false

},

ticks:{

maxTicksLimit:6,

padding:10,

callback:function(value){

return "\u20B9" +
formatDashboardNumber(value);

}

}

}

}

}

}

);

setTimeout(function(){

spendChart.data.datasets[0].data =
dashboardChartValues;

spendChart.update();

}, 450);

/* ADD SUBSCRIPTION MODAL FIX */

var subscriptionModal =

document.getElementById(
"subscriptionModal"
);

function openModal(){

if(subscriptionModal){

subscriptionModal.classList.add(
"show"
);

document.body.style.overflow =
"hidden";

}

}

function closeModal(){

if(subscriptionModal){

subscriptionModal.classList.remove(
"show"
);

document.body.style.overflow =
"auto";

}

}

window.onclick = function(e){

if(

subscriptionModal &&

e.target === subscriptionModal

){

closeModal();

}

};

</script>

</body>

</html>
