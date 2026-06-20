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

<div id="manageAccountModal" class="modal" data-open-on-load="<%= accountError != null %>">

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

<link rel="stylesheet" href="../css/manage_account.css">

<script src="../js/manage_account.js"></script>
