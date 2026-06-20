<%@ page import="model.User"%>

<%

User user =
(User)session.getAttribute(
"user"
);

%>

<div class="sidebar">

    <!-- TOP SECTION -->

    <div>

        <div class="logo">

            <img src="../images/logo.png" alt="Logo">

            <h3>

                Track<span>Ur</span>Subs

            </h3>

        </div>

        <div class="menu">

            <a class="${pageContext.request.requestURI.contains('user_dashboard.jsp') ? 'active' : ''}" 
               href="../pages/user_dashboard.jsp">

                <i class="fa-solid fa-table-columns"></i>

                Dashboard

            </a>

            <a class="${pageContext.request.requestURI.contains('user_subscriptions.jsp') ? 'active' : ''}" 
               href="../pages/user_subscriptions.jsp">

                <i class="fa-solid fa-credit-card"></i>

                Subscriptions

            </a>

            <a class="${pageContext.request.requestURI.contains('user_analytics.jsp') ? 'active' : ''}" 
               href="../pages/user_analytics.jsp">

                <i class="fa-solid fa-chart-line"></i>

                Analytics

            </a>

            <a class="${pageContext.request.requestURI.contains('user_renewals.jsp') ? 'active' : ''}" 
               href="../pages/user_renewals.jsp">

                <i class="fa-regular fa-bell"></i>

                Renewals

            </a>

        </div>

    </div>

<!-- BOTTOM SECTION -->

<div class="bottom-side">

    <div class="account"
    data-open-manage-account>

        <div>

            <h4>

            <%= user!=null

            ? user.getFullName()

            : "User Account" %>

            </h4>

            <p>

            Manage profile

            </p>

        </div>

    </div>

    <form action="${pageContext.request.contextPath}/logout"
          method="post">

    <button class="logout"
            type="submit">

        <i class="fa-solid fa-right-from-bracket"></i>

        Sign out

    </button>

    </form>

</div>

</div>
