const loginCard = document.querySelector(".card");
const loginForm = document.querySelector("form");

function playCardEntrance(){
    loginCard.classList.remove("card-leaving");
    loginCard.classList.remove("card-entering");
    void loginCard.offsetWidth;
    loginCard.classList.add("card-entering");
}

playCardEntrance();

window.addEventListener("pageshow", function(event){
    if (event.persisted) {
        playCardEntrance();
    }
});

document.querySelectorAll("a").forEach(function(link){
    link.addEventListener("click", function(event){
        if (
            event.ctrlKey ||
            event.metaKey ||
            event.shiftKey ||
            event.altKey ||
            link.target === "_blank"
        ) {
            return;
        }

        event.preventDefault();
        loginCard.classList.remove("card-entering");
        loginCard.classList.add("card-leaving");

        setTimeout(function(){
            window.location.href = link.href;
        }, 160);
    });
});

loginForm.addEventListener("submit", function(event){
    event.preventDefault();
    loginCard.classList.remove("card-entering");
    loginCard.classList.add("card-leaving");

    setTimeout(function(){
        loginForm.submit();
    }, 160);
});
