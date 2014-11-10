<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<style type="text/css">
.bar {
    height: 18px;
}
</style>
<script>	
		
	$(document).ready(function(){
		$("#loadingPopup")
		.dialog(
				{
					dialogClass: 'no-close',
					closeOnEscape: false,
					autoOpen : false,
					height : '200',
					width : '260',
					modal : true,
					position: [document.body.clientWidth/2 -130,50]
				});
	
	});
	function openLoadingPopup(showProgress)
	{
		if(showProgress)
		{
			$("#progress").css("display","block");
			$("#imgLoading").css("display","none");
		}
		else
		{
			$("#progress").css("display","none");
			$("#imgLoading").css("display","block");
		}
		$("#loadingPopup").dialog("open");
	}
	function closeLoadingPopup()
	{
		$("#loadingPopup").dialog("close");
	}
</script>

<%-- <c:out value="${RemoteSignEnabled}"></c:out> --%>

<div id="loadingPopup" title="Loading..." align="center" style="z-index:99999">
	<img id="imgLoading" src="../Images/loader.gif">
	
	<div id="progress" style="width: 231px" align="left">
		<div class="bar" style="width: 0%;background-image: url('../Images/progress_bar2.png');" ></div><br>
		<div style="width="231px" align="center">
		<b><label style="font-size: 25px;color: #0065a7;" id="barPercentage" style="position: absolute;"></label></b>
		</div>
		
	</div>
</div>
