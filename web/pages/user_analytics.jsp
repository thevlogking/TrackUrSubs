<%@ page contentType="text/html;charset=UTF-8"%>

<%@ page import="model.User"%>
<%@ page import="dao.AnalyticsDAO"%>
<%@ page import="model.LeastUsedSubscription"%>
<%@ page import="java.util.*"%>

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
    <title>Analytics</title>

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="../css/user_dashboard.css">
    <link rel="stylesheet" href="../css/user_analytics.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

    <style>
        .content {
            min-height: 100vh;
            box-sizing: border-box;
            padding: 118px 6vw 56px;
            color: #f8fafc;
            background:
                radial-gradient(circle at 12% 6%, rgba(38, 56, 119, .28), transparent 34%),
                radial-gradient(circle at 76% 0%, rgba(107, 30, 92, .24), transparent 32%),
                linear-gradient(125deg, #07101e 0%, #0a0d18 45%, #120818 100%);
        }

        .content h1 {
            position: relative;
            z-index: 1;
            margin: 0;
            font-size: 34px;
            line-height: 1.05;
            font-weight: 800;
            letter-spacing: 0;
        }

        .analytics-header {
            position: relative;
            z-index: 1;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 18px;
            width: min(100%, 1250px);
            margin-bottom: 26px;
        }

        .analytics-title-block {
            min-width: 0;
        }

        .analytics-subtitle {
            position: relative;
            z-index: 1;
            margin: 6px 0 0;
            color: #9aa4b8;
            font-size: 15px;
        }

        .analytics-download {
            position: relative;
            z-index: 2;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-width: 212px;
            min-height: 53px;
            padding: 0 24px;
            color: #f8fafc;
            font: inherit;
            font-size: 16px;
            font-weight: 800;
            white-space: nowrap;
            border: 0;
            border-radius: 13px;
            background: linear-gradient(100deg, #7554ff 0%, #22c7df 100%);
            cursor: pointer;
            transition: transform .2s ease, box-shadow .2s ease, filter .2s ease;
        }

        .analytics-download:hover,
        .analytics-download:focus-visible {
            transform: translateY(-2px);
            filter: brightness(1.05);
            box-shadow: 0 22px 38px rgba(34, 199, 223, .22), 0 18px 32px rgba(117, 84, 255, .24);
            outline: none;
        }

        .analytics-download:disabled {
            cursor: wait;
            opacity: .72;
            transform: none;
        }

        .analytics-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 24px;
            width: min(100%, 1250px);
        }

        .analytics-card {
            position: relative;
            overflow: hidden;
            min-height: 330px;
            padding: 26px;
            border: 1px solid rgba(148, 163, 184, .18);
            border-radius: 24px;
            background:
                linear-gradient(155deg, rgba(25, 31, 48, .92), rgba(14, 24, 31, .88) 58%, rgba(22, 17, 31, .9)),
                rgba(15, 23, 42, .74);
            box-shadow: 0 24px 60px rgba(0, 0, 0, .34);
        }

        .analytics-card::before {
            content: "";
            position: absolute;
            inset: 0;
            pointer-events: none;
            background:
                linear-gradient(rgba(255, 255, 255, .025) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, .018) 1px, transparent 1px);
            background-size: 4px 4px;
            opacity: .32;
        }

        .card-header {
            position: relative;
            z-index: 1;
            margin-bottom: 18px;
        }

        .card-header h3 {
            margin: 0;
            color: #f8fafc;
            font-size: 17px;
            font-weight: 800;
            letter-spacing: 0;
        }

        .chart-caption {
            display: block;
            margin-top: 3px;
            color: #99a4ba;
            font-size: 13px;
            font-weight: 500;
        }

        .chart-wrap {
            position: relative;
            z-index: 1;
            height: 235px;
        }

        .chart-wrap canvas {
            display: block;
            width: 100% !important;
            height: 100% !important;
        }

        .pie-service-layout {
            position: relative;
            z-index: 1;
            display: grid;
            grid-template-columns: 280px minmax(170px, 1fr);
            gap: 26px;
            align-items: center;
            min-height: 280px;
        }

        .donut-wrap {
            width: 280px;
            height: 280px;
            aspect-ratio: 1 / 1;
            margin: 0;
        }

        .service-legend {
            display: flex;
            flex-direction: column;
            gap: 10px;
            max-height: 236px;
            overflow-y: auto;
            padding-right: 4px;
        }

        .service-legend-item {
            display: grid;
            grid-template-columns: 12px minmax(0, 1fr);
            gap: 10px;
            align-items: center;
            color: #dbe3f2;
            font-size: 13px;
            font-weight: 600;
            line-height: 1.25;
        }

        .service-legend-dot {
            width: 12px;
            height: 12px;
            border-radius: 999px;
            box-shadow: 0 0 0 2px rgba(255, 255, 255, .16);
        }

        .service-legend-name {
            min-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .full-width {
            grid-column: 1 / -1;
            min-height: 430px;
        }

        .full-width .chart-wrap {
            height: 335px;
        }

        .analytics-empty {
            position: relative;
            z-index: 1;
            display: flex;
            flex-direction: column;
            min-height: 210px;
            align-items: center;
            justify-content: center;
            padding: 28px;
            text-align: center;
            border: 1px dashed rgba(117, 84, 255, .22);
            border-radius: 18px;
            background:
                radial-gradient(circle at 50% 0%, rgba(117, 84, 255, .1), transparent 48%),
                rgba(15, 23, 42, .2);
            overflow: hidden;
        }

        .analytics-empty::before {
            content: "";
            position: absolute;
            top: -80px;
            left: 50%;
            width: 190px;
            height: 190px;
            border-radius: 50%;
            background: rgba(34, 199, 223, .08);
            filter: blur(65px);
            transform: translateX(-50%);
            pointer-events: none;
        }

        .analytics-empty-icon {
            position: relative;
            z-index: 1;
            display: grid;
            width: 62px;
            height: 62px;
            margin-bottom: 17px;
            place-items: center;
            color: #73e4ff;
            font-size: 24px;
            border: 1px solid rgba(255, 255, 255, .1);
            border-radius: 19px;
            background:
                linear-gradient(145deg, rgba(117, 84, 255, .24), rgba(34, 199, 223, .12));
            box-shadow:
                0 14px 32px rgba(0, 0, 0, .2),
                inset 0 1px 0 rgba(255, 255, 255, .07);
        }

        .analytics-empty-title {
            position: relative;
            z-index: 1;
            margin-bottom: 8px;
            color: #f8fafc;
            font-size: 19px;
            font-weight: 750;
        }

        .analytics-empty-text {
            position: relative;
            z-index: 1;
            max-width: 360px;
            color: #9aa4b8;
            font-size: 13px;
            line-height: 1.65;
        }

        .least-used-card {
            min-height: 0;
        }

        .least-used-grid {
            position: relative;
            z-index: 1;
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
        }

        .least-used-item {
            display: grid;
            grid-template-columns: 42px minmax(0, 1fr) auto;
            gap: 14px;
            align-items: center;
            width: 100%;
            min-height: 96px;
            padding: 16px;
            color: #f8fafc;
            text-align: left;
            border: 1px solid rgba(148, 163, 184, .18);
            border-radius: 8px;
            background: rgba(15, 23, 42, .56);
            cursor: pointer;
            transition: transform .2s ease, border-color .2s ease, background .2s ease;
        }

        .least-used-item:hover,
        .least-used-item:focus-visible {
            transform: translateY(-2px);
            border-color: rgba(125, 211, 252, .42);
            background: rgba(30, 41, 59, .68);
            outline: none;
        }

        .least-used-icon {
            display: inline-grid;
            width: 42px;
            height: 42px;
            place-items: center;
            border-radius: 8px;
            color: #fff;
            font-size: 18px;
            box-shadow: 0 10px 26px rgba(0, 0, 0, .22);
        }

        .least-used-name {
            display: block;
            overflow: hidden;
            color: #f8fafc;
            font-size: 15px;
            font-weight: 800;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .least-used-meta {
            display: block;
            margin-top: 5px;
            color: #9aa4b8;
            font-size: 12px;
            font-weight: 600;
        }

        .least-used-action {
            color: #a7f3d0;
            font-size: 16px;
        }

        .subscription-modal {
            position: fixed;
            inset: 0;
            z-index: 50;
            display: none;
            align-items: center;
            justify-content: center;
            padding: 24px;
            background: rgba(2, 6, 23, .72);
            backdrop-filter: blur(12px);
        }

        .subscription-modal.is-open {
            display: flex;
        }

.subscription-dialog {
    width: min(100%, 600px);
            padding: 24px;
            border: 1px solid rgba(148, 163, 184, .22);
            border-radius: 8px;
            background:
                linear-gradient(145deg, rgba(25, 31, 48, .98), rgba(12, 19, 31, .98)),
                #0f172a;
            box-shadow: 0 30px 90px rgba(0, 0, 0, .42);
        }

        .subscription-dialog-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            margin-bottom: 18px;
        }

        .subscription-dialog-title {
            margin: 0;
            color: #f8fafc;
            font-size: 20px;
            font-weight: 800;
            letter-spacing: 0;
        }

        .subscription-modal-close {
            display: inline-grid;
            width: 36px;
            height: 36px;
            place-items: center;
            color: #cbd5e1;
            border: 1px solid rgba(148, 163, 184, .2);
            border-radius: 8px;
            background: rgba(15, 23, 42, .7);
            cursor: pointer;
        }

        .subscription-modal-close:hover,
        .subscription-modal-close:focus-visible {
            color: #fff;
            border-color: rgba(248, 250, 252, .36);
            outline: none;
        }

        .subscription-dialog-copy {
            margin: 0 0 18px;
            color: #dbe3f2;
            font-size: 15px;
            line-height: 1.6;
        }

        .subscription-dialog-tip {
            margin: 0;
            padding: 14px;
            color: #a7f3d0;
            font-size: 13px;
            font-weight: 700;
            line-height: 1.45;
            border: 1px solid rgba(52, 211, 153, .24);
            border-radius: 8px;
            background: rgba(6, 78, 59, .18);
        }

        @media (max-width: 980px) {
            .content {
                padding: 104px 20px 34px;
            }

            .analytics-header {
                align-items: stretch;
                flex-direction: column;
            }

            .analytics-download {
                width: 100%;
            }

            .analytics-grid {
                grid-template-columns: 1fr;
            }

            .analytics-card {
                min-height: 300px;
                padding: 22px;
                border-radius: 20px;
            }

            .pie-service-layout {
                grid-template-columns: 1fr;
                gap: 18px;
            }

            .donut-wrap {
                width: min(280px, 100%);
                height: auto;
                margin: 0 auto;
            }

            .service-legend {
                display: grid;
                grid-template-columns: repeat(2, minmax(0, 1fr));
                max-height: none;
                overflow: visible;
            }

            .least-used-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 560px) {
            .service-legend {
                grid-template-columns: 1fr;
            }

            .full-width .chart-wrap {
                height: 390px;
            }

            .least-used-item {
                grid-template-columns: 38px minmax(0, 1fr) auto;
                padding: 14px;
            }
        }
    </style>
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

onclick="openSubscriptionModal(
'<%=sub.getSubscriptionName()%>',
'<%=sub.getPlanName()%>',
'<%=sub.getBillingCycle()%>',
'<%=sub.getUsageCount()%>',
'<%=sub.getMostUsedMonth()%>'
)">

