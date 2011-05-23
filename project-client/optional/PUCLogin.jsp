<%@ taglib prefix='c' uri='http://java.sun.com/jstl/core'%>
<%@
    page language="java"
	import="org.springframework.security.ui.AbstractProcessingFilter,org.springframework.security.ui.webapp.AuthenticationProcessingFilter,org.springframework.security.ui.savedrequest.SavedRequest,org.springframework.security.AuthenticationException,org.pentaho.platform.uifoundation.component.HtmlComponent,org.pentaho.platform.engine.core.system.PentahoSystem,org.pentaho.platform.util.messages.LocaleHelper,org.pentaho.platform.api.engine.IPentahoSession,org.pentaho.platform.web.http.WebTemplateHelper,org.pentaho.platform.api.engine.IUITemplater,org.pentaho.platform.web.jsp.messages.Messages,java.util.List,java.util.ArrayList,java.util.StringTokenizer,org.apache.commons.lang.StringEscapeUtils,org.pentaho.platform.web.http.PentahoHttpSessionHelper"%>



<%!// List of request URL strings to look for to send 401

	private List<String> send401RequestList;

	public void jspInit() {
		// super.jspInit(); 
		send401RequestList = new ArrayList<String>();
		String unauthList = getServletConfig().getInitParameter("send401List"); //$NON-NLS-1$
		if (unauthList == null) {
			send401RequestList.add("AdhocWebService"); //$NON-NLS-1$
		} else {
			StringTokenizer st = new StringTokenizer(unauthList, ","); //$NON-NLS-1$
			String requestStr;
			while (st.hasMoreElements()) {
				requestStr = st.nextToken();
				send401RequestList.add(requestStr.trim());
			}
		}
	}%>

<%
	response.setCharacterEncoding(LocaleHelper.getSystemEncoding());
	String path = request.getContextPath();

	IPentahoSession userSession = PentahoHttpSessionHelper
			.getPentahoSession(request);
	// SPRING_SECURITY_SAVED_REQUEST_KEY contains the URL the user originally wanted before being redirected to the login page
	// if the requested url is in the list of URLs specified in the web.xml's init-param send401List,
	// then return a 401 status now and don't show a login page (401 means not authenticated)
	Object reqObj = request.getSession().getAttribute(AbstractProcessingFilter.SPRING_SECURITY_SAVED_REQUEST_KEY);
	String requestedURL = "";
	if (reqObj != null) {
		requestedURL = ((SavedRequest) reqObj).getFullRequestUrl();

		String lookFor;
		for (int i = 0; i < send401RequestList.size(); i++) {
			lookFor = send401RequestList.get(i);
			if (requestedURL.indexOf(lookFor) >= 0) {
				response.sendError(401);
				return;
			}
		}
	}

	boolean loggedIn;
	String remoteUser = request.getRemoteUser();
	if (remoteUser != null && remoteUser != "") {
		loggedIn = true;
	}
	
	int year = (new java.util.Date()).getYear() + 1900;
	
%>
<html lang="en">
    <head>
        <title>Login to Steel Wheels - Pentaho User Console</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="gwt:property" content="locale=</%=request.getLocale()%>">
        <!-- Uncomment to put your own favicon
        <link rel="shortcut icon" href="/pentaho-style/favicon.ico" /> -->
        <style type="text/css" media="screen, projection">
            *{margin:0;padding:0;}
            html{font-size:100%;}
            body{background:#fff;color:#222;font-family:"Helvetica Neue", Arial, Helvetica, sans-serif;text-align:center;font-size:75%;}
            h2{font-size:2em;margin-bottom:0.75em;}
            .error{background:#FBE3E4;border:2px solid #FBC2C4;color:#8a1f11;margin-bottom:1em;text-align:center;width:332px;padding:6px;}
            #login-logo{padding:40px 0;}
            #login-form{background:#fff;border:1px solid #ccc;text-align:left;width:350px;-moz-border-radius:5px;-webkit-border-radius:5px;-moz-box-shadow:0 1px 3px #ddd;-webkit-box-shadow:0 1px 3px #ddd;margin:0 auto;padding:15px 15px 25px;}
            #login-form h2{text-align:center;padding:5px 0;}
            #login-form .field{width:335px;margin:15px 0;}
            #login-form .field label{color:#777;display:block;font-size:1em;font-weight:700;margin-bottom:5px;text-align:left;}
            #login-form .field input{border:1px solid #ccc;font-size:1.2em;width:100%;padding:5px;}
        </style>

        <script type="text/javascript">
            // If the Username and Password values are blank then alert();
            // This can be replaced with an AJAX solution
            function checkForm(form) {
                if(form.j_username.value == "" && form.j_password.value == "") {
                    alert('You can not have a blank Username and Password!')
                    return false;
                }
            }
        </script>
    </head>
    <body>
        <!-- Login Logo -->
        <div id="login-logo">
            <!-- Steel Wheels logo located under the Steel Wheels webapp-->
            <!-- <img src="/sw-style/active/sw_logo.jpg" alt="Steel Wheels Logo"> -->
            <img src="/pentaho-style/larger_logo.png" alt="Steel Wheels Logo">
        </div>

        <!-- Login Form -->
        <div id="login-form">
            <!-- Header -->
            <h2>Login to Steel Wheels</h2>
            <!-- If the login_error URL parameter is set then show error box -->
            <!-- </% if (request.getParameter("login_error") != null) {%> -->
            <div class="error">Authentication failed! Please try again!</div>
            <!-- </% }%> -->

            <!-- Form -->
            <form id="sw-login" method="POST" action="/pentaho/j_spring_security_check">
                <!-- Username -->
                <div class="field">
                    <label for="username">Username</label>
                    <input id="username" name="j_username" type="text">
                </div>
                <!-- Password -->

                <div class="field">
                    <label for="password">Password</label>
                    <input id="password" name="j_password" type="password">
                </div>
                <!-- On click on the submit button run the checkFrom function -->
                <input type="submit" value="Login" onclick="return checkForm(form);">
            </form>
        </div>

    </body>
</html>
<%!// reads the exception stored by AbstractProcessingFilter
	private String getUserMessage(final AuthenticationException e) {
		String userMessage = Messages
				.getString("UI.USER_LOGIN_FAILED_DEFAULT_REASON");
		if (null != e) {
			String errorClassName = e.getClass().getName();
			errorClassName = errorClassName.replace('.', '_');
			errorClassName = errorClassName.toUpperCase();
			String key = "UI.USER_LOGIN_FAILED_REASON_" + errorClassName;
			String tmp = Messages.getString(key);
			if (null != tmp && 0 != tmp.length() && !tmp.startsWith("!")) {
				userMessage = tmp;
			}
		}
		return userMessage;
	}%>
