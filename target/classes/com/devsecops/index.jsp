<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE>Just simple JavaServer pages for CI/CD testing</TITLE>

<META NAME="author" CONTENT="Marty Hall -- hall@apl.jhu.edu">
<META NAME="keywords"
      CONTENT="JSP,JavaServer Pages,servlets">
<META NAME="description"
      CONTENT="A quick example of the four main JSP tags.">
<LINK REL=STYLESHEET
      HREF="My-Style-Sheet.css"
      TYPE="text/css">
</HEAD>

<BODY BGCOLOR="#FDF5E6" TEXT="#000000" LINK="#0000EE"
      VLINK="#551A8B" ALINK="#FF0000">

<CENTER>
<TABLE BORDER=5 BGCOLOR="#EF8429">
  <TR><TH CLASS="TITLE">
      Using JavaServer Pages</TABLE>
</CENTER>
<P>

Some dynamic content for testing <BR>
Test tomcat container <BR>
Second project <BR>
Testing CI/CD job <BR>
Second testing <BR>
<UL>
  <LI><B>Expression.</B><BR>
      Your hostname: <%= request.getRemoteHost() %>.
  <LI><B>Declaration (plus expression).</B><BR>
      <%! private int accessCount = 0; %>
      Accesses to page since server reboot: <%= ++accessCount %>
  <LI><B>Directive (plus expression).</B><BR>
      <%@ page import = "java.util.*" %>
      Current date: <%= new Date() %>
</UL>


</BODY>
</HTML>
