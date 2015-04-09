<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">

<link rel="icon" type="image/png" href="<c:url value="/Images/favicon.png"/>" />

<style type="text/css">
.no-close .ui-dialog-titlebar-close {
	display: none;
}

body {
	background-color: #FFF !important;
}

.bar {
	height: 18px;
	background: green;
}

.sign {
	/* .ui-selected { background: #F39814; color: white; } */
	position: absolute;
	display: inline-block;
	border: 1px solid black;
	background-size: 100% 100%;
	background-repeat: no-repeat;
	/* Explorer 5.5 -> 7 */
	/* filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7f00ff00, endColorstr=#7f00ff00); */
	/* Explorer 8 */
	/* -ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr=#7f00ff00, endColorstr=#7f00ff00)"; /*- See more at: http://brainleaf.eu/index.php/tutorial-css/35-tutorial-css-background-opacity-una-tecnica-per-non-influenzare-gli-elementi-child#OpacityGenerator */
	*/
}

.signSelected {
	background-image: url('<c:url value="/Images/sigfield_unsigned_selected.png"/>');
}

.sigScritta {
	background-image: url('<c:url value="/Images/sigCertificate.png"/>');
}

.signUnselected {
	background-image: url('<c:url value="/Images/sigfield_unsigned_unselected.png"/>');
}

.signTaskVisible {
	background: url('<c:url value="/Images/visible.png"/>');
}

.signTaskInvisible {
	background: url('<c:url value="/Images/invisible.png"/>');
}

.signVerde {
	background: url('<c:url value="/Images/firma_verde.png"/>');
	background-size: 100% 100%;
}

.signRossa {
	background: url('<c:url value="/Images/firma_rossa.png"/>');
	background-size: 100% 100%;
}

.taskSelected {
	background: #eef0bf;
	/* Explorer 5.5 -> 7 */
	filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#eef0bf,
		endColorstr=#eef0bf);
	/* Explorer 8 */
	/*-ms-filter:
		"progid:DXImageTransform.Microsoft.gradient(startColorstr=#7f00ff00, endColorstr=#7f00ff00)";*/
	/*- See more at: http://brainleaf.eu/index.php/tutorial-css/35-tutorial-css-background-opacity-una-tecnica-per-non-influenzare-gli-elementi-child#OpacityGenerator */
}

.signName {
	position: absolute;
	top: 50%;
	/* adjust top up half the height of a single line */
	margin-top: -0.5em;
	/* force content to always be a single line */
	overflow: hidden;
	white-space: nowrap;
	width: 100%;
	text-overflow: ellipsis;
	color: white;
	font-style: italic;
	font-weight: bold;
	font-size: 14px;
}

#imageContainer {
	/*_height: expression(this.scrollHeight >=  600 ?  "600px" :  "auto");*/
	/* sets max-height for IE6 */
	/*max-height: 600px;*/
	/* sets max-height value for all standards-compliant browsers */
	/*_width: expression(this.scrollWidth >=  700 ?  "700px" :  "auto");*/
	/* sets max-height for IE6 */
	/*max-width: 700px;*/
	/* sets max-height value for all standards-compliant browsers */
	/*overflow: scroll;*/
	
}

#cont {
	border: thin solid black !important;
	margin: 0px !important;
	margin-top: 0px !important;
	width: auto;
}

#uploadingContainer {
	margin: 0px !important;
	padding: 5px;
	height: 80px;
}

#uploadtext {
	font-size: 14px;
	font-weight: bold;
	color: black;
}
</style>

<link rel="stylesheet" type="text/css" href="<c:url value='/Style/style.css'/>" />
<link rel="stylesheet" type="text/css" href="<c:url value='/Style/mystyle.css'/>" />
<link rel="stylesheet" href="<c:url value='/Style/jquery-ui.css'/>" />
<link rel="stylesheet" href="<c:url value="/Script/contextMenu/jquery.contextMenu.css"/>" />
<script>
	window.console = window.console
			|| (function() {
				var c = {};
				c.log = c.warn = c.debug = c.info = c.error = c.time = c.dir = c.profile = c.clear = c.exception = c.trace = c.assert = function(
						s) {
				};
				return c;
			})();
</script>


<script src="<c:url value="/Script/jquery-1.9.1/jquery-1.9.1.min.js"/>"></script>
<%-- <script src="<c:url value="/Applet/js/bio-sign-in.js"/>"></script> --%>
<script src="<c:url value="/Applet/js/class.js"/>"></script>
<script src="<c:url value="/Applet/js/hand-1.3.8.js"/>"></script>
<script src="<c:url value="/Applet/js/SigningInterface.js"/>"></script>
<script src="<c:url value="/Applet/js/AppletInterface.js"/>"></script>
<script src="<c:url value="/Applet/js/TouchInterface.js"/>"></script>
<script src="<c:url value="/Applet/js/deployJava.js"/>"></script>


<script src="<c:url value="/Script/jquery-1.9.1/jquery-ui.js"/>"></script>
<script src="<c:url value="/Script/contextMenu/jquery.contextMenu.js"/>"></script>
<%-- <script src="<c:url value="/Script/jquery.ui.widget.js"/>"></script> --%>
<!-- <script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script> -->
<script src="<c:url value="/Script/jquery.iframe-transport.js"/>"></script>
<script src="<c:url value="/Script/jquery.fileupload.js"/>"></script>
<script src="<c:url value="/Script/knockout-2.3.0.js"/>"></script>
<script
	src="<c:url value="/Script/menu/jquery.easing.compatibility.js"/>"></script>
<script src="<c:url value="/Script/upclick-min.js"/>"></script>
<script src="<c:url value="/Script/json2.js"/>"></script>

<script src="<c:url value="/Script/pdfjs/compatibility.js"/>"></script>

<script src="<c:url value="/Script/pdfjs/pdf.js"/>"></script>