<%
String imageName =
sub.getSubscriptionName()
.toLowerCase()
.replace(" ", "");
%>

<img
src="../images/<%=imageName%>.png"
alt="<%=sub.getSubscriptionName()%>"
style="
width:42px;
height:42px;
border-radius:8px;
object-fit:contain;
background:#86848400;
padding:4px;
">

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

<script>
const serviceLabels = [
<%
int i = 0;

for (String key : services.keySet()) {
    if (i++ > 0) {
        out.print(",");
    }

    out.print(jsString(key));
}
%>
];

const serviceValues = [
<%
i = 0;

for (Double value : services.values()) {
    if (i++ > 0) {
        out.print(",");
    }

    out.print(value == null ? 0 : value);
}
%>
];

const trendLabels = [
<%
int renewalPdfIndex = 0;

for(String month : renewalData.keySet()){

    if(renewalPdfIndex++ > 0){
        out.print(",");
    }

    out.print(jsString(month));
}
%>
];

const trendValues = [
<%
renewalPdfIndex = 0;

for(Integer count : renewalData.values()){

    if(renewalPdfIndex++ > 0){
        out.print(",");
    }

    out.print(count);
}
%>
];

const totalMonthlySpend = <%= totalMonthlySpend %>;
const leastUsedRecords = [
<%
int leastPdfIndex = 0;

for (LeastUsedSubscription sub : leastUsedSubscriptions) {
    if (leastPdfIndex++ > 0) {
        out.print(",");
    }

    out.print("{");
    out.print("name:" + jsString(sub.getSubscriptionName()));
    out.print(",plan:" + jsString(sub.getPlanName()));
    out.print(",cycle:" + jsString(sub.getBillingCycle()));
    out.print(",amount:" + sub.getAmount());
    out.print(",usageCount:" + sub.getUsageCount());
    out.print(",mostUsedMonth:" + jsString(sub.getMostUsedMonth()));
    out.print("}");
}
%>
];
const palette = [
    "#ef0d18",
    "#f59e0b",
    "#a3a3a8",
    "#fb0a3f",
    "#22c55e",
    "#3b82f6",
    "#f97316",
    "#8b5cf6",
    "#06b6d4",
    "#eab308",
    "#14b8a6",
    "#ec4899",
    "#84cc16",
    "#64748b",
    "#f43f5e",
    "#0ea5e9"
];

