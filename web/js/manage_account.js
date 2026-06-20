document.addEventListener(
"DOMContentLoaded",
function(){

const modal =
document.getElementById(
"manageAccountModal"
);

window.openManageAccount =
function(){

modal.style.display =
"flex";

};

document
.querySelector(
".close-btn"
)

.addEventListener(
"click",
function(){

modal.style.display =
"none";

});

document.addEventListener(
"click",
function(event){

const trigger =
event.target.closest(
"[data-open-manage-account]"
);

if(trigger){

openManageAccount();

}

});

if(modal.dataset.openOnLoad === "true"){

window.addEventListener(
"load",
function(){

openManageAccount();

});

}

window.onclick =
function(e){

if(e.target===modal){

modal.style.display =
"none";

}

};

document
.getElementById(
"profilePic"
)

.addEventListener(
"change",
function(e){

const file =
e.target.files[0];

if(file){

document
.getElementById(
"profilePreview"
)

.src =
URL.createObjectURL(
file
);

}

});

});
