<%@ page import="model.User"%>

<%

User user =

(User)session.getAttribute(
"user"
);

%>

<div class="topbar">

    <div class="nav-left">

    </div>

    <div class="nav-right">

        <div class="nav-profile">

            <button
            type="button"
            class="profile-menu-toggle"
            aria-label="Open account menu"
            aria-expanded="false">

                <img

                src="<%= user!=null && user.getProfilePicture()!=null

                && !user.getProfilePicture().isEmpty()

                ? user.getProfilePicture()

                : request.getContextPath()+"/images/default_profile.png" %>"

                alt="Profile"

                class="navbar-profile-img">

            </button>

            <div class="mobile-account-menu"
                 id="mobileAccountMenu">

                <button type="button"
                        class="mobile-account-action"
                        data-mobile-manage-account>

                    <i class="fa-solid fa-user-gear"></i>

                    Manage account

                </button>

                <form action="${pageContext.request.contextPath}/logout"
                      method="post">

                    <button type="submit"
                            class="mobile-account-action mobile-signout-action">

                        <i class="fa-solid fa-right-from-bracket"></i>

                        Sign out

                    </button>

                </form>

            </div>
        </div>

    </div>

</div>

<script src="../js/user_navbar.js"></script>