const gridColor = "rgba(148, 163, 184, .10)";
const tickColor = "#9aa4b8";
const rupee = "\u20B9";

const getServiceColor = (index) => {
    if (palette[index]) {
        return palette[index];
    }

    return "hsl(" + ((index * 47) % 360) + ", 82%, 56%)";
};

const serviceColors = serviceLabels.map((_, index) => getServiceColor(index));
const formatMoney = (value) => rupee + Number(value || 0).toFixed(2);

const wrapLabel = (label, limit = 12) => {
    const words = String(label).split(" ");
    const lines = [];
    let currentLine = "";

    words.forEach((word) => {
        const nextLine = currentLine ? currentLine + " " + word : word;

        if (nextLine.length > limit && currentLine) {
            lines.push(currentLine);
            currentLine = word;
        } else {
            currentLine = nextLine;
        }
    });

    if (currentLine) {
        lines.push(currentLine);
    }

    return lines.length ? lines : [String(label)];
};

const escapeHtml = (value) => String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

const renderServiceLegend = () => {
    const legend = document.getElementById("serviceLegend");

    if (!legend) {
        return;
    }

    legend.innerHTML = serviceLabels.map((label, index) => {
        const safeLabel = escapeHtml(label);
        const color = serviceColors[index];
        return (
            '<div class="service-legend-item" title="' + safeLabel + '">' +
                '<span class="service-legend-dot" style="background:' + color + '"></span>' +
                '<span class="service-legend-name">' + safeLabel + '</span>' +
            '</div>'
        );
    }).join("");
};


