const analyticsDataElement = document.getElementById("analyticsData");
const analyticsData = analyticsDataElement
    ? JSON.parse(
        (
            analyticsDataElement.content
                ? analyticsDataElement.content.textContent
                : analyticsDataElement.textContent
        ) || "{}"
    )
    : {};

const serviceLabels = analyticsData.serviceLabels || [];
const serviceValues = analyticsData.serviceValues || [];
const trendLabels = analyticsData.trendLabels || [];
const trendValues = analyticsData.trendValues || [];
const totalMonthlySpend = Number(analyticsData.totalMonthlySpend || 0);
const leastUsedRecords = analyticsData.leastUsedRecords || [];

const palette = [
    "#ef0d18",
    "#f59e0b",
    "#a3a3a8",
    "#fb0a3f",
    "#22c55e",
    "#3b82f6",
    "#f97316",
    "#8b5cf6",
    "#06b6d4",
    "#eab308",
    "#14b8a6",
    "#ec4899",
    "#84cc16",
    "#64748b",
    "#f43f5e",
    "#0ea5e9"
];

const gridColor = "rgba(148, 163, 184, .10)";
const tickColor = "#9aa4b8";
const rupee = "\u20B9";

const getServiceColor = (index) => {
    if (palette[index]) {
        return palette[index];
    }

    return "hsl(" + ((index * 47) % 360) + ", 82%, 56%)";
};

const serviceColors = serviceLabels.map((_, index) => getServiceColor(index));
const formatMoney = (value) => rupee + Number(value || 0).toFixed(2);

const wrapLabel = (label, limit = 12) => {
    const words = String(label).split(" ");
    const lines = [];
    let currentLine = "";

    words.forEach((word) => {
        const nextLine = currentLine ? currentLine + " " + word : word;

        if (nextLine.length > limit && currentLine) {
            lines.push(currentLine);
            currentLine = word;
        } else {
            currentLine = nextLine;
        }
    });

    if (currentLine) {
        lines.push(currentLine);
    }

    return lines.length ? lines : [String(label)];
};

const escapeHtml = (value) => String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

const renderServiceLegend = () => {
    const legend = document.getElementById("serviceLegend");

    if (!legend) {
        return;
    }

    legend.innerHTML = serviceLabels.map((label, index) => {
        const safeLabel = escapeHtml(label);
        const color = serviceColors[index];
        return (
            '<div class="service-legend-item" title="' + safeLabel + '">' +
                '<span class="service-legend-dot" style="background:' + color + '"></span>' +
                '<span class="service-legend-name">' + safeLabel + '</span>' +
            '</div>'
        );
    }).join("");
};


function openSubscriptionModal(

subscriptionName,
planName,
billingCycle,
usageCount,
mostUsedMonth

){

    const modal =
    document.getElementById(
    "subscriptionModal"
    );

    const title =
    document.getElementById(
    "subscriptionModalTitle"
    );

    const copy =
    document.getElementById(
    "subscriptionModalCopy"
    );

    const tip =
    document.getElementById(
    "subscriptionModalTip"
    );

    title.textContent =
    subscriptionName;

    copy.innerHTML =

    "<strong>Usage Count:</strong> "
    + usageCount +

    "<br><br>" +

    "<strong>Most Used Period:</strong> "
    +
    (
        mostUsedMonth &&
        mostUsedMonth !== "null"

        ? mostUsedMonth

        : "No usage data available"
    );

    tip.innerHTML =

    "This subscription has one of your lowest usage counts." +

    "<br><br>" +

    (
        mostUsedMonth &&
        mostUsedMonth !== "null"

        ?

        "Most activity was recorded during <b>"
        + mostUsedMonth +
        "</b>."

        :

        "No recent usage activity was found."
    )

    +

    "<br><br>" +

    "Consider switching to a cheaper plan, pausing the subscription, or cancelling it if you no longer use it regularly.";

    modal.classList.add(
    "is-open"
    );

    modal.setAttribute(
    "aria-hidden",
    "false"
    );
}

