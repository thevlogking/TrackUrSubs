package controller;

import dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import model.User;

import utils.PasswordUtil;
import utils.CloudinaryUtil;

import java.io.IOException;

@WebServlet("/updateAccount")

@MultipartConfig(

fileSizeThreshold = 1024 * 1024,

maxFileSize = 1024 * 1024 * 5,

maxRequestSize = 1024 * 1024 * 10

)

public class UpdateAccountServlet
extends HttpServlet {

@Override

protected void doPost(

HttpServletRequest request,
HttpServletResponse response)

throws ServletException, IOException {

try {

HttpSession session =
request.getSession();

User currentUser =
(User) session.getAttribute(
"user"
);

if(currentUser == null){

response.sendRedirect(

request.getContextPath()
+ "/pages/signin.jsp"

);

return;

}

/* FORM DATA */

String fullName =
request.getParameter(
"fullName"
);

String currentPassword =
request.getParameter(
"currentPassword"
);

String newPassword =
request.getParameter(
"newPassword"
);

String confirmPassword =
request.getParameter(
"confirmPassword"
);

/* VERIFY CURRENT PASSWORD FIRST */

String currentHash =

PasswordUtil.hashPassword(
currentPassword
);

if(!currentUser
.getPasswordHash()
.equals(currentHash)){

session.setAttribute(

"accountError",

"Current password does not match."

);

response.sendRedirect(

request.getContextPath()
+ "/pages/user_dashboard.jsp"

);

return;

}

/* PASSWORD UPDATE */

String passwordHash =

currentUser.getPasswordHash();

if(newPassword != null &&
!newPassword.isBlank()){

if(!newPassword.equals(
confirmPassword
)){

session.setAttribute(

"accountError",

"New passwords do not match."

);

response.sendRedirect(

request.getContextPath()
+ "/pages/user_dashboard.jsp"

);

return;

}

passwordHash =

PasswordUtil.hashPassword(
newPassword
);

}

/* PROFILE IMAGE */

String profileUrl =

currentUser.getProfilePicture();

Part imagePart =
request.getPart(
"profilePic"
);

if(imagePart != null &&
imagePart.getSize() > 0){

profileUrl =

CloudinaryUtil
.uploadImage(
imagePart
);

}

/* UPDATE OBJECT */

currentUser.setFullName(
fullName
);

currentUser.setPasswordHash(
passwordHash
);

currentUser.setProfilePicture(
profileUrl
);

/* DATABASE UPDATE */

UserDAO dao =
new UserDAO();

boolean updated =

dao.updateUser(
currentUser
);

if(updated){

session.setAttribute(

"user",

currentUser

);

session.setAttribute(

"accountSuccess",

"Account updated successfully."

);

}else{

session.setAttribute(

"accountError",

"Unable to update account."

);

}

response.sendRedirect(

request.getContextPath()
+ "/pages/user_dashboard.jsp"

);

}catch(Exception e){

e.printStackTrace();

request.getSession()
.setAttribute(

"accountError",

"Something went wrong."

);

response.sendRedirect(

request.getContextPath()
+ "/pages/user_dashboard.jsp"

);

}

}

}