function openSubscriptionModal(

subscriptionName,
planName,
billingCycle,
usageCount,
mostUsedMonth

){

    const modal =
    document.getElementById(
    "subscriptionModal"
    );

    const title =
    document.getElementById(
    "subscriptionModalTitle"
    );

    const copy =
    document.getElementById(
    "subscriptionModalCopy"
    );

    const tip =
    document.getElementById(
    "subscriptionModalTip"
    );

    title.textContent =
    subscriptionName;

    copy.innerHTML =

    "<strong>Usage Count:</strong> "
    + usageCount +

    "<br><br>" +

    "<strong>Most Used Period:</strong> "
    +
    (
        mostUsedMonth &&
        mostUsedMonth !== "null"

        ? mostUsedMonth

        : "No usage data available"
    );

    tip.innerHTML =

    "This subscription has one of your lowest usage counts." +

    "<br><br>" +

    (
        mostUsedMonth &&
        mostUsedMonth !== "null"

        ?

        "Most activity was recorded during <b>"
        + mostUsedMonth +
        "</b>."

        :

        "No recent usage activity was found."
    )

    +

    "<br><br>" +

    "Consider switching to a cheaper plan, pausing the subscription, or cancelling it if you no longer use it regularly.";

    modal.classList.add(
    "is-open"
    );

    modal.setAttribute(
    "aria-hidden",
    "false"
    );
}

const closeSubscriptionModal = () => {
    const modal = document.getElementById("subscriptionModal");

    if (!modal) {
        return;
    }

    modal.classList.remove("is-open");
    modal.setAttribute("aria-hidden", "true");
};


document.addEventListener("click", (event) => {
    if (event.target.id === "subscriptionModal" || event.target.closest("#subscriptionModalClose")) {
        closeSubscriptionModal();
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
        closeSubscriptionModal();
    }
});

Chart.defaults.font.family = "Inter, system-ui, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif";
Chart.defaults.color = tickColor;

const staggeredDelay = (context) => {
    if (context.type === "data" && context.mode === "default") {
        return context.dataIndex * 120;
    }

    return 0;
};

const renewalSinglePoint = trendValues.length === 1;
const renewalChartLabels = renewalSinglePoint
    ? ["", trendLabels[0], ""]
    : trendLabels;
const renewalChartValues = renewalSinglePoint
    ? [trendValues[0], trendValues[0], trendValues[0]]
    : trendValues;
const renewalRealPoints = renewalSinglePoint
    ? [false, true, false]
    : trendValues.map(() => true);

