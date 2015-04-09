//var colors = ["rgb(100, 255, 100)", "rgb(255, 0, 0)", "rgb(0, 255, 0)", "rgb(0, 0, 255)", "rgb(0, 255, 100)", "rgb(10, 255, 255)", "rgb(255, 0, 100)"];
var colors = ["rgb(42, 0, 255)"]
function TouchInterface(){}
	  
TouchInterface = SigningInterface.extend({	
	init: function(htmlContainer){
		this.setHtmlContainer(htmlContainer);
	},	
	
	createSigningInterface: function(statusCallback) {
		this.pointerDown = {};
		this.lastPositions = {};
		this.canvasTouch = document.createElement('canvas');
		this.canvasTouch.id = 'canvasTouch';
		this.htmlContainer.append(this.canvasTouch);
		$('#canvasTouch').css('background-color', 'rgba(158, 167, 184, 0.2)');
		
		this.canvasTouch.width = 0;
		this.canvasTouch.height = 0;

		//$('#someId').height('480px');
		//$('#someId').width('800px');
		
		context = this.canvasTouch.getContext("2d");

		context.fillStyle = "rgba(50, 50, 50, 1)";
		context.fillRect(0, 0, this.canvasTouch.width, this.canvasTouch.height);

		//$("body").on("pointerdown", "canvas", onPointerDown);
		this.canvasTouch.addEventListener("pointerdown", this.onPointerDown, false);
		this.canvasTouch.addEventListener("pointermove", this.onPointerMove, false);
		this.canvasTouch.addEventListener("pointerup", this.onPointerUp, false);
		this.canvasTouch.addEventListener("pointerout", this.onPointerUp, false);
		this.canvasTouch.addEventListener("pointerenter", this.onPointerEnter, false);
		this.canvasTouch.addEventListener("pointerleave", this.onPointerLeave, false);
		this.canvasTouch.addEventListener("pointerover", this.onPointerOver, false);
		if(statusCallback) 
			statusCallback(2);
		console.log("applet status is:" +2);
		this.triggerInitCompleted();
			
	},
	calculatePanel: function (maxWidth, maxHeight, rectangleWidth, rectangleHeight){

		//var canvas = document.getElementById('canvasTouch');
		var width=maxWidth;
		var height=maxHeight;
		var marginLeft=0;
		var marginTop=0;
		this.ratio=1;
		if (rectangleWidth) {
			var ratioWidth = maxWidth/rectangleWidth;
			var ratioHeight = maxHeight/rectangleHeight;
			if (ratioWidth>ratioHeight) {
				this.ratio=ratioHeigth;
			}
			else{
				this.ratio=ratioWidth;
			}
			width=rectangleWidth*this.ratio;
			height=rectangleHeight*this.ratio;
			marginLeft=(maxWidth-width)/2;
			marginTop=(maxHeight-height)/2;
			this.loadImage(viewModel.actualPage());
		}
		
		this.canvasTouch.width=width;
		this.canvasTouch.height=height;
		
		this.canvasTouch.style.marginLeft=marginLeft+"px";
		this.canvasTouch.style.marginTop=marginTop+"px";
	},
	showPanel: function(maxWidth, maxHeight){
		this.maxWidth=maxWidth;
		this.maxHeight=maxHeight;
		this.canvasTouch.style.border = "black 1px solid";
		this.calculatePanel(this.maxWidth, this.maxHeight, this.rectangleWidth, this.rectangleHeight);
		
	},
	hidePanel: function(){
		//var canvas = document.getElementById('canvasTouch');
		this.canvasTouch.width=0;
		this.canvasTouch.heigth=0;
		this.canvasTouch.style.border = "black 0px solid";
	},
	customButtons: function(){
		var self=this;
		return {'Firma' : function() {
			self.triggerSignAcquired('', self.canvasTouch.toDataURL().split(',')[1]);
		},};
		
		
	},
	loadImage: function(page){
		if (!this.rectangleX) return;
		var allImage = new Image();
		allImage.src =  "data:image/png;base64,"+pages[page-1].imgB64;
		//b64Image=pages[page-1].imgB64;
		
		
		var crop_canvas = document.createElement('canvas');
	    crop_canvas.width = (this.rectangleWidth?this.rectangleWidth:this.maxWidth)*1.5;
	    crop_canvas.height = (this.rectangleHeight?this.rectangleHeight:this.maxHeight)*1.5;
	    var left=0;
	    var top=0;
	    if (this.rectangleX) {
	    	left=this.rectangleX*1.5;
	    	top=this.rectangleY*1.5;
	    }
	    
	    crop_canvas.getContext('2d').drawImage(allImage, left, top, crop_canvas.width, crop_canvas.height, 0, 0, crop_canvas.width, crop_canvas.height);
//	    window.open(crop_canvas.toDataURL());
		var croppedImage = new Image();
		croppedImage.src =  crop_canvas.toDataURL();
		
		 var resize_canvas = document.createElement('canvas');
		 resize_canvas.width = crop_canvas.width*this.ratio/1.5;
		 resize_canvas.height = crop_canvas.height*this.ratio/1.5;
//		    resize_canvas.height = height;
		    resize_canvas.getContext('2d').drawImage(croppedImage, 0, 0, resize_canvas.width, resize_canvas.height);
//		    window.open(resize_canvas.toDataURL());
		    this.canvasTouch.style.backgroundImage="url('"+resize_canvas.toDataURL()+"')"
	},
//	setServerKeyLength:function(length){
//		var self = this;
//		setTimeout(function() {
//			self.selectedApplet.setServerKeyLength(length);
//		}, 0);
//	},
	setSignRectangle:function(x,y,width,height) {
		this.rectangleWidth=width;
		this.rectangleHeight=height;
		this.rectangleX=x;
		this.rectangleY=y;
		this.calculatePanel(this.maxWidth, this.maxHeight, this.rectangleWidth, this.rectangleHeight);
	},
//	setPdfFile:function(base64File){
//		var self = this;
//		setTimeout(function() {
//			try{
//				self.selectedApplet.setPdfFile(base64File);
//			}
//			catch(r) {
//				console.log("exception setPdfFile: "+r);
//			}
//		}, 0);
//	},
//	setEnablePdfJS:function(){
//		var self = this;
//		setTimeout(function() {
//			try{
//				self.selectedApplet.setEnablePdfJS();
//			}
//			catch(r) {
//				console.log("exception setEnablePdfJS: "+r);
//			}
//		}, 0);
//	},
//	removeLastSignature:function(){
//		var self = this;
//		setTimeout(function() {
//			try{
//				self.selectedApplet.removeLastSignature();
//			}
//			catch(r) {
//				console.log("exception removeLastSignature: "+r);
//			}
//		}, 0);
//	},
//	getAllPages:function(){
//		return this.selectedApplet.getAllPages();
//	},
//	getPageB64:function(page){
//		return this.selectedApplet.getPageB64(page);
//	},
//	setPdfBase64Image:function(imageDataString,pdfPointWidth,actualPage,totalPage) {
//		try {
//			this.selectedApplet.setPdfBase64Image(imageDataString,pdfPointWidth,actualPage,totalPage);
//		}
//		catch(r) {
//			console.log("exception setPdfBase64Image: "+r);
//		}
//	},
//	setPdfAndRect:function(imageDataString,pdfPointWidth,actualPage,totalPage,x,y,width,height) {
//		try{
//			this.selectedApplet.setPdfBase64Image(imageDataString,pdfPointWidth,actualPage,totalPage);
//			this.selectedApplet.setSignRectangle(x,y,width,height);
//		}
//		catch(r) {
//			console.log("exception setPdfAndRect: "+r);
//		}
//	},
//	stop:function(){
//		var self = this;
//		setTimeout(function() {
//			try{
//				self.selectedApplet.stop();
//			}
//			catch(r) {
//				console.log("exception stop: "+r);
//			}
//		}, 0);
//	},
//	destroy:function(){
//		var self = this;
//		setTimeout(function() {
//			try{
//				self.selectedApplet.destroy();
//			}
//			catch(r) {
//				console.log("exception destroy: "+r);
//			}
//		}, 0);
//	},
//	setSigTag:function(tag){
//		try{
//			this.selectedApplet.setSigTag(tag);
//		}
//		catch(r) {
//			console.log("exception setSigTag: "+r);
//		}
//	},
//	setEnableDocView:function(enabled){
//		var self = this;
//		setTimeout(function() {		
//			try{
//				self.selectedApplet.setEnableDocView(enabled);
//			}
//			catch(r) {
//				console.log("exception setEnableDocView: "+r);
//			}		
//		}, 0);
//	},
	onPointerMove: function(evt) {
//		pointerLog(evt);
	    if (signingInterface.pointerDown[evt.pointerId]) {

	        var color = colors[evt.pointerId % colors.length];

	        context.strokeStyle = color;

	        context.beginPath();
	        context.lineWidth = 4*evt.pressure*signingInterface.ratio;
	        context.moveTo(signingInterface.lastPositions[evt.pointerId].x, signingInterface.lastPositions[evt.pointerId].y);
	        //context.lineTo(evt.clientX+cumulativeOffset(context.canvas).left, evt.clientY-cumulativeOffset(context.canvas).top);
	        context.lineTo(evt.offsetX, evt.offsetY);
	        context.closePath();
	        context.stroke();

//	        signingInterface.lastPositions[evt.pointerId] = { x: evt.clientX+cumulativeOffset(context.canvas).left, y: evt.clientY -cumulativeOffset(context.canvas).top};
	        signingInterface.lastPositions[evt.pointerId] = { x: evt.offsetX, y: evt.offsetY};
		
	    }
	},
	onPointerUp: function (evt) {
		signingInterface.pointerDown[evt.pointerId] = false;
	},
	onPointerEnter: function (evt) {
		if (evt.pressure>0)
			signingInterface.onPointerDown(evt);
	},
	onPointerLeave: function (evt) {
		signingInterface.onPointerUp(evt);
	},
	onPointerDown: function (evt) {
		signingInterface.pointerDown[evt.pointerId] = true;

		signingInterface.lastPositions[evt.pointerId] = { x: evt.offsetX, y: evt.offsetY };
	    //pointerLog(evt);
	},

//	clearPanel:function(){
//		var self = this;
//		setTimeout(function() {		
//			try{
//				self.selectedApplet.clearPanel();
//			}
//			catch(r) {
//				console.log("exception clearPanel: "+r);
//			}		
//		}, 0);
//	},
//	startCapture:function(showOnly){
//		try{
//			if(showOnly)
//				this.selectedApplet.startCapture(true);
//			else
//				this.selectedApplet.startCapture(false);
//		}
//		catch(r) {
//			console.log("exception start Capture: "+r);
//		}
//	},
	getDeviceInfo:function(){
		return "TOUCH";
	},
//	setBindingData:function(hash, alg, offset, count) {
//		try{
//			this.selectedApplet.setBindingData(hash, alg, offset, count);
//		}
//		catch(r) {
//			console.log('error in setBindingData:'+r);
//		}
//	}
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
	
//
//function initCompleted() {
//	signingInterface.selectedApplet = eval("document."+signingInterface.appletName);
//	signingInterface.triggerInitCompleted();
//}
//
//
//var isCancelSign=false;
//function cancelSign() {
//	if (!isCancelSign)
//		isCancelSign=true;
//}
//
//var __checkCancelSign = setInterval(function(){
//	if (isCancelSign) {
//		isCancelSign=false;
//		signingInterface.triggerCancelSign();
//	}	
//},1000);
//
//
//var isBioChanged=false;
//var __bio="";
//var __image="";
//var __checkBioInterval = setInterval(function(){
//	if (isBioChanged) {
//		isBioChanged=false;
//		signingInterface.triggerSignAcquired(__bio, __image);
//	}
//	
//},1000);
//
//function signAcquired(bio, image) {
//	if (__bio != bio || __image!=image) {
//		__bio=bio;
//		__image=image;
//		isBioChanged=true;
//	}
//}
//
//function log(msg) {
//	//console.log(msg);
//}