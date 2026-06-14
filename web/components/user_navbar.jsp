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
            aria-expanded="false"
            onclick="toggleMobileAccountMenu(event)">

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
                        onclick="openMobileManageAccount()">

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

<script>

function closeMobileAccountMenu(){

    const menu =
    document.getElementById(
    "mobileAccountMenu"
    );

    const toggle =
    document.querySelector(
    ".profile-menu-toggle"
    );

    if(menu){

        menu.classList.remove(
        "is-open"
        );
    }

    if(toggle){

        toggle.setAttribute(
        "aria-expanded",
        "false"
        );
    }
}

function toggleMobileAccountMenu(event){

    event.stopPropagation();

    if(!window.matchMedia(
       "(max-width: 640px)"
       ).matches){

        closeMobileAccountMenu();

        return;
    }

    const menu =
    document.getElementById(
    "mobileAccountMenu"
    );

    const toggle =
    event.currentTarget;

    if(!menu){

        return;
    }

    const isOpen =
    menu.classList.toggle(
    "is-open"
    );

    toggle.setAttribute(
    "aria-expanded",
    isOpen ? "true" : "false"
    );
}

function openMobileManageAccount(){

    closeMobileAccountMenu();

    openManageAccount();
}

document.addEventListener(
"click",
function(event){

    const profile =
    document.querySelector(
    ".nav-profile"
    );

    if(profile &&
       !profile.contains(event.target)){

        closeMobileAccountMenu();
    }
});

document.addEventListener(
"keydown",
function(event){

    if(event.key === "Escape"){

        closeMobileAccountMenu();
    }
});

window.addEventListener(
"resize",
function(){

    if(!window.matchMedia(
       "(max-width: 640px)"
       ).matches){

        closeMobileAccountMenu();
    }
});

</script>
