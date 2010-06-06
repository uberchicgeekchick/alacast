/*
 * @Class: ElementUtility
 * 
 * @Description: Utility for inspecting properties and removing classes
 * 
 * @Usage: new ElementUtility( Obj )
 * @Methods: withinViewport(), removeClasses( Array )
 * 
 */
	
var ElementUtility = (!detectBrowser.modernBrowser())?function(){}:Class.create();
ElementUtility.prototype = (!detectBrowser.modernBrowser())?{}:{
	
	initialize: function(element)
	{
		this.setElement(element);
	},
	
	setElement: function(element)
	{
		this.el = element;
	},
	
	getElement: function()
	{
		return this.el;
	},
	
	withinViewport: function(element)
	{
		// is element within
		if(element != null)
		{
		 	this.setElement(element);
		}
				
		var elOffset = this.el.cumulativeOffset();
		var vpOffset = document.viewport.getScrollOffsets();
		var elDim = this.el.getDimensions();
		var vpDim = document.viewport.getDimensions();
		
		if ( (elOffset[1] + elDim.height) > vpOffset[1] + vpDim.height || (elOffset[0] + elDim.width) > vpOffset[0] + vpDim.width - 25 )
		{
			return false;
		}
		else
		{
			return true;
		}
		
	},
	
	cumulativeOffsetBorders: function(element) {
		var valueT = 0, valueL = 0;
		do
		{
			valueT += element.offsetTop  || 0;
			valueL += element.offsetLeft || 0;
			
			
			element = element.offsetParent;
			if(element)
			{
				valueT += parseInt(Element.getStyle(element, 'borderTopWidth')) || 0;
				valueL += parseInt(Element.getStyle(element, 'borderLeftWidth')) || 0;
			}
		}
		while (element);
		
		if (Prototype.Browser.IE)
		{
			// why does IE add 2px borders??
			valueT = valueT - 2;
			valueL = valueL - 2;
		}
		
		_returnOffset = function(l, t)
		{
  			var result = [l, t];
			result.left = l;
			result.top = t;
			return result;
		};
		
		return _returnOffset(valueL, valueT);
	}
};


/*
 * @Class: FloatingInfo
 * @Extends: ElementUtility
 * 
 * @Description: abstracted overlay class
 * 
 */

