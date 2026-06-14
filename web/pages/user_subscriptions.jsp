<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.ArrayList" %>
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
    List<Subscription> subscriptions =
            dao.getSubscriptionsByUserId(user.getUserId());

    List<Subscription> activeSubscriptions = new ArrayList<>();
    List<Subscription> expiredSubscriptions = new ArrayList<>();
    LocalDate today = LocalDate.now();

    for (Subscription subscription : subscriptions) {
        if (subscription.getRenewalDate() != null
                && subscription.getRenewalDate().toLocalDate().isBefore(today)) {
            expiredSubscriptions.add(subscription);
        } else {
            activeSubscriptions.add(subscription);
        }
    }

    double totalSpend = 0;

    for (Subscription subscription : activeSubscriptions) {
        double amount = subscription.getAmount();
        String billingCycle = subscription.getBillingCycle() == null
                ? ""
                : subscription.getBillingCycle().trim().toLowerCase();

        if ("yearly".equals(billingCycle)) {
            totalSpend += amount / 12;
        } else if ("weekly".equals(billingCycle)) {
            totalSpend += amount * 4;
        } else if ("quarterly".equals(billingCycle)) {
            totalSpend += amount / 3;
        } else {
            totalSpend += amount;
        }
    }
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

    <style>
        body,
        .content,
        button,
        input,
        select {
            font-family: "Inter", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        .page-head {
            align-items: flex-start;
            margin-bottom: 24px;
        }

        .page-head h2 {
            font-size: 34px;
            margin-bottom: 6px;
        }

        .page-head p {
            opacity: .7;
        }

        .subscription-stats {
            display: grid;
            grid-template-columns: repeat(2, 240px);
            gap: 18px;
            margin-bottom: 28px;
        }

        .sub-stat {
            position: relative;
            min-height: 100px;
            padding: 18px 22px;
            overflow: hidden;
            border: 1px solid rgba(255, 255, 255, .06);
            border-radius: 18px;
            background: rgba(255, 255, 255, .04);
            backdrop-filter: blur(18px);
            transition: .3s ease;
        }

        .sub-stat:hover {
            transform: translateY(-4px);
            border-color: rgba(34, 211, 238, .18);
            box-shadow: 0 10px 30px rgba(0, 0, 0, .35);
        }

        .sub-stat::after {
            content: "";
            position: absolute;
            top: -50px;
            right: -50px;
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: rgba(34, 211, 238, .06);
            filter: blur(35px);
        }

        .sub-stat p {
            margin-bottom: 8px;
            font-size: 13px;
            opacity: .7;
        }

        .sub-stat h3 {
            margin: 0;
            font-size: 30px;
            font-weight: 700;
        }

        .filter-row {
            display: flex;
            gap: 18px;
            margin-bottom: 32px;
        }

        .search-box {
            position: relative;
            flex: 1;
        }

        .search-box input {
            width: 100%;
            padding: 15px 18px 15px 50px;
            border: none;
            border-radius: 16px;
            outline: none;
            background: rgba(255, 255, 255, .04);
            color: white;
        }

        .search-box i {
            position: absolute;
            top: 16px;
            left: 18px;
            opacity: .7;
        }

        .filter-select {
            padding: 14px 18px;
            border: none;
            border-radius: 16px;
            background: #0d1226;
            color: white;
        }

        .subscription-section {
            margin-bottom: 32px;
        }

        .subscription-section-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 16px;
            padding: 0 4px;
        }

        .subscription-section-head h3 {
            margin: 0;
            font-size: 24px;
        }

        .section-count {
            min-width: 36px;
            padding: 7px 11px;
            border: 1px solid rgba(255, 255, 255, .08);
            border-radius: 999px;
            background: rgba(255, 255, 255, .05);
            color: rgba(255, 255, 255, .76);
            font-size: 13px;
            font-weight: 700;
            text-align: center;
        }

        .subscription-wrapper {
            position: relative;
            min-height: 220px;
            padding: 34px;
        }

        .subscription-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 24px;
            align-items: start;
        }

        .sub-card {
            position: relative;
            display: flex;
            min-height: 330px;
            padding: 28px;
            overflow: visible;
            flex-direction: column;
            border: 1px solid rgba(255, 255, 255, .06);
            border-radius: 26px;
            background: linear-gradient(145deg, rgba(14, 18, 40, .95), rgba(4, 8, 22, .98));
            backdrop-filter: blur(20px);
            transition: all .35s ease;
        }

        .sub-card::before {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: 26px;
            background: radial-gradient(circle at top right, rgba(34, 211, 238, .08), transparent 45%);
            opacity: 0;
            transition: .35s;
            pointer-events: none;
        }

        .sub-card:hover {
            transform: translateY(-10px) scale(1.02);
            border-color: rgba(34, 211, 238, .18);
            box-shadow: 0 20px 50px rgba(0, 0, 0, .45);
        }

        .sub-card:hover::before {
            opacity: 1;
        }

        .card-actions {
            position: absolute;
            top: 20px;
            right: 20px;
            z-index: 2;
            display: flex;
            flex-direction: column;
            gap: 10px;
            opacity: 0;
            transform: translateY(-10px);
            pointer-events: none;
            transition: .3s ease;
        }

        .sub-card:hover .card-actions,
        .sub-card:focus-within .card-actions {
            opacity: 1;
            transform: translateY(0);
            pointer-events: auto;
        }

        .card-actions .edit-btn,
        .card-actions .delete-btn {
            position: static;
            display: flex;
            width: 42px;
            height: 42px;
            padding: 0;
            align-items: center;
            justify-content: center;
            border: none;
            border-radius: 12px;
            color: #fff;
            cursor: pointer;
            opacity: 1;
            transition: transform .3s ease, box-shadow .3s ease;
        }

        .card-actions .edit-btn {
            background: linear-gradient(135deg, #4f46e5, #3b82f6);
        }

        .card-actions .delete-btn {
            background: linear-gradient(135deg, #dc2626, #ef4444);
        }

        .card-actions .edit-btn:hover,
        .card-actions .delete-btn:hover {
            color: #fff;
            transform: translateY(-3px) scale(1.08);
        }

        .card-actions .edit-btn:hover {
            box-shadow: 0 0 20px rgba(59, 130, 246, .45);
        }

        .card-actions .delete-btn:hover {
            box-shadow: 0 0 20px rgba(239, 68, 68, .45);
        }

        .sub-logo {
            display: flex;
            width: 64px;
            height: 64px;
            margin-top: 18px;
            margin-bottom: 20px;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            border-radius: 18px;
            background: rgba(255, 255, 255, .06);
            box-shadow: inset 0 0 15px rgba(255, 255, 255, .03);
        }

        .sub-logo img {
            width: 70%;
            height: 70%;
            object-fit: contain;
        }

        .sub-card h3 {
            margin-bottom: 6px;
            font-size: 22px;
            font-weight: 700;
        }

        .subscription-price {
            margin-bottom: 2px;
            font-size: 38px;
            font-weight: 700;
        }

        .plan {
            margin-bottom: 22px;
            font-size: 14px;
            opacity: .65;
        }

        .row {
            display: flex;
            justify-content: space-between;
            padding: 6px 0;
            font-size: 14px;
            opacity: .9;
        }

        .empty-sub {
            display: flex;
            min-height: 260px;
            padding: 34px 28px;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            border: 1px dashed rgba(124, 92, 255, .24);
            border-radius: 24px;
            background:
                radial-gradient(circle at 50% 0%, rgba(124, 92, 255, .1), transparent 45%),
                rgba(255, 255, 255, .018);
            text-align: center;
        }

        .empty-sub i {
            display: flex;
            width: 72px;
            height: 72px;
            margin-bottom: 20px;
            align-items: center;
            justify-content: center;
            border: 1px solid rgba(255, 255, 255, .1);
            border-radius: 22px;
            background: linear-gradient(145deg, rgba(124, 92, 255, .24), rgba(34, 211, 238, .12));
            color: #73e4ff;
            font-size: 28px;
        }

        .empty-sub h2 {
            margin-bottom: 10px;
            font-size: 28px;
        }

        .empty-sub p {
            max-width: 470px;
            color: rgba(255, 255, 255, .62);
            font-size: 15px;
            line-height: 1.65;
        }

        .filter-empty {
            display: none;
        }

        @media (max-width: 900px) {
            .subscription-stats {
                grid-template-columns: 1fr;
            }

            .page-head {
                flex-direction: column;
                gap: 20px;
            }

            .subscription-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 620px) {
            .filter-row {
                flex-direction: column;
            }

            .subscription-wrapper {
                padding: 22px;
            }
        }
    </style>

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

            <button class="add-btn" onclick="openModal()">
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
                <p>Monthly Spend</p>
                <h3>&#8377;<%= Math.round(totalSpend) %></h3>
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
                                            onclick="openEditModalFromCard(this)">
                                            <i class="fa-solid fa-pen"></i>
                                        </button>

                                        <button
                                            type="button"
                                            class="delete-btn"
                                            aria-label="Delete <%= html(service) %>"
                                            onclick="deleteSubscription(<%= sub.getSubscriptionId() %>)">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>

                                        <form
                                            id="deleteForm<%= sub.getSubscriptionId() %>"
                                            action="<%= request.getContextPath() %>/DeleteSubscriptionServlet"
                                            method="post"
                                            style="display:none;">
                                            <input
                                                type="hidden"
                                                name="subscriptionId"
                                                value="<%= sub.getSubscriptionId() %>" />
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

    <script>
        function deleteSubscription(subscriptionId) {
            if (confirm("Delete this subscription permanently?")) {
                document.getElementById("deleteForm" + subscriptionId).submit();
            }
        }

        function openEditModalFromCard(button) {
            const card = button.closest(".sub-card");

            openEditModal(
                card.dataset.id,
                card.dataset.name,
                card.dataset.plan,
                card.dataset.amount,
                card.dataset.billing,
                card.dataset.renewal,
                card.dataset.lastUsed,
                card.dataset.expired === "true"
            );
        }

        const searchInput = document.getElementById("searchSubscription");
        const billingFilter = document.getElementById("billingFilter");

        function filterSubscriptions() {
            const searchText = searchInput.value.toLowerCase().trim();
            const billingValue = billingFilter.value.toLowerCase();

            document.querySelectorAll(".subscription-section").forEach(section => {
                const cards = section.querySelectorAll(".sub-card");
                const filterEmpty = section.querySelector(".filter-empty");
                let visibleCount = 0;

                cards.forEach(card => {
                    const matchesSearch = card.dataset.name
                        .toLowerCase()
                        .includes(searchText);
                    const matchesBilling =
                        billingValue === "all"
                        || card.dataset.billing.toLowerCase().includes(billingValue);
                    const visible = matchesSearch && matchesBilling;

                    card.style.display = visible ? "flex" : "none";

                    if (visible) {
                        visibleCount++;
                    }
                });

                if (filterEmpty) {
                    filterEmpty.style.display =
                        cards.length > 0 && visibleCount === 0 ? "flex" : "none";
                }
            });
        }

        searchInput.addEventListener("input", filterSubscriptions);
        billingFilter.addEventListener("change", filterSubscriptions);
    </script>
</body>
</html>