<script>
	var signingInterface;
	var codeBase = "<c:url value='/Applet/applet/'/>";
	var SCALE_FACTOR = (1 / (3 / 4) / 2);

	var xmlBioSignature;
	var base64Image;

	var isFeaXml = false;
	var viewModel;
	var documentUploaded = true;

	var signsStructure = {};
	var playNormalSign = false;
	var playNormalSignIndex = 0;

	var callback;
	var enableAddSignature;
	var enableFlatCopy;
	var onlyShow = false;
	function initViewModel() {
		viewModel = {
			selectedRandom : ko.observable(0),
			connectedTab : ko.observable(""),
			selectedUUID : ko.observable("").extend({
				uuidChange : {}
			}),
			actualPage : ko.observable(0).extend({
				pageChange : -1
			}),
			totalPages : ko.observable(0),
			signatureApplied : ko.observableArray(),
			signatureSelected : ko.observable(-1).extend({
				sigSelectChange : {}
			}),
			signInfoModel : {
				issuer : ko.observable(""),
				signatureName : ko.observable(""),
				revisionModified : ko.observable(false),
				subject : ko.observable(""),
				signatureCoverWholeDocument : ko.observable(false),
				errors : ko.observableArray(),
				documentRevision : ko.observable(0),
				verificationAgainsKeyStoreSuccessfully : ko.observable(false),
				totalRevision : ko.observable(0)
			},
			bindingData : {
				hash : "",
				alg : "",
				offset : 0,
				count : 0
			}

		};

		viewModel.availableNextPage = ko.computed(function() {
			return this.actualPage() < this.totalPages();
		}, viewModel);

		viewModel.removeSignature = function(signature) {
			if (signature.id == viewModel.signatureSelected())
				viewModel.signatureSelected(-1);
			viewModel.signatureApplied.remove(signature);

		};

		viewModel.availablePrevPage = ko.computed(function() {
			return this.actualPage() > 1;
		}, viewModel);

		viewModel.pageUrl = ko.computed(function() {
			var random = this.selectedRandom();
			var uid = this.selectedUUID();
			var page = this.actualPage();
			return "getImage?uuid=" + this.selectedUUID() + "&page="
					+ this.actualPage() + "&random=" + random;

		}, viewModel);

		viewModel.getNextSignature = function(index) {
			if (playNormalSign) {
				return getSignatureSequence()[0];
			} else {
				var min = Number.MAX_VALUE;
				if (index < 0) {
					//cerco il minimo
					for ( var i = 0; i < getSignatureSequence().length; i++) {
						var name = getSignatureSequence()[i].name();
						name = name.substring(4);
						name = name.substring(0, name.indexOf('_'));
						var seqn = parseInt(name);
						if (seqn < min)
							min = seqn;

					}
					nextIndex = min;
					return getSignatureByName2("SEQ_" + min);
				}
				var current = Number.MAX_VALUE;
				var signatures = getSignatureSequence();

				for ( var i = 0; i < signatures.length; i++) {
					var seqn = parseInt(signatures[i].name().substring(4));
					if (seqn > index && seqn < current) {
						current = seqn;
						nextIndex = seqn;
					}
				}
				if (current != Number.MAX_VALUE)
					return getSignatureByName2("SEQ_" + current);
				return null;
			}

		};
	}
	var realWidthPage = 0;
	function getNumberOfPages() {
		//console.log("getNumberOfPages");
		$.ajax({
			type : "POST",
			url : 'getPdfInfo',
			data : {
				uuid : viewModel.selectedUUID()
			},
			success : function(data) {
// 				if (documentUploaded)
// 					viewModel.actualPage(1);

			if(isIE())
				{
				viewModel.totalPages(data.pagesN);
				}
				$.each(data.signatures, function(index, value) {
					$("#signSeqDisabled").css("display", "none");
					$("#signSeq").css("display", "inline");
					var newSig = new signatureModel();
					newSig.name(value.name);
					newSig.top(value.top);
					newSig.left(value.left);
					newSig.height(value.height);
					newSig.width(value.width);
					newSig.page = parseInt(value.page);
					newSig.pageHeight = value.pageHeight;
					newSig.pageWidth = value.pageWidth;
					newSig.isEditable = false;
// 					if (!value.fromText)
// 						newSig.isNew = false;
// 					if (value.fromText)
						newSig.isNew = value.isNew;
					//if (value.fromText!=undefined)
					newSig.isFea(true);
					newSig.signed = value.signed;
					if (documentUploaded) {
						var signData = {};
						signData["name"] = value.name;
						signData["width"] = value.width;
						signData["height"] = value.height;
						signData["displayName"] = value.displayName;
						signData["mandatory"] = value.mandatory;
						signData["description"] = value.description;
						signData["dsig"] = value.dsig;
						//signData["mandatory"] = value.mandatory;
						signsStructure[value.name] = signData;
					}
					viewModel.signatureApplied.push(newSig);

				});
				if (documentUploaded) {
					if (getSignatureSequence().length == 0) {
						playNormalSign = true;
						playNormalSignIndex = 0;
					}
				}
				documentUploaded = false;
				sort();

				$.ajax({
					type : "POST",
					url : 'getBindingInfo',
					data : {
						uuid : viewModel.selectedUUID()
					},
					success : function(data) {

						viewModel.bindingData.hash = data.hash;
						viewModel.bindingData.alg = data.alg;
						viewModel.bindingData.offset = data.offset;
						viewModel.bindingData.count = data.count;

						if ((playNormalSign && playClicked) || playClicked)
							playSignature();

						$("#endDoc").prop('disabled', false);

						// 						if(allSignMandatorySigned())
						// 						{

						// 							$("#endDoc").prop('disabled', false);

						// 						}
						// 						else
						// 						{
						// 							$("#endDoc").prop('disabled', true);
						// 						}
					},
					error : function(xhr) {
						console.log(xhr.responseText);
					},
					dataType : 'json'
				});

			},
			dataType : 'json'
		});
	}

	function download() {
		if (typePassed == 0) {
			$.ajax({
				dataType : 'json',
				type : "POST",
				url : 'prepareDownload',
				data : {
					uuid : uuid,
					config : ko.toJSON(viewModel, null, 2)
				},
				success : function(data) {

					if (!data.errorMessage) {
						window.open("download?uuid=" + data.uuid, "_self");
					} else
						alert('KO ' + data.errorMessage);
				}

			});
		} else if (typePassed == 2 || typePassed == 1)
			window.open("download?uuid=" + uuid);
	}

	function abilitaCtx(toEnable) {
		$("#imageContainer").contextMenu(toEnable);
		if (toEnable) {
			$("#disableCtx").show();
			$("#enableCtx").hide();
		} else {
			$("#disableCtx").hide();
			$("#enableCtx").show();
		}
	}

	function addSignature() {
		if (enableAddSignature == 'false') {
			alert("Aggiungi firma non abilitato");
			return;
		}
		playClicked = false;
		var newSig = new signatureModel();
		newSig.isFea(true);
		newSig.appearance("2");
		//sigAppearanceChanged("2");
		viewModel.signatureApplied.push(newSig);
		viewModel.signatureSelected(newSig.id);
		sort();

		var signData = {};
		signData["name"] = newSig.name();
		signData["width"] = newSig.width();
		signData["height"] = newSig.height();
		signData["mandatory"] = false;
		signsStructure[newSig.name()] = signData;

		return newSig;
	}

	function getSignatureByName(sigName) {
		var sigWithName = getSignatureById(viewModel.signatureSelected());
		if (sigWithName == null)
			return null;
		var sigs = $.grep(viewModel.signatureApplied(), function(n, i) { // just use arr
			return n.name() == sigWithName.name();
		});
		if (sigs == null || sigs.length == 0)
			return null;
		return sigs[0];
	}

	function getSignatureByName2(sigName) {

		var sigs = $.grep(viewModel.signatureApplied(), function(n, i) { // just use arr
			return n.name().indexOf(sigName) != -1;
		});
		if (sigs == null || sigs.length == 0)
			return null;
		return sigs[0];
	}

	function getSignatureById(sigId) {
		var sigs = $.grep(viewModel.signatureApplied(), function(n, i) { // just use arr
			return n.id == sigId;
		});
		if (sigs == null || sigs.length == 0)
			return null;
		return sigs[0];
	}

	ko.extenders.pageChange = function(target, option) {

		target.subscribe(function(newValue) {
			viewModel.signatureSelected(option);
			loadImage(newValue);

		});

		// 		document.

		return target;
	};

	function loadImage(page) {
		try{
		if(!isIE()){
			var imgB64 = pages[page - 1].hasNewSignature ? signingInterface
					.getPageB64(page, 1) : pages[page - 1].imgB64;
			if (!imgB64) throw "Image not found, requesting trough ajax";
			pages[page - 1].imgB64 = imgB64;
			pages[page - 1].hasNewSignature = false;
			realWidthPage = pages[page - 1].pointWidth * 2;
			$("#imageContainer").css("width", (realWidthPage * SCALE_FACTOR));
			$('#pageImage').attr('src', 'data:image/png;base64,' + imgB64)
					.attr('height',
							pages[page - 1].pointHeight * SCALE_FACTOR * 2)
					.attr("width",
							pages[page - 1].pointWidth * SCALE_FACTOR * 2);
			console.log("image set on page: " + page);
		}
		else
		{
			if(pages[page-1]!=undefined )
			{
				var imgB64 = pages[page - 1].hasNewSignature ? signingInterface
						.getPageB64(page, 1) : pages[page - 1].imgB64;

				if (!imgB64) throw "Image not found, requesting trough ajax"
				pages[page - 1].imgB64 = imgB64;
				pages[page - 1].hasNewSignature = false;
				$('#pageImage').attr('src', 'data:image/png;base64,' + imgB64);
				$('#pageImage').attr('height','100%').attr("width",'100%');
			}
			else
			{
				$.ajax({
					dataType : 'json',
					type : "GET",
					url : 'getImage',
					data : {
						uuid : uuid,
						page:page,
						random:Math.random()
					},
					success : function(data) {

						pages[page - 1] =
							{
								imgB64 : data.imageb64,
								hasNewSignature : false,
								totalPages:viewModel.totalPages(),
								pointWidth:data.width,
								pointHeight:data.height,
								
							};
						
						$('#pageImage').attr('src', 'data:image/png;base64,' + data.imageb64);
						$('#pageImage').attr('height','100%').attr("width",'100%');
						
						
					},
					error : function(data) {

						console.log(data);
					}

				});
			}
			
		}
		}catch (r){
			console.log(r);
			$.ajax({
				dataType : 'json',
				type : "GET",
				url : 'getImage',
				data : {
					uuid : uuid,
					page:page,
					random:Math.random()
				},
				success : function(data) {

					pages[page - 1] =
						{
							imgB64 : data.imageb64,
							hasNewSignature : false,
							totalPages:viewModel.totalPages(),
							pointWidth:data.width,
							pointHeight:data.height,
							
						};
					
					$('#pageImage').attr('src', 'data:image/png;base64,' + data.imageb64);
					$('#pageImage').attr('height','100%').attr("width",'100%');
					
					
				},
				error : function(data) {

					console.log(data);
				}

			});
			
		}
	}

	
	ko.extenders.uuidChange = function(target, option) {
		target.subscribe(function(newValue) {
			//$('#uploadingContainer').hide("drop");
			$('#newContainer').show("fade");
			var docType = '';

			// 			$.ajax({
			// 				type : "GET",
			// 				url : 'getFileAsB64',
			// 				async: false,
			// 				data : {
			// 					uuid : newValue
			// 				},
			// 				success : function(data) {
			//openLoadingPopup();

			if(!isIE())
			{
				startPdfRendering(newValue, function() {
					viewModel.actualPage(1);
					if (typePassed)
						docType = typePassed;
					else
						docType = $("#documentType").val();
					if (docType == '0')
						getNumberOfPages();
	
				});
			}
			else
			{
				viewModel.actualPage(1);
				if (typePassed)
					docType = typePassed;
				else
					docType = $("#documentType").val();
				if (docType == '0')
					getNumberOfPages();
			}

		});
		return target;
	};

	ko.extenders.sigSelectChange = function(target, option) {
		target.subscribe(function(newValue) {
			// 	    	if (newValue==-1) return true;
			var selector = '#sign' + newValue;
			var selectedDiv = $(selector)[0];
			if (selectedDiv) {
				var sig = ko.dataFor(selectedDiv);
				if (sig.isVisible()) {
					//$('body').scrollTo(selector); 
				}
			}
		});
		return target;
	};

	function sort() {
		viewModel.signatureApplied.sort(function(left, right) {
			if (!left.isVisible())
				return -1;
			if (!right.isVisible())
				return 1;
			return left.page == right.page ? (left.top() == right.top() ? 0
					: (left.top() < right.top() ? -1 : 1))
					: (left.page < right.page ? -1 : 1);
		});
	}

	// 	ko.extenders.sortSignatures= function(target, option) {
	// 	    target.subscribe(function(newValue) {
	// // 	    	if (newValue==-1) return true;
	// 			sort();
	// 	    });
	// 	    return target;
	// 	};

	initViewModel();

	var sigCounterName = 0;
	function signatureModel() {
		sigCounterName++;
		this.id = sigCounterName;
		this.isNew = true;
		this.isEditable = true;
		this.page = viewModel.actualPage();
		this.left = ko.observable(0);
		this.signed = false;
		this.top = ko.observable(0);
		this.width = ko.observable(150);
		this.height = ko.observable(50);
		this.pageWidth = $('#pageImage').width();
		this.pageHeight = $('#pageImage').height();
		this.name = ko.observable("Signature_" + this.id);
		this.imageUrl = ko.observable("");
		this.imageId = ko.observable("");
		this.imageUrlStandard = ko.observable("../Images/sigMarioRossi.png");
		this.appearance = ko.observable("0");
		this._isVisible = ko.observable(true);
		this.isFea = ko.observable(false);
		this.skip = ko.observable(false);
		this.isVisible = ko.computed(function() {

			return this._isVisible() && (this.width() + this.height() > 0);
		}, this);
		this.toggleVisibility = function() {
			if (this.isEditable)
				this._isVisible(!this._isVisible());

		};
		this.toggleFea = function() {
			if (!this.signed) {
				this.isFea(!this.isFea());
				if (this.isFea()) {
					this.appearance("2");
					sigAppearanceChanged("2");
				} else {
					this.appearance("0");
					sigAppearanceChanged("0");
				}
			}
		}
		this.select = function() {
			if (this.isVisible())
				viewModel.actualPage(this.page);
			viewModel.signatureSelected(this.id);
			return true;
		};
		this.isMandatory = function() {
			var signData = signsStructure[this.name()];
			if (signData && signData.mandatory)
				return true;
			else
				return false;
		};
		this.displayName = function() {
			var signData = signsStructure[this.name()];
			if (signData && signData.displayName)
				return signData.displayName;
			else
				return this.name();
		};
		this.signOrShow = function(play) {
			showText('<spring:message code="label.opensignature" text="Open Signature..." />', false);
			var that = this;
			setTimeout(
					function() {
						if (play == true)
							playClicked = true;
						else
							playClicked = false;

						if (that.signed) {
							$
									.ajax({
										dataType : 'json',
										type : "GET",
										url : 'getSigInfo',
										data : {
											uuid : viewModel.selectedUUID(),
											sigName : getSignatureById(
													viewModel
															.signatureSelected())
													.name()
										},
										success : function(data) {

											if (!data.errorMessage) {
												viewModel.signInfoModel
														.subject(data.success.subject);
												viewModel.signInfoModel
														.issuer(data.success.issuer);
												viewModel.signInfoModel
														.signatureName(data.success.signatureName);
												viewModel.signInfoModel
														.revisionModified(data.success.revisionModified);
												viewModel.signInfoModel
														.signatureCoverWholeDocument(data.success.signatureCoverWholeDocument);
												viewModel.signInfoModel
														.errors(data.success.verificationAgainsKeyStoreErrors);
												viewModel.signInfoModel
														.documentRevision(data.success.documentRevision);
												viewModel.signInfoModel
														.verificationAgainsKeyStoreSuccessfully(data.success.verificationAgainsKeyStoreSuccessfully);
												viewModel.signInfoModel
														.totalRevision(data.success.totalRevision);
												$("#sign-info").dialog("open");

												toTabRemoto();
											} else
												alert('KO ' + data.errorMessage);
										}

									});
							// 				alert('Signature already signed, singing info coming shortly...');
						} else {
							if (that.isFea()) {
								//$("#dialog-formFEA").dialog("open");
								$("#tdFD").css("display", "none");
								$("#dialog-form").dialog("open");

								toTabRemoto();
								//initializeApplet();

								/*
									## RESTART DELL'APPLET
								 */
								if (viewModel.bindingData.hash != '')
									signingInterface.setBindingData(
											viewModel.bindingData.hash,
											viewModel.bindingData.alg,
											viewModel.bindingData.offset,
											viewModel.bindingData.count);

								if (signsStructure[getSignatureById(
										viewModel.signatureSelected()).name()].dsig)
									signingInterface
											.setSigTag(signsStructure[getSignatureById(
													viewModel
															.signatureSelected())
													.name()].dsig);

								signingInterface.setSignRectangle(
										getSignatureById(
												viewModel.signatureSelected())
												.left(), getSignatureById(
												viewModel.signatureSelected())
												.top(), getSignatureById(
												viewModel.signatureSelected())
												.width(), getSignatureById(
												viewModel.signatureSelected())
												.height());

								signingInterface.setPdfBase64Image('', 0,
										viewModel.actualPage(), viewModel
												.totalPages());

								if (signingInterface != null) {
									// 						console.log("WebSigningApplet.appletStartCapture(); in remoteSign");
									signingInterface.startCapture(false);
									$('#lblInfo').text(
											'Please sign on your tablet');
								}

								/*
									## FINE RESTART DELL'APPLET
								 */

								$("#tabs").tabs("disable", 0);
								$("#tabs").tabs("select", 1);
								$("#tabsTipoFirma").tabs("disable", 1);
							} else {
								$("#tdFD").css("display", "block");
								$("#tabs").tabs("enable", 0);
								$("#tabs").tabs("select", 0);
								$("#tabsTipoFirma").tabs("enable", 1);
								if (that.appearance() == "1") {
									if (that.imageId() == '')//controllo se è stato fatto l'upload di un immagine
									{
										alert("Please upload a signature image!");
										return;
									}

								}
								$("#dialog-form").dialog("open");
								//load();
								$("#tabs").tabs("enable", 0);
								$("#tabs").tabs("select", 0);

								if (that.appearance() == "2")//biometrica
								{
									$("#tabs").tabs("disable", 0);
									$("#tabs").tabs("select", 1);
								}
							}
						}

						showText("", true)
					}, 100);
		}
	}

	function toTabletExternal() {

		$('#tabletExternal,#tabRemoto').empty();
		var el = $('#tabletManagerPanel'), div = $('#tabletExternal'), clone_div = $('<div>');
		var width = 1, height = 1;
		clone_div.css({
			width : width,
			height : height
		});
		div.append(clone_div);

		signingInterface.hidePanel();
		// 	        el.css({
		// 	            position:'absolute'});
		el.css({
			left : clone_div.offset().left,
			top : clone_div.offset().top
		});
		$('#webSigningFD').height('1px');
		$('#webSigningFD').width('1px');
	}

	function toTabRemoto() {
		$('#webSigningFD').height('480px');
		$('#webSigningFD').width('800px');
		signingInterface.showPanel(800,480);
		//$('#someId').height('480px');
		//$('#someId').width('800px');
		$('#tabletExternal,#tabRemoto').empty();
		var el = $('#tabletManagerPanel'), div = $('#tabRemoto'), clone_div = $('<div>');
		var width = 800, height = 480;
		clone_div.css({
			width : width,
			height : height
		});
		div.append(clone_div);
		el.css({
			position : 'absolute'
		});
		el.css({
			left : clone_div.offset().left,
			top : clone_div.offset().top
		});
		el.css("z-index", 99999);
	}

	//EVENTI TOUCH
	function onDivPointerDown(e) {
	      //  Assign the current pointer to the gesture object
		    testbox.innerHTML = ""+e.pressure+"\r\nDown";
	      this.gestureObject.addPointer(e.pointerId);
	    }
	    
	    
	    function onDivPointerMove(e) {
	      //  Assign the current pointer to the gesture object
		    testbox.innerHTML = ""+e.pressure+"\r\nMove";
	    }
	    
	    function onDivGestureChange(e) {
	      // Update the transform on this element
	      var currentXform = new MSCSSMatrix(e.target.style.msTransform);
	      e.target.style.msTransform = currentXform.translate(e.offsetX, e.offsetY).
	      translate(e.translationX, e.translationY).
	      translate(-e.offsetX, -e.offsetY);
	    }

	    function onDivGestureTap(e) {
	      //  On tap (or click), change colors
	      if (e.target.style.backgroundColor == "red") {
	        e.target.style.backgroundColor = "green";
	        }else{
	        e.target.style.backgroundColor = "red";
	      }
	    }
	    
	    //FINE EVENTI TOUCH
	
	var appletEventBinding = false;
	function startApplet() {
		setTimeout(function() {
			console.log("called startApplet()");
			showText('<spring:message code="label.startapplet" text="Start Applet..." />', false)
			selectedName = "FD";
			if (!signingInterface) {

				signingInterface = DetectSigningInterface('webSigningFD',
						$('#tabletManagerPanel'), codeBase);

				if (!appletEventBinding) {
					console.log("Effettuo binding eventi applet");
					$('#tabletManagerPanel').on('deviceError', function(error) {
						$('#lblError').text(error);
					});

					$('#tabletManagerPanel').on('cancelSign', function() {

						$("#dialog-form").dialog("close");

						//WebSigningApplet.clearPanel();
					});

					$("#fileupload").prop('disabled', true);
					$('#tabletManagerPanel').on(
							'initCompleted',
							function() {
								viewModel.connectedTab(signingInterface
										.getDeviceInfo());
								signingInterface.setEnablePdfJS();
								//WebSigningApplet.clearPanel();
							});

					$('#tabletManagerPanel').on('signAcquired',
							function(event, bio, image) {
								$('#lblInfo').text('signAcquired');
								xmlBioSignature = bio;

								base64Image = image;
								// 							$('#xmlBioSignature')
								// 									.val(bio);
								// 							$('#base64image').val(
								// 									image);
								//console.log('signAcquired, setting bio done');

								popupSign();
							});
					$('#tabletManagerPanel').on('noDevice', function(event) {
						alert("Nessun device connesso!");
						try {
							$("#dialog-form").dialog("close");
						} catch (e) {
							// TODO: handle exception
						}
						//setTimeout(function(){
						// 								$("#dialog-form").dialog("close");
						//WebSigningApplet=null;
						//},0);
					});

					appletEventBinding = true;
				}
// 				if (window.PointerEvent){
// 					showText("Detected touch device", false);
// 					var testbox = document.getElementById("tabletManagerPanel");
// 					  testbox.addEventListener("pointerdown", onDivPointerDown, true);
// 			          testbox.addEventListener("pointermove", onDivPointerMove, true);

// 			          //  Instantiate a new gesture object and assign it to the div we're going to move
// 			          testbox.gestureObject = new MSGesture();
// 			          testbox.gestureObject.target = testbox;

// 			          //  Set up handlers for gesture events
// 			          testbox.addEventListener("MSGestureChange", onDivGestureChange, false);
// 			          testbox.addEventListener("MSGestureTap", onDivGestureTap, false);
// 				}
// 				else {
					signingInterface.createSigningInterface(function(status) {
						if (status == 2) {
							$("#fileupload").prop('disabled', false);
							showText("", true);
						}
						if (status == 3) {
							showText("Error start applet", false);
						}
					});
// 				}
			}
		}, 0);
	}

	$(function() {

		//startApplet();

		$.fn.scrollTo = function(target, options, callback) {
			if (typeof options == 'function' && arguments.length == 2) {
				callback = options;
				options = target;
			}
			var settings = $.extend({
				scrollTarget : target,
				offsetTop : 150,
				offsetLeft : 150,
				duration : 500,
				easing : 'swing'
			}, options);
			return this
					.each(function() {
						var scrollPane = $(this);
						var scrollTarget = (typeof settings.scrollTarget == "number") ? settings.scrollTarget
								: $(settings.scrollTarget);
						// 						console.log("scrollTarget.position().left: "
						// 								+ scrollTarget.position().left);
						// 						console.log("scrollPane.scrollLeft():      "
						// 								+ scrollPane.scrollLeft());
						var scrollY = (typeof scrollTarget == "number") ? scrollTarget
								: scrollTarget.position().top
										- parseInt(settings.offsetTop);
						var scrollX = (typeof scrollTarget == "number") ? scrollTarget
								: scrollTarget.position().left
										- parseInt(settings.offsetLeft);

						// 						console
						// 								.log("scrollX                       :"
						// 										+ scrollX);
						scrollPane.animate({
							scrollTop : scrollY,
							scrollLeft : scrollX
						}, parseInt(settings.duration), settings.easing,
								function() {
									if (typeof callback == 'function') {
										callback.call(this);
									}
								});
					});
		};
		ko.bindingHandlers.customPos = {
			init : function(element, valueAccessor) {
				var signature = valueAccessor();
				if (signature.isEditable) {
					$(element)
							.draggable(
									{
										containment : "parent",
										start : function(event, ui) {
											viewModel.signatureSelected(ko
													.dataFor(ui.helper[0]).id);
										},
										stop : function(event, ui) { //use stop in prod

											signature.left(Math
													.floor(ui.position.left));
											signature.top(Math
													.floor(ui.position.top));
											sort();

										}
									});

					$(element)
							.resizable(
									{
										minHeight : 20,
										minWidth : 100,
										start : function(event, ui) {
											viewModel.signatureSelected(ko
													.dataFor(ui.helper[0]).id);
										},
										resize : function(event, ui) { //use stop in prod
											if ((ui.position.left + ui.size.width) > $(
													'#pageImage').width()) {
												ui.size.width = $('#pageImage')
														.width()
														- ui.position.left;
											}
											if ((ui.position.top + ui.size.height) > $(
													'#pageImage').height()) {
												ui.size.height = $('#pageImage')
														.height()
														- ui.position.top;
											}

											if (ui.size.width > 390)
												ui.size.width = 390;
											if (ui.size.height > 190)
												ui.size.height = 190;
											signature.height(Math
													.floor(ui.size.height));
											signature.width(Math
													.floor(ui.size.width));

										}
									});
				}
				$(element).css({
					position : 'absolute'
				});
			},
			update : function(element, valueAccessor) {
				var signature = valueAccessor();
				$(element).css("left", signature.left() + "px");
				$(element).css("top", signature.top() + "px");
				$(element).css("width", signature.width() + "px");
				$(element).css("height", signature.height() + "px");
			}
		};

		ko.applyBindings(viewModel, document.getElementById('container'));
		$('#newContainer').hide();
		/*$('#fileupload').fileupload({
			//forceIframeTransport : true,
			//dataType: 'json',
			add: function (e, data) {
		        data.submit(); //this will 'force' the submit in IE < 10
		    },
			
			done : function(e, data) {
				closeLoadingPopup();
				$("#wizard").tabs("disable",0);
				if (!data.result.errorMessage) {
					var docSelected = $("#documentType").val();
					loadSignType(docSelected);
					
						$("#divConMarcaTemporale").css("display","block");
					if(docSelected==0)//PDF
					{
						
						 $("#divConMarcaTemporale").css("display","none");
						 $("#wizard").tabs("enable",1);
						 $("#wizard").tabs("select",1);
					}
					
					viewModel.selectedUUID(data.result.uuid);
					uuid=data.result.uuid;
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
			always: function(e, data) {
				  var result;
				  if (data.textStatus == 'parsererror') {  // IE9 fails on upload's JSON response
				    result = JSON.parse(data.jqXHR.responseText);
				  } else if (data.textStatus == 'success') {
				    result = data.result;
				  }

				  if (result) {
				    // ...perform custom handling...
				  }
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
		 */

		var uploader = document.getElementById('fileupload');

		upclick({
			dataname : 'file',
			element : uploader,
			action : 'upload',
			onstart : function(filename) {
				//documentUploaded = false;
				//openLoadingPopup();
				//alert('Start upload: '+filename);
			},
			oncomplete : function(response_data) {
				documentUploaded = true;
				closeLoadingPopup();
				var data = '';
				try {
					data = $.parseJSON($($(response_data)[0]).html());
				} catch (a) {
					data = $.parseJSON(response_data);
				}

				//$("#wizard").tabs("disable",0);
				if (data) {
					var docSelected = $("#documentType").val();
					loadSignType(docSelected);

					$("#divConMarcaTemporale").css("display", "block");
					if (docSelected == 0)//PDF
					{

						$("#divConMarcaTemporale").css("display", "none");
						//$("#wizard").tabs("enable",1);
						// $("#wizard").tabs("select",1);
					}

					viewModel.selectedUUID(data.uuid);
					uuid = data.uuid;
					$("#docuuid").val(uuid);
					$("#tab1").css("display", "none");
					$("#tab4").css("display", "block");
				} else
					alert('KO ' + data.errorMessage);
			}
		});

		$("input[type=file]").each(function(e, t) {
			//console.log(this);
			$(this).attr("accept", "application/pdf");
			//console.log( $(this).attr("accept"));  
		}

		);
		/*	 $('#fileupload')
		       .bind('fileuploadstop', function (e, data) {
		          alert("ciao");
		       });*/

		typePassed = "${type}";
		uuidPassed = "${uuid}";
		uuid=uuidPassed;
		xmlPassed = '<c:out value="${xmlDoc}" escapeXml="false"/>';
		nextIndex = "${nextIndex}";
		callbackURL = "${callbackURL}";
		enableAddSignature = "${enableAddSignature}";
		enableFlatCopy = "${enableFlatCopy}";
		if (uuidPassed) {
			viewModel.selectedUUID(uuidPassed);

		}
		if (enableAddSignature != 'false') {
			$("#addSigDisabled").css("display", "none");
			$("#addSig").css("display", "inline");
		} else {
			$("#addSigDisabled").css("display", "inline");
			$("#addSig").css("display", "none");
		}
		if (callbackURL) {
			$("#saveDocDisabled").css("display", "inline");
			$("#saveDoc").css("display", "none");
		}

	});

	

	var uuidPassed;
	var typePassed;
	var xmlPassed;
	var nextIndex = "-2";
	var oldIndex = "-2";
	var playClicked = false;
	//DL!!!
	function checkFormat() {

	};

	function loadCertificates(selectorCL, selectorUN) {
		if (selectorCL == undefined)
			selectorCL = "#certificateList";
		if (selectorUN == undefined)
			selectorUN = "#username";
		var username = $(selectorUN).val();
		if (username == '') {
			alert("Specificare un nome utente!");
			return;
		}
		$.ajax({
			dataType : 'json',
			type : "GET",
			url : 'getCertificates',
			data : {
				username : username
			},
			beforeSend : function(xhr) {
				openLoadingPopup();
			},
			success : function(data) {
				closeLoadingPopup();
				if (!data.errorMessage) {
					certs = data.certificates;
					var index = 0;
					$(selectorCL).html("");
					for ( var i in data.certificates) {
						var obj = data.certificates[i];
						var val;
						val = obj["dn"] + " - " + obj["createdOn"];
						$(selectorCL).append(
								"<option value=\"" + index + "\">" + val
										+ "</option>");
						index++;
					}
				} else
					alert(data.errorMessage);
			},
			error : function(xhr) {
				closeLoadingPopup();
			}
		});
	}

	function loadSignType(documentType, selectorSignType, selectorPackaging) {
		if (selectorSignType == undefined)
			selectorSignType = "#signType";
		if (selectorPackaging == undefined)
			selectorPackaging = "#packaging";

		$(selectorSignType).html("");
		$("#packaging").html("");

		if (documentType == 0)//PDF
		{
			$(selectorSignType).append(
					"<option value=\"PAdES-BES\">PAdES-BES</option>");
			$(selectorSignType).append(
					"<option value=\"PAdES-EPES\">PAdES-EPES</option>");
			$(selectorSignType).append(
					"<option value=\"PAdES-LTV\">PAdES-LTV</option>");
			$("#packaging").append(
					"<option value=\"DETACHED\">DETACHED</option>");

		} else if (documentType == 1)//XML
		{
			$(selectorSignType).append(
					"<option value=\"XAdES-BES\">XAdES-BES</option>");
			$(selectorSignType).append(
					"<option value=\"XAdES-EPES\">XAdES-EPES</option>");
			$(selectorSignType).append(
					"<option value=\"XAdES-T\">XAdES-T</option>");
			$(selectorSignType).append(
					"<option value=\"XAdES-C\">XAdES-C</option>");
			$(selectorSignType).append(
					"<option value=\"XAdES-X\">XAdES-X</option>");
			$(selectorSignType).append(
					"<option value=\"XAdES-XL\">XAdES-XL</option>");
			$(selectorSignType).append(
					"<option value=\"XAdES-A\">XAdES-A</option>");

			$(selectorPackaging).append(
					"<option value=\"ENVELOPING\">ENVELOPING</option>");
			$(selectorPackaging).append(
					"<option value=\"ENVELOPED\">ENVELOPED</option>");
			$(selectorPackaging).append(
					"<option value=\"DETACHED\">DETACHED</option>");

		} else//BINARIO
		{
			$(selectorSignType).append(
					"<option value=\"CAdES-BES\">CAdES-BES</option>");
			$(selectorSignType).append(
					"<option value=\"CAdES-EPES\">CAdES-EPES</option>");
			$(selectorSignType).append(
					"<option value=\"CAdES-T\">CAdES-T</option>");
			$(selectorSignType).append(
					"<option value=\"CAdES-C\">CAdES-C</option>");
			$(selectorSignType).append(
					"<option value=\"CAdES-X\">CAdES-X</option>");
			$(selectorSignType).append(
					"<option value=\"CAdES-XL\">CAdES-XL</option>");
			$(selectorSignType).append(
					"<option value=\"CAdES-A\">CAdES-A</option>");

			$(selectorPackaging).append(
					"<option value=\"ENVELOPING\">ENVELOPING</option>");
			$(selectorPackaging).append(
					"<option value=\"DETACHED\">DETACHED</option>");
		}
	}

	var count = 0;
	function signDocument(docType, sigName, config, username, otp, pin,
			_base64image, _xmlBioSignature, type) {
		var sig = getSignatureById(viewModel.signatureSelected());
		pages[sig.page - 1].hasNewSignature = true;
		pagesWithSignature.push(sig.page - 1);
		if ((sig != null && sig.isFea()) || isFeaXml) {

			$
					.ajax({
						dataType : 'json',
						type : "POST",
						url : 'signFEA',
						data : {
							uuid : uuid,
							sigName : sigName,
							config : config,
							base64image : _base64image,
							xmlBioSignature : _xmlBioSignature,
							docType : docType,
							type : type,
							packaging : $("#packaging").val()

						},
						beforeSend : function() {
							//$("#dialog-form").dialog("close");
							var upm = document.getElementById("webSigningFD");
							//upm.style.visibility='hidden';
							//upm.style.width='400px';							
							showText("Firma in corso...", false)
							//openLoadingPopup();
						},
						success : function(data) {

							base64Image = null;
							xmlBioSignature = null;

							if (!data.errorMessage) {
								loadImage(viewModel.actualPage());
								/*location = window.location.origin
										+ window.location.pathname
										+ "?uuid="
										+ data.uuid;*/
								var newLocation = location.pathname + "?uuid="
										+ data.uuid + "&type=" + docType;

								if (playClicked) {

									if (data.uuid) {
										count++;
										uuid = data.uuid;
										//closeLoadingPopup();

										if (getSignatureSequence().length >= 1) {

											if (getSignatureSequence().length == 1)
												$("#dialog-form").dialog(
														"close");
											viewModel.signatureApplied
													.removeAll();

											viewModel.selectedUUID(data.uuid);
											var d = new Date();
											viewModel.selectedRandom(d
													.getTime());
											$('#newContainer').show("fade");
											var docType = '';
											if (typePassed)
												docType = typePassed;
											else
												docType = $("#documentType")
														.val();
											if (docType == '0')
												getNumberOfPages();
										}

									}
								} else {

									uuid = data.uuid;
									//closeLoadingPopup();
									$("#dialog-form").dialog("close");
									viewModel.signatureApplied.removeAll();

									viewModel.selectedUUID(data.uuid);
									var d = new Date();
									viewModel.selectedRandom(d.getTime());

									$('#newContainer').show("fade");
									var docType = '';
									if (typePassed)
										docType = typePassed;
									else
										docType = $("#documentType").val();
									if (docType == '0')
										getNumberOfPages();
								}

							} else {
								signingInterface.removeLastSignature();
								//closeLoadingPopup();
								alert('KO ' + data.errorMessage);
								$('#lblInfo').text(
										'Please sign again on your tablet');
								console
										.log("signingInterface.startCapture(); in remoteSign,signFEA,error");
								signingInterface.startCapture(false);
							}

							showText("", true)
						},
						error : function(xhr) {
							base64Image = null;
							xmlBioSignature = null;
							signingInterface.removeLastSignature();
							//closeLoadingPopup();							
							showText(xhr.responseText, false)
							//alert(xhr.responseText);

						}
					});
		}

		else {

			if ($("#certificateList").val() == undefined) {
				alert("Seleziona un certificato!");
				return;
			}
			var certificateIndex = parseInt($("#certificateList").val());
			var wsHsmUri = certs[certificateIndex].hsmUri;
			var hsmName = certs[certificateIndex].hsmName;
			var keyAlias = certs[certificateIndex].keyAlias;
			var partitionName = certs[certificateIndex].partitionName;
			var imageUuid = '';
			var sigAppearance = '';
			//if(type==0)
			if ($("#documentType").val() == "0") {
				imageUuid = getSignatureById(viewModel.signatureSelected())
						.imageId();
				sigAppearance = getSignatureById(viewModel.signatureSelected())
						.appearance()[0];
			}

			$
					.ajax({
						dataType : 'json',
						type : "POST",
						url : 'sign2',
						data : {
							uuid : uuid,
							docType : $("#documentType").val(),
							wsHsmUri : wsHsmUri,
							hsmName : hsmName,
							keyAlias : keyAlias,
							partitionName : partitionName,
							sigName : sigName,
							config : config,
							userName : username,
							otp : otp,
							pin : pin,
							base64image : base64image,
							xmlBioSignature : xmlBioSignature,
							type : type,
							packaging : $("#packaging").val(),
							sigImageUuid : imageUuid,
							sigAppearanceType : sigAppearance

						},
						beforeSend : function(xhr) {
							openLoadingPopup();
						},
						success : function(data) {

							if (!data.errorMessage) {
								uuid = data.uuid;
								$("#dialog-form").dialog("close");

								/*location = window.location.origin
										+ window.location.pathname
										+ "?uuid="
										+ data.uuid+"&type="+docType;
										;*/
								location.href = location.pathname + "?uuid="
										+ data.uuid + "&type=" + docType;

								/*if($( "#documentType" ).val()==1)
								{
									var xmlDocString = data.xmlDocument;
									xmlDoc.setValue(xmlDocString);
								}*/

							} else {
								closeLoadingPopup();
								alert('KO ' + data.errorMessage);
								if (!(xmlBioSignature == undefined || xmlBioSignature == ''))
									$('#lblInfo').text(
											'Please sign again on your tablet');
								console
										.log("signingInterface.startCapture(); in remoteSign-signv2");
								signingInterface.startCapture(false);
							}

						},
						error : function(xhr) {
							closeLoadingPopup();
							alert(xhr.responseText);

						}
					});
		}
	}
	$(document).ready(function() {

		startApplet();
		createSmartphoneDialog();
		//$($("#btnSign")[0].parentNode).addClass("current");

		//$("#wizard").tabs();

		//$("#wizard").css("visibility","visible");
		$("#accordion").accordion({
			heightStyle : "content"
		});
		/*	 $( "input[type=button],button" )
		      .button();*/

		disableAllTabs();

		$("#documentType").change(function() {
			disableAllTabs();
			/*var indexSelected = $("#documentType option:selected").val();
			if(indexSelected==0)
				$("#fileupload").attr("accept","application/pdf");
			else if(indexSelected==1)
				$("#fileupload").attr("accept","text/xml");
			else
				$("#fileupload").attr("accept","*.*");*/
		});

		//$("#wizard").tabs("enable",0);
		//$("#wizard").tabs("select",0);
		if (uuidPassed && typePassed == 0) {
			uuid = uuidPassed;
			$("#tab1").css("display", "none");
			$("#tab4").css("display", "block");
			/*$("#wizard").tabs("disable",0);
			$("#wizard").tabs("enable",1);
			$("#wizard").tabs("select",1);*/
		}
		if (uuidPassed && typePassed == 2) {
			uuid = uuidPassed;
			/*$("#wizard").tabs("disable",0);
			$("#wizard").tabs("enable",3);
			$("#wizard").tabs("select",3);*/
		}
		if (uuidPassed && typePassed == 1) {
			uuid = uuidPassed;
			/*$("#wizard").tabs("disable",0);
			$("#wizard").tabs("enable",2);
			$("#wizard").tabs("select",2);*/
			xmlDoc.setValue(formatXml(xmlPassed));
			xmlDoc.clearSelection();
		}
		if (typePassed) {
			loadSignType(parseInt(typePassed));
			$("#documentType").val(typePassed);
		}

	});
	function disableAllTabs() {
		/*$("#wizard").tabs("disable",1);
		$("#wizard").tabs("disable",2);
		$("#wizard").tabs("disable",3);*/

	}
	var certs;
	var uuid;
	var xmlDoc;

	function formatXml(xml) {
		var formatted = '';
		var reg = /(>)(<)(\/*)/g;
		xml = xml.replace(reg, '$1\r\n$2$3');
		var pad = 0;
		jQuery.each(xml.split('\r\n'), function(index, node) {
			var indent = 0;
			if (node.match(/.+<\/\w[^>]*>$/)) {
				indent = 0;
			} else if (node.match(/^<\/\w/)) {
				if (pad != 0) {
					pad -= 1;
				}
			} else if (node.match(/^<\w[^>]*[^\/]>.*$/)) {
				indent = 1;
			} else {
				indent = 0;
			}

			var padding = '';
			for ( var i = 0; i < pad; i++) {
				padding += '  ';
			}

			formatted += padding + node + '\r\n';
			pad += indent;
		});

		return formatted;
	}

	function uploadImage() {
		var selector = "#upImage"
				+ getSignatureById(viewModel.signatureSelected()).id;
		var oMyForm = new FormData();
		oMyForm.append("file", $(selector)[0].files[0]);
		$.ajax({
			url : 'uploadImage',
			data : oMyForm,
			dataType : 'json',
			processData : false,
			contentType : false,
			type : 'POST',
			success : function(data) {
				var imageId = data.uuid;
				getSignatureById(viewModel.signatureSelected())
						.imageId(imageId);
				getSignatureById(viewModel.signatureSelected()).imageUrl(
						'../Images/' + data.imageName);
			},
			error : function(data) {
				// console.log(data);
			}
		});

	}

	function sigAppearanceChanged(a) {
		var signature = getSignatureById(viewModel.signatureSelected());
		var id = signature.id;
		if (a == 1)//carica da file
		{
			$("#upImage" + id).css("visibility", "visible");
		} else if (a == 0)//scritta
		{
			$("#upImage" + id).css("visibility", "hidden");
			signature.imageUrl("");
			signature.imageId("");
			signature.imageUrlStandard("../Images/sigCertificate.png");
		} else if (a == 2)//firma biometrica
		{
			$("#upImage" + id).css("visibility", "hidden");
			signature.imageUrl("");
			signature.imageId("");
			signature.imageUrlStandard("../Images/sigMarioRossi.png");
		}
	}
	var currentLang = 'en';

	function showSignFeaXML() {
		$("#tdFD").css("display", "none");
		$("#dialog-form").dialog("open");
		toTabRemoto();
		$("#tabs").tabs("disable", 0);
		$("#tabs").tabs("select", 1);
		$("#tabsTipoFirma").tabs("disable", 1);
	}

	function playSignature() {

		playClicked = true;
		//alert("next: "+nextIndex);
		//console.log("currentIndex:" +nextIndex +" n.sig. "+viewModel.signatureApplied().length);

		var lastIndex = nextIndex;

		var sigToPlay = viewModel.getNextSignature(nextIndex);
		if (sigToPlay != null) {
			//console.log("eseguo currentIndex:" +nextIndex);
			sigToPlay.select();
			if (!signsStructure[sigToPlay.name()]['prevIndex'])
				signsStructure[sigToPlay.name()]['prevIndex'] = lastIndex;
			sigToPlay.signOrShow(true);
		} else {

			$("#dialog-form").dialog("close");
			if (signingInterface != null) {
				signingInterface.clearPanel();
				signingInterface.stop();
			}
			$("#signSeqDisabled").css("display", "inline");
			$("#signSeq").css("display", "none");
			//$('#webSigningFD').remove();
			//WebSigningApplet=null;
		}
	}

	function getSignatureSequence() {
		var signs = new Array();
		for ( var i = 0; i < viewModel.signatureApplied().length; i++) {
			var sig = viewModel.signatureApplied()[i];
			var name = sig.name();
			name = name.substring(4);
			name = name.substring(0, name.indexOf('_'));
			var seqn = parseInt(name);

			if (!playNormalSign) {
				if (sig.name().indexOf('SEQ_') != -1 && !sig.signed
						&& seqn >= nextIndex)
					signs.push(sig);
			} else {

				if (!sig.signed && !(signsStructure[sig.name()] || {
					skip : false
				}).skip)
					signs.push(sig);
			}

		}
		return signs;
	}

	function allSignMandatorySigned() {
		var signs = getSignatureSequence();
		for ( var i = 0; i < signs.length; i++) {
			if (signs[i].name().indexOf('_MAND_1') != -1 && !signs[i].signed)
				return false;
		}
		return true;
	}

	function endDocument() {
		$.ajax({
			dataType : 'json',
			type : "POST",
			url : 'endDocument',
			data : {
				docuuid : uuid
			},
			beforeSend : function() {
				$("#endDoc").css("disabled", "true")
				showText("Stop capture signature!!!", false);
			},
			success : function(data) {
				location.href = 'home';
				showText("", true);
			},
			error : function(xhr, textStatus, error) {
				$("#endDoc").css("disabled", "false");
				showText(textStatus, false);
			}

		});

	}

	function undoSign() {
		playClicked = false;
		playNormalSign=false;
		nextIndex = "-1";
		annullaFirma(true);
	}

	function annullaFirma(cancelPlay) {
		if (cancelPlay)
			playClicked = false;
		$.ajax({
			dataType : 'json',
			url : 'undoLastSign',
			data : {
				uuid : uuid
			},
			beforeSend : function() {
				//openLoadingPopup();
				showText('<spring:message code="label.loadingdocument" text="Loading document..." />', false);
			},
			success : function(data) {

				signingInterface.removeLastSignature();
				var lastPageWithSignature = pages[pagesWithSignature.pop()];
				if (lastPageWithSignature)
					lastPageWithSignature.hasNewSignature = true;
				loadImage(viewModel.actualPage());
				var selected = getSignatureById(viewModel.signatureSelected());
				if (selected && !cancelPlay) {
					var last = signsStructure[selected.name()].prevIndex || -2;
					nextIndex = last - 1;
				}

				//closeLoadingPopup();
				showText("", true);
				viewModel.signatureApplied.removeAll();

				viewModel.selectedUUID(data.uuid);
				var d = new Date();
				viewModel.selectedRandom(d.getTime());
				$('#newContainer').show("fade");
				var docType = '';
				if (typePassed)
					docType = typePassed;
				else
					docType = $("#documentType").val();
				if (docType == '0')
					getNumberOfPages();
			}
		});

	}

	function vediDocumento() {
		onlyShow = true;
		$("#dialog-form").dialog("open");
		toTabRemoto();
		if (1 == 1) { //da 

			signingInterface.setPdfBase64Image(codeBaseWithHost
					+ '/signManagement/' + $('#pageImage').attr('src'),
					realWidthPage, viewModel.actualPage(), viewModel
							.totalPages());

			signingInterface.setSignRectangle(1, 1, 1, 1);

		}
		signingInterface.startCapture(true);

	}

	function getDocumentProgress(progressData) {
		// 		  var percent = (progressData.loaded * 100 ) /  progressData.total;
		// 		  console.log(percent);
		// 		  $("#messageText").text("Loading document: " + percent + "%");
// 		$("#messageText").text('<spring:message code="label.renderingdocument" text="Rendering Document..." />');
	}
	var pages = [];
	var pagesWithSignature = [];
	function startPdfRendering(pdfUrl, callback) {
		PDFJS.disableWorker = false; // due to CORS

		var canvas = document.createElement('canvas'), // single off-screen canvas
		ctx = canvas.getContext('2d'), // to render to

		currentPage = 1;
		//$("#messageText").text('<spring:message code="label.renderingdocument" text="Rendering Document..." />');
		//$("#visibilityText").show();

		PDFJS.getDocument("getFileBytes?uuid=" + pdfUrl, null, null,
				getDocumentProgress).then(function(pdf) {
			//$("#visibilityText").hide();
			var totalPages = pdf.numPages;

			// init parsing of first page
			if (currentPage <= pdf.numPages)
				getPage();

			// main entry point/function for loop
			function getPage() {

				// when promise is returned do as usual
				pdf.getPage(currentPage).then(function(page) {

					var scale = 2;
					var viewport = page.getViewport(scale);

					canvas.height = viewport.height;
					canvas.width = viewport.width;
					width = viewport.width;

					var renderContext = {
						canvasContext : ctx,
						viewport : viewport
					};

					// now, tap into the returned promise from render:
					page.render(renderContext).then(function() {

						// store compressed image data in array
						pages.push({
							imgB64 : canvas.toDataURL().split('base64,')[1],
							totalPages : totalPages,
							pointWidth : viewport.width / 2,
							pointHeight : viewport.height / 2,
							hasNewSignature : false
						});
						viewModel.totalPages(pages.length);
						if (currentPage == 1 && callback) {
							callback();
						}
						if (currentPage < pdf.numPages) {
							//drawPage(currentPage-1,addPage);
							currentPage++;
							getPage(); // get next page
						}

					});
				});
			}
		});
	}

	function getPdfPage(pageIndex) {
		return pages[pageIndex];
	}

	function back() {
		location.href = "home";
	}
	showText = function(message, hidden) {
		if (hidden) {
			$("#messageText").text(message);
			$("#visibilityText").hide()
		} else {
			$("#messageText").text(message);
			$("#visibilityText").show();
		}
	};
	
	
	function isIE () {
		  var myNav = navigator.userAgent.toLowerCase();
		  
		  return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
		}
	
	
	function sendToSmartphone()
	{
		var body="bsi://biosignin.org?uuid="+uuid;
		location.href = "mailto:?body="+body;
	}
	
	function createSmartphoneDialog()
	{
		$("#smartphone-dialog")
		.dialog(
				{
					resizable: false,
					draggable: false,
					autoOpen : false,
					minHeight : '605px',
					width : '830px',
					modal : true,
					open : function(event, ui) {
						$("#smartUrl").val('bsi://biosignin.org?'+uuid);
					},
					buttons : {
						'<spring:message code="label.inviaUrlViaMail" text="Invia email" />' : function() {
							sendToSmartphone();
							$("#smartphone-dialog").dialog("close");
						}
					
					}
					
				
				});
	}
</script>

</head>



<body>
	<div class="operationState">
		<div style="padding-left: 7px;" id="visibilityText">
			<img style="width: 30px; vertical-align: middle; margin-right: 0px;"
				src="<c:url value="/Images/status_progress.gif"/>" /> <span
				class="messageState" id="messageText"></span>
		</div>
		
		<div style="color:white;text-align:right;padding-top:5px;padding-right:15px;">
			<span >Powered by Innovery</span>
		</div>
	</div>
	<div id='container' class="cont"
		data-bind="style: {height: viewModel.selectedUUID()?'0px':'250px'}"
		style="width: 100%">
		<div id="uploadingContainer" style="width: 100%">

			<%-- <c:import url="menu.jsp"></c:import>  --%>

			<div id="wizard" style="width: 99%">
				<div id="tab1">
					<dl>
						<label style="display: none"><spring:message
								code="label.selezionaTipoDoc" text="Select document type" /></label>
						<select name="type" id="documentType" style="display: none">
							<option value="0">PDF - PAdES</option>
							<option value="1">XML - XAdES</option>
							<option value="2">
								<spring:message code="label.tipoGenerico" text="Generic" />
							</option>

						</select>
						<div style="display: none">
							<label><spring:message code="label.selezionaDoc"
									text="Select document" /></label><br> <input id="fileupload"
								type="file" name="file" onchange="openLoadingPopup()"
								accept="application/pdf">
						</div>
					</dl>
				</div>
				<div id="tab4" style="display: none">
					<dl>


						<div id="newContainer" width="100%">
							<table width="100%">
								<tr>
									<td width="20%" style="vertical-align: top">
										<table>
											<tr>
												<td style="width: 40px"><img id="addSig"
													title='<spring:message code="label.addsignature" text="Add signature field" />' width="40px" height="40px"
													src="../Images/add_firma.png"
													onmouseover="this.src='../Images/add_firma_hover.png'"
													onmouseout="this.src='../Images/add_firma.png'"
													onclick="addSignature()" /> <img id="addSigDisabled"
													style="display: none" title='<spring:message code="label.addsignature" text="Add signature field" />'
													width="40px" height="40px"
													src="../Images/add_firma_disabled.png" /></td>
												<td style="width: 40px"><img id="signSeq"
													style="display: none;" title='<spring:message code="label.sequncesignature" text="Play sequnce signature" />'
													width="40px" height="40px"
													src="../Images/play_signature.png"
													onmouseover="this.src='../Images/play_signature_hover.png'"
													onmouseout="this.src='../Images/play_signature.png'"
													onclick="playSignature()" /> <img id="signSeqDisabled"
													style="" title='<spring:message code="label.sequncesignature" text="Play sequnce signature" />' width="40px"
													height="40px" src="../Images/play_signature_disabled.png" />

												</td>
												<td style="width: 40px"><img id="saveDoc" style=""
													title='<spring:message code="label.savesignature" text="Save Signature" />' width="40px" height="40px"
													src="../Images/save_document.png"
													onmouseover="this.src='../Images/save_document_hover.png'"
													onmouseout="this.src='../Images/save_document.png'"
													onclick="download()" /> <img id="saveDocDisabled"
													style="display: none" title='<spring:message code="label.savesignature" text="Save Signature" />' width="40px"
													height="40px" src="../Images/save_document_disabled.png" />

												</td>
												<td style="width: 40px">
													<form action="endDocument"
														style="display: inline; padding-left: 0px;">
														<input id="docuuid" type="hidden" value="${uuid}"
															name="docuuid"> <input id="callbackURL"
															value="${callbackURL}" type="hidden" name="callbackURL">
														<input id="enableFlatCopy" value="${enableFlatCopy}"
															type="hidden" name="enableFlatCopy"> <input
															title='<spring:message code="label.endsignature" text="End Signature" />' id="endDoc" type="image" height="40px"
															src="<c:url value='/Images/stop_signature.png'/>"
															onmouseover="this.src='../Images/stop_signature_hover.png'"
															onmouseout="this.src='../Images/stop_signature.png'" />
													</form>
												</td>
												<td style="width: 40px"><img id="showDoc" style=""
													title='<spring:message code="label.showdocument" text="Show Document" />' width="40px" height="40px"
													src="../Images/vediDoc.png"
													onmouseover="this.src='../Images/vediDocHover.png'"
													onmouseout="this.src='../Images/vediDoc.png'"
													onclick="vediDocumento()" /></td>
												<td style="width: 40px"><img id="annullaFirma" style=""
													title='<spring:message code="label.deletelastsignature" text="Delete Last Signature" />' width="40px" height="40px"
													src="../Images/annullaFirma.png"
													onmouseover="this.src='../Images/annullaFirmaHover.png'"
													onmouseout="this.src='../Images/annullaFirma.png'"
													onclick="undoSign()" /></td>
													
												<td style="width: 40px"><img style=""
													title='<spring:message code="label.sendToSmartphone" text="Send to Smartphone" />' width="40px" height="40px"
													src="../Images/sendToSmartphon.png"
													onmouseover="this.src='../Images/sendToSmartphonHover.png'"
													onmouseout="this.src='../Images/sendToSmartphon.png'"
													onclick='$("#smartphone-dialog").dialog("open");' /> 

												</td>
											</tr>
										</table> <!-- 											    <img style="display: inline;" id="imgFineFirmaDisabled" width="40px" height="40px"  src="../Images/stop_signature_disabled.png" /> -->
										<!-- 											    <img title="Fine firma" style="display: none" id="imgFineFirmaEnabled" width="40px" height="40px"  src="../Images/stop_signature.png" onmouseover="this.src='../Images/stop_signature_hover.png'" onmouseout="this.src='../Images/stop_signature.png'" onclick="endDocument();" /> -->




										<!-- 											    <img id="annullaFirmacDisabled" style="padding-bottom:6px;display:none" title="Annulla ultima firma" width="40px" height="40px"  src="../Images/annullaFirmaDisabled.png" /> -->


										<br> <label><span
											data-bind="text: 'Device '+viewModel.connectedTab()"></span></label><br>
									<br>

										<div
											style="border-left: 5px solid #357eb3; border-right: 5px solid #357eb3; border-top: 5px solid #357eb3; padding: 3px; width: 300px; height: 25px; background-color: #0065a7; color: white"
											align="center">
											<spring:message code="label.elencoCampiFirma"
												text="List of signature fields" />
										</div>
										<div
											style="border: 5px solid #357eb3; padding: 3px; width: 300px;">
											<div style="width: 250px;">
												<img width="25px" height="25px"
													src="../Images/firma_rossa.png"> <spring:message code="label.requiredsignature" text="Required Signature" />
												<div id="taskContainer" align="left"
													style="width: 250px; font-size: 8pt;">
													<!-- ko foreach: viewModel.signatureApplied() -->
													<!-- ko if: $data.isMandatory() -->
													<div style="margin-left: 20px; width: 250px; padding: 3px;">
														<img width="20px" height="20px" style="float: left;"
															data-bind="attr:{src: $data.signed?'../Images/firma_verde.png':'../Images/firma_rossa.png'}">
														<div
															style="vertical-align: middle; margin-left: 5px; cursor: pointer;"
															data-bind="'click': $data.select, 'event' : { 'dblclick': $data.signOrShow }">
															<span data-bind="text:$data.displayName()"></span> - Pag.
															<span data-bind="text:$data.isVisible()?$data.page:'N/A'"></span>

														</div>
													</div>
													<!-- /ko -->
													<!-- /ko -->
												</div>
											</div>
											<br>
											<div style="width: 250px">
												<img width="25px" height="25px"
													src="../Images/firma_blu.png"> <spring:message code="label.signaturenotrequired" text="Signature not Required" />
												<div id="taskContainer2" align="left"
													style="width: 250px; font-size: 8pt;">
													<!-- ko foreach: viewModel.signatureApplied() -->
													<!-- ko if: !$data.isMandatory() -->
													<div style="margin-left: 20px; width: 250px; padding: 3px;">
														<img width="20px" height="20px" style="float: left;"
															data-bind="attr:{src: $data.signed?'../Images/firma_verde.png':'../Images/firma_rossa.png'}">
														<!-- ko if: $data.isEditable -->
														<img style="float: left; cursor: pointer;"
															src="<c:url value='/Images/delete.png'/>"
															data-bind="click: $parent.removeSignature">
														<!-- /ko -->
														<div
															style="vertical-align: middle; margin-left: 5px; cursor: pointer;"
															data-bind="'click': $data.select, 'event' : { 'dblclick': $data.signOrShow }">
															<span data-bind="text:$data.displayName()"></span> - Pag.
															<span data-bind="text:$data.isVisible()?$data.page:'N/A'"></span>
														</div>
													</div>
													<!-- /ko -->
													<!-- /ko -->
												</div>
											</div>
										</div> <!-- 							</form> -->
									</td>
									<td width="80%" style="vertical-align: top">
										<div align="left">

											<div align="center">
												<!-- 										<input data-bind="enable: viewModel.availablePrevPage()" -->
												<!-- 											type="button" value="Prev Page" -->
												<!-- 											onclick="viewModel.actualPage(viewModel.actualPage()-1)" />  -->
												<table>
													<tr>
														<td style="vertical-align: middle;"><a href="#"
															data-bind="visible: viewModel.availablePrevPage()"> <img
																width="35px" height="35px" src="../Images/prev.png"
																onmouseover="this.src='../Images/prev_hover.png'"
																onmouseout="this.src='../Images/prev.png'"
																onclick="viewModel.actualPage(viewModel.actualPage()-1)" />
														</a></td>
														<td style="vertical-align: middle;"><span
															data-bind="text: 'Page '+viewModel.actualPage()+'/'+viewModel.totalPages()"></span></td>
														<td style="vertical-align: middle;">
															<!-- 											<input data-bind="enable: viewModel.availableNextPage()" -->
															<!-- 											type="button" value="Next Page" --> <!-- 											onclick="viewModel.actualPage(viewModel.actualPage()+1)" /> -->
															<a href="#"
															data-bind="visible: viewModel.availableNextPage()"> <img
																width="35px" height="35px" src="../Images/next.png"
																onmouseover="this.src='../Images/next_hover.png'"
																onmouseout="this.src='../Images/next.png'"
																onclick="viewModel.actualPage(viewModel.actualPage()+1)" />
														</a>
														</td>
													</tr>
												</table>



												<!--  addSignature -->
												<div id="imageContainer"
													style="border: 5px solid #357eb3; width: 810px; position: relative;">
													<!-- ko foreach: viewModel.signatureApplied() -->
													<!-- ko if: $data.isVisible() -->
													<!-- ko if: $data.isEditable -->
													<!-- ko if: $data.page==viewModel.actualPage() -->
													<div
														style="cursor: pointer; max-width: 390px; max-height: 190px;"
														data-bind="customPos: $data, 'click': $data.select, attr: {'id': 'sign'+$data.id,'class':'sign' } , 'event' : { dblclick: $data.signOrShow }">
														<!-- 													<div class="signName" data-bind=" text:$data.imageUrl()==''? $data.name():''"></div> -->
														<img src="../Images/sigMarioRossi.png" width="100%"
															height="100%">
														<div class="signName"></div>
													</div>
													<!-- /ko -->
													<!-- /ko -->
													<!-- ko if: !$data.isEditable -->
													<!-- ko if: $data.page==viewModel.actualPage() -->
													<div style="cursor: pointer;"
														onmouseover="this.style.border = '1px solid #000000'"
														onmouseout="this.style.border = '0px solid #000000'"
														data-bind="customPos: $data, 'click': $data.select, attr: {'id': 'sign'+$data.id,'class':'sign' }, 'event' : { dblclick: $data.signOrShow }">
														<div class="signName"></div>
														<img src="../Images/blank.png" width="100%" height="100%">
													</div>
													<!-- /ko -->
													<!-- /ko -->
													<!-- /ko -->
													<!-- /ko -->
													<img id="pageImage" />
												</div>

											</div>
										</div>
									</td>
								</tr>
							</table>
						</div>
					</dl>
				</div>
			</div>
		</div>
		<div id="tabletExternal"></div>
		<div id="tabletManagerPanel"></div>
		<c:import url="signFormFD.jsp"></c:import>

<!-- 		 <pre data-bind="text: 'DEBUG: \r\n'+ko.toJSON($root, null, 2)" style="float: left"></pre> -->
	</div>
	<c:import url="loading.jsp"></c:import>
	<div id="smartphone-dialog" align="center">
		Smartphone URL
		<input type="text" id="smartUrl" style="width: 500px">
	</div>
</body>
</html>