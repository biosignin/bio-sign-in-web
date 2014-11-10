<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<c:set var="req" value="${pageContext.request}" />
<c:set var="baseURL"
	value="${fn:replace(req.requestURL, fn:substring(req.requestURI, 1, fn:length(req.requestURI)), req.contextPath)}" />


	

<!--
	
//-->

<script type="text/javascript"
	src="<c:url value='/Script/sctp/main.js' />"></script>
<script type="text/javascript"
	src="<c:url value='/Script/sctp/extra.js' />"></script>
	<script src="<c:url value="/Script/json2.js"/>"></script>
<script type="text/javascript">

	// function abilita() {
	// 	var isFormValid = true;
	// 	getAllInput().each(function() {
	// 		console.log('checkin '+$(this)[0].id+ ' - "'+$(this).val()+'"');
	// 		if (!$(this).val())
	// 			isFormValid = false;
	// 	});
	// 	$("#dialog-form input[type='submit']").prop('disabled', !isFormValid);
	// }

	// function getAllInput(){
	// 	return $('#dialog-form input').not(':input[type=button], :input[type=submit], :input[type=reset]');
	// }
	var selectCertFromList=false;
	var currentUrlWithPath = "<c:out value='${baseURL}'/>";
	
	var codeBaseWithHost = "<c:out value='${baseURL}'/>";
	
	
	var selectedName;
	
	
	$(function() {
		
		
		
		$("#tabs").tabs( );
		
		$( "#tabsTipoFirma" ).tabs({
			select: function(event, ui) {
        		if(ui.index==1)
        			load();
        	}
	});
		// 	abilita();
		// 	getAllInput().each(function() {
		// 		$(this).change(abilita);
		// 	});

		$("#sign-info").dialog({
			autoOpen : false,
			height : 'auto',
			width : '550px',
			modal : true

		});

		$("#dialog-form")
				.dialog(
						{
							resizable: false,
							draggable: false,
							autoOpen : false,
							minHeight : '605px',
							width : '830px',
							modal : true,
							/*dialogClass: 'dlgfixed',
						    position: "center",*/
							//position:['center','top'],
							//position: [document.body.clientWidth/2 -500,(window.screen.availHeight-50)/2 - Math.round($("#dialog-form").height())/2],
							open : function(event, ui) {
								

								toTabRemoto();
								//setTimeout(function()
								{
									$("#dialog-form")
									.dialog({
										position: [document.body.clientWidth/2 -500,$(window).height()/2 - Math.round($("#dialog-form").parent().height())/2]
									});
									selectedApplet = document.webSigningFD;
									selectedAppletContainer=WebSigningApplet;
									
										
									if(1==1 && !onlyShow) { //da 
										if(signsStructure[getSignatureById(viewModel.signatureSelected()).name()].dsig)
											WebSigningApplet.setSigTag(signsStructure[getSignatureById(viewModel.signatureSelected()).name()].dsig);
									
									}
									if(onlyShow)
									{
										WebSigningApplet.setPdfBase64Image(codeBaseWithHost+'/signManagement/'+$('#pageImage').attr('src'),realWidthPage,
												viewModel.actualPage(),viewModel.totalPages());
										
										WebSigningApplet.setSignRectangle(1,
													1,
													1,
													1);
											
									}
									
								}
								//,0);
								
								
								if(playClicked==false)
								{
									$(".ui-dialog-buttonpane button:contains('Salta')").attr("disabled", true)
			                        .addClass("ui-state-disabled");
									$(".ui-dialog-buttonpane button:contains('Annulla')").attr("disabled", true)
			                        .addClass("ui-state-disabled");
								}
								else
								{
									$(".ui-dialog-buttonpane button:contains('Salta')").attr("disabled", false)
			                        .removeClass("ui-state-disabled");
									$(".ui-dialog-buttonpane button:contains('Annulla')").attr("disabled", false)
			                        .removeClass("ui-state-disabled");
								}
								
								
							},
							buttons : {
								/*"Sign" : function() {
									playClicked=false;
									popupSign();
									
									
								},*/
								'<spring:message code="label.cancel" text="Cancel" />' : function() {
									/*WebSigningApplet.clearPanel();
									WebSigningApplet.stop();*/
									$(this).dialog("close");
									
								},
								'<spring:message code="label.skip.signature" text="Skip Signature" />':function() {
									if(playClicked)
									{
										var sig = getSignatureById(viewModel.signatureSelected());
										if(sig.name().indexOf('_MAND_1')!=-1)
											alert("La firma è obbligatoria");
										else
										{
											//$(this).dialog("close");
											signsStructure[sig.name()].skip =true;
											playSignature();
											
										/*	if(1==1) { //da 
												
												WebSigningApplet.setPdfBase64Image(codeBaseWithHost+'/signManagement/'+$('#pageImage').attr('src'),realWidthPage);
												
												WebSigningApplet.setSignRectangle(getSignatureById(viewModel.signatureSelected()).left(),
															getSignatureById(viewModel.signatureSelected()).top(),
															getSignatureById(viewModel.signatureSelected()).width(),
															getSignatureById(viewModel.signatureSelected()).height());
													
											}
											if(WebSigningApplet!=null)
												{
												//console.log("called WebSigningApplet.appletStartCapture()()");
												WebSigningApplet.appletStartCapture();
												}*/
											
											$('#lblInfo').text('Please sign on your tablet');
										}
									}
									
								},
								'<spring:message code="label.deletelastsignature" text="Delete Last Signature" />':function() {
									if(playClicked)
									{
										annullaFirma();
									}
									
								}
							},
							close : function() {
								//WebSigningApplet=null;
								//$('#webSigningFD').remove();
								WebSigningApplet.clearPanel();
								WebSigningApplet.stop();
								toTabletExternal();
								if(playClicked)
									nextIndex = nextIndex-1;
// 								WebSigningApplet=null;
								
// 								setTimeout(function(){
// 										$('#tabletManagerPanel').html("");
										
// 									},0);
								//$(this).dialog("close");
							}
						});

		
		
		//$(".dlgfixed").center(false);
	});

	
	
	
	function advancedChanged(a)
	{
		if(a.checked)
			$("#signAdvanced").css("display","block");
		else
			$("#signAdvanced").css("display","none");
	}
	
	function signLocalStep1(indice)
	{
		var base64Cert = getCert(indice);
		var sigName='';
		var sigImageUuid='';
		if(getSignatureById(viewModel.signatureSelected())!=undefined)
		{	sigName=getSignatureById(
					viewModel
					.signatureSelected()).name();
			sigImageUuid=getSignatureById(
					viewModel.signatureSelected()).imageId();
		}
		$.ajax({
			type : "POST",
			url : 'signLocalStep1',
			data : {
				uuid : viewModel.selectedUUID(),
				base64Cert:base64Cert,
				type:$("#signType").val(),
				docType:$("#documentType").val(),
				packaging :$("#packaging").val(),
				config:ko.toJSON(
						viewModel, null, 2),
				sigName:sigName,
				sigImageUuid:sigImageUuid
			},
			beforeSend:function(){
				openLoadingPopup();
			},
			success : function(data) {
				if (!data.errorMessage) {
					closeLoadingPopup();
					//console.log(data);
					var digest= signData(data.signData);
					$.ajax({
						type : "POST",
						url : 'signLocalStep2',
						data : {
							uuid : viewModel.selectedUUID(),
							base64Digest:digest,
							docType:$("#documentType").val(),
							sigName:sigName
						},
						beforeSend:function(){
							openLoadingPopup();
						},
						success : function(data) {
							if (!data.errorMessage) {
								
								uuid = data.uuid;
								$("#dialog-form").dialog("close");
								location.href = location.pathname+"?uuid="
								+ data.uuid+"&type="+$("#documentType").val();
							}
							else
								{
								closeLoadingPopup();
								alert(data.errorMessage);
								
								}
						},
						dataType : 'json'
					});
				}
				else
				{
					closeLoadingPopup();
					alert(data.errorMessage);
					
					}
				
			},
			dataType : 'json'
		});
	}
	
	/*function toggleVisualizzaDocumento(item)
	{
		WebSigningApplet.setEnableDocView(item.checked+'');
	}*/
	
	function signTypeChanged()
	{
		var val = $("#signType").val();
		if(val=="XAdES-T" || val =="CAdES-T")
			$("#chkConMarcaTemporale").attr("checked",true);
		else
			$("#chkConMarcaTemporale").attr("checked",false);
	}
	
	function popupSign()
	{
		
		var indexTabSelected = $("#tabsTipoFirma").tabs('option', 'selected');
		if(indexTabSelected==1)
		{
			
			var login=plugin().isCardLoggedIn(getSlot());
			if(!login)
				login = loginSmartCard();
			
			if(!login)
				return;
			
			var indice = getSignCert(getSlot());
			if(indice)
			{
				fillSignCerts();
				$('#signCertSelector option').eq(indice).prop('selected', true);
			}
			if(!indice && !selectCertFromList)
			{
				fillSignCerts();
				alert('<spring:message code="error.selezionaCertificato" text="Seleziona certificato!" />');
				$("#listaCertificatiSC").css("display","block");
				selectCertFromList=true;
				return;
			}
			signLocalStep1(indice);
			return;
			
			
		}
		var docSelected = $("#documentType").val();
		
		if(docSelected==0)
		{
			signDocument(docSelected,getSignatureById(
					viewModel
					.signatureSelected())
			.name(),ko.toJSON(
					viewModel, null, 2),
					'',$("#dialog-form")
					.find(
					"input[name='otp']")
			.val(),
			$("#dialog-form")
			.find(
					"input[name='pin']")
			.val(),
			base64Image,			
			xmlBioSignature,
			$("#signType").val());
		}
		else if(docSelected==1)//xml
		{
			var sigName = $("#xmlSigName").val();
			signDocument(docSelected,'','',
					'',$("#dialog-form")
					.find(
					"input[name='otp']")
			.val(),
			$("#dialog-form")
			.find(
					"input[name='pin']")
			.val(),

			base64Image,			
			xmlBioSignature,
			$("#signType").val());
		}
		else//binario
		{
			signDocument(docSelected,'signature_1','',
					'',$("#dialog-form")
					.find(
					"input[name='otp']")
			.val(),
			$("#dialog-form")
			.find(
					"input[name='pin']")
			.val(),

			base64Image,			
			xmlBioSignature,
			$("#signType").val());
		}
	};
	
	
	
	
	