const closeSubscriptionModal = () => {
    const modal = document.getElementById("subscriptionModal");

    if (!modal) {
        return;
    }

    modal.classList.remove("is-open");
    modal.setAttribute("aria-hidden", "true");
};

document.addEventListener("click", (event) => {
    const item = event.target.closest("[data-subscription-modal]");

    if (!item) {
        return;
    }

    openSubscriptionModal(
        item.dataset.subscriptionName,
        item.dataset.planName,
        item.dataset.billingCycle,
        item.dataset.usageCount,
        item.dataset.mostUsedMonth
    );
});

document.addEventListener("click", (event) => {
    if (event.target.id === "subscriptionModal" || event.target.closest("#subscriptionModalClose")) {
        closeSubscriptionModal();
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
        closeSubscriptionModal();
    }
});

Chart.defaults.font.family = "Inter, system-ui, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif";
Chart.defaults.color = tickColor;

const staggeredDelay = (context) => {
    if (context.type === "data" && context.mode === "default") {
        return context.dataIndex * 120;
    }

    return 0;
};

const renewalSinglePoint = trendValues.length === 1;
const renewalChartLabels = renewalSinglePoint
    ? ["", trendLabels[0], ""]
    : trendLabels;
const renewalChartValues = renewalSinglePoint
    ? [trendValues[0], trendValues[0], trendValues[0]]
    : trendValues;
const renewalRealPoints = renewalSinglePoint
    ? [false, true, false]
    : trendValues.map(() => true);