var FloatingInfo = (!detectBrowser.modernBrowser())?function(){}:Class.create();
FloatingInfo.prototype = (!detectBrowser.modernBrowser())?{}:Object.extend( new ElementUtility(), {
	initialize: function(element, parameters)
	{
		// set element
		this.setElement(element);
		
		// set parameters 
		this.content = parameters.contentRender;
		this.positionObj = parameters.positionObject;
		this.floatByType = 'element';	
		this.floatDirection = parameters.floatDirection;
		this.widthClass = parameters.widthClass;
		
		if( typeof(parameters.padding) == "number" )
		{
			this.arrowPadding = parameters.padding;
		}
		else
		{
			this.arrowPadding = 0;
		}
		
		this.setOverlayClasses(parameters.overlayClasses);
		this.setArrowClass(parameters.arrowClass);
		
		if (typeof(parameters.timeOut) == "number")
		{
			this.timeOut = parameters.timeOut;
		}else{
			this.timeOut = 600;
		}
		
		// fetch existing overlay elements
		this.arrow = $('floatArrow');
		this.floatMessage = $('floatMessage');
		

		if(Prototype.Browser.IE)
		{
			this.floatMessageIFrame = $('floatMessageIFrame');
			this.floatMessageIFrame2 = $('floatMessageIFrame2');
		}
		this.floatMessageInner = $('floatMessageInner');
		this.floatMessageTop = $('floatMessageTop');
		this.floatMessageBottom = $('floatMessageBottom');

		// render content
		this.fetchOverlay();
		this.renderContent();
		
		this.cancellogin = $('cancellogin');
		this.closelink = $('closelink');
		//this.mynasa = $('mynasah5');
		// create and set location of float
		if(this.floatDirection == 'auto'){
			
			this.floatRight();
					
			if(ElementUtility.prototype.withinViewport(this.floatMessage)==false){
				this.floatLeft();
			}
			if(ElementUtility.prototype.withinViewport(this.floatMessage)==false){
				this.floatUp();
			}
			if(ElementUtility.prototype.withinViewport(this.floatMessage)==false){
				this.floatDown();
			}
		}else{
			switch(this.floatDirection){
				case 'top':
					this.floatUp();
				break;
				case 'right':
					this.floatRight();
				break;
				case 'bottom':
					this.floatDown();
				break;
				case 'left':
					this.floatLeft();
				break;
				default:
					this.floatRight();
				break;
			}
		}
		
		// hide element on window resize
		Event.observe(window,'resize',function(){
			FloatingInfo.prototype.currentLivingElement = null;
			FloatingInfo.prototype.hideOverlay();
		});

		// track element life
		this.saveLifeFunction();
		
		// delegate mouseout, mouseover events
		this.floatMessage.onmouseover = this.saveLifeFunction.bind(this);
		this.arrow.onmouseover = this.saveLifeFunction.bind(this);

		this.floatMessage.onmouseout = this.endLifeFunction.bind(this);
		this.arrow.onmouseout = this.endLifeFunction.bind(this);
		
		//if($('mynasah5')){
		//	this.mynasa.onmousedown = this.saveLifeFunction.bind(this);
		//	this.arrow.onmousedown = this.saveLifeFunction.bind(this);
		//}
		/*if($('cancellogin')){
			this.cancellogin.onmousedown = this.endLifeFunction.bind(this);
		}
		if($('closelink')){
			this.closelink.onmousedown = this.endLifeFunction.bind(this);
		}*/
		// start observing on our element for a mouseout 
		if(!this.el.hasClassName('observe_click')){
			Event.observe(this.el, 'mouseout', this.floatHandler.bind(this));
		}
		else{
		 if($('cancellogin')){
			Event.observe($('cancellogin'), 'click', function(event) {
				//Event.observe(this.el, 'mousedown', this.mouseDownHandler.bind(this));
				event.preventDefault();
				FloatingInfo.prototype.hideOverlay();
			});
		 }
		 if($('closelink')){
			Event.observe($('closelink'), 'click', function(event) {
//				Event.observe(this.el, 'mousedown', this.mouseDownHandler.bind(this));
				event.preventDefault();
				FloatingInfo.prototype.hideOverlay();
			});
		 }
		}
		if(!this.el.hasClassName('observe_click')){
			Event.observe(this.el, 'blur', this.focusHandler.bind(this));
		}
	
//	auto focusing removed due to incompatibilities with keyboard accessibility code	
//		this.floatMessageInner.focus();			
	},
	
	setOverlayClasses: function(classes)
	{
		if( typeof(classes) == "object" )
		{
			this.topOverlayClass = classes.top;
			this.innerOverlayClass = classes.inner;
			this.bottomOverlayClass = classes.bottom;
		}
	},
	
	setArrowClass: function(myClass)
	{
		this.arrowClass = myClass;
	},
	
	applyClasses: function(direction)
	{		
		
		this.floatMessage.className = "normal_overlay_float";
		if(this.widthClass && this.widthClass != 'null'){
			this.floatMessage.className = this.widthClass + '_float';
		}
		
		if(Prototype.Browser.IE)
		{
			var arrowchild = document.getElementById( 'floatArrow');
			
			if(arrowchild != null)
			{
				document.body.removeChild(arrowchild);
				this.arrow = new Element("div",{'id':'floatArrow'});
				document.body.appendChild(this.arrow);
			}	
		}
		
		// first remove all classes
		this.floatMessageTop.className = '';
		this.floatMessageInner.className = '';
		this.floatMessageBottom.className = '';
		this.arrow.className = '';

		//apply classes
		this.floatMessageTop.addClassName(this.topOverlayClass);
		this.floatMessageInner.addClassName(this.innerOverlayClass);
		this.floatMessageBottom.addClassName(this.bottomOverlayClass );
		this.arrow.addClassName(this.arrowClass + '_' + direction);

	},
	
	fetchOverlay: function()
	{		
		if(!this.floatMessage)
		{
			this.arrow = new Element("div",{'id':'floatArrow'});
			this.floatMessageTop = new Element("div",{'id':'floatMessageTop'});
			this.floatMessageBottom = new Element("div",{'id':'floatMessageBottom'});
			this.floatMessageInner = new Element("div",{'id':'floatMessageInner'});
			this.floatMessage = new Element("div",{'id':'floatMessage'});
			if(Prototype.Browser.IE)
			{
				this.floatMessageIFrame = new Element("iframe",{
					'id':'floatMessageIFrame',
					'src':'javascr'+'ipt:\'<ht'+'ml></ht'+'ml>\''
//					'src':'/blank.html'
				});
				this.floatMessageIFrame.frameBorder=0;
//				this.floatMessageIFrame.allowTransparency="yes";
//				this.floatMessageIFrame.style.cssText = 'background:transparent';
				this.floatMessageIFrame.setStyle({
					'backgroundColor':'#000000',
					'zIndex':9997,
					'position':'absolute'
				});
				this.floatMessageIFrame2 = new Element("iframe",{
					'id':'floatMessageIFrame2',
					'src':'javascr'+'ipt:\'<ht'+'ml></ht'+'ml>\''
//					'src':'/blank.html'
				});
				this.floatMessageIFrame2.frameBorder=0;
//				this.floatMessageIFrame.allowTransparency="yes";
//				this.floatMessageIFrame.style.cssText = 'background:transparent';
				this.floatMessageIFrame2.setStyle({
					'backgroundColor':'#000000',
					'zIndex':9997,
					'position':'absolute'
				});
			}
			
			this.floatMessage.appendChild(this.floatMessageTop);
			this.floatMessage.appendChild(this.floatMessageInner);
			this.floatMessage.appendChild(this.floatMessageBottom);
			document.body.appendChild(this.floatMessage);
			if(Prototype.Browser.IE)
			{
				document.body.appendChild(this.floatMessageIFrame);
				document.body.appendChild(this.floatMessageIFrame2);
			}
			document.body.appendChild(this.arrow);
		}
	},
	
	hideOverlay: function()
	{
		_quickHide = function()
		{
			if(Prototype.Browser.IE)
			{
				var i1 = $('floatMessageIframe');
				var i2 = $('floatMessageIframe2');
				if(i1){
					i1.hide();
				}
				if($('floatMessageIframe2')){
					i2.hide();
				}
			}
			var fm = $('floatMessage');
			var fa = $('floatArrow');
			if(fm){
				fm.hide();
			}
			if(fa){
				fa.hide();
			}
		};
		
		_quickHide();
		/*
		if(Prototype.Browser.IE)
		{
			_quickHide();
		}
		else
		{
			Effect.Fade('floatArrow',{ duration:0.2 });
			Effect.Fade('floatMessage',{ duration:0.2, afterFinish:_quickHide });
		}
		*/
	},
	
	renderContent: function()
	{	
		if( typeof(this.content) == "function" )
		{
			this.content(this.floatMessageInner);
		}
		else if(typeof(this.content) == "string")
		{
			this.floatMessageInner.update(this.content);
		}
	},
	
	overlayPosition: function()
	{	
		// float absolutely 
		if( this.positionObj && this.positionObj.x != null && this.positionObj.y != null && typeof(Number(this.positionObj.x)) == "number" && typeof(Number(this.positionObj.y)) == "number" )
		{
			var posY = this.positionObj.y;
			var posx = this.positionObj.x;
			this.floatByType = 'absolute';
		}
		// float by mouse
		else if( this.positionObj && this.positionObj.event != null )
		{
			Event.observe(document, this.positionObj.event, function(){
				return function (event) {
					var posY = Event.pointerY(event);
					var posX = Event.pointerX(event);
				};
			}, false);

			this.floatByType = 'mouse';
		}
		// float by element
		else
		{
			var posArr = ElementUtility.prototype.cumulativeOffsetBorders(this.el);
			var posY = posArr[1];
			var posX = posArr[0];
			this.floatByType = 'element';
		}
		
		var position = {"x": posX, "y": posY};
			
		return position;
	},
	
	getDimensions: function(){
		
		// get dimensions by style properties to offset issues with getHeight() and getWidth
		var valueElementH = parseInt(Element.getStyle(this.el, 'height')) || 0;
		var valueElementW = parseInt(Element.getStyle(this.el, 'width')) || 0;
		var valueArrowH = parseInt(Element.getStyle(this.arrow, 'height')) || 0;
		var valueArrowW = parseInt(Element.getStyle(this.arrow, 'width')) || 0;
		var valueFloatH = parseInt(Element.getStyle(this.floatMessage, 'height')) || 0;
		var valueFloatW = parseInt(Element.getStyle(this.floatMessage, 'width')) || 0;
		
		var dimensions = {
			"element": { "h":valueElementH, "w":valueElementW },
			"arrow": { "h":valueArrowH, "w":valueArrowW },			
			"floatMessage": { "h":valueFloatH, "w":valueFloatW }	
		};
		
		return dimensions;
	},
	
	saveLifeFunction: function()
	{
		FloatingInfo.prototype.currentLivingElement = this.el;
	},
	
	endLifeFunction: function()
	{
		FloatingInfo.prototype.currentLivingElement = null;	
	},
    
	focusHandler: function(privateElement){
		Event.stopObserving(this.el, "blur", this.focusHandler);
		this.hideOverlay();
	},

	mouseDownHandler: function(privateElement){
		Event.stopObserving(this.el, "mousedown", this.mouseDownHandler);
		this.hideOverlay();
	},

	floatHandler: function(privateElement)
	{		

		// instantiate safariHover class to handle inner elements 
		new safariHover('out',this.el, privateElement, function()
		{
			// ignore child elements in this handler
			if(privateElement.target==this.el || privateElement.target==this.el.firstChild)
			{
				FloatingInfo.prototype.previousLivingElement = this.el;
				this.endLifeFunction();
				
				// create timers hash if we don't yet have one.
				if( typeof(FloatingInfo.prototype.timers)=='undefined' )
				{
					FloatingInfo.prototype.timers = {};
				}
				// clean up previous timer for a given element
				if(FloatingInfo.prototype.timers[this.el])
				{
					clearInterval(FloatingInfo.prototype.timers[this.el]);
				}
				
				// create a new interval timer for a given element
				FloatingInfo.prototype.timers[this.el] = setInterval(function()
				{
					if(!$('floatMessage')) {
						// if the float message is gone, shut the timer down.
						clearInterval(FloatingInfo.prototype.timers[this.el]);
					}
					else
					{	
						if(FloatingInfo.prototype.currentLivingElement == null)
						{
							if($('floatMessage'))
							{
								this.hideOverlay();
							}
							clearInterval(FloatingInfo.prototype.timers[this.el]);
							Event.stopObserving(this.el, "mouseout", this.floatHandler);
						}
						else
						{
							// life was saved
						}
					}
				}.bind(this),this.timeOut);
				Event.stop(privateElement);
			}
		}.bind(this));
	},

	floatRight: function()
	{
		// get x,y co-ordinates
		var position = this.overlayPosition();
		
		// set classes
		this.applyClasses('left');
		
		// get dimensions of all elements
		var dimensions = this.getDimensions();
		
		if(this.floatByType == 'element')
		{
			var floatY = position.y - ( ( this.floatMessage.getHeight() - dimensions.element.h  ) / 2);
			var floatX = position.x + this.arrowPadding + this.arrow.getWidth() + dimensions.element.w;
			var arrowY = position.y - (( this.arrow.getHeight() - dimensions.element.h  ) / 2);
			var arrowX = position.x + this.arrowPadding + dimensions.element.w;
		}
		else
		{
			var floatY = position.y - ( this.floatMessage.getHeight() / 2 );
			var floatX = position.x - this.arrowPadding - dimensions.arrow.w;
			var arrowY = position.y - ( dimensions.arrow.h / 2 );
			var arrowX = position.x - this.arrowPadding;	
		}
			
		this.arrow.setStyle({	
			top: arrowY + 'px',
			left: arrowX + 'px',
			opacity: 1.0
		});
		
		this.floatMessage.setStyle({
			top: floatY + 'px',
			left: floatX + 'px',
			opacity: 1.0,
			visibility: 'visible'
		});
		if(Prototype.Browser.IE)
		{
			this.floatMessageIFrame.setStyle({
				top:(parseInt(this.floatMessage.getStyle('top'))+3)+'px',
				left:this.floatMessage.getStyle('left'),
				width:(this.floatMessage.getWidth()-2)+'px',
				height:(this.floatMessage.getHeight()-6)+'px',
				opacity:1.0,
				visibility:'visible'
			});
			$('floatMessageIFrame').show();
			this.floatMessageIFrame2.setStyle({
				top:this.floatMessage.getStyle('top'),
				left:(parseInt(this.floatMessage.getStyle('left'))+3)+'px',
				width:(this.floatMessage.getWidth()-6)+'px',
				height:this.floatMessage.getHeight()+'px',
				opacity:1.0,
				visibility:'visible'
			});
			$('floatMessageIFrame2').show();
		}
		$('floatMessage').show();
		$('floatArrow').show();
	},
	
	floatLeft: function()
	{
		// get x,y co-ordinates
		var position = this.overlayPosition();
		
		// set classes
		this.applyClasses('right');
		
		// get dimensions of all elements
		var dimensions = this.getDimensions();
		
		if(this.floatByType == 'element')
		{
			var floatY = position.y - ( ( this.floatMessage.getHeight() - dimensions.element.h  ) / 2);
			var floatX = position.x - this.arrowPadding - this.arrow.getWidth() - this.floatMessage.getWidth();
			var arrowY = position.y - (( this.arrow.getHeight() - dimensions.element.h  ) / 2);
			var arrowX = position.x - this.arrowPadding - this.arrow.getWidth();
		}
		else
		{
			var floatY = position.y - ( this.floatMessage.getHeight() / 2 );
			var floatX = position.x - this.arrowPadding - dimensions.arrow.w;
			var arrowY = position.y - ( dimensions.arrow.h / 2 );
			var arrowX = position.x - this.arrowPadding;	
		}
			
		this.arrow.setStyle({	
			top: arrowY + 'px',
			left: arrowX + 'px',
			opacity: 1.0
		});
		
		this.floatMessage.setStyle({
			top: floatY + 'px',
			left: floatX + 'px',
			opacity: 1.0,
			visibility: 'visible'
		});
		if(Prototype.Browser.IE)
		{
			this.floatMessageIFrame.setStyle({
				top:(parseInt(this.floatMessage.getStyle('top'))+3)+'px',
				left:this.floatMessage.getStyle('left'),
				width:(this.floatMessage.getWidth()-2)+'px',
				height:(this.floatMessage.getHeight()-6)+'px',
				opacity:1.0,
				visibility:'visible'
			});
			$('floatMessageIFrame').show();
			this.floatMessageIFrame2.setStyle({
				top:this.floatMessage.getStyle('top'),
				left:(parseInt(this.floatMessage.getStyle('left'))+3)+'px',
				width:(this.floatMessage.getWidth()-6)+'px',
				height:this.floatMessage.getHeight()+'px',
				opacity:1.0,
				visibility:'visible'
			});
			$('floatMessageIFrame2').show();
		}
		$('floatMessage').show();
		$('floatArrow').show();
	},

	floatUp: function()
	{
		// get x,y co-ordinates
		var position = this.overlayPosition();
		
		// set classes
		this.applyClasses('down');
		
		// get dimensions of all elements
		var dimensions = this.getDimensions();
		
		if(this.floatByType == 'element')
		{
			var floatY = position.y - this.arrowPadding - this.floatMessage.getHeight() - dimensions.arrow.h;
			var floatX = position.x - (( this.floatMessage.getWidth() - this.el.getWidth()  ) / 2);
			var arrowY = position.y - this.arrowPadding - dimensions.arrow.h;
			var arrowX = position.x - ( ( this.arrow.getWidth() / 2 ) - ( this.el.getWidth() / 2 ) );

		}
		else
		{
			var floatY = position.y + this.arrowPadding + this.floatMessage.getHeight();
			var floatX = position.x - ( this.floatMessage.getWidth() / 2 );
			var arrowY = position.y + this.arrowPadding;
			var arrowX = position.x - ( dimensions.arrow.w / 2 );	
		}

		this.arrow.setStyle({	
			top: arrowY + 'px',
			left: arrowX + 'px',
			opacity: 1.0
		});
		
		this.floatMessage.setStyle({
			top: floatY + 'px',
			left: floatX + 'px',
			opacity: 1.0,
			visibility: 'visible'
		});
		if(Prototype.Browser.IE)
		{
			this.floatMessageIFrame.setStyle({
				top:(parseInt(this.floatMessage.getStyle('top'))+3)+'px',
				left:this.floatMessage.getStyle('left'),
				width:(this.floatMessage.getWidth()-2)+'px',
				height:(this.floatMessage.getHeight()-6)+'px',
				opacity:1.0,
				visibility:'visible'
			});
			$('floatMessageIFrame').show();
			this.floatMessageIFrame2.setStyle({
				top:this.floatMessage.getStyle('top'),
				left:(parseInt(this.floatMessage.getStyle('left'))+3)+'px',
				width:(this.floatMessage.getWidth()-6)+'px',
				height:this.floatMessage.getHeight()+'px',
				opacity:1.0,
				visibility:'visible'
			});
			$('floatMessageIFrame2').show();
		}
		$('floatMessage').show();
		$('floatArrow').show();
	},
	
	floatDown: function()
	{
		// get x,y co-ordinates
		var position = this.overlayPosition();
		
		// set classes
		this.applyClasses('up');
		
		// get dimensions of all elements
		var dimensions = this.getDimensions();
		
		if(this.floatByType == 'element')
		{
			var floatY = position.y + this.arrowPadding + this.arrow.getHeight() + this.el.getHeight();
			var floatX = position.x - (( this.floatMessage.getWidth() - this.el.getWidth()  ) / 2);
			var arrowY = position.y + this.arrowPadding + this.el.getHeight();
			var arrowX = position.x - ( ( this.arrow.getWidth() / 2 ) - ( this.el.getWidth() / 2 ) );

		}
		else
		{
			var floatY = position.y + this.arrowPadding + dimensions.arrow.h;
			var floatX = position.x - ( this.floatMessage.getWidth() / 2 );
			var arrowY = position.y + this.arrowPadding;
			var arrowX = position.x - ( dimensions.arrow.w / 2 );	
		}
		
		this.arrow.setStyle({	
			top: arrowY + 'px',
			left: arrowX + 'px',
			opacity: 1.0
		});	
			
		this.floatMessage.setStyle({
			top: floatY + 'px',
			left: floatX + 'px',
			opacity: 1.0,
			visibility: 'visible'
		});
		if(Prototype.Browser.IE)
		{
			this.floatMessageIFrame.setStyle({
				top:(parseInt(this.floatMessage.getStyle('top'))+3)+'px',
				left:this.floatMessage.getStyle('left'),
				width:(this.floatMessage.getWidth()-2)+'px',
				height:(this.floatMessage.getHeight()-6)+'px',
				opacity:1.0,
				visibility:'visible'
			});
			$('floatMessageIFrame').show();
			this.floatMessageIFrame2.setStyle({
				top:this.floatMessage.getStyle('top'),
				left:(parseInt(this.floatMessage.getStyle('left'))+3)+'px',
				width:(this.floatMessage.getWidth()-6)+'px',
				height:this.floatMessage.getHeight()+'px',
				opacity:1.0,
				visibility:'visible'
			});
			$('floatMessageIFrame2').show();
		}
		$('floatMessage').show();
		$('floatArrow').show();
	}
});
// end class

