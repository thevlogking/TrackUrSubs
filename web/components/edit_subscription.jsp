<div id="editModal" class="edit-modal">

    <div class="edit-modal-box">

        <div class="edit-header">

            <h2 id="editModalTitle">Edit Subscription</h2>

            <button
            class="close-modal-btn"
            onclick="closeEditModal()">

                <i class="fa-solid fa-xmark"></i>

            </button>

        </div>

        <form action="<%=request.getContextPath()%>/UpdateSubscriptionServlet"
              method="post">

            <input
type="hidden"
id="editId"
name="subscriptionId">

<input
type="hidden"
id="editExpired"
name="expiredEdit"
value="false">

<label>Subscription Name</label>

<input
type="text"
id="editName"
name="subscriptionName"
readonly>

<label>Plan Name</label>

<input
type="text"
id="editPlan"
name="planName"
readonly>

<label>Amount</label>

<input
type="number"
step="0.01"
min="0"
id="editAmount"
name="amount"
readonly>

<label>Billing Cycle</label>

<select
id="editBilling"
name="billingCycle"
disabled>

    <option>Weekly</option>
    <option>Monthly</option>
    <option>Quarterly</option>
    <option>Yearly</option>

</select>

<label>Renewal Date</label>

<input
type="date"
id="editRenewal"
name="renewalDate"
readonly>

<label>Last Used Date</label>

<input
type="date"
id="editLastUsed"
name="lastUsedDate"
required>
            <div class="edit-actions">

                <button
                class="save-edit-btn"
                id="editSubmitButton"
                type="submit">

                    Update

                </button>

                <button
                type="button"
                class="cancel-edit-btn"
                onclick="closeEditModal()">

                    Cancel

                </button>

            </div>

        </form>

    </div>

</div>

<style>

.edit-modal{

display:none;

position:fixed;

inset:0;

background:rgba(0,0,0,.72);

backdrop-filter:blur(7px);

justify-content:center;

align-items:center;

z-index:9999;

padding:20px;

overflow-y:auto;

}

.edit-modal.show{

display:flex;

}

.edit-modal-box{

width:min(470px,100%);

padding:30px;

border-radius:28px;

background:#10182d;

border:1px solid rgba(255,255,255,.08);

box-shadow:0 20px 60px rgba(0,0,0,.45);

display:flex;

flex-direction:column;

gap:14px;

max-height:calc(100vh - 40px);

overflow-y:auto;

}

.edit-header{

display:flex;

justify-content:space-between;

align-items:center;

margin-bottom:12px;

}

.edit-header h2{

font-size:28px;

margin:0;

}

.close-modal-btn{

border:none;

background:none;

color:white;

font-size:22px;

cursor:pointer;

padding:6px;

border-radius:50%;

transition:
color .3s ease,
transform .3s ease,
background .3s ease;

}

.close-modal-btn:hover{

color:#ff3b3b;
transform:rotate(90deg);

}

.edit-modal label{

font-size:14px;

opacity:.75;

display:block;

margin-top:8px;

margin-bottom:6px;

}

.edit-modal input,
.edit-modal select{

width:100%;

padding:14px;

border:none;

outline:none;

border-radius:14px;

background:#182341;

color:white;

font-size:14px;

margin-bottom:8px;

}
.edit-modal input[readonly]{

opacity:.7;

cursor:not-allowed;

background:#111b36;

}

.edit-modal select:disabled{

opacity:.7;

cursor:not-allowed;

background:#111b36;

}
.edit-actions{

display:flex;

gap:12px;

margin-top:18px;

}

.save-edit-btn{

flex:1;

padding:14px;

border:none;

border-radius:14px;

cursor:pointer;

font-weight:600;

background:linear-gradient(
90deg,
#3b82f6,
#06b6d4
);

color:white;

}

.cancel-edit-btn{

flex:1;

padding:14px;

border:none;

border-radius:14px;

cursor:pointer;

background:#26314f;

color:white;

}

@media(max-width:520px){

.edit-modal{
padding:14px;
align-items:flex-start;
}

.edit-modal-box{
padding:22px;
border-radius:22px;
max-height:calc(100dvh - 28px);
}

.edit-header h2{
font-size:24px;
}

.edit-actions{
flex-direction:column;
}

}

</style>

<script>

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
        ? "<%= java.time.LocalDate.now() %>"
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

window.onclick=function(event){

let modal =

document.getElementById(
"editModal"
);

if(event.target === modal){

closeEditModal();

}

}

</script>
