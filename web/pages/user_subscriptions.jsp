<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.SubscriptionDAO" %>
<%@ page import="model.Subscription" %>
<%@ page import="model.User" %>

<%!
    private String html(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/pages/signin.jsp");
        return;
    }

    SubscriptionDAO dao = new SubscriptionDAO();
    List<Subscription> activeSubscriptions =
            dao.getSubscriptionsByUserId(user.getUserId());

    List<Subscription> expiredSubscriptions =
            dao.getExpiredSubscriptionsByUserId(user.getUserId());

%>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="../components/site_tab.jsp" %>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="../css/user_dashboard.css" />
    <link rel="stylesheet" href="../css/add_subscription.css" />
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
          rel="stylesheet" />

    <link rel="stylesheet" href="../css/user_subscriptions.css">

    <link rel="stylesheet" href="../css/responsive.css" />
</head>
<body>
    <jsp:include page="../components/user_sidebar.jsp" />
    <jsp:include page="../components/user_navbar.jsp" />

    <div class="content">
        <div class="page-head">
            <div>
                <h2>Subscriptions</h2>
                <p>Manage your active and expired subscriptions</p>
            </div>

            <button class="add-btn" data-open-subscription-modal>
                <i class="fa-solid fa-plus"></i>
                Add Subscription
            </button>
        </div>

        <div class="subscription-stats">
            <div class="sub-stat">
                <p>Active Services</p>
                <h3><%= activeSubscriptions.size() %></h3>
            </div>

            <div class="sub-stat">
                <p>Expired Subscriptions</p>
                <h3><%= expiredSubscriptions.size() %></h3>
            </div>
        </div>

        <div class="filter-row">
            <div class="search-box">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input
                    type="text"
                    id="searchSubscription"
                    placeholder="Search subscriptions..." />
            </div>

            <select class="filter-select" id="billingFilter">
                <option value="all">All Plans</option>
                <option value="weekly">Weekly</option>
                <option value="monthly">Monthly</option>
                <option value="quarterly">Quarterly</option>
                <option value="yearly">Yearly</option>
            </select>
        </div>

        <%
            List<Subscription>[] subscriptionGroups = new List[]{
                activeSubscriptions,
                expiredSubscriptions
            };
            String[] sectionTitles = {
                "Active Subscriptions",
                "Expired Subscriptions"
            };

            for (int groupIndex = 0; groupIndex < subscriptionGroups.length; groupIndex++) {
                List<Subscription> group = subscriptionGroups[groupIndex];
                boolean expiredGroup = groupIndex == 1;
        %>
            <section class="subscription-section"
                     data-subscription-section="<%= expiredGroup ? "expired" : "active" %>">
                <div class="subscription-section-head">
                    <h3><%= sectionTitles[groupIndex] %></h3>
                    <span class="section-count"><%= group.size() %></span>
                </div>

                <div class="card subscription-wrapper">
                    <% if (group.isEmpty()) { %>
                        <div class="empty-sub server-empty">
                            <i class="fa-solid <%= expiredGroup ? "fa-clock-rotate-left" : "fa-credit-card" %>"></i>
                            <h2>
                                <%= expiredGroup
                                        ? "No expired subscriptions"
                                        : "No active subscriptions yet" %>
                            </h2>
                            <p>
                                <%= expiredGroup
                                        ? "Subscriptions will move here automatically after their renewal date passes."
                                        : "Your active subscriptions will appear here once they are added or renewed." %>
                            </p>
                        </div>
                    <% } else { %>
                        <div class="subscription-grid">
                            <% for (Subscription sub : group) {
                                String service = sub.getSubscriptionName() == null
                                        ? ""
                                        : sub.getSubscriptionName();
                                String logoName = service.toLowerCase()
                                        .replace(" ", "");
                                String logo = request.getContextPath()
                                        + "/images/" + logoName + ".png";
                                String renewalDate = sub.getRenewalDate() == null
                                        ? ""
                                        : sub.getRenewalDate().toString();
                                String lastUsedDate = sub.getLastUsedDate() == null
                                        ? ""
                                        : sub.getLastUsedDate().toString();
                            %>
                                <article
                                    class="sub-card"
                                    data-id="<%= sub.getSubscriptionId() %>"
                                    data-name="<%= html(service) %>"
                                    data-plan="<%= html(sub.getPlanName()) %>"
                                    data-amount="<%= sub.getAmount() %>"
                                    data-billing="<%= html(sub.getBillingCycle()) %>"
                                    data-renewal="<%= renewalDate %>"
                                    data-last-used="<%= lastUsedDate %>"
                                    data-expired="<%= expiredGroup %>">

                                    <div class="card-actions">
                                        <button
                                            type="button"
                                            class="edit-btn"
                                            aria-label="Edit <%= html(service) %>"
                                            data-edit-subscription>
                                            <i class="fa-solid fa-pen"></i>
                                        </button>

                                        <button
                                            type="button"
                                            class="delete-btn"
                                            aria-label="Delete <%= html(service) %>"
                                            data-delete-subscription
                                            data-subscription-id="<%= sub.getSubscriptionId() %>">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>

                                        <form
                                            id="deleteForm<%= sub.getSubscriptionId() %>"
                                            action="<%= request.getContextPath() %>/DeleteSubscriptionServlet"
                                            method="post"
                                            class="delete-form">
                                            <input
                                                type="hidden"
                                                name="subscriptionId"
                                                value="<%= sub.getSubscriptionId() %>" />
                                            <input
                                                type="hidden"
                                                name="expiredSubscription"
                                                value="<%= expiredGroup %>" />
                                        </form>
                                    </div>

                                    <div class="sub-logo">
                                        <img src="<%= html(logo) %>" alt="" />
                                    </div>

                                    <h3><%= html(service) %></h3>

                                    <div class="subscription-price">
                                        &#8377;<%= String.format("%.0f", sub.getAmount()) %>
                                    </div>

                                    <p class="plan"><%= html(sub.getPlanName()) %></p>

                                    <div class="row">
                                        <span><%= expiredGroup ? "Expired On" : "Next Bill" %></span>
                                        <span><%= renewalDate %></span>
                                    </div>

                                    <div class="row">
                                        <span>Billing</span>
                                        <span><%= html(sub.getBillingCycle()) %></span>
                                    </div>
                                </article>
                            <% } %>
                        </div>

                        <div class="empty-sub filter-empty">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <h2>No subscriptions found</h2>
                            <p>Try changing the search text or billing filter.</p>
                        </div>
                    <% } %>
                </div>
            </section>
        <% } %>
    </div>

    <%@ include file="../components/add_subscription.jsp" %>
    <%@ include file="../components/manage_account.jsp" %>
    <%@ include file="../components/edit_subscription.jsp" %>

    <script src="../js/user_subscriptions.js"></script>
</body>
</html>