/*
 * @Class: safariHover
 * 
 * @Description: class to handle safari 2 issue with inner element
 * 
 */
var safariHover = (!detectBrowser.modernBrowser())?function(){}:Class.create();
safariHover.prototype = (!detectBrowser.modernBrowser())?{}:{
	
	initialize: function(hoverState, hoverElement, hoverEvent, callBack)
	{
		this.callBack = callBack;
		if(Prototype.Browser.WebKit && hoverElement.tagName.toLowerCase() != 'td' && detectBrowser.whichVersion() == '2')
			{
			if(hoverState == 'over')
			{
				var IsItIn = Position.within(hoverElement, Event.pointerX(hoverEvent), Event.pointerY(hoverEvent));
				
				if(IsItIn && !hoverElement.ItIsIn)
				{
					hoverElement.ItIsIn = true;
					
					if(typeof(this.callBack)=='function')
					{
						this.callBack();
					}
				}
			}
			
			if(hoverState == 'out')
			{
				var IsItIn = Position.within(hoverElement, Event.pointerX(hoverEvent), Event.pointerY(hoverEvent));
				
				if(!IsItIn && hoverElement.ItIsIn)
				{
					hoverElement.ItIsIn = false;
					
					if(typeof(this.callBack)=='function')
					{
						this.callBack();
					}
				}
			}
		} else {

			if(typeof(this.callBack)=='function')
			{
				this.callBack();
			}
		}
	}
};