<div id="editModal" class="edit-modal" data-today="<%= java.time.LocalDate.now() %>">

    <div class="edit-modal-box">

        <div class="edit-header">

            <h2 id="editModalTitle">Edit Subscription</h2>

            <button
            class="close-modal-btn"
            data-close-edit-modal>

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
                data-close-edit-modal>

                    Cancel

                </button>

            </div>

        </form>

    </div>

</div>

<link rel="stylesheet" href="../css/edit_subscription.css">

<script src="../js/edit_subscription.js"></script>
