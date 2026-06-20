        function deleteSubscription(subscriptionId) {
            if (confirm("Delete this subscription permanently?")) {
                document.getElementById("deleteForm" + subscriptionId).submit();
            }
        }

        function openEditModalFromCard(button) {
            const card = button.closest(".sub-card");

            openEditModal(
                card.dataset.id,
                card.dataset.name,
                card.dataset.plan,
                card.dataset.amount,
                card.dataset.billing,
                card.dataset.renewal,
                card.dataset.lastUsed,
                card.dataset.expired === "true"
            );
        }

        document.addEventListener("click", function(event) {
            const editButton = event.target.closest("[data-edit-subscription]");
            const deleteButton = event.target.closest("[data-delete-subscription]");

            if (editButton) {
                openEditModalFromCard(editButton);
            }

            if (deleteButton) {
                deleteSubscription(deleteButton.dataset.subscriptionId);
            }
        });

        const searchInput = document.getElementById("searchSubscription");
        const billingFilter = document.getElementById("billingFilter");

        function filterSubscriptions() {
            const searchText = searchInput.value.toLowerCase().trim();
            const billingValue = billingFilter.value.toLowerCase();

            document.querySelectorAll(".subscription-section").forEach(section => {
                const cards = section.querySelectorAll(".sub-card");
                const sectionCount = section.querySelector(".section-count");
                const filterEmpty = section.querySelector(".filter-empty");
                let visibleCount = 0;

                cards.forEach(card => {
                    const matchesSearch = card.dataset.name
                        .toLowerCase()
                        .includes(searchText);
                    const matchesBilling =
                        billingValue === "all"
                        || card.dataset.billing.toLowerCase().includes(billingValue);
                    const visible = matchesSearch && matchesBilling;

                    card.style.display = visible ? "flex" : "none";

                    if (visible) {
                        visibleCount++;
                    }
                });

                if (sectionCount) {
                    sectionCount.textContent = visibleCount;
                }

                if (filterEmpty) {
                    filterEmpty.style.display =
                        cards.length > 0 && visibleCount === 0 ? "flex" : "none";
                }
            });
        }

        searchInput.addEventListener("input", filterSubscriptions);
        billingFilter.addEventListener("change", filterSubscriptions);
        filterSubscriptions();
