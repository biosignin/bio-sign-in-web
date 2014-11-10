<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<!DOCTYPE html>
<html>
<head>
<!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"><![endif]-->
<link rel="icon" 
      type="image/png" 
      href="<c:url value="/Images/favicon.png"/>" />

<link rel="stylesheet" type="text/css"
	href="<c:url value='/Style/mystyle.css'/>" />
<link rel="stylesheet" type="text/css"
	href="<c:url value='/Style/style.css'/>" />
	<link rel="stylesheet" href="<c:url value='/Style/jquery-ui.css'/>" />
<style type="text/css">
.fileinput-button {
  position: relative;
  overflow: hidden;
}
.fileinput-button input {
  position: absolute;
  top: 0;
  right: 0;
  margin: 0;
  opacity: 0;
  -ms-filter: 'alpha(opacity=0)';
  font-size: 200px;
  direction: ltr;
  cursor: pointer;
}

/* Fixes for IE < 8 */
@media screen\9 {
  .fileinput-button input {
    filter: alpha(opacity=0);
    font-size: 100%;
    height: 100%;
  }
}
</style>



<script src="<c:url value="/Script/jquery-1.9.1/jquery-1.9.1.min.js"/>"></script>
<script src="<c:url value="/Script/jquery-1.9.1/jquery-ui.js"/>"></script>
<script src="<c:url value="/Script/jquery.iframe-transport.js"/>"></script>
<script src="<c:url value="/Script/jquery.fileupload.js"/>"></script>

<script>
 
	$(document).ready(function() {
		$('#uploadSign').fileupload({
			dataType : 'json',
			add : function(e, data){
				openLoadingPopup(true);
				data.submit();
			},
			done : function(e, data) {								
				closeLoadingPopup();
				var uuid = data.result.uuid;
				var ext = data.result.ext;
				if (!data.result.errorMessage) {
					var parameters='';
					parameters+='?uuid='+uuid;
					parameters+='&type=0';
					parameters+='&enableAddSignature='+$('#chkEnableAddSignature').prop('checked');
					parameters+='&enableFlatCopy='+$('#chkEnableFlatCopy').prop('checked');
					location.href = "remoteSign" + parameters;
				} else
					alert('KO ' + data.result.errorMessage);
			},
			error: function(a,b,c){
				//console.log(a);
				var error = "Cannot Upload document";
				try	{
					var r = jQuery.parseHTML(a.responseText);
					   error = r[3].innerText;
				}
				catch(e)
				{}
			   
               alert(error);
		},
		progressall: function (e, data) {
	        var progress = parseInt(data.loaded / data.total * 100, 10);
	        $('#progress .bar').css(
	            'width',
	            progress + '%'
	        );
	        $("#barPercentage").text(progress + '%');
	        
	    }
		});
		
		$('#uploadVerify').fileupload({
			dataType : 'json',
			add : function(e, data){
				openLoadingPopup(true);
				data.submit();
			},
			done : function(e, data) {
							
				closeLoadingPopup();
				var uuid = data.result.uuid;
				var ext = data.result.ext;
				if (!data.result.errorMessage) {															
					location.href = "validateSign?uuid=" + uuid + "&ext="+ext+"&lang=";
				} else
					alert('KO ' + data.result.errorMessage);
			},
			error: function(a,b,c){
				//console.log(a);
				var error = "Cannot Upload document";
				try	{
					var r = jQuery.parseHTML(a.responseText);
					   error = r[3].innerText;
				}
				catch(e)
				{}
			   
               alert(error);
		},
		
		progressall: function (e, data) {
	        var progress = parseInt(data.loaded / data.total * 100, 10);
	        $('#progress .bar').css(
	            'width',
	            progress + '%'
	        );
	        $("#barPercentage").text(progress + '%');
	        
	    }
		});
	});
	
</script>
</head>
<body>
	
	<div class="operationState">
		<div style="color:white;text-align:right;padding-top:5px;padding-right:15px;">
			<span >Powered by Innovery</span>
		</div>
	</div>
	<div class="btnContainer">
		<div class="btn" id="btnSign">
			<img src="<c:url value="/Images/firma_hover.png"/>" />
			<div style="padding-top: 60px">
				<div class="btnOperation btnSign" id="btnSignBio"
					>
					<img src="<c:url value="/Images/sign_fea_bio.png"/>"
						style="width: 35px; vertical-align: middle" /> <span class="fileinput-button"><spring:message code="label.biometric" text="Biometrica" />
				<input id="uploadSign"  type="file" accept="application/pdf,application/xml" name="file" data-url="upload"  ></span>
				</div>
				
			</div>
		</div>
		
		<div class="btn" id="btnSettings">
			<img src="<c:url value="/Images/settings38.png"/>" />
			<div style="padding-top: 60px" align="left">
				<input type="checkbox" id="chkEnableAddSignature" checked="checked"><label for="chkEnableAddSignature" style="font-size: 10px;"><spring:message code="label.enableAddSignature" text="Enable add signature" /></label><br>
				<input type="checkbox" id="chkEnableFlatCopy"><label for="chkEnableFlatCopy" style="font-size: 10px;"><spring:message code="label.enableFlatCopy" text="Enable flat copy" /></label><br>
			</div>
		</div>


	</div>
	<c:import url="loading.jsp"></c:import>
</body>

</html>
