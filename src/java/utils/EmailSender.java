package util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

public class EmailSender {


private static final String SMTP_HOST =
System.getenv("SMTP_HOST");

private static final String SMTP_PORT =
System.getenv("SMTP_PORT");

private static final String SMTP_USER =
System.getenv("SMTP_USER");

private static final String SMTP_PASS =
System.getenv("SMTP_PASS");

private static final String FROM_EMAIL =
System.getenv("FROM_EMAIL");

public static void sendEmail(
        String to,
        String subject,
        String body)
throws Exception {

    Properties props =
    new Properties();

    props.put(
    "mail.smtp.host",
    SMTP_HOST);

    props.put(
    "mail.smtp.port",
    SMTP_PORT);

    props.put(
    "mail.smtp.auth",
    "true");

    props.put(
    "mail.smtp.starttls.enable",
    "true");

    Session session =

    Session.getInstance(

    props,

    new Authenticator() {

        @Override
        protected PasswordAuthentication
        getPasswordAuthentication() {

            return new PasswordAuthentication(

            SMTP_USER,

            SMTP_PASS);
        }
    });

    Message message =

    new MimeMessage(session);

    message.setFrom(

    new InternetAddress(
    FROM_EMAIL));

    message.setRecipients(

    Message.RecipientType.TO,

    InternetAddress.parse(
    to));

    message.setSubject(
    subject);

    message.setContent(

    body,

    "text/html; charset=UTF-8");

    Transport.send(
    message);
}


}