const createAnalyticsCharts = () => {
    if (!serviceLabels.length) {
        return;
    }

    renderServiceLegend();

    new Chart(document.getElementById("trendChart"), {
        type: "line",
        data: {
            labels: renewalChartLabels,
            datasets: [{
                data: renewalChartValues,
                backgroundColor: (context) => {
                    const {chart} = context;
                    const {ctx, chartArea} = chart;

                    if (!chartArea) {
                        return "#22d3ee";
                    }

                    const gradient = ctx.createLinearGradient(
                        0,
                        chartArea.top,
                        0,
                        chartArea.bottom
                    );

                    gradient.addColorStop(0, "rgba(34, 211, 238, .30)");
                    gradient.addColorStop(1, "rgba(99, 102, 241, .03)");

                    return gradient;
                },
                borderColor: "#22d3ee",
                borderWidth: 3,
                fill: true,
                tension: .38,
                spanGaps: true,
                pointBackgroundColor: "#6366f1",
                pointBorderColor: "#f8fafc",
                pointBorderWidth: 2,
                pointRadius: (context) =>
                    renewalRealPoints[context.dataIndex]
                    ? 6
                    : 0,
                pointHoverRadius: (context) =>
                    renewalRealPoints[context.dataIndex]
                    ? 8
                    : 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            resizeDelay: 120,
            animation: {
                duration: 1100,
                easing: "easeOutQuart"
            },
            animations: {
                tension: {
                    duration: 850,
                    easing: "easeOutQuart",
                    from: .1,
                    to: .38
                }
            },
            interaction: {
                intersect: false,
                mode: "index"
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    displayColors: false,
                    backgroundColor: "#090d19",
                    borderColor: "rgba(148, 163, 184, .16)",
                    borderWidth: 1,
                    titleColor: "#f8fafc",
                    bodyColor: "#7c83ff",
                    padding: 14,
                    cornerRadius: 12,
                    filter: (context) =>
                        renewalRealPoints[context.dataIndex],
                    callbacks: {
                        label: (context) =>context.parsed.y + " renewal(s)"
                    }
                }
            },
            layout: {
                padding: {
                    left: 24,
                    right: 24,
                    top: 18
                }
            },
            scales: {
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        color: tickColor,
                        maxRotation: 0,
                        minRotation: 0,
                        callback: function(value) {
                            return this.getLabelForValue(value) || "";
                        }
                    }
                },
                y: {
                    beginAtZero: true,
                    suggestedMax: Math.max(
                        2,
                        Math.max.apply(null, trendValues) + 1
                    ),
                    grid: {
                        color: gridColor,
                        borderDash: [3, 4],
                        drawBorder: false
                    },
                    ticks: {
                        color: tickColor,
                        stepSize: 1,
                        precision: 0,
                        callback: (value) =>
                            Number.isInteger(value)
                            ? value
                            : ""
                    }
                }
            }
        }
    });

    new Chart(document.getElementById("serviceChart"), {
        type: "doughnut",
        data: {
            labels: serviceLabels,
            datasets: [{
                data: serviceValues,
                backgroundColor: serviceColors,
                borderColor: "#f8fafc",
                borderWidth: 2,
                hoverOffset: 10,
                spacing: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            resizeDelay: 120,
            cutout: "58%",
            rotation: -55,
            animation: {
                animateRotate: true,
                animateScale: true,
                duration: 1200,
                easing: "easeOutQuart"
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: "#090d19",
                    borderColor: "rgba(148, 163, 184, .16)",
                    borderWidth: 1,
                    padding: 12,
                    cornerRadius: 12,
                    callbacks: {
                        label: (context) => context.label + " : " + formatMoney(context.parsed)
                    }
                }
            }
        }
    });

    new Chart(document.getElementById("costChart"), {
        type: "bar",
        data: {
            labels: serviceLabels,
            datasets: [{
                data: serviceValues,
                borderRadius: 8,
                borderSkipped: false,
                backgroundColor: serviceColors,
                maxBarThickness: 76,
                barPercentage: .72,
                categoryPercentage: .72
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            resizeDelay: 120,
            animation: {
                duration: 1100,
                easing: "easeOutQuart",
                delay: staggeredDelay
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    displayColors: false,
                    backgroundColor: "#090d19",
                    borderColor: "rgba(148, 163, 184, .16)",
                    borderWidth: 1,
                    padding: 12,
                    cornerRadius: 12,
                    callbacks: {
                        label: (context) => formatMoney(context.parsed.y)
                    }
                }
            },
            layout: {
                padding: {
                    bottom: 16
                }
            },
            scales: {
                x: {
                    grid: {
                        color: gridColor,
                        borderDash: [3, 4],
                        drawBorder: true
                    },
                    ticks: {
                        color: tickColor,
                        maxRotation: 0,
                        minRotation: 0,
                        autoSkip: false,
                        padding: 10,
                        callback: function(value) {
                            return wrapLabel(this.getLabelForValue(value), 12);
                        }
                    }
                },
                y: {
                    beginAtZero: true,
                    grid: {
                        color: gridColor,
                        borderDash: [3, 4],
                        drawBorder: true
                    },
                    ticks: {
                        color: tickColor,
                        callback: (value) => rupee + value
                    }
                }
            }
        }
    });
};

requestAnimationFrame(createAnalyticsCharts);

const waitForPaint = () => new Promise((resolve) => {
    requestAnimationFrame(() => requestAnimationFrame(resolve));
});

const pdfMoney = (value) => "INR " + Number(value || 0).toFixed(2);
const pdfSafeText = (value) => {
    if (value === null || value === undefined || value === "" || value === "null") {
        return "-";
    }

    return String(value);
};

const fitText = (pdf, text, maxWidth) => {
    const value = pdfSafeText(text);

    if (pdf.getTextWidth(value) <= maxWidth) {
        return value;
    }

    let output = value;

    while (output.length > 3 && pdf.getTextWidth(output + "...") > maxWidth) {
        output = output.slice(0, -1);
    }

    return output + "...";
};

const hexToRgb = (hex) => {
    const normalized = String(hex).replace("#", "");
    const full = normalized.length === 3
        ? normalized.split("").map((part) => part + part).join("")
        : normalized;

    return [
        parseInt(full.slice(0, 2), 16),
        parseInt(full.slice(2, 4), 16),
        parseInt(full.slice(4, 6), 16)
    ];
};

const PDF_TOTAL_PAGES = 2;

const drawPdfBackground = (pdf, pageWidth, pageHeight, pageNumber) => {
    pdf.setFillColor(5, 10, 22);
    pdf.rect(0, 0, pageWidth, pageHeight, "F");

    pdf.setFillColor(12, 21, 38);
    pdf.roundedRect(8, 8, pageWidth - 16, pageHeight - 16, 4, 4, "F");

    pdf.setFillColor(18, 31, 55);
    pdf.rect(8, 8, pageWidth - 16, 22, "F");

    pdf.setDrawColor(45, 64, 96);
    pdf.setLineWidth(.25);
    pdf.line(8, 30, pageWidth - 8, 30);

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(7);
    pdf.setTextColor(132, 148, 170);
    pdf.text("Page " + pageNumber + " of " + PDF_TOTAL_PAGES, pageWidth - 18, pageHeight - 8, { align: "right" });
};

const drawPdfHeader = (pdf, pageWidth) => {
    const generatedAt = new Date().toLocaleString("en-IN", {
        day: "2-digit",
        month: "short",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit"
    });

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(15);
    pdf.setTextColor(248, 250, 252);
    pdf.text("TrackUrSubs Analytics Report", 14, 19);

    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(7);
    pdf.setTextColor(148, 163, 184);
    pdf.text("Professional subscription spend summary", 14, 25);
    pdf.text("Generated: " + generatedAt, pageWidth - 14, 18, { align: "right" });
};

const drawPdfMetric = (pdf, x, y, width, label, value, accent) => {
    pdf.setFillColor(15, 26, 45);
    pdf.setDrawColor(45, 64, 96);
    pdf.roundedRect(x, y, width, 15, 2.5, 2.5, "FD");

    const rgb = hexToRgb(accent);
    pdf.setFillColor(rgb[0], rgb[1], rgb[2]);
    pdf.roundedRect(x + 3, y + 3, 2, 9, 1, 1, "F");

    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(6);
    pdf.setTextColor(148, 163, 184);
    pdf.text(label, x + 8, y + 6);

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(9);
    pdf.setTextColor(248, 250, 252);
    pdf.text(value, x + 8, y + 11.5);
};

const drawPdfPanel = (pdf, x, y, width, height, title, subtitle) => {
    pdf.setFillColor(13, 23, 37);
    pdf.setDrawColor(45, 64, 96);
    pdf.roundedRect(x, y, width, height, 3, 3, "FD");

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(9.5);
    pdf.setTextColor(248, 250, 252);
    pdf.text(title, x + 4, y + 8);

    if (subtitle) {
        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7);
        pdf.setTextColor(148, 163, 184);
        pdf.text(subtitle, x + 4, y + 15);
    }
};

