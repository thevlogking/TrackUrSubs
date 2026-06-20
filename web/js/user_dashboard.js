var dashboardReduceMotion = false;

function formatDashboardNumber(value){

return Math.round(value).toLocaleString(
"en-IN"
);

}

function findDashboardCard(element){

while(element && !element.classList.contains("stat-card")){

element =
element.parentElement;

}

return element;

}

function animateDashboardAmount(amountElement){

var target =
Number(
amountElement.getAttribute("data-target") || 0
);

var isCurrency =
amountElement.getAttribute("data-currency") === "true";

var prefix =
isCurrency
? "\u20B9"
: "";

var parentCard =
findDashboardCard(amountElement);

if(dashboardReduceMotion){

amountElement.textContent =
prefix + formatDashboardNumber(target);

return;

}

var duration = 1350;
var startTime =
performance.now();

if(parentCard){

parentCard.classList.add(
"is-counting"
);

}

function step(now){

var progress =
Math.min(
(now - startTime) / duration,
1
);

var eased =
1 - Math.pow(
1 - progress,
3
);

amountElement.textContent =
prefix + formatDashboardNumber(
target * eased
);

if(progress < 1){

requestAnimationFrame(
step
);

}else{

amountElement.textContent =
prefix + formatDashboardNumber(target);

if(parentCard){

parentCard.classList.remove(
"is-counting"
);

}

}

}

requestAnimationFrame(
step
);

}

function runDashboardAnimations(){

var animatedElements =
document.querySelectorAll(
".page-head, .stat-card, .graph-card"
);

for(var i = 0; i < animatedElements.length; i++){

animatedElements[i].classList.add(
"dashboard-animate"
);

}

requestAnimationFrame(function(){

for(var i = 0; i < animatedElements.length; i++){

animatedElements[i].classList.add(
"is-visible"
);

}

});

var amountElements =
document.querySelectorAll(
".stat-amount"
);

setTimeout(function(){

for(var i = 0; i < amountElements.length; i++){

animateDashboardAmount(
amountElements[i]
);

}

}, 180);

}

if(document.readyState === "loading"){

document.addEventListener(
"DOMContentLoaded",
runDashboardAnimations
);

}else{

runDashboardAnimations();

}

var dashboardSpendDataElement =
document.getElementById(
"dashboardSpendData"
);

var dashboardSpendData =
dashboardSpendDataElement
? JSON.parse(
(dashboardSpendDataElement.content
? dashboardSpendDataElement.content.textContent
: dashboardSpendDataElement.textContent) || '{"labels":[],"values":[]}'
)
: { labels: [], values: [] };

var dashboardSpendLabels =
dashboardSpendData.labels || [];

var dashboardSpendValues =
dashboardSpendData.values || [];

var dashboardSinglePoint =
dashboardSpendValues.length === 1;

var dashboardChartLabels =
dashboardSinglePoint
? ["", dashboardSpendLabels[0], ""]
: dashboardSpendLabels;

var dashboardChartValues =
dashboardSinglePoint
? [
dashboardSpendValues[0],
dashboardSpendValues[0],
dashboardSpendValues[0]
]
: dashboardSpendValues;

var dashboardRealPoints =
dashboardSinglePoint
? [false,true,false]
: dashboardSpendValues.map(function(){
return true;
});

var spendChart =
new Chart(

document.getElementById(
"spendChart"),

{

type:"line",

data:{

labels:dashboardChartLabels,

datasets:[{

data:dashboardChartValues.map(function(){
return 0;
}),

fill:true,

backgroundColor:function(context){

var chart =
context.chart;

var area =
chart.chartArea;

if(!area){

return "#7c5cff";
}

var gradient =
chart.ctx.createLinearGradient(
0,
area.top,
0,
area.bottom
);

gradient.addColorStop(
0,
"rgba(34,211,238,.30)"
);

gradient.addColorStop(
1,
"rgba(124,92,255,.03)"
);

return gradient;

},

borderColor:"#7c5cff",

borderWidth:3,

pointBackgroundColor:"#22d3ee",

pointBorderColor:"#ffffff",

pointBorderWidth:2,

pointRadius:function(context){

return dashboardRealPoints[
context.dataIndex
]
? 6
: 0;

},

pointHoverRadius:function(context){

return dashboardRealPoints[
context.dataIndex
]
? 8
: 0;

},

pointHitRadius:18,

tension:.38,

spanGaps:true

}]

},

options:{

responsive:true,

maintainAspectRatio:false,

interaction:{

mode:"nearest",

intersect:true

},

animation:{

duration:dashboardReduceMotion ? 0 : 1200,

easing:"easeOutQuart",

delay:function(context){

return context.type === "data"
&& context.mode === "default"
? context.dataIndex * 90
: 0;

}

},

animations:{

tension:{

duration:dashboardReduceMotion ? 0 : 900,

easing:"easeOutQuart",

from:.1,

to:.38

}

},

plugins:{

legend:{

display:false

},

tooltip:{

displayColors:false,

backgroundColor:"#090d19",

borderColor:"rgba(148,163,184,.18)",

borderWidth:1,

padding:12,

cornerRadius:10,

filter:function(context){

return dashboardRealPoints[
context.dataIndex
];

},

callbacks:{

title:function(items){

if(!items.length){

return "";
}

return dashboardSpendLabels[
dashboardSinglePoint
? 0
: items[0].dataIndex
];

},

label:function(context){

return "Monthly spend: \u20B9" +
formatDashboardNumber(
context.parsed.y
);

}

}

},

},

layout:{

padding:{

left:28,

right:28,

top:18

}

},

scales:{

x:{

offset:true,

grid:{

display:false

},

ticks:{

autoSkip:false,

maxRotation:0,

callback:function(value){

var label =
this.getLabelForValue(value);

if(!label){

return "";
}

var words =
String(label).split(" ");

return words.length > 1
? words
: label;

}

}

},

y:{

beginAtZero:true,

suggestedMax:Math.max(
100,
Math.ceil(
Math.max.apply(
null,
dashboardSpendValues.concat([0])
) * 1.2 / 50
) * 50
),

grid:{

color:"rgba(148,163,184,.10)",

borderDash:[3,4],

drawBorder:false

},

ticks:{

maxTicksLimit:6,

padding:10,

callback:function(value){

return "\u20B9" +
formatDashboardNumber(value);

}

}

}

}

}

}

);

setTimeout(function(){

spendChart.data.datasets[0].data =
dashboardChartValues;

spendChart.update();

}, 450);

/* ADD SUBSCRIPTION MODAL FIX */

var subscriptionModal =

document.getElementById(
"subscriptionModal"
);

function openModal(){

if(subscriptionModal){

subscriptionModal.classList.add(
"show"
);

document.body.style.overflow =
"hidden";

}

}

function closeModal(){

if(subscriptionModal){

subscriptionModal.classList.remove(
"show"
);

document.body.style.overflow =
"auto";

}

}

window.onclick = function(e){

if(

subscriptionModal &&

e.target === subscriptionModal

){

closeModal();

}

};
