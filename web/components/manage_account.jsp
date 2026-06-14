<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="model.User"%>

<%

User currentUser =
(User)session.getAttribute("user");

String accountError =
(String)session.getAttribute(
"accountError"
);

session.removeAttribute(
"accountError"
);

if(currentUser==null){

response.sendRedirect(
request.getContextPath()
+"/pages/signin.jsp"
);

return;

}

%>

<div id="manageAccountModal" class="modal">

<div class="modal-content">

<span class="close-btn">

<i class="fa-solid fa-xmark"></i>

</span>

<!-- PROFILE -->

<form
action="<%=request.getContextPath()%>/updateAccount"
method="post"
enctype="multipart/form-data">

<div class="profile-header">

<div class="profile-upload">

<img
src="<%= (currentUser.getProfilePicture()!=null && !currentUser.getProfilePicture().isEmpty())

? currentUser.getProfilePicture()

: request.getContextPath()+"/images/default_profile.png" %>"

id="profilePreview"

class="profile-image"

alt="Profile">

<label for="profilePic">

<i class="fa-solid fa-camera"></i>

</label>

<input
type="file"
id="profilePic"
name="profilePic"
accept="image/*"
hidden>

</div>

</div>

<% if(accountError != null){ %>

<div class="account-error">

<i class="fa-solid fa-circle-exclamation"></i>

<span>

<%=accountError%>

</span>

</div>

<script>

window.addEventListener(
"load",
function(){

openManageAccount();

});

</script>

<% } %>

<!-- FULL NAME -->

<div class="field">

<label>Full Name</label>

<input
type="text"
name="fullName"
value="<%=currentUser.getFullName()%>"
required>

</div>

<!-- EMAIL -->

<div class="field">

<label>Email Address</label>

<div class="readonly-box">

<%=currentUser.getEmail()%>

</div>

</div>

<!-- PASSWORD -->

<div class="field">

<label>Current Password</label>

<input
type="password"
name="currentPassword"
placeholder="Enter current password"
required>

</div>

<div class="password-grid">

<div class="field">

<label>New Password</label>

<input
type="password"
name="newPassword"
placeholder="Leave empty if unchanged">

</div>

<div class="field">

<label>Confirm Password</label>

<input
type="password"
name="confirmPassword"
placeholder="Confirm password">

</div>

</div>

<button
type="submit"
class="save-btn">

<i class="fa-solid fa-floppy-disk"></i>

Save Changes

</button>

</form>

</div>

</div>

<style>

.modal{

display:none;

position:fixed;

top:0;
left:0;

width:100%;
height:100%;

background:
rgba(0,0,0,.78);

backdrop-filter:
blur(12px);

justify-content:center;
align-items:center;

padding:20px;

z-index:9999;

}

.modal-content{

width:92%;

max-width:720px;

padding:34px 42px;

border-radius:28px;

background:

linear-gradient(
180deg,
#081223,
#0b1730
);

border:

1px solid rgba(255,255,255,.05);

box-shadow:

0 25px 60px rgba(0,0,0,.45);

position:relative;

animation:
slideUp .3s ease;

max-height:calc(100vh - 40px);

overflow-y:auto;

}

/* CLOSE */

.close-btn{

position:absolute;

top:22px;
right:28px;

font-size:34px;

cursor:pointer;

opacity:.8;

transition:.3s;
color:rgb(249, 24, 24);

}

.close-btn:hover{

transform:rotate(90deg);

opacity:1;


}

/* PROFILE */

.profile-header{

display:flex;

justify-content:center;

margin-bottom:25px;

}

.profile-upload{

position:relative;

}

.profile-image{

width:90px;
height:90px;

border-radius:50%;

object-fit:cover;

border:3px solid rgba(255,255,255,.08);

box-shadow:

0 0 30px rgba(122,77,255,.30);

}

.profile-upload label{

position:absolute;

bottom:0;
right:0;

width:34px;
height:34px;

border-radius:50%;

display:flex;

justify-content:center;
align-items:center;

cursor:pointer;

background:

linear-gradient(
135deg,
#7a4dff,
#22d3ee
);

}

/* ERROR */

.account-error{

display:flex;

align-items:center;

gap:12px;

padding:14px 18px;

margin-bottom:20px;

border-radius:14px;

background:

rgba(255,90,90,.18);

border:

1px solid rgba(255,90,90,.28);

color:

#ffb5b5;

font-weight:600;

}

.account-error i{

color:#ff6b6b;

}

/* FIELD */

.field{

display:flex;

flex-direction:column;

margin-bottom:14px;

}

.field label{

margin-bottom:9px;

font-weight:600;

font-size:15px;

}

.field input{

height:54px;

padding:14px 18px;

border:none;

border-radius:12px;

background:#1b2538;

color:white;

font-size:15px;

transition:.3s;

}

.field input:focus{

outline:none;

border:1px solid #22d3ee;

box-shadow:

0 0 0 4px rgba(34,211,238,.08);

}

.readonly-box{

height:54px;

display:flex;

align-items:center;

padding:0 18px;

border-radius:12px;

background:

rgba(255,255,255,.05);

border:

1px solid rgba(255,255,255,.05);

color:white;

}

/* GRID */

.password-grid{

display:grid;

grid-template-columns:1fr 1fr;

gap:14px;

}

/* BUTTON */

.save-btn{

width:100%;

height:58px;

margin-top:20px;

border:none;

border-radius:14px;

cursor:pointer;

font-size:17px;

font-weight:700;

color:white;

background:

linear-gradient(
90deg,
#3366ee,
#5687ff
);

transition:.3s;

}

.save-btn:hover{

transform:translateY(-3px);

box-shadow:

0 14px 30px rgba(51,102,238,.35);

}

@keyframes slideUp{

from{

opacity:0;

transform:
translateY(20px);

}

to{

opacity:1;

transform:
translateY(0);

}

}

@media(max-width:700px){

.modal{
align-items:flex-start;
padding:14px;
overflow-y:auto;
}

.modal-content{

width:100%;
padding:24px;
max-height:calc(100dvh - 28px);

}

.password-grid{

grid-template-columns:1fr;

}

.close-btn{
top:16px;
right:20px;
}

}

</style>

<script>

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

.onclick =
function(){

modal.style.display =
"none";

};

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

</script>