const drawChartImage = (pdf, canvasId, x, y, width, height, title, subtitle) => {
    drawPdfPanel(pdf, x, y, width, height, title, subtitle);

    const canvas = document.getElementById(canvasId);

    if (!canvas) {
        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7);
        pdf.setTextColor(148, 163, 184);
        pdf.text("No chart data available", x + width / 2, y + height / 2, { align: "center" });
        return;
    }

    const paddingTop = subtitle ? 15 : 11;
    const boxX = x + 4;
    const boxY = y + paddingTop;
    const boxWidth = width - 8;
    const boxHeight = height - paddingTop - 4;
    const canvasRatio = canvas.width / canvas.height;
    const boxRatio = boxWidth / boxHeight;
    let imageWidth = boxWidth;
    let imageHeight = boxHeight;

    if (canvasRatio > boxRatio) {
        imageHeight = imageWidth / canvasRatio;
    } else {
        imageWidth = imageHeight * canvasRatio;
    }

    const imageX = boxX + (boxWidth - imageWidth) / 2;
    const imageY = boxY + (boxHeight - imageHeight) / 2;

    pdf.addImage(canvas.toDataURL("image/png"), "PNG", imageX, imageY, imageWidth, imageHeight);
};

const drawWrappedPdfText = (pdf, text, x, y, maxWidth, lineHeight, align = "left") => {
    const words = pdfSafeText(text).split(" ");
    const lines = [];
    let line = "";

    words.forEach((word) => {
        const testLine = line ? line + " " + word : word;

        if (line && pdf.getTextWidth(testLine) > maxWidth) {
            lines.push(line);
            line = word;
        } else {
            line = testLine;
        }
    });

    if (line) {
        lines.push(line);
    }

    lines.slice(0, 2).forEach((lineText, index) => {
        pdf.text(fitText(pdf, lineText, maxWidth), x, y + (index * lineHeight), { align });
    });
};

