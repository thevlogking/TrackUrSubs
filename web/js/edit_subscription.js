function openEditModal(
id,
name,
plan,
amount,
billing,
renewal,
lastUsed,
expired
){

document.getElementById(
"editModal"
).classList.add(
"show"
);

document.getElementById(
"editId"
).value=id;

document.getElementById(
"editName"
).value=name;

document.getElementById(
"editPlan"
).value=plan;

document.getElementById(
"editAmount"
).value=amount;

document.getElementById(
"editBilling"
).value=billing;

document.getElementById(
"editRenewal"
).value=renewal;

document.getElementById(
"editLastUsed"
).value=lastUsed;

const expiredEdit = Boolean(expired);
const planInput = document.getElementById("editPlan");
const amountInput = document.getElementById("editAmount");
const billingInput = document.getElementById("editBilling");
const renewalInput = document.getElementById("editRenewal");
const lastUsedInput = document.getElementById("editLastUsed");

document.getElementById("editExpired").value =
expiredEdit ? "true" : "false";

document.getElementById("editModalTitle").textContent =
expiredEdit ? "Renew Expired Subscription" : "Edit Subscription";

document.getElementById("editSubmitButton").textContent =
expiredEdit ? "Renew Subscription" : "Update";

planInput.readOnly = !expiredEdit;
planInput.required = expiredEdit;
amountInput.readOnly = !expiredEdit;
amountInput.required = expiredEdit;
billingInput.disabled = !expiredEdit;
billingInput.required = expiredEdit;
renewalInput.readOnly = !expiredEdit;
renewalInput.required = expiredEdit;
renewalInput.min = expiredEdit
        ? (document.getElementById("editModal").dataset.today || "")
        : "";
lastUsedInput.required = !expiredEdit;

}

function closeEditModal(){

document.getElementById(
"editModal"
).classList.remove(
"show"
);

}

document.querySelectorAll(
"[data-close-edit-modal]"
).forEach(function(button){

button.addEventListener(
"click",
closeEditModal
);

});

window.onclick=function(event){

let modal =

document.getElementById(
"editModal"
);

if(event.target === modal){

closeEditModal();

}

}
