document.querySelectorAll(
".feature-card,.dashboard,.dashboard-card"
).forEach(el=>{

el.classList.add("hidden");

});

const observer=

new IntersectionObserver(entries=>{

entries.forEach(entry=>{

if(entry.isIntersecting){

entry.target.classList.add("show");

}

});

});

document.querySelectorAll(".hidden")
.forEach(el=>{

observer.observe(el);

});

document.querySelectorAll(
'a[href^="#"]'
).forEach(anchor=>{

anchor.addEventListener(
'click',
function(e){

e.preventDefault();

const target=document.querySelector(
this.getAttribute('href')
);

if(target){

target.scrollIntoView({
behavior:"smooth"
});

}

});

});