const createAnalyticsCharts = () => {
    if (!serviceLabels.length) {
        return;
    }

    renderServiceLegend();

    new Chart(document.getElementById("trendChart"), {
        type: "line",
        data: {
            labels: renewalChartLabels,
            datasets: [{
                data: renewalChartValues,
                backgroundColor: (context) => {
                    const {chart} = context;
                    const {ctx, chartArea} = chart;

                    if (!chartArea) {
                        return "#22d3ee";
                    }

                    const gradient = ctx.createLinearGradient(
                        0,
                        chartArea.top,
                        0,
                        chartArea.bottom
                    );

                    gradient.addColorStop(0, "rgba(34, 211, 238, .30)");
                    gradient.addColorStop(1, "rgba(99, 102, 241, .03)");

                    return gradient;
                },
                borderColor: "#22d3ee",
                borderWidth: 3,
                fill: true,
                tension: .38,
                spanGaps: true,
                pointBackgroundColor: "#6366f1",
                pointBorderColor: "#f8fafc",
                pointBorderWidth: 2,
                pointRadius: (context) =>
                    renewalRealPoints[context.dataIndex]
                    ? 6
                    : 0,
                pointHoverRadius: (context) =>
                    renewalRealPoints[context.dataIndex]
                    ? 8
                    : 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            resizeDelay: 120,
            animation: {
                duration: 1100,
                easing: "easeOutQuart"
            },
            animations: {
                tension: {
                    duration: 850,
                    easing: "easeOutQuart",
                    from: .1,
                    to: .38
                }
            },
            interaction: {
                intersect: false,
                mode: "index"
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    displayColors: false,
                    backgroundColor: "#090d19",
                    borderColor: "rgba(148, 163, 184, .16)",
                    borderWidth: 1,
                    titleColor: "#f8fafc",
                    bodyColor: "#7c83ff",
                    padding: 14,
                    cornerRadius: 12,
                    filter: (context) =>
                        renewalRealPoints[context.dataIndex],
                    callbacks: {
                        label: (context) =>context.parsed.y + " renewal(s)"
                    }
                }
            },
            layout: {
                padding: {
                    left: 24,
                    right: 24,
                    top: 18
                }
            },
            scales: {
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        color: tickColor,
                        maxRotation: 0,
                        minRotation: 0,
                        callback: function(value) {
                            return this.getLabelForValue(value) || "";
                        }
                    }
                },
                y: {
                    beginAtZero: true,
                    suggestedMax: Math.max(
                        2,
                        Math.max.apply(null, trendValues) + 1
                    ),
                    grid: {
                        color: gridColor,
                        borderDash: [3, 4],
                        drawBorder: false
                    },
                    ticks: {
                        color: tickColor,
                        stepSize: 1,
                        precision: 0,
                        callback: (value) =>
                            Number.isInteger(value)
                            ? value
                            : ""
                    }
                }
            }
        }
    });

    new Chart(document.getElementById("serviceChart"), {
        type: "doughnut",
        data: {
            labels: serviceLabels,
            datasets: [{
                data: serviceValues,
                backgroundColor: serviceColors,
                borderColor: "#f8fafc",
                borderWidth: 2,
                hoverOffset: 10,
                spacing: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            resizeDelay: 120,
            cutout: "58%",
            rotation: -55,
            animation: {
                animateRotate: true,
                animateScale: true,
                duration: 1200,
                easing: "easeOutQuart"
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: "#090d19",
                    borderColor: "rgba(148, 163, 184, .16)",
                    borderWidth: 1,
                    padding: 12,
                    cornerRadius: 12,
                    callbacks: {
                        label: (context) => context.label + " : " + formatMoney(context.parsed)
                    }
                }
            }
        }
    });

    new Chart(document.getElementById("costChart"), {
        type: "bar",
        data: {
            labels: serviceLabels,
            datasets: [{
                data: serviceValues,
                borderRadius: 8,
                borderSkipped: false,
                backgroundColor: serviceColors,
                maxBarThickness: 76,
                barPercentage: .72,
                categoryPercentage: .72
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            resizeDelay: 120,
            animation: {
                duration: 1100,
                easing: "easeOutQuart",
                delay: staggeredDelay
            },
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    displayColors: false,
                    backgroundColor: "#090d19",
                    borderColor: "rgba(148, 163, 184, .16)",
                    borderWidth: 1,
                    padding: 12,
                    cornerRadius: 12,
                    callbacks: {
                        label: (context) => formatMoney(context.parsed.y)
                    }
                }
            },
            layout: {
                padding: {
                    bottom: 16
                }
            },
            scales: {
                x: {
                    grid: {
                        color: gridColor,
                        borderDash: [3, 4],
                        drawBorder: true
                    },
                    ticks: {
                        color: tickColor,
                        maxRotation: 0,
                        minRotation: 0,
                        autoSkip: false,
                        padding: 10,
                        callback: function(value) {
                            return wrapLabel(this.getLabelForValue(value), 12);
                        }
                    }
                },
                y: {
                    beginAtZero: true,
                    grid: {
                        color: gridColor,
                        borderDash: [3, 4],
                        drawBorder: true
                    },
                    ticks: {
                        color: tickColor,
                        callback: (value) => rupee + value
                    }
                }
            }
        }
    });
};

requestAnimationFrame(createAnalyticsCharts);

const waitForPaint = () => new Promise((resolve) => {
    requestAnimationFrame(() => requestAnimationFrame(resolve));
});

const pdfMoney = (value) => "INR " + Number(value || 0).toFixed(2);
const pdfSafeText = (value) => {
    if (value === null || value === undefined || value === "" || value === "null") {
        return "-";
    }

    return String(value);
};

const fitText = (pdf, text, maxWidth) => {
    const value = pdfSafeText(text);

    if (pdf.getTextWidth(value) <= maxWidth) {
        return value;
    }

    let output = value;

    while (output.length > 3 && pdf.getTextWidth(output + "...") > maxWidth) {
        output = output.slice(0, -1);
    }

    return output + "...";
};

const hexToRgb = (hex) => {
    const normalized = String(hex).replace("#", "");
    const full = normalized.length === 3
        ? normalized.split("").map((part) => part + part).join("")
        : normalized;

    return [
        parseInt(full.slice(0, 2), 16),
        parseInt(full.slice(2, 4), 16),
        parseInt(full.slice(4, 6), 16)
    ];
};

const PDF_TOTAL_PAGES = 2;

