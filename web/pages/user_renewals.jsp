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

<style>

.renewal-grid{

display:grid;

grid-template-columns:
repeat(auto-fit,minmax(240px,1fr));

gap:18px;

margin-top:24px;

}

.renew-card{

position:relative;

padding:18px;

border-radius:22px;

background:
linear-gradient(
180deg,
rgba(9,12,40,.95),
rgba(3,6,25,.98)
);

border:
1px solid rgba(255,255,255,.05);

backdrop-filter:
blur(18px);

display:flex;

flex-direction:column;

justify-content:space-between;

min-height:240px;

overflow:hidden;

transition:
transform .35s ease,
box-shadow .35s ease,
border .35s ease;

}

.renew-card:hover{

transform:
translateY(-6px);

box-shadow:
0 12px 28px rgba(0,0,0,.30);

border:
1px solid rgba(124,92,255,.30);

}

.renew-card::before{

content:"";

position:absolute;

top:-40px;

right:-40px;

width:120px;

height:120px;

background:
rgba(124,92,255,.12);

filter:blur(60px);

border-radius:50%;

}

.logo-circle{

width:52px;

height:52px;

border-radius:14px;

background:
rgba(255,255,255,.06);

display:flex;

justify-content:center;

align-items:center;

overflow:hidden;

margin-bottom:14px;

}

.subscription-logo{

width:32px;

height:32px;

object-fit:contain;

}

.renew-title{

font-size:18px;

font-weight:700;

line-height:1.3;

word-break:break-word;

}

.plan{

font-size:12px;

opacity:.65;

margin-top:4px;

margin-bottom:2px;

}

.price{

display:flex;

align-items:flex-start;

margin-top:12px;

margin-bottom:14px;

}

.currency{

font-size:18px;

font-weight:700;

margin-top:5px;

margin-right:2px;

}

.amount{

font-size:38px;

font-weight:800;

line-height:1;

letter-spacing:-1px;

}

.billing{

display:inline-flex;

align-items:center;

padding:6px 12px;

border-radius:16px;

font-size:11px;

font-weight:600;

background:
rgba(124,92,255,.16);

color:#d9d4ff;

width:fit-content;

margin-bottom:12px;

}

.card-footer{

border-top:
1px solid rgba(255,255,255,.06);

padding-top:14px;

margin-top:6px;

}

.info-row{

display:flex;

justify-content:space-between;

align-items:center;

font-size:12px;

margin-bottom:12px;

opacity:.85;

gap:10px;

}

.info-row span:last-child{

text-align:right;

font-weight:600;

}

.days-left{

display:inline-flex;

align-items:center;

justify-content:center;

padding:8px 12px;

border-radius:22px;

font-size:11px;

font-weight:700;

background:
linear-gradient(
90deg,
#7c5cff,
#a855f7
);

color:white;

width:fit-content;

}

/* Due Soon */

.renew-card.urgent .days-left{

background:
linear-gradient(
90deg,
#ef4444,
#dc2626
);

}

/* Empty State */

.empty-state{

position:relative;

padding:58px 30px;

text-align:center;

border-radius:26px;

background:
radial-gradient(
circle at 50% 0%,
rgba(124,92,255,.1),
transparent 42%
),
linear-gradient(
180deg,
rgba(9,12,40,.95),
rgba(3,6,25,.98)
);

border:
1px solid rgba(124,92,255,.16);

backdrop-filter:
blur(18px);

overflow:hidden;

transition:
transform .35s ease,
box-shadow .35s ease;

display:flex;

flex-direction:column;

justify-content:center;

align-items:center;

min-height:240px;

grid-column:1/-1;

}

.empty-state:hover{

transform:
translateY(-6px);

box-shadow:
0 12px 28px rgba(0,0,0,.30);

border:
1px solid rgba(124,92,255,.30);

}

.empty-state::before{

content:"";

position:absolute;

top:-90px;

left:50%;

width:240px;

height:240px;

background:
rgba(124,92,255,.1);

filter:blur(75px);

border-radius:50%;

transform:translateX(-50%);

pointer-events:none;

}

.empty-icon{

position:relative;

z-index:1;

width:70px;

height:70px;

margin-bottom:20px;

display:flex;

align-items:center;

justify-content:center;

border:
1px solid rgba(255,255,255,.1);

border-radius:22px;

background:
linear-gradient(
145deg,
rgba(124,92,255,.25),
rgba(34,211,238,.12)
);

box-shadow:
0 16px 36px rgba(0,0,0,.2),
inset 0 1px 0 rgba(255,255,255,.08);

}

.empty-icon i{

font-size:28px;

color:#73e4ff;

}

.empty-state-clear .empty-icon{

background:
linear-gradient(
145deg,
rgba(16,185,129,.22),
rgba(34,211,238,.12)
);

}

.empty-state-clear .empty-icon i{

color:#66edbd;

}

.empty-eyebrow{

position:relative;

z-index:1;

margin-bottom:10px;

color:#65ddff;

font-size:11px;

font-weight:700;

letter-spacing:.12em;

text-transform:uppercase;

}

.empty-title{

position:relative;

z-index:1;

font-size:25px;

font-weight:700;

margin-bottom:10px;

}

.empty-text{

position:relative;

z-index:1;

color:rgba(255,255,255,.62);

font-size:14px;

max-width:440px;

line-height:1.7;

}

/* Responsive */

@media(max-width:768px){

.renewal-grid{

grid-template-columns:1fr;

gap:16px;

}

.renew-card{

min-height:220px;

padding:16px;

}

.amount{

font-size:34px;

}

.logo-circle{

width:48px;

height:48px;

}

.subscription-logo{

width:28px;

height:28px;

}

}

</style>
<link rel="stylesheet" href="../css/responsive.css">

</head>

<body>

<jsp:include page="../components/user_sidebar.jsp"/>

<jsp:include page="../components/user_navbar.jsp"/>

<div class="content">

<h1>Renewals</h1>

<p style="margin:4px 0 0;color:#a7b4d8;font-size:14px;font-weight:400;">Next 30 days of recurring charges.</p>

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
