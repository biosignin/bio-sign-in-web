function WebSigning(appletName, appletContainer, codeBasePath) {
	this.appletName=appletName;
	this.codeBasePath = codeBasePath;
	this.appletContainer = appletContainer;
	
}

WebSigning.prototype.createTabletManagerApplet = function(statusCallback) {
	 var attributes = {
		id : this.appletName,
		code : 'eu.inn.biosign.DeviceManager.class',
		archive : 'applet-bio-sign-in.jar,bcprov-jdk15on-1.50.jar,bcmail-jdk15on-1.50.jar,bcpkix-jdk15on-1.50.jar,stu-mod.jar,axiom-mod.jar',
		width : 1,
		height : 1
	};
	var parameters = {
		java_status_events : 'true',
		separate_jvm : true,
		java_arguments : "-Xmx512m",
		codebase : this.codeBasePath,
		mayscript : true
	};

	function docWriteWrapper(jq, func) {
		var oldwrite = document.write, content = '';
		document.write = function(text) {
			content += text;
		};
		func();
		document.write = oldwrite;
		jq.html(content);
	}

	docWriteWrapper(this.appletContainer, function() {
		deployJava.runApplet(attributes, parameters, '1.7');
	});
	
	(function checkAppletStatus(){
		selectedApplet = document.webSigningFD;
		if(!selectedApplet || selectedApplet.status == 1){
			setTimeout(checkAppletStatus, 100);
		}else{
			if(statusCallback) statusCallback(selectedApplet.status);
			console.log("applet status is:" +selectedApplet.status);
		}
	})();
};

WebSigning.prototype.isSignatureAcquired = function() {
	return this.signatureAcquired;
};

WebSigning.prototype.setServerKeyLength = function(length) {
	setTimeout(function() {
		selectedApplet.setServerKeyLength(length);
	}, 0);
};

WebSigning.prototype.setSignRectangle = function(x,y,width,height) {
	//setTimeout(function() {
		try{
			selectedApplet.setSignRectangle(x,y,width,height);
		}
		catch(r)
		{
			console.log("exception setSignRectangle: "+r);
		}
		
	//}, 0);
};


WebSigning.prototype.setPdfFile = function(base64File) {
	setTimeout(function() {
		try{
			selectedApplet.setPdfFile(base64File);
		}
		catch(r)
		{
			console.log("exception setPdfFile: "+r);
		}
	}, 0);
};

WebSigning.prototype.setEnablePdfJS = function() {
	setTimeout(function() {
		try{
			selectedApplet.setEnablePdfJS();
		}
		catch(r)
		{
			console.log("exception setEnablePdfJS: "+r);
		}
	}, 0);
};

WebSigning.prototype.removeLastSignature = function() {
	//setTimeout(function() {
		try{
			selectedApplet.removeLastSignature();
		}
		catch(r)
		{
			console.log("exception removeLastSignature: "+r);
		}
	//}, 0);
};

WebSigning.prototype.getAllPages = function() {
	return selectedApplet.getAllPages();
};

WebSigning.prototype.getPageB64 = function(page) {
	return selectedApplet.getPageB64(page);
};





WebSigning.prototype.setPdfBase64Image = function(imageDataString,pdfPointWidth,actualPage,totalPage) {
	//setTimeout(function() {
		try{

			selectedApplet.setPdfBase64Image(imageDataString,pdfPointWidth,actualPage,totalPage);
		}
		catch(r)
		{
			console.log("exception setPdfBase64Image: "+r);
		}
	//}, 0);
};

WebSigning.prototype.setPdfAndRect = function(imageDataString,pdfPointWidth,
		actualPage,totalPage,x,y,width,height) {
//	setTimeout(function() {
		
		try{
			selectedApplet.setPdfBase64Image(imageDataString,pdfPointWidth,actualPage,totalPage);
			selectedApplet.setSignRectangle(x,y,width,height);
		}
		catch(r)
		{
			console.log("exception setPdfAndRect: "+r);
		}
//	}, 0);
};

WebSigning.prototype.stop = function() {
	setTimeout(function() {
		
		try{
			selectedApplet.stop();
		}
		catch(r)
		{
			console.log("exception stop: "+r);
		}
	}, 0);
};

WebSigning.prototype.destroy = function() {
	setTimeout(function() {
		
		try{
			selectedApplet.destroy();
		}
		catch(r)
		{
			console.log("exception destroy: "+r);
		}
	}, 0);
};

WebSigning.prototype.setSigTag = function(tag) {
//	setTimeout(function() {
		
		try{
			selectedApplet.setSigTag(tag);
		}
		catch(r)
		{
			console.log("exception setSigTag: "+r);
		}
		
//	}, 0);
};

WebSigning.prototype.setEnableDocView = function(enabled) {
	setTimeout(function() {
		
		try{
			selectedApplet.setEnableDocView(enabled);
		}
		catch(r)
		{
			console.log("exception setEnableDocView: "+r);
		}
		
	}, 0);
};

WebSigning.prototype.clearPanel = function() {
	setTimeout(function() {
		
		try{
			selectedApplet.clearPanel();
		}
		catch(r)
		{
			console.log("exception clearPanel: "+r);
		}
		
	}, 0);
};