</script>
<%--  <canvas id="myCanvas"/> --%>
<spring:message code="title.infoFirma" text="Sign Information" var="sigInfoTitle"/>
<div id="sign-info" title="${sigInfoTitle}">


	<fieldset>

		<table width="100%">
			<tr>
				<td valign="top">
					<dl>
						<dt>
							<span style="font-weight: bold;"><spring:message code="label.campoDiFirma" text="Signature field:"/> </span><span
								data-bind="text: viewModel.signInfoModel.signatureName " />
						</dt>
						<dt>
							<span style="font-weight: bold;"><spring:message code="label.firmatoDa" text="Signed by:"/> </span><span
								data-bind="text: viewModel.signInfoModel.subject " />
						</dt>
						<dt>
							<span style="font-weight: bold;"><spring:message code="label.rilasciatoDa" text="Issued by:"/></span><span
								data-bind="text: viewModel.signInfoModel.issuer " />
						</dt>
						<dt>
							<span style="font-weight: bold;"><spring:message code="label.firmatoInteroDocumento" text="Sign Whole Document:"/> </span><span
								data-bind="text: viewModel.signInfoModel.signatureCoverWholeDocument " />
						</dt>
						<dt>
							<span style="font-weight: bold;"><spring:message code="label.revisione" text="Revision:"/></span><span
								data-bind="text: (viewModel.signInfoModel.documentRevision() +'/'+viewModel.signInfoModel.totalRevision())" />
						</dt>
						<dt>
							<span style="font-weight: bold;"><spring:message code="label.modificatoDopoe" text="Modified after:"/> </span><span
								data-bind="text: viewModel.signInfoModel.revisionModified" />
						</dt>
						<dt>
							<span style="font-weight: bold;"><spring:message code="label.verificaFirma" text="Signature verification:"/> </span><span
								data-bind="text: viewModel.signInfoModel.VerificationAgainsKeyStoreSuccessfully ? 'Valid':'Error'" />
						</dt>

						<dt>
							<ul data-bind="foreach: viewModel.signInfoModel.errors()">
								<li><b data-bind="text: $data"></b></li>
							</ul>
						</dt>


					</dl>
				</td>
			</tr>
		</table>




	</fieldset>




	<!-- 						</form> -->