const drawPdfBackground = (pdf, pageWidth, pageHeight, pageNumber) => {
    pdf.setFillColor(5, 10, 22);
    pdf.rect(0, 0, pageWidth, pageHeight, "F");

    pdf.setFillColor(12, 21, 38);
    pdf.roundedRect(8, 8, pageWidth - 16, pageHeight - 16, 4, 4, "F");

    pdf.setFillColor(18, 31, 55);
    pdf.rect(8, 8, pageWidth - 16, 22, "F");

    pdf.setDrawColor(45, 64, 96);
    pdf.setLineWidth(.25);
    pdf.line(8, 30, pageWidth - 8, 30);

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(7);
    pdf.setTextColor(132, 148, 170);
    pdf.text("Page " + pageNumber + " of " + PDF_TOTAL_PAGES, pageWidth - 18, pageHeight - 8, { align: "right" });
};

const drawPdfHeader = (pdf, pageWidth) => {
    const generatedAt = new Date().toLocaleString("en-IN", {
        day: "2-digit",
        month: "short",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit"
    });

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(15);
    pdf.setTextColor(248, 250, 252);
    pdf.text("TrackUrSubs Analytics Report", 14, 19);

    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(7);
    pdf.setTextColor(148, 163, 184);
    pdf.text("Professional subscription spend summary", 14, 25);
    pdf.text("Generated: " + generatedAt, pageWidth - 14, 18, { align: "right" });
};

const drawPdfMetric = (pdf, x, y, width, label, value, accent) => {
    pdf.setFillColor(15, 26, 45);
    pdf.setDrawColor(45, 64, 96);
    pdf.roundedRect(x, y, width, 15, 2.5, 2.5, "FD");

    const rgb = hexToRgb(accent);
    pdf.setFillColor(rgb[0], rgb[1], rgb[2]);
    pdf.roundedRect(x + 3, y + 3, 2, 9, 1, 1, "F");

    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(6);
    pdf.setTextColor(148, 163, 184);
    pdf.text(label, x + 8, y + 6);

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(9);
    pdf.setTextColor(248, 250, 252);
    pdf.text(value, x + 8, y + 11.5);
};

const drawPdfPanel = (pdf, x, y, width, height, title, subtitle) => {
    pdf.setFillColor(13, 23, 37);
    pdf.setDrawColor(45, 64, 96);
    pdf.roundedRect(x, y, width, height, 3, 3, "FD");

    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(9.5);
    pdf.setTextColor(248, 250, 252);
    pdf.text(title, x + 4, y + 8);

    if (subtitle) {
        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7);
        pdf.setTextColor(148, 163, 184);
        pdf.text(subtitle, x + 4, y + 15);
    }
};

const drawChartImage = (pdf, canvasId, x, y, width, height, title, subtitle) => {
    drawPdfPanel(pdf, x, y, width, height, title, subtitle);

    const canvas = document.getElementById(canvasId);

    if (!canvas) {
        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7);
        pdf.setTextColor(148, 163, 184);
        pdf.text("No chart data available", x + width / 2, y + height / 2, { align: "center" });
        return;
    }

    const paddingTop = subtitle ? 15 : 11;
    const boxX = x + 4;
    const boxY = y + paddingTop;
    const boxWidth = width - 8;
    const boxHeight = height - paddingTop - 4;
    const canvasRatio = canvas.width / canvas.height;
    const boxRatio = boxWidth / boxHeight;
    let imageWidth = boxWidth;
    let imageHeight = boxHeight;

    if (canvasRatio > boxRatio) {
        imageHeight = imageWidth / canvasRatio;
    } else {
        imageWidth = imageHeight * canvasRatio;
    }

    const imageX = boxX + (boxWidth - imageWidth) / 2;
    const imageY = boxY + (boxHeight - imageHeight) / 2;

    pdf.addImage(canvas.toDataURL("image/png"), "PNG", imageX, imageY, imageWidth, imageHeight);
};

