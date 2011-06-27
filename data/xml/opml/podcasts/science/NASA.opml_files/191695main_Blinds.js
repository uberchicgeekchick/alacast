/*
 * @Class: Blinds
 * 
 * @Description: A class which can turn a set of elements into overlapping 'blinds' which open and close with animation
 * 
 * @Usage: 
 *	
 *	var s3=new Blinds(collection contentElements,element containerElement, capElement, options hash);
 *
 *	<div id="" class="blinds 89 auto click closeable closed">
 *
 *		blinds - makes the div contents into blinds
 *		89        - height of content by default (omitting this parameter makes the blinds 
 *		            automatically-sized by content height of each blind. to avoid this, make 
 *		            sure to explicitly specify the height in case you want statically-sized heights)
 *		auto      - make height automatically detected
 *		click     - make blinds click-activated instead of mouseover-activated
 *		closeable - make blinds able to close
 *		closed    - make all the sections of the blinds closed initially
 *
 *	options hash details:
 *
 *	{
 *     'current_id':'test123',                 the DOM id of the link or heading which is the "current" item
 *     'current_item_class':'someclassname'    the CSS classname to apply to an element which is "current"
 *	}
 *
 * @Methods: no public methods
 * 
 */

var Blinds=(!detectBrowser.modernBrowser())?function(){}:Class.create();
Blinds.prototype=(!detectBrowser.modernBrowser())?{}:{	
	initialize: function(elements,containerElement,capElement,options,id){ //extra id  param
		if(!elements){
			return false;
		}
		if(!containerElement){
			return false;
		}
		this.contentHeight=80;
		var classNames=$A(containerElement.classNames());

		this.containerElement=containerElement;		
		// Some elements look bizarre during initial load until javascript gets to them.
		// For those elements, we apply a class called "prejs" so that once the code is 
		// running it can remove that CSS class. This way, a "pre-rendered" state can be
		// seen by the user while the Javascript is still loading, and unsettled layout 
		// can be avoided.
		if(this.containerElement.className.indexOf("prejs_")>-1){
			for(var i=0;i<classNames.length;i++){
				if(classNames[i].indexOf("prejs_")>-1){
					this.containerElement.removeClassName(classNames[i]);
				}
			}
		}

		this.contentHeight=parseInt(classNames.find(function(cname){ return parseInt(cname)>0; }));
		this.eventType=(classNames.include("click")?"click":"mouseover");
		this.autoHeight=classNames.include("auto") || (typeof(this.contentHeight)!='number');
		this.isAnimating=false;
		this.nextEffect=null;
		this.initiallyClosed=classNames.include("closed");
		this.closeable=this.initiallyClosed || classNames.include("closeable");
		if(options!=null && typeof(options)=='object' && typeof(options['current_id'])=='string' && options['current_id'].strip()!=""){
			var currentItemClass="current_item";
			if(typeof(options['current_item_class'])=='string'){
				options['current_item_class']=currentItemClass;
			}
			var currentItem=$(options['current_id'].strip());
			if(currentItem){
				currentItem.addClassName(currentItemClass);
				// climb up to .content
				// prev() yields header
				// give header current style too
			
				// if this is NOT the content node, we have to climb up to it
				if(currentItem.hasClassName("content")!=true){
					var p=currentItem;
					var done=false;
					while(!done && p!=document.body){
						p=p.up();
						if(p.hasClassName("content")){
							p.addClassName(currentItemClass);
							this.contentElementToOpen=p;
							if(p.previous()){
								p.previous().addClassName(currentItemClass);
							}
							done=true;
						}
					}
				} else {
					this.contentElementToOpen=currentItem;
				}
			}
		
		}
		if(this.contentElementToOpen){
			this.previousElement=this.contentElementToOpen;
		} else {
			this.previousElement=elements[0];
		}
		this.elements=elements;
		this.capElement=capElement;
		this.currentlyHoveredElement=-1;	 // index of currently hovered element. Used to track if we have "committed" to hovering over a blind
		this.measuredSizes=[];
		this.transition=(classNames.include("click")?Effect.Transitions.EaseTo:Effect.Transitions.EaseFromTo);
		this.makeSliders();
		// id check
		if (id != null) {
			this.activateBlind (id);
		}
	},
	
	/*eTouch - Parag*/
	activateBlind: function (id) {
		var element=null;
		var tokens=id.split ('_');
		this.elements.each (function(item){
			if (item.getAttribute ("blindsindex") == $(tokens[0]).parentNode.parentNode.getAttribute ("blindsindex")) {
				element=item;
			}
		})
		if (element != null) {
			var func=this.makeSlideFunc (this.elements, element, 
					$(id).parentNode.parentNode.getAttribute ("blindsindex"));
			func ();
		}
		$(id).setStyle ('font-weight: bold');
	}, 
	 /*eTouch -Parag*/

	// iterate through the content blocks and make assign event listeners which trigger the sliding animation
	makeSliders: function(elements){
		this.elements.each(function(item,i){
			item=$(item);

			item.setAttribute("blindsindex",i);
			if(this.contentElementToOpen){
				if(this.contentElementToOpen==item){
					// found the "current" item
					item.setAttribute("blindstatus","open");
				} else {
					item.setAttribute("blindstatus","closed");
				}
			} else {				
				/* this is added,not to open the first item of left nav if nothing is opened. */
				//item.setAttribute("blindstatus",((i==0)?((this.initiallyClosed==true)?"closed":"open"):("closed")));
					if(this.eventType == 'click') {
						item.setAttribute("blindstatus","closed");
					} else {
						item.setAttribute("blindstatus",((i==0)?((this.initiallyClosed==true)?"closed":"open"):("closed")));
					}
               /* End of changes for,not to open the first item of left nav if nothing is opened. */
			}


			// if a particular element is to be opened because it's "current", we make it open
			// and make all others closed
			if(this.contentElementToOpen){
				if(this.contentElementToOpen==item && this.initiallyClosed==false){
					item.previous().addClassName('active_header');
					item.addClassName('active_content');
					item.next().addClassName('active_footer');					
				} else {
					item.previous().addClassName('inactive_header');
					item.addClassName('inactive_content');
					item.next().addClassName('inactive_footer');					
				}
			} else {
				// If no particular element is to be open, set the 0th element as open (unless initiallyClosed is true)
				if(i==0 && this.initiallyClosed==false) {
				
					/* this is added,not to open the first item of left nav if nothing is opened. */
					if(this.eventType == 'click') {
						item.previous().addClassName('inactive_header');
						item.addClassName('inactive_content');
						item.next().addClassName('inactive_footer');
					} else {
						item.previous().addClassName('active_header');
						item.addClassName('active_content');
						item.next().addClassName('active_footer');
					}
					/* End of changes for,not to open the first item of left nav if nothing is opened. */

				} else {
					item.previous().addClassName('inactive_header');
					item.addClassName('inactive_content');
					item.next().addClassName('inactive_footer');
				}
			}

			// measure size of the content area
			if(this.autoHeight) {
				this.measuredSizes[i]=item.getHeight();
			}

			if(this.initiallyClosed==true){
				item.setStyle({'height':'0px'});
			} else {
				if(this.contentElementToOpen){
					if(this.contentElementToOpen==item){
						item.setStyle({'height':(this.autoHeight?this.measuredSizes[i]:this.contentHeight)+'px'});
					} else {
						item.setStyle({'height':'0px'});						
					}
				} else {
					//item.setStyle({'height':((i==0)?(this.autoHeight?this.measuredSizes[i]:this.contentHeight):(0))+'px'});
					/* this is added,not to open the first item of left nav if nothing is opened. */
					if(this.eventType == 'click') {
						item.setStyle({'height':'0px'});		
					} else {
						item.setStyle({'height':((i==0)?(this.autoHeight?this.measuredSizes[i]:this.contentHeight):(0))+'px'});
					}
					/* End of changes for,not to open the first item of left nav if nothing is opened. */
				}
			}

			// slightly different classes get applied to the last item in the blinds so they can be styled as a cap or base.
			if(i==this.elements.length - 1){
				item.previous().addClassName('last_header');
				item.addClassName("last_content");
				item.next().addClassName('last_footer');
			}
			item.previous().isHeader=true;
			item.isContent=true;
			// observe the header, content, and footer of each blind panel with mouse events (click or hover depending on config)
			[item.previous(),item,item.next()].each(function(subItem){
				var slideFunc=this.makeSlideFunc(this.elements,item,i);
				
				// 	Allow the keyboard focus to actually activate this blind section
				subItem.getElementsBySelector("a").each(function(focusableItem){
					if(focusableItem.hasClassName('deadmouse')){
						// we require some placeholder / dummy links that don't go anywhere
						// kill all links that have class "deadmouse"
						
						// both of these events fire when a click happens so we don't want the side to happen twice
						var focusHasFired=false;
						Event.observe(focusableItem,'click',function(ev){
							if(focusHasFired){
								focusHasFired=false;
							} else {
								slideFunc();
							}
							ev.stop();
							focusHasFired=false;
							return false;
						}.bind(this));
						Event.observe(focusableItem,'focus',function(ev){
							focusHasFired=true;
							slideFunc();
							ev.stop();
							return false;
						}.bind(this));
					} else {
						if(subItem.isHeader==true){
							// all links inside of headers can be focus-triggers-open
							Event.observe(focusableItem,'focus',slideFunc);
						} else if (subItem.isContent==true){
							// for content we have to proxy slideFunc through a check to see if 
							// the item is currently open before triggering slideFunc
							Event.observe(focusableItem,'focus',function(){
								if(subItem.getAttribute("blindstatus")!="open"){
									// if this item is already opening, we need to tell slideFunc not to queue this attempt to
									// open after the current open. Thus, we pass in the current item plus a flag to tell it
									// to check that we aren't trying to double-open a given content area
									if(this.isAnimating!=true){
										slideFunc(true,subItem);
									}
								}
							}.bind(this));
						}
					}
				}.bind(this));
				
				if(subItem) {
					Event.observe(subItem,this.eventType,slideFunc);
				}
				if(subItem && this.eventType=='mouseover') {
					Event.observe(subItem,'mouseout',this.makeMouseOutFunc(this.elements,item,i));
				}
			}.bind(this));
		
			Event.observe(item.previous(),"mouseover",function(){item.previous().addClassName('header_hover')});
			Event.observe(item.previous(),"mouseout",function(){item.previous().removeClassName('header_hover')});
		}.bind(this));
		this.setCapClasses(this.elements[0]);
		this.setFooterBlendingClasses(this.elements[0]);
	},

	// check for a queued effect. If one is present cancel the current one and start the new one
	checkForNextEffect: function(effect){
		this.isAnimating=false;
		if(typeof(this.nextEffect)=='function'){
			var f=this.nextEffect;
			this.nextEffect=null;
			f();
		}
	},

	// if there is a cap (element immediately above the top header), style it according to whether the header is active 
	setCapClasses: function(currentElement){		
		if(this.capElement) {
			// is the capping element active ?
			if(parseInt(currentElement.getAttribute("blindsindex"))==0){
				this.capElement.removeClassName("cap_inactive");
				this.capElement.addClassName("cap_active");
			} else {
				this.capElement.removeClassName("cap_active");
				this.capElement.addClassName("cap_inactive");								
			}
		}
	},

	// a footer can either be above an inactive header, or above an active header, or not above any header at all. 
	// Append appropriate CSS classes
	setFooterBlendingClasses: function(currentElement,activeIndex){
		if(typeof(activeIndex)!='number') activeIndex=parseInt(currentElement.getAttribute("blindsindex"));
		for(var i=0;i<this.elements.length;i++){
			if(i==activeIndex - 1){
				this.elements[i].next().removeClassName("above_inactive");
				this.elements[i].next().addClassName("above_active");
			} else {
				if(i!=this.elements.length - 1){
					this.elements[i].next().removeClassName("above_active");
					this.elements[i].next().addClassName("above_inactive");
				}
			}
		}
	},

	makeMouseOutFunc:function(elements,currentElement,i){
		return function(){
			if(this.currentlyHoveredElement==i){ // clear commitment to this hover
				this.currentlyHoveredElement=-1;
			}
		}.bind(this);
	},

	// return a function that makes element, the i'th element, slide to its open location. All other 
	// elements should slide to their locations too
	makeSlideFunc: function(elements, currentElement, i){
		var newEffect=function(dontQueueIfAnimating, dontQueueElementObject){
			// drop self into basket. This slide gets queued up to be the next slide to happen (unless another one comes along)
			if(this.isAnimating==true){
				// this effect can be called with a flag that indicates not to queue after the current transition is finished,
				// but rather just let this attempt go ignored. This is used for keyboard focus control for links inside of the 
				// content region of the blind
				if(dontQueueIfAnimating!=true){
					this.nextEffect=newEffect;
				} else {
					if(dontQueueElementObject!=currentElement){
						this.nextEffect=newEffect;
					}
				}
				return;
			}
			this.currentlyHoveredElement=i;
			// if closing elements is not permitted and the to-slide element matches 
			// the previously-slid element, don't allow a close
			if(this.closeable!=true && this.previousElement==currentElement) {
				return;
			}
			setTimeout(function(){
				if(this.currentlyHoveredElement==i){
				
					var swapBlindStyles=function(){
						// apply active + inactive classes
					
						// if previous==current, that means the to-be-slid element matches the previously-slid element
						if(this.previousElement==currentElement){
							if(currentElement.getAttribute("blindstatus")=="closed"){
								// currently closed - going to be open
								currentElement.previous().removeClassName('inactive_header');
								currentElement.removeClassName('inactive_content');
								currentElement.next().removeClassName('inactive_footer');
								this.setCapClasses(currentElement);
								this.setFooterBlendingClasses(currentElement);
								currentElement.previous().addClassName('active_header');
								currentElement.addClassName('active_content');
								currentElement.next().addClassName('active_footer');
							} else {
								// currently open - going to be closed
								currentElement.previous().addClassName('inactive_header');
								currentElement.addClassName('inactive_content');
								currentElement.next().addClassName('inactive_footer');
								currentElement.previous().removeClassName('active_header');
								currentElement.removeClassName('active_content');
								currentElement.next().removeClassName('active_footer');
							}
						} else {
							// Normal slide - some element needs to be open, some *other* element needs to be closed.
							this.previousElement.previous().addClassName('inactive_header');
							this.previousElement.addClassName('inactive_content');
							this.previousElement.next().addClassName('inactive_footer');
							currentElement.previous().addClassName('active_header');
							currentElement.addClassName('active_content');
							currentElement.next().addClassName('active_footer');
							// remove active + inactive classes
							this.previousElement.previous().removeClassName('active_header');
							this.previousElement.removeClassName('active_content');
							this.previousElement.next().removeClassName('active_footer');
							currentElement.previous().removeClassName('inactive_header');
							currentElement.removeClassName('inactive_content');
							currentElement.next().removeClassName('inactive_footer');
							this.setCapClasses(currentElement);
							this.setFooterBlendingClasses(currentElement);
						}
					}.bind(this);

					// The target height for the content region is either the automatically-measured height or 
					// a strictly-defined height in the CSS class of the blinds
					var targetHeight=(this.autoHeight?this.measuredSizes[i]:this.contentHeight)+'px';
					var fx;
					if(this.previousElement==currentElement && this.closeable==true){
						// next element is also current
						if(currentElement.getAttribute("blindstatus")=="closed"){
							// open it
							fx=[new Effect.RoundedMorph(currentElement,{style:{'height':targetHeight},sync:true,transition:this.transition})];
						} else {
							// close it
							fx=[new Effect.RoundedMorph(currentElement,{style:{'height':'0px'},sync:true,transition:this.transition})];
						}
					} else {
						fx=[
							new Effect.RoundedMorph(currentElement,{style:{'height':targetHeight},sync:true,transition:this.transition}),
							new Effect.RoundedMorph(this.previousElement,{style:{'height':'0px'},sync:true,transition:this.transition})
						];
					}
				
					//
					// Note:
					// if closed , remove hide_blind before opening
					// if open, add hide_blind after closing
					//
					new Effect.Parallel(fx,{
							fps:50,wait:true,duration:500/1000,
							beforeStart:function(effect){
								// note: WHEN the blindstyles are swapped is order-of-operations sensitive, it must happen 
								// before setClosed() or setOpen() run.
								swapBlindStyles();
								this.isAnimating=true;
								// about to open, so remove the content hiding for Safari2
								if(this.previousElement==currentElement && this.closeable){
									if(currentElement.getAttribute("blindstatus")=="closed"){
										currentElement.removeClassName('hide_blind');
									}
								} else {
									currentElement.removeClassName('hide_blind');
								}
							
							}.bind(this),
							afterFinish:function(effect){
								if(this.previousElement==currentElement && this.closeable){
									if(currentElement.getAttribute("blindstatus")=="closed"){
										this.setOpen(currentElement);
									} else {
										this.setClosed(currentElement);
										// has just finished closing, add content hiding for Safari2
										currentElement.addClassName('hide_blind');
									}
								} else {
									this.setOpen(currentElement);
									this.setClosed(this.previousElement);
									// has just finished closing, add content hiding for Safari2
									this.previousElement.addClassName('hide_blind');
								}
								this.previousElement=currentElement;
								this.checkForNextEffect();
							}.bind(this)
						}
					);
					this.currentlyHoveredElement=-1;
				}
			}.bind(this),(this.eventType=='click')?15:225);
			// setTimeout
		}.bind(this);
		return newEffect;
	},

	// given elem the CSS classes which indicate it is an open blind
	setOpen:function(elem){
		elem=$(elem);
		elem.setAttribute("blindstatus","open");
		elem.addClassName("blind_open");
		elem.removeClassName("blind_closed");		
	},

	// given elem the CSS classes which indicate it is a closed blind
	setClosed:function(elem){
		elem=$(elem);
		elem.setAttribute("blindstatus","closed");
		elem.addClassName("blind_closed");
		elem.removeClassName("blind_open");
	}
};
