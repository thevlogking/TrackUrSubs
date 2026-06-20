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

const profileMenuToggle =
document.querySelector(
".profile-menu-toggle"
);

if(profileMenuToggle){

    profileMenuToggle.addEventListener(
    "click",
    toggleMobileAccountMenu
    );
}

const mobileManageButton =
document.querySelector(
"[data-mobile-manage-account]"
);

if(mobileManageButton){

    mobileManageButton.addEventListener(
    "click",
    openMobileManageAccount
    );
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