const drawPdfCostBarChart = (pdf, x, y, width, height, rows) => {
    drawPdfPanel(pdf, x, y, width, height, "Cost By Service", "Monthly equivalent");

    if (!rows.length) {
        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7.5);
        pdf.setTextColor(148, 163, 184);
        pdf.text("No chart data available", x + width / 2, y + height / 2, { align: "center" });
        return;
    }

    const chartX = x + 18;
    const chartY = y + 23;
    const chartWidth = width - 30;
    const chartHeight = height - 43;
    const labelTop = chartY + chartHeight + 7;
    const maxValue = Math.max(...rows.map((row) => Number(row.amount || 0)), 1);
    const barSlot = chartWidth / rows.length;
    const barWidth = Math.min(12, Math.max(6, barSlot * .45));

    pdf.setDrawColor(38, 55, 82);
    pdf.setLineWidth(.2);
    pdf.line(chartX, chartY + chartHeight, chartX + chartWidth, chartY + chartHeight);

    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(6.5);
    pdf.setTextColor(148, 163, 184);

    for (let step = 0; step <= 2; step++) {
        const value = (maxValue / 2) * step;
        const gridY = chartY + chartHeight - ((value / maxValue) * chartHeight);
        pdf.setDrawColor(26, 42, 65);
        pdf.line(chartX, gridY, chartX + chartWidth, gridY);
        pdf.text(String(Math.round(value)), chartX - 4, gridY + 1.8, { align: "right" });
    }

    rows.forEach((row, index) => {
        const barHeight = (Number(row.amount || 0) / maxValue) * (chartHeight - 2);
        const barX = chartX + (index * barSlot) + ((barSlot - barWidth) / 2);
        const barY = chartY + chartHeight - barHeight;
        const rgb = hexToRgb(row.color || palette[index % palette.length]);
        const labelX = chartX + (index * barSlot) + (barSlot / 2);

        pdf.setFillColor(rgb[0], rgb[1], rgb[2]);
        pdf.roundedRect(barX, barY, barWidth, barHeight, 1.8, 1.8, "F");

        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7.2);
        pdf.setTextColor(226, 232, 240);
        drawWrappedPdfText(pdf, row.service, labelX, labelTop, barSlot - 2, 4.5, "center");
    });
};

const drawPdfTable = (pdf, x, y, width, height, title, columns, rows, startIndex, options = {}) => {
    const safeRows = Array.isArray(rows) ? rows : [];
    const rowHeight = options.rowHeight || 6.4;
    const headerY = y + (options.headerOffset || 30);
    const maxRows = Math.max(0, Math.floor((height - (options.rowAreaOffset || 35)) / rowHeight));
    const visibleRows = options.maxRows ? Math.min(maxRows, options.maxRows) : maxRows;
    const endIndex = Math.min(safeRows.length, startIndex + visibleRows);
    const showingCount = Math.max(0, endIndex - startIndex);
    const subtitle = endIndex < safeRows.length
        ? "Showing " + showingCount + " of " + safeRows.length + " record(s)"
        : safeRows.length + " record(s)";

    drawPdfPanel(pdf, x, y, width, height, title, options.subtitle || subtitle);
    pdf.setDrawColor(45, 64, 96);
    pdf.setLineWidth(.2);
    pdf.line(x + 4, y + 18, x + width - 4, y + 18);

    if (!safeRows.length) {
        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7);
        pdf.setTextColor(148, 163, 184);
        pdf.text("No records available", x + width / 2, y + height / 2, { align: "center" });
        return endIndex;
    }

    pdf.setFillColor(22, 36, 58);
    pdf.rect(x + 4, headerY - 5, width - 8, 8, "F");
    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(options.headerFontSize || 5.5);
    pdf.setTextColor(203, 213, 225);

    let colX = x + 6;

    columns.forEach((column) => {
        const textX = column.align === "center"
            ? colX + (column.width / 2)
            : column.align === "right"
                ? colX + column.width - 2
                : colX;
        pdf.text(column.label, textX, headerY, { align: column.align || "left" });
        colX += column.width;
    });

    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(options.fontSize || 5.5);

    for (let index = startIndex; index < endIndex; index++) {
        const row = safeRows[index];
        const rowY = headerY + 5 + ((index - startIndex) * rowHeight);

        if ((index - startIndex) % 2 === 0) {
            pdf.setFillColor(15, 26, 45);
            pdf.rect(x + 4, rowY - (rowHeight * .62), width - 8, rowHeight, "F");
        }

        colX = x + 6;

        columns.forEach((column) => {
            const rawValue = column.format ? column.format(row[column.key], row, index) : row[column.key];
            const text = fitText(pdf, rawValue, column.width - 2);

            if (column.colorKey && row[column.colorKey]) {
                const rgb = hexToRgb(row[column.colorKey]);
                pdf.setFillColor(rgb[0], rgb[1], rgb[2]);
                pdf.circle(colX + 1.2, rowY - 1.2, 1.2, "F");
                pdf.setTextColor(226, 232, 240);
                pdf.text(text, colX + 4, rowY);
            } else {
                const textX = column.align === "center"
                    ? colX + (column.width / 2)
                    : column.align === "right"
                        ? colX + column.width - 2
                        : colX;
                pdf.setTextColor(226, 232, 240);
                pdf.text(text, textX, rowY, { align: column.align || "left" });
            }

            colX += column.width;
        });
    }

    if (endIndex < safeRows.length) {
        pdf.setFont("helvetica", "bold");
        pdf.setFontSize(7);
        pdf.setTextColor(34, 211, 238);
        pdf.text("+" + (safeRows.length - endIndex) + " more not shown", x + width - 6, y + height - 5, { align: "right" });
    }

    return endIndex;
};

