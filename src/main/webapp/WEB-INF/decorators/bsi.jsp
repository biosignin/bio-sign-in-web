<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator"
	prefix="decorator"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<decorator:head></decorator:head>
<title>BioSignIn</title>
</head>
<body>
	<div class="logo">
		<img src="<c:url value="/Images/logon300.png"/>" />
	</div>
	<decorator:body></decorator:body>
</body>
</html>