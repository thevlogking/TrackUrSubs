function closeModal(){

    const modal =
    document.getElementById(
    "subscriptionModal"
    );

    if(modal){

        modal.classList.remove(
        "show"
        );
    }
}

function openModal(){

    const modal =
    document.getElementById(
    "subscriptionModal"
    );

    if(modal){

        modal.style.display =
        "flex";

        modal.classList.add(
        "show"
        );
    }
}

document.addEventListener("click", function(event){

    if(event.target.closest("[data-open-subscription-modal]")){

        openModal();
    }

    if(event.target.closest("[data-close-subscription-modal]")){

        closeModal();
    }
});