const drawWrappedPdfText = (pdf, text, x, y, maxWidth, lineHeight, align = "left") => {
    const words = pdfSafeText(text).split(" ");
    const lines = [];
    let line = "";

    words.forEach((word) => {
        const testLine = line ? line + " " + word : word;

        if (line && pdf.getTextWidth(testLine) > maxWidth) {
            lines.push(line);
            line = word;
        } else {
            line = testLine;
        }
    });

    if (line) {
        lines.push(line);
    }

    lines.slice(0, 2).forEach((lineText, index) => {
        pdf.text(fitText(pdf, lineText, maxWidth), x, y + (index * lineHeight), { align });
    });
};

const drawPdfCostBarChart = (pdf, x, y, width, height, rows) => {
    drawPdfPanel(pdf, x, y, width, height, "Cost By Service", "Monthly equivalent");

    if (!rows.length) {
        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7.5);
        pdf.setTextColor(148, 163, 184);
        pdf.text("No chart data available", x + width / 2, y + height / 2, { align: "center" });
        return;
    }

    const chartX = x + 18;
    const chartY = y + 23;
    const chartWidth = width - 30;
    const chartHeight = height - 43;
    const labelTop = chartY + chartHeight + 7;
    const maxValue = Math.max(...rows.map((row) => Number(row.amount || 0)), 1);
    const barSlot = chartWidth / rows.length;
    const barWidth = Math.min(12, Math.max(6, barSlot * .45));

    pdf.setDrawColor(38, 55, 82);
    pdf.setLineWidth(.2);
    pdf.line(chartX, chartY + chartHeight, chartX + chartWidth, chartY + chartHeight);

    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(6.5);
    pdf.setTextColor(148, 163, 184);

    for (let step = 0; step <= 2; step++) {
        const value = (maxValue / 2) * step;
        const gridY = chartY + chartHeight - ((value / maxValue) * chartHeight);
        pdf.setDrawColor(26, 42, 65);
        pdf.line(chartX, gridY, chartX + chartWidth, gridY);
        pdf.text(String(Math.round(value)), chartX - 4, gridY + 1.8, { align: "right" });
    }

    rows.forEach((row, index) => {
        const barHeight = (Number(row.amount || 0) / maxValue) * (chartHeight - 2);
        const barX = chartX + (index * barSlot) + ((barSlot - barWidth) / 2);
        const barY = chartY + chartHeight - barHeight;
        const rgb = hexToRgb(row.color || palette[index % palette.length]);
        const labelX = chartX + (index * barSlot) + (barSlot / 2);

        pdf.setFillColor(rgb[0], rgb[1], rgb[2]);
        pdf.roundedRect(barX, barY, barWidth, barHeight, 1.8, 1.8, "F");

        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7.2);
        pdf.setTextColor(226, 232, 240);
        drawWrappedPdfText(pdf, row.service, labelX, labelTop, barSlot - 2, 4.5, "center");
    });
};