</div>


<spring:message code="title.firma" text="Sign" var="sigTitle"/>
<div id="dialog-form" title="${sigTitle}">

	
					<div id="tabRemoto">
							<table>
								<tr>
									<td>
					
											<div id="tab-bio">
												<div >
					
					

													<div id="messagePanel">
	<!-- 													<div id="statusImage"></div> -->
														<span id="lblInfo"><spring:message code="label.connettiTablet" text="Connecting to your signature tablet ..." /></span> 
														<span id="lblError"></span>
													</div>
<!-- 													<input type="hidden" name="xmlBioSignature" id="xmlBioSignature" /> -->
<!-- 													<input type="hidden" name="base64image" id="base64image" /> -->
												</div>
											</div>
						
										</td>
									</tr>
									<tfoot>
										<tr>
											<td colspan="2" align="right"><input type="hidden"
											name="hiddenStartupError" id="hiddenStartupError" value="false" />
											<!-- 									<input type="submit" value="Sign"> --></td>
									</tr>
								</tfoot>
							</table>
		
						<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE"
							value="/wEPDwUKLTE3NTYyMzczMQ9kFgICAw9kFgoCAw8PFgIeBFRleHQFCWRzYWRzYWRzYWRkAgUPDxYCHwAFC2RzYWRhdXlpaXV1ZGQCBw8PFgIfAAUkYTk5MTRjMGMtMzlkMC00YWYyLWExMzUtZTY3YmM0MzRhODRlZGQCCQ8PFgIfAAUnQ29ubmVjdGluZyB0byB5b3VyIHNpZ25hdHVyZSB0YWJsZXQgLi4uZGQCDQ8PFgIfAAUNNC4xLjIuMTAgYmV0YWRkZLD0as48WXYwR5mwkr7RMQKtAX9gT9z4poyBmXrZ5q1Q" />
				
						<input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION"
							value="/wEWAgLstPaSCwLMkNCVCnV/l7/foSp4b9XItEPbzLulDLsH1PnNU60SCjpeyvTq" />
				
				
				
<!-- 					</fieldset> -->
				</div>

	<br>
<!-- 			<div id="divConMarcaTemporale"> -->
<!-- 				<input type="checkbox" id="chkVisualizzaDocumento" onchange="javascript:toggleVisualizzaDocumento(this);"><label for="chkVisualizzaDocumento">Visualizza Documento</label> -->
<!-- 			</div> -->
			

</div>

