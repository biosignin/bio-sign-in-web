 
function AppletInterface(){}
	  
AppletInterface = SigningInterface.extend({	
	init: function(appletName, codeBasePath, htmlContainer){
		this.appletName=appletName;
		this.codeBasePath=codeBasePath;
		this.setHtmlContainer(htmlContainer);
	},
	canRenderPages: function(){
		return true;
	},	
	
	createSigningInterface: function(statusCallback) {

		var attributes = {
			id : this.appletName,
			code : 'eu.inn.biosign.DeviceManager.class',
			archive : 'applet-bio-sign-in.jar,bcprov-jdk15on-1.50.jar,bcmail-jdk15on-1.50.jar,bcpkix-jdk15on-1.50.jar',
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
		docWriteWrapper(this.htmlContainer, function() {
			deployJava.runApplet(attributes, parameters, '1.7');
		});
		var self = this;
		(function checkAppletStatus(){
			self.selectedApplet = eval("document."+self.appletName);
			if(!self.selectedApplet || self.selectedApplet.status == 1){
				setTimeout(checkAppletStatus, 500);
			}else{
				if(statusCallback) 
					statusCallback(self.selectedApplet.status);
				console.log("applet status is:" +self.selectedApplet.status);
			}
		})();
	},
	
	
	
	//setHtmlContainer: function(val){
	//	SigningInterface.prototype.htmlContainer=val;
	//},
	setServerKeyLength:function(length){
		var self = this;
		setTimeout(function() {
			self.selectedApplet.setServerKeyLength(length);
		}, 0);
	},
	setSignRectangle:function(x,y,width,height) {
		try{
			this.selectedApplet.setSignRectangle(x,y,width,height);
		}
		catch(r) {
			console.log("exception setSignRectangle: "+r);
		}
	},
	setPdfFile:function(base64File){
		var self = this;
		setTimeout(function() {
			try{
				self.selectedApplet.setPdfFile(base64File);
			}
			catch(r) {
				console.log("exception setPdfFile: "+r);
			}
		}, 0);
	},
	setEnablePdfJS:function(){
		var self = this;
		setTimeout(function() {
			try{
				self.selectedApplet.setEnablePdfJS();
			}
			catch(r) {
				console.log("exception setEnablePdfJS: "+r);
			}
		}, 0);
	},
	removeLastSignature:function(){
		var self = this;
		setTimeout(function() {
			try{
				self.selectedApplet.removeLastSignature();
			}
			catch(r) {
				console.log("exception removeLastSignature: "+r);
			}
		}, 0);
	},
	getAllPages:function(){
		return this.selectedApplet.getAllPages();
	},
	getPageB64:function(page){
		return this.selectedApplet.getPageB64(page);
	},
	setPdfBase64Image:function(imageDataString,pdfPointWidth,actualPage,totalPage) {
		try {
			this.selectedApplet.setPdfBase64Image(imageDataString,pdfPointWidth,actualPage,totalPage);
		}
		catch(r) {
			console.log("exception setPdfBase64Image: "+r);
		}
	},
	setPdfAndRect:function(imageDataString,pdfPointWidth,actualPage,totalPage,x,y,width,height) {
		try{
			this.selectedApplet.setPdfBase64Image(imageDataString,pdfPointWidth,actualPage,totalPage);
			this.selectedApplet.setSignRectangle(x,y,width,height);
		}
		catch(r) {
			console.log("exception setPdfAndRect: "+r);
		}
	},
	stop:function(){
		var self = this;
		setTimeout(function() {
			try{
				self.selectedApplet.stop();
			}
			catch(r) {
				console.log("exception stop: "+r);
			}
		}, 0);
	},
	destroy:function(){
		var self = this;
		setTimeout(function() {
			try{
				self.selectedApplet.destroy();
			}
			catch(r) {
				console.log("exception destroy: "+r);
			}
		}, 0);
	},
	setSigTag:function(tag){
		try{
			this.selectedApplet.setSigTag(tag);
		}
		catch(r) {
			console.log("exception setSigTag: "+r);
		}
	},
	setEnableDocView:function(enabled){
		var self = this;
		setTimeout(function() {		
			try{
				self.selectedApplet.setEnableDocView(enabled);
			}
			catch(r) {
				console.log("exception setEnableDocView: "+r);
			}		
		}, 0);
	},
	clearPanel:function(){
		var self = this;
		setTimeout(function() {		
			try{
				self.selectedApplet.clearPanel();
			}
			catch(r) {
				console.log("exception clearPanel: "+r);
			}		
		}, 0);
	},
	startCapture:function(showOnly){
		try{
			if(showOnly)
				this.selectedApplet.startCapture(true);
			else
				this.selectedApplet.startCapture(false);
		}
		catch(r) {
			console.log("exception start Capture: "+r);
		}
	},
	getDeviceInfo:function(){
		return this.selectedApplet.getDeviceInfo();
	},
	setBindingData:function(hash, alg, offset, count) {
		try{
			this.selectedApplet.setBindingData(hash, alg, offset, count);
		}
		catch(r) {
			console.log('error in setBindingData:'+r);
		}
	}
	//,
	
	
	
	
	//triggerSignAcquired:function(bio, image){
	//	this.htmlContainer.trigger('signAcquired', [ bio, image ]);
	//},
	//triggerNoDevice:function(){
	//	this.htmlContainer.trigger('noDevice');
	//},
	//triggerDeviceError:function(error){
	//	this.htmlContainer.trigger('deviceError', [ error ]);
	//},
	//triggerCancelSign:function(){
	//	this.htmlContainer.trigger('deviceError');
	//},
	//triggerInitCompleted:function(){
	//	this.htmlContainer.trigger('initCompleted');
	//}
	
});	
	

function initCompleted() {
	signingInterface.selectedApplet = eval("document."+signingInterface.appletName);
	signingInterface.triggerInitCompleted();
}


var isCancelSign=false;
function cancelSign() {
	if (!isCancelSign)
		isCancelSign=true;
}

var __checkCancelSign = setInterval(function(){
	if (isCancelSign) {
		isCancelSign=false;
		signingInterface.triggerCancelSign();
	}	
},1000);


var isBioChanged=false;
var __bio="";
var __image="";
var __checkBioInterval = setInterval(function(){
	if (isBioChanged) {
		isBioChanged=false;
		signingInterface.triggerSignAcquired(__bio, __image);
	}
	
},1000);

function signAcquired(bio, image) {
	if (__bio != bio || __image!=image) {
		__bio=bio;
		__image=image;
		isBioChanged=true;
	}
}

function log(msg) {
	//console.log(msg);
}