const buildPdfRows = () => {
    const renewalTotal = trendValues.reduce((sum, value) => sum + Number(value || 0), 0);

    return {
        renewalTotal,
        services: serviceLabels.map((label, index) => ({
            color: serviceColors[index],
            service: label,
            amount: Number(serviceValues[index] || 0),
            share: totalMonthlySpend ? (Number(serviceValues[index] || 0) / totalMonthlySpend) * 100 : 0
        })),
        renewals: trendLabels.map((label, index) => ({
            month: label,
            renewals: Number(trendValues[index] || 0)
        })),
        leastUsed: leastUsedRecords.map((record) => ({
            name: record.name,
            plan: record.plan,
            amount: Number(record.amount || 0),
            cycle: record.cycle,
            usageCount: Number(record.usageCount || 0),
            mostUsedMonth: record.mostUsedMonth
        }))
    };
};

const compactPdfRowOptions = (rowCount, height) => {
    const rowHeight = Math.max(5.2, Math.min(7.2, (height - 35) / Math.max(rowCount, 1)));
    const fontSize = rowHeight < 6 ? 5.8 : 6.5;

    return {
        rowHeight,
        fontSize,
        headerFontSize: 6.6,
        headerOffset: 30,
        rowAreaOffset: 35
    };
};

const downloadWholePagePdf = async () => {
    const button = document.getElementById("downloadAnalyticsPdf");

    if (!window.jspdf) {
        alert("PDF export tools are still loading. Please try again in a moment.");
        return;
    }

    const originalText = button ? button.innerHTML : "";

    try {
        if (button) {
            button.disabled = true;
            button.innerHTML = '<i class="fa-solid fa-spinner fa-spin" aria-hidden="true"></i><span>Preparing PDF</span>';
        }

        await new Promise((resolve) => setTimeout(resolve, 350));
        await waitForPaint();

        const rows = buildPdfRows();
        const pdf = new jspdf.jsPDF("l", "mm", "a4");
        const pageWidth = pdf.internal.pageSize.getWidth();
        const pageHeight = pdf.internal.pageSize.getHeight();

        drawPdfBackground(pdf, pageWidth, pageHeight, 1);
        drawPdfHeader(pdf, pageWidth);

        drawPdfMetric(pdf, 14, 35, 62, "Total monthly spend", pdfMoney(totalMonthlySpend), "#22d3ee");
        drawPdfMetric(pdf, 82, 35, 52, "Services tracked", String(serviceLabels.length), "#8b5cf6");
        drawPdfMetric(pdf, 140, 35, 58, "Upcoming renewals", String(rows.renewalTotal), "#22c55e");
        drawPdfMetric(pdf, 204, 35, 62, "Least used records", String(rows.leastUsed.length), "#f97316");

        drawChartImage(pdf, "trendChart", 14, 58, 132, 56, "Renewal Distribution", "Upcoming renewals by month");
        drawChartImage(pdf, "serviceChart", 152, 58, 131, 56, "Cost Per Service", "Monthly spend share");
        drawPdfCostBarChart(pdf, 14, 122, 269, 67, rows.services);

        pdf.addPage();
        drawPdfBackground(pdf, pageWidth, pageHeight, 2);
        drawPdfHeader(pdf, pageWidth);

        pdf.setFont("helvetica", "bold");
        pdf.setFontSize(10);
        pdf.setTextColor(226, 232, 240);
        pdf.text("Detailed Records", 14, 39);

        drawPdfTable(
            pdf,
            14,
            44,
            132,
            84,
            "Service Costs",
            [
                { label: "Service", key: "service", width: 66, colorKey: "color" },
                { label: "Monthly Cost", key: "amount", width: 34, format: pdfMoney, align: "center" },
                { label: "Share", key: "share", width: 22, format: (value) => Number(value || 0).toFixed(1) + "%", align: "center" }
            ],
            rows.services,
            0,
            compactPdfRowOptions(rows.services.length, 84)
        );

        drawPdfTable(
            pdf,
            152,
            44,
            131,
            84,
            "Renewals",
            [
                { label: "Month", key: "month", width: 72 },
                { label: "Count", key: "renewals", width: 32, format: (value) => String(value || 0), align: "center" }
            ],
            rows.renewals,
            0,
            compactPdfRowOptions(rows.renewals.length, 84)
        );

        drawPdfTable(
            pdf,
            14,
            137,
            269,
            52,
            "Least Used Subscriptions",
            [
                { label: "Subscription", key: "name", width: 64 },
                { label: "Plan", key: "plan", width: 48 },
                { label: "Cost", key: "amount", width: 30, format: pdfMoney, align: "center" },
                { label: "Cycle", key: "cycle", width: 28, align: "center" },
                { label: "Usage", key: "usageCount", width: 22, format: (value) => String(value || 0), align: "center" },
                { label: "Most Used", key: "mostUsedMonth", width: 50 }
            ],
            rows.leastUsed,
            0,
            compactPdfRowOptions(rows.leastUsed.length, 52)
        );

        pdf.save("trackursubs-analytics.pdf");
    } catch (error) {
        console.error("Unable to export analytics PDF", error);
        alert("Unable to create the PDF. Please try again.");
    } finally {
        if (button) {
            button.disabled = false;
            button.innerHTML = originalText;
        }
    }
};

document.getElementById("downloadAnalyticsPdf")
    ?.addEventListener("click", downloadWholePagePdf);
</script>

</body>

</html>
