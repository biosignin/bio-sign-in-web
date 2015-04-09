//var signingInterface;
//var signingInterface;

function is_touch_device() {
 return (('ontouchstart' in window)
      || (navigator.MaxTouchPoints > 0)
      || (navigator.msMaxTouchPoints > 0));
 //navigator.msMaxTouchPoints for microsoft IE backwards compatibility
}

function DetectSigningInterface(appletName, htmlContainer, codeBasePath){
	if (is_touch_device()){
		if (confirm('Touch input type detected, do you want use it?')) {
			return new TouchInterface(htmlContainer);
		}
	}
	return new AppletInterface(appletName, codeBasePath, htmlContainer);
	
};








function SigningInterface(){}
	  
SigningInterface = Class.extend({
	init: function(){
		throw new Error('The constructor is private, please use SigningInterface.createSigningInterface.');
	},
	createSigningInterface: function(statusCallback) {
		console.log("createSigningInterface called, but no implementation founded");
		if(statusCallback) {
			console.log("stubbing status callback");
			statusCallback(2);
		}
			
	},
	setHtmlContainer: function(val){
		SigningInterface.prototype.htmlContainer=val;
	},
	canRenderPages: function(){
		return false;
	},
	showPanel: function(width, heigth){
		console.log("showPanel called, but no implementation founded");
	},
	hidePanel: function(){
		console.log("hidePanel called, but no implementation founded");
	},
	customButtons: function(){
		return {};
	},
	setServerKeyLength:function(length){
		console.log("setServerKeyLength called, but no implementation founded");
	},
	setSignRectangle:function(x,y,width,height) {
		console.log("setSignRectangle called, but no implementation founded");
	},
	setPdfFile:function(base64File){
		console.log("setPdfFile called, but no implementation founded");
	},
	setEnablePdfJS:function(){
		console.log("setEnablePdfJS called, but no implementation founded");
	},
	removeLastSignature:function(){
		console.log("removeLastSignature called, but no implementation founded");
	},
	getAllPages:function(){
		console.log("getAllPages called, but no implementation founded");
	},
	getPageB64:function(page){
		console.log("getPageB64 called, but no implementation founded");
	},
	setPdfBase64Image:function(imageDataString,pdfPointWidth,actualPage,totalPage) {
		console.log("setPdfBase64Image called, but no implementation founded");
	},
	setPdfAndRect:function(imageDataString,pdfPointWidth,actualPage,totalPage,x,y,width,height) {
		console.log("setPdfAndRect called, but no implementation founded");
	},
	stop:function(){
		console.log("stop called, but no implementation founded");
	},
	destroy:function(){
		console.log("destroy called, but no implementation founded");
	},
	setSigTag:function(tag){
		console.log("setSigTag called, but no implementation founded");
	},
	setEnableDocView:function(enabled){
		console.log("setEnableDocView called, but no implementation founded");
	},
	clearPanel:function(){
		console.log("clearPanel called, but no implementation founded");
	},
	startCapture:function(showOnly){
		console.log("startCapture called, but no implementation founded");
	},
	getDeviceInfo:function(){
		console.log("getDeviceInfo called, but no implementation founded");
	},
	setBindingData:function(hash, alg, offset, count) {
		console.log("setBindingData called, but no implementation founded");
	},
	
	
	
	
	triggerSignAcquired:function(bio, image){
		this.htmlContainer.trigger('signAcquired', [ bio, image ]);
	},
	triggerNoDevice:function(){
		this.htmlContainer.trigger('noDevice');
	},
	triggerDeviceError:function(error){
		this.htmlContainer.trigger('deviceError', [ error ]);
	},
	triggerCancelSign:function(){
		this.htmlContainer.trigger('deviceError');
	},
	triggerInitCompleted:function(){
		this.htmlContainer.trigger('initCompleted');
	}
});