WebSigning.prototype.appletStartCapture = function(showOnly) {
	//setTimeout(function() {
		try{
			console.log('1'+this.appletContainer);
			if(showOnly)
				selectedApplet.startCapture(true);
			else
				selectedApplet.startCapture(false);
			console.log('2'+this.appletContainer);
			console.log('-----');
		}
		catch(r)
		{
			console.log("exception start Capture: "+r);
		}
		
	//}, 0);
};


WebSigning.prototype.getAppletBioData = function() {
	return selectedApplet.getBioData();
};

WebSigning.prototype.getDeviceInfo = function() {
	return selectedApplet.getDeviceInfo();
};

WebSigning.prototype.setBindingData = function(hash, alg, offset, count) {
	
	try{
		selectedApplet.setBindingData(hash, alg, offset, count);
	}
	catch(r)
	{
		console.log('error in setBindingData:'+r);
	}
	
};

WebSigning.prototype.signAcquired = function(bio, image) {
//	console.log(this.appletContainer);
	this.appletContainer.trigger('signAcquired', [ bio, image ]);
};

WebSigning.prototype.noDevice = function() {
	setTimeout(function() {
//		console.log(this.appletContainer);
		this.appletContainer.trigger('noDevice');
		
	}, 0);
};
WebSigning.prototype.onAppletError = function(error) {
	this.appletContainer.trigger('appletError', [ error ]);

};

function noDevice() {
		//console.log("before calling nodevice");
		selectedAppletContainer.noDevice();
		//console.log("after nodevice called");
//	}, 0);
}

function initCompleted() {
		selectedApplet = document.webSigningFD;
		selectedAppletContainer = WebSigningApplet;
		selectedAppletContainer.initCompleted();
}


WebSigning.prototype.cancelSign = function() {
	this.appletContainer.trigger('cancelSign');
};

var isCancelSign=false;

function cancelSign() {
	if (!isCancelSign)
		isCancelSign=true;
}

var __checkCancelSign = setInterval(function(){
	if (isCancelSign) {
		isCancelSign=false;
		selectedAppletContainer.cancelSign();
	}
	
},1000);


var isBioChanged=false;
var __bio="";
var __image="";
var __checkBioInterval = setInterval(function(){
	if (isBioChanged) {
		isBioChanged=false;
		selectedAppletContainer.signAcquired(__bio, __image);
	}
	
},1000);
function signAcquired(bio, image) {
	//console.log("bio from app " + bio);
		if (__bio != bio || __image!=image) {
		__bio=bio;
		__image=image;
		isBioChanged=true;
	}
//	bio='<?xml version="1.0" encoding="UTF-8" standalone="no"?><EncryptedSignatureDataContainer version="1.0"><EncryptedSessionKey Certificate="MIIB5TCCAU4CCQCjqUIxhGV9rTANBgkqhkiG9w0BAQUFADA3MQswCQYDVQQGEwJJVDEXMBUGA1UEChMOaW5ub3ZlcnkgUy5wLkExDzANBgNVBAMTBlBvc3RlbDAeFw0xMzEwMTAxMjM0MDRaFw0xNDEwMTAxMjM0MDRaMDcxCzAJBgNVBAYTAklUMRcwFQYDVQQKEw5pbm5vdmVyeSBTLnAuQTEPMA0GA1UEAxMGUG9zdGVsMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCXzSDWadYfGIfLSBH0jeoHnrp5zAbqei+OWj1fCl1Md+AnqS+Gcz/943j7m1NkddwDmU4j+qUZExC8oElS8ky6kInwUGsHP9ooWj01aeSCMxOVbZVqG5Kxz1khvTIPZ9LMYK5WDAj2wpN/UOU8iHDVAAYnuzV2YuhAgXPIYZZSTwIDAQABMA0GCSqGSIb3DQEBBQUAA4GBAA8TRwI3pv30Xy6m2K3v42QEsytuAPVcJM47AV0EgC9EBUt5x1YPB+RM4wZejs+tfTtcBBQGTJaSTe5VpdBHob2k11LCDIHFdxJAZlk77o9Vs+/IPuLckLXPe2xj3mvP2LwwLh6m3BPQv5K2nX+pe85Of9xQTnl9LeLI59zN3thB" Encoding="Base64" Padding="OAEP">F/UtluE+BoWdHwr8pCEj06X40kEU1latjv++aVjEomz6aVA6tdMg2WsY14tV9g5uSQRO8KPfoGmFCMlSYrf8huonr4smnpFs17/auySRBHPfF4M5ifGV9gwITBABr25plRa5WpnZPvCySvxogKkvY4syAqHTWFLGZuXSD8LnRks=</EncryptedSessionKey><EncryptedData CipherMode="CBC" CipherSize="128" Encoding="Base64" IvSize="128" KeySize="256" PaddingMode="PKCS7" SymmetricAlgorithm="AES">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</EncryptedData></EncryptedSignatureDataContainer>';

//	//console.log("bio new " + bio);
	////console.log("img from app " + image);
	//selectedAppletContainer.signAcquired(bio, image);
}

function log(msg) {
	//console.log(msg);
}

WebSigning.prototype.initCompleted = function() {
	console.log(this.appletContainer);
	this.appletContainer.trigger('appletInitialized');
};


