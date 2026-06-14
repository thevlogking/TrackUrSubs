<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div id="subscriptionModal" class="modal-overlay">

    <div class="modal-box">

        <!-- CLOSE BUTTON -->

        <button
            type="button"
            class="close-modal"
            onclick="closeModal()">

            <i class="fa-solid fa-xmark"></i>

        </button>

        <h2>New Subscription</h2>

        <!-- FORM START -->

        <form
            action="${pageContext.request.contextPath}/subscriptions"
            method="post">

            <!-- SERVICE -->

            <div class="field">

                <label>Service</label>

                <select
                    name="subscription_name"
                    required>

                    <option value="">
                        Select Service
                    </option>

                    <option value="Netflix">
                        Netflix
                    </option>

                    <option value="Amazon Prime Video">
                        Amazon Prime Video
                    </option>

                    <option value="YouTube Premium">
                        YouTube Premium
                    </option>

                    <option value="JioHotstar">
                        JioHotstar
                    </option>

                    <option value="Apple TV+">
                        Apple TV+
                    </option>

                    <option value="ZEE5">
                        ZEE5
                    </option>

                    <option value="Sony Liv">
                        Sony Liv
                    </option>

                    <option value="Hoichoi">
                        Hoichoi
                    </option>

                    <option value="Fancode">
                        Fancode
                    </option>

                    <option value="MX Player">
                        MX Player
                    </option>

                </select>

            </div>

            <!-- PLAN -->

            <div class="field">

                <label>Plan Name</label>

                <input
                    type="text"
                    name="plan_name"
                    placeholder="Basic / Premium"
                    required>

            </div>

            <!-- PRICE + BILLING -->

            <div class="double">

                <div class="field">

                    <label>Price</label>

                    <input
                        type="number"
                        name="amount"
                        placeholder="299"
                        min="1"
                        step="0.01"
                        required>

                </div>

                <div class="field">

                    <label>Billing</label>

                    <select
                        name="billing_cycle"
                        required>

                        <option value="">
                            Select Billing
                        </option>

                        <option value="Weekly">
                            Weekly
                        </option>

                        <option value="Monthly">
                            Monthly
                        </option>

                        <option value="Quarterly">
                            Quarterly
                        </option>

                        <option value="Yearly">
                            Yearly
                        </option>

                    </select>

                </div>

            </div>

            <!-- NEXT RENEWAL -->

            <div class="field">

                <label>Next Renewal</label>

                <input
                    type="date"
                    name="renewal_date"
                    required>

            </div>

            <!-- SUBMIT -->

            <button
                type="submit"
                class="submit-btn">

                Add Subscription

            </button>

        </form>

        <!-- FORM END -->

    </div>

</div>

<script>

function closeModal(){

    document
        .getElementById(
            "subscriptionModal")
        .style.display = "none";
}

function openModal(){

    document
        .getElementById(
            "subscriptionModal")
        .style.display = "flex";
}

</script>