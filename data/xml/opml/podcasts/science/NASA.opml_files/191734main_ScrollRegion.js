if(detectBrowser.modernBrowser()){



/*
 * @Class: ScrollFactory
 * 
 * @Description: A class that when instantiated will seek out any elements which have a classname containing "scrollbarize" and add scroll bars to those elements
 * 
 * @Usage: new ScrollFactory()
 * 
 */

var ScrollFactory=Class.create();
ScrollFactory.prototype={
	initialize:function(){
		if (ScrollFactory.prototype.runOnce!=true) {
			this.scrollers=$$('.scrollbarize').map(function(scrollableElement){
				return new ScrollRegion(scrollableElement);
			});
			ScrollFactory.prototype.runOnce=true;
		}
	}	
};


/*
 * @Class: ScrollRegion
 * 
 * @Description: A scrollbar class which applies a scrollbar to a given element, with the option of turning off the default scrollbar handle
 * 
 * @Usage: new ScrollRegion(scrollableElement,noScrollHandle)
 * 
 */

var ScrollRegion=Class.create();
ScrollRegion.prototype={
	initialize:function(scrollableElement,noScrollHandle){

		this.downFlag=false;
		this.upFlag=false;

		var currentFrameScroll=0;
		var scrollableElementIframe;
		this.scrollableElement=scrollableElement;
		
		try
		{
		if(this.scrollableElement.immediateDescendants()[0]) {
			if(this.scrollableElement.immediateDescendants()[0].tagName == 'IFRAME') {
				scrollableElementIframe=this.scrollableElement.immediateDescendants()[0];
			}
		}
		}
		catch(err)
		{}
		
		this.btnUp=this.scrollableElement.appendChild(new Element("div",{'className':'track_up','id':'track_up'}));
		this.scrollBody=this.scrollableElement.appendChild(new Element("div",{'className':'track'}));
		this.btnDown=this.scrollableElement.appendChild(new Element("div",{'className':'track_down','id':'track_down'}));

		if(!scrollableElementIframe && noScrollHandle!=true){
			this.scrollBody.setStyle({'overflow':'hidden'});
			var scrollHandle=new Element("div",{
				'className':'track_handle'
			});
			scrollHandle.setStyle({
				'height':'28px'/*,
				'backgroundColor':'#eee'*/
			});

			this.scrollHandle=scrollHandle;
			this.scrollBody.insert(scrollHandle);
			scrollHandle=$(this.scrollBody.firstChild);

			var dragger=new Draggable(scrollHandle,{
				'constraint':'vertical',
				'snap':function(x,y){					
					var sinMotion=false;
					if(window['sinMotion']==true){
						sinMotion=true;
					}
					if(sinMotion){
						dragger.options.constraint=null;
						x=Math.round(Math.sin(y/32) * 16);
					}

					var scrollbarheight=this.scrollBody.getHeight();
					var scrollhandleheight=scrollHandle.getHeight();
					var totalheight=(scrollbarheight - scrollhandleheight);
					
					if(this.scrollableElement.scrollHeight <= this.scrollableElement.getHeight()){
						this.resetScroll();
						return [x,0];
					}
					var result;
					if(y < 0){
						result=[x,0];
					} else if(y > totalheight) {
						result=[x,totalheight];
					} else {
						result=[x,y];
					}
					var ratio=Math.max(0, Math.min(1, y / totalheight));
					doScroll(null,ratio);
					return result;
				}.bind(this)
			});
		}
		
		var moveScrollHandle=function(newRatio){
			if(newRatio>1.0){
				newRatio=1.0;
			}
			var scrollbarheight=this.scrollBody.getHeight();
			var scrollhandleheight=scrollHandle.getHeight();
			var totalheight=(scrollbarheight - scrollhandleheight);		
			if(scrollHandle){
				scrollHandle.setStyle({'top':(totalheight*newRatio)+'px'});
			}
		}.bind(this);
		
		var doScroll=function(by,toRatio){
			var scrollbarheight=this.scrollBody.getHeight();
			var scrollhandleheight=scrollHandle.getHeight();
			var totalheight=(scrollbarheight - scrollhandleheight);
			
	  	if(!scrollableElementIframe) {
				if(typeof(toRatio)=='number'){
					// moving with scroll handle
					this.scrollableElement.scrollTop=(this.scrollableElement.scrollHeight - this.scrollableElement.getHeight()) * toRatio;
				} else {
					// moving with buttons
	  			this.scrollableElement.scrollTop=this.scrollableElement.scrollTop + by;
					if(noScrollHandle!=true){
						moveScrollHandle(this.scrollableElement.scrollTop / (this.scrollableElement.scrollHeight - this.scrollableElement.getHeight()));
					}
				}
			} else {
				// an iframe can only be scrolled with up/down buttons
				window.frames[scrollableElementIframe.id].scrollBy(0, by);
			}			
		}.bind(this);

		Event.observe(this.btnDown,'mousedown',function(ev){
			this.downFlag=true;
			var timer=setInterval(function(){
			  if(this.downFlag == false){
			   // stop this function from running 100ms from now
			   clearInterval(timer);
			   this.downFlag=null;
			  } else if(this.downFlag == true) {
					doScroll(12);
			  }
			}.bind(this),25);
			ev.stop();
		}.bind(this));
		Event.observe(this.btnDown,'mouseup',function(ev){
			this.downFlag=false;
			ev.stop();
		}.bind(this));

		Event.observe(this.btnUp,'mousedown',function(ev){
			this.upFlag=true;
			var timer=setInterval(function(){
			  if(this.upFlag == false){
			   // stop this function from running 100ms from now
			   clearInterval(timer);
			   this.upFlag=null;
			  } else if(this.upFlag == true) {
					doScroll(-12);
			  }
			}.bind(this),25);
			ev.stop();
		}.bind(this));
		Event.observe(this.btnUp,'mouseup',function(ev){
			this.upFlag=false;
			ev.stop();
		}.bind(this));
		
		[this.btnUp,this.btnDown].each(function(elm){
			Event.observe(elm,'mouseover',function(ev){
				elm.addClassName('scrollHover');
				ev.stop();
			}.bind(this));
			Event.observe(elm,'mouseout',function(ev){
				elm.removeClassName('scrollHover');
				ev.stop();
			}.bind(this));		
		});
		
		this.resetScroll();
	},
	
	// Reset some of the scrollbar's attributes by re-measuring the scrollable element and 
	// determining whether it needs to have a scrollbar anymore. Also, place the handle in 
	// the correct spot if the height of the scrollable region has changed.
	resetScroll:function(){
	    try{
		//alert("this.scrollableElement.scrollHeight:"+this.scrollableElement.scrollHeight);
		//alert("this.scrollableElement.getHeight():"+this.scrollableElement.getHeight());
		if(this.scrollableElement.scrollHeight <= this.scrollableElement.getHeight()){
		    //alert("hide");
			this.scrollableElement.addClassName("scrollbar_hidden");
			this.btnUp.hide();
			this.scrollBody.hide();
			this.btnDown.hide();
		} else {
		    //alert("show");
			this.scrollableElement.removeClassName("scrollbar_hidden");
			this.btnUp.show();
			this.scrollBody.show();
			this.btnDown.show();			
		}
		if(this.scrollHandle!=null && typeof(this.scrollHandle)=='object'){
			this.scrollableElement.scrollTop=0;
			this.scrollHandle.setStyle({'top':'0px'});
		}}
		catch(err)
		{}
	}
};




}