const drawPdfTable = (pdf, x, y, width, height, title, columns, rows, startIndex, options = {}) => {
    const safeRows = Array.isArray(rows) ? rows : [];
    const rowHeight = options.rowHeight || 6.4;
    const headerY = y + (options.headerOffset || 30);
    const maxRows = Math.max(0, Math.floor((height - (options.rowAreaOffset || 35)) / rowHeight));
    const visibleRows = options.maxRows ? Math.min(maxRows, options.maxRows) : maxRows;
    const endIndex = Math.min(safeRows.length, startIndex + visibleRows);
    const showingCount = Math.max(0, endIndex - startIndex);
    const subtitle = endIndex < safeRows.length
        ? "Showing " + showingCount + " of " + safeRows.length + " record(s)"
        : safeRows.length + " record(s)";

    drawPdfPanel(pdf, x, y, width, height, title, options.subtitle || subtitle);
    pdf.setDrawColor(45, 64, 96);
    pdf.setLineWidth(.2);
    pdf.line(x + 4, y + 18, x + width - 4, y + 18);

    if (!safeRows.length) {
        pdf.setFont("helvetica", "normal");
        pdf.setFontSize(7);
        pdf.setTextColor(148, 163, 184);
        pdf.text("No records available", x + width / 2, y + height / 2, { align: "center" });
        return endIndex;
    }

    pdf.setFillColor(22, 36, 58);
    pdf.rect(x + 4, headerY - 5, width - 8, 8, "F");
    pdf.setFont("helvetica", "bold");
    pdf.setFontSize(options.headerFontSize || 5.5);
    pdf.setTextColor(203, 213, 225);

    let colX = x + 6;

    columns.forEach((column) => {
        const textX = column.align === "center"
            ? colX + (column.width / 2)
            : column.align === "right"
                ? colX + column.width - 2
                : colX;
        pdf.text(column.label, textX, headerY, { align: column.align || "left" });
        colX += column.width;
    });

    pdf.setFont("helvetica", "normal");
    pdf.setFontSize(options.fontSize || 5.5);

    for (let index = startIndex; index < endIndex; index++) {
        const row = safeRows[index];
        const rowY = headerY + 5 + ((index - startIndex) * rowHeight);

        if ((index - startIndex) % 2 === 0) {
            pdf.setFillColor(15, 26, 45);
            pdf.rect(x + 4, rowY - (rowHeight * .62), width - 8, rowHeight, "F");
        }

        colX = x + 6;

        columns.forEach((column) => {
            const rawValue = column.format ? column.format(row[column.key], row, index) : row[column.key];
            const text = fitText(pdf, rawValue, column.width - 2);

            if (column.colorKey && row[column.colorKey]) {
                const rgb = hexToRgb(row[column.colorKey]);
                pdf.setFillColor(rgb[0], rgb[1], rgb[2]);
                pdf.circle(colX + 1.2, rowY - 1.2, 1.2, "F");
                pdf.setTextColor(226, 232, 240);
                pdf.text(text, colX + 4, rowY);
            } else {
                const textX = column.align === "center"
                    ? colX + (column.width / 2)
                    : column.align === "right"
                        ? colX + column.width - 2
                        : colX;
                pdf.setTextColor(226, 232, 240);
                pdf.text(text, textX, rowY, { align: column.align || "left" });
            }

            colX += column.width;
        });
    }

    if (endIndex < safeRows.length) {
        pdf.setFont("helvetica", "bold");
        pdf.setFontSize(7);
        pdf.setTextColor(34, 211, 238);
        pdf.text("+" + (safeRows.length - endIndex) + " more not shown", x + width - 6, y + height - 5, { align: "right" });
    }

    return endIndex;
};

const buildPdfRows = () => {
    const renewalTotal = trendValues.reduce((sum, value) => sum + Number(value || 0), 0);

    return {
        renewalTotal,
        services: serviceLabels.map((label, index) => ({
            color: serviceColors[index],
            service: label,
            amount: Number(serviceValues[index] || 0),
            share: totalMonthlySpend ? (Number(serviceValues[index] || 0) / totalMonthlySpend) * 100 : 0
        })),
        renewals: trendLabels.map((label, index) => ({
            month: label,
            renewals: Number(trendValues[index] || 0)
        })),
        leastUsed: leastUsedRecords.map((record) => ({
            name: record.name,
            plan: record.plan,
            amount: Number(record.amount || 0),
            cycle: record.cycle,
            usageCount: Number(record.usageCount || 0),
            mostUsedMonth: record.mostUsedMonth
        }))
    };
};

const compactPdfRowOptions = (rowCount, height) => {
    const rowHeight = Math.max(5.2, Math.min(7.2, (height - 35) / Math.max(rowCount, 1)));
    const fontSize = rowHeight < 6 ? 5.8 : 6.5;

    return {
        rowHeight,
        fontSize,
        headerFontSize: 6.6,
        headerOffset: 30,
        rowAreaOffset: 35
    };
};

const downloadWholePagePdf = async () => {
    const button = document.getElementById("downloadAnalyticsPdf");

    if (!window.jspdf) {
        alert("PDF export tools are still loading. Please try again in a moment.");
        return;
    }

    const originalText = button ? button.innerHTML : "";

    try {
        if (button) {
            button.disabled = true;
            button.innerHTML = '<i class="fa-solid fa-spinner fa-spin" aria-hidden="true"></i><span>Preparing PDF</span>';
        }

        await new Promise((resolve) => setTimeout(resolve, 350));
        await waitForPaint();

        const rows = buildPdfRows();
        const pdf = new jspdf.jsPDF("l", "mm", "a4");
        const pageWidth = pdf.internal.pageSize.getWidth();
        const pageHeight = pdf.internal.pageSize.getHeight();

        drawPdfBackground(pdf, pageWidth, pageHeight, 1);
        drawPdfHeader(pdf, pageWidth);

        drawPdfMetric(pdf, 14, 35, 62, "Total monthly spend", pdfMoney(totalMonthlySpend), "#22d3ee");
        drawPdfMetric(pdf, 82, 35, 52, "Services tracked", String(serviceLabels.length), "#8b5cf6");
        drawPdfMetric(pdf, 140, 35, 58, "Upcoming renewals", String(rows.renewalTotal), "#22c55e");
        drawPdfMetric(pdf, 204, 35, 62, "Least used records", String(rows.leastUsed.length), "#f97316");

        drawChartImage(pdf, "trendChart", 14, 58, 132, 56, "Renewal Distribution", "Upcoming renewals by month");
        drawChartImage(pdf, "serviceChart", 152, 58, 131, 56, "Cost Per Service", "Monthly spend share");
        drawPdfCostBarChart(pdf, 14, 122, 269, 67, rows.services);

        pdf.addPage();
        drawPdfBackground(pdf, pageWidth, pageHeight, 2);
        drawPdfHeader(pdf, pageWidth);

        pdf.setFont("helvetica", "bold");
        pdf.setFontSize(10);
        pdf.setTextColor(226, 232, 240);
        pdf.text("Detailed Records", 14, 39);

        drawPdfTable(
            pdf,
            14,
            44,
            132,
            84,
            "Service Costs",
            [
                { label: "Service", key: "service", width: 66, colorKey: "color" },
                { label: "Monthly Cost", key: "amount", width: 34, format: pdfMoney, align: "center" },
                { label: "Share", key: "share", width: 22, format: (value) => Number(value || 0).toFixed(1) + "%", align: "center" }
            ],
            rows.services,
            0,
            compactPdfRowOptions(rows.services.length, 84)
        );

        drawPdfTable(
            pdf,
            152,
            44,
            131,
            84,
            "Renewals",
            [
                { label: "Month", key: "month", width: 72 },
                { label: "Count", key: "renewals", width: 32, format: (value) => String(value || 0), align: "center" }
            ],
            rows.renewals,
            0,
            compactPdfRowOptions(rows.renewals.length, 84)
        );

        drawPdfTable(
            pdf,
            14,
            137,
            269,
            52,
            "Least Used Subscriptions",
            [
                { label: "Subscription", key: "name", width: 64 },
                { label: "Plan", key: "plan", width: 48 },
                { label: "Cost", key: "amount", width: 30, format: pdfMoney, align: "center" },
                { label: "Cycle", key: "cycle", width: 28, align: "center" },
                { label: "Usage", key: "usageCount", width: 22, format: (value) => String(value || 0), align: "center" },
                { label: "Most Used", key: "mostUsedMonth", width: 50 }
            ],
            rows.leastUsed,
            0,
            compactPdfRowOptions(rows.leastUsed.length, 52)
        );

        pdf.save("trackursubs-analytics.pdf");
    } catch (error) {
        console.error("Unable to export analytics PDF", error);
        alert("Unable to create the PDF. Please try again.");
    } finally {
        if (button) {
            button.disabled = false;
            button.innerHTML = originalText;
        }
    }
};

document.getElementById("downloadAnalyticsPdf")
    ?.addEventListener("click", downloadWholePagePdf);
