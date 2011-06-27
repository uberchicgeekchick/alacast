/*
 * @Class: DropDownMenu
 * 
 * @Description: A dropdown navigation menu with sliding animation.
 * 
 * @Usage: var dd=new DropDownMenu(list of dropdown elements, overall parent element with CSS class parameters);
 *	
 * @Methods: no public methods
 * 
 */

DropDownMenu=(!detectBrowser.modernBrowser())?function(){}:Class.create();
DropDownMenu.prototype=(!detectBrowser.modernBrowser())?{}:{


	dropDownDisabledCheck: function(){
		if(window['dropDownMenusDisabled']==true){
			this.springloaderDelay=1;
			this.downDelay=1;
			this.upDelay=1;
			this.hoverOutDelay=1;
		} else {
			this.downDelay=570;
			this.upDelay=450;
			this.springloaderDelay=200;
			this.hoverOutDelay=250;
		}
	},

	initialize: function(droppers,dropcontainer){
		// TODO make these parametric from dropcontainer's CSS class
		this.downDelay=570;
		this.upDelay=450;
		this.springloaderDelay=200;
		this.hoverOutDelay=250;
		this.dropDownDisabledCheck();
		
		// classname can be something like "dropper [otherstyle otherstyle otherstyle] INT INT INT .."
		this.dropperWidths=droppers.map(function(item){
			return item.classNames().toString().split(" ").select(function(token){
				return parseInt(token) > -1;
			})[0];
		});

		// calculate horizontal offset locations of each dropdown
		this.dropperOffsets=this.dropperWidths.inject([0],function(acc,item){
			acc.push(acc[acc.length - 1] + parseInt(item));
			return acc;
		});

		// fetch header height from the container's CSS class names
		var headerHeight=dropcontainer.classNames().toString().split(" ").select(function(token){
			return parseInt(token) > -1;
		})[0];

		this.iframesEnabled=false;
		this.droppers=droppers;
		this.dropperiFrames=[];
		this.hoverStates=[];
		this.states=[];
		this.visibilityInitialized=[];
		// there exists a "next action" for every given dropdown. This way we can queue the next state
		// that a dropdown wants to go to if a dropdown is too busy animating while we interrupt it
		// with another target state.
		this.nextAction=[];
		
		//	next actions are baskets in which a waiting action can drop in a closure to be executed after the current action
		for(var i=0;i<this.droppers.length;i++) { this.nextAction[i]=null; }

		//	we need to do some things to hide droppers
		for(var i=0;i<this.droppers.length;i++) { this.visibilityInitialized[i]=false; }

		//	states: closed, opening, open, closing, closed
		for(var i=0;i<this.droppers.length;i++) { this.states[i]="closed"; }
		
		//	hover states: in, out
		for(var i=0;i<this.droppers.length;i++) { this.hoverStates[i]="out"; }

		for(var i=0;i<this.droppers.length;i++){
			var dropper=this.droppers[i];

			dropper.setStyle({'zIndex':800});

			var lis=dropper.getElementsBySelector('li');
			var hasItems=lis.length > 0;

			if(hasItems && this.iframesEnabled){

				var zfixIFrame=new Element("iframe",{
					'id':'floatMessageIFrame',
					'src':'javascr'+'ipt:\'<ht'+'ml></ht'+'ml>\''
				});
				zfixIFrame.frameBorder=0;
				zfixIFrame.setStyle({
					'backgroundColor':'#2e2e2e', // #2e2e2e
					'zIndex':795,
					'position':'absolute'
					// 'height':'0px'
				});

				var ul=$(lis[0].parentNode);
				ul.setStyle({
					'zIndex':805
				});

				zfixIFrame=dropper.appendChild(zfixIFrame);
				this.dropperiFrames[i]=zfixIFrame;
				// console.debug(this.dropperiFrames[i]);
			}

			//
			// Make two re-useable, cloneable handlers that fire when the mouse leaves or enters
			// either the dropper or the heading for each dropdown menu.
			//
			var mouseout=(function(dropdownDiv,dropperIndex,dropperHasItems){
				return function(ev){
					this.hoverStates[dropperIndex]="out";
					setTimeout(function(){
						// if still hovering outside... go ahead and slide back up
						if(this.hoverStates[dropperIndex]=="out"){
							if(this.states[dropperIndex]=="open"){
								this.applyHoverClasses(dropdownDiv,"over","out");	// wrapper div
								this.applyHoverClasses(dropdownDiv.previous(),"over","out"); // heading
								this.doSlideUp(dropdownDiv,dropperIndex,dropperHasItems);
							} else if (this.states[dropperIndex]=="closing"){
								// reject mouse-out, already closing
							} else {
								// reject mouse-out, but queue up the next action
								// fill nextAction basket with a close action
								this.nextAction[dropperIndex]=function(){
									if(this.hoverStates[dropperIndex]=='out' && this.states[dropperIndex]=="open"){
										this.applyHoverClasses(dropdownDiv,"over","out");	// wrapper div
										this.applyHoverClasses(dropdownDiv.previous(),"over","out"); // heading
										this.doSlideUp(dropdownDiv,dropperIndex,dropperHasItems);
									}
								}.bind(this);
							}
						} else if (this.hoverStates[dropperIndex]=="in"){
							// reject a mouse-out, we're still hovering.
						}
					}.bind(this),this.hoverOutDelay);
				}.bind(this);
			}.bind(this))(dropper,i,hasItems);

			var mouseover=(function(dropdownDiv,dropperIndex,dropperHasItems){
				var dropperHasBeenInitialized=false;
				return function(ev){
					
					if(!dropperHasBeenInitialized){
						//
						// Set styles and calculate dropper heights on-demand
						//
						dropdownDiv.getElementsBySelector("ul").each(function(item){
							item.setStyle({'position':'absolute'});
						});

						if(dropperHasItems){
							var lis=dropdownDiv.getElementsBySelector("li");
							var totalHeight=0;			
							for(var l=0;l<lis.length;l++){
								totalHeight += lis[l].getHeight();
							}
							dropdownDiv.setStyle({
								'position':'absolute',
								'top':headerHeight+"px",
								'left':this.dropperOffsets[dropperIndex]+"px",
								'width':this.dropperWidths[dropperIndex]+"px",
								'height':(totalHeight+5)+"px"
							});
							this.initializeDropperDisplay(dropdownDiv);
						}
						dropperHasBeenInitialized=true;
					}

					this.hoverStates[dropperIndex]="in";
					// moused in over ev.target
					if(this.states[dropperIndex]=="closed"){
						setTimeout(function(){
							// Timed Springloader function: if we're still hovering over THIS menu, go ahead and fly out.
							if(this.hoverStates[dropperIndex]=="in"){
								this.applyHoverClasses(dropdownDiv,"out","over");	// wrapper div
								this.applyHoverClasses(dropdownDiv.previous(),"out","over");	// heading
								this.doSlideDown(dropdownDiv,dropperIndex,dropperHasItems);
							}
						}.bind(this),this.springloaderDelay);
					} else if (this.states[dropperIndex]=="closing"){
						//
						// moused in while already closing
						// queue up an opening nextAction IF we are the heading portion, not the dropper itself
						//
						if(ev.target!=dropdownDiv){
							// queue up next action to open up this dropdown
							this.nextAction[dropperIndex]=function(){
								if(this.hoverStates[dropperIndex]=='in' && this.states[dropperIndex]=="closed"){
									this.applyHoverClasses(dropdownDiv,"out","over");	// wrapper div
									this.applyHoverClasses(dropdownDiv.previous(),"out","over");	// heading
									this.doSlideDown(dropdownDiv,dropperIndex,dropperHasItems);
								}
							}.bind(this);
						} else {
							// reject mouse-in: ev.target was not the dropdowndiv, it was some other element
						}
					} else {
						// reject this mouse-in: not closed
					}
				}.bind(this);
			}.bind(this))(dropper,i,hasItems);

			Event.observe(dropper,'mouseover',mouseover);
			Event.observe(dropper.previous(),'mouseover',mouseover);
			// 
			Event.observe(dropper.previous(),'mouseout',mouseout);
			Event.observe(dropper,'mouseout',mouseout);
		}
	},
	
	// remove "removedClass" from the element
	// add "addedClass" to the element
	applyHoverClasses: function(element,removedClass,addedClass){
		element.removeClassName(removedClass);
		element.addClassName(addedClass);
	},

	initializeDropperDisplay: function(dropper){
		var ul=dropper.getElementsBySelector('ul')[0];
		var iframe=dropper.getElementsBySelector('iframe')[0];
		var ulHeight=ul.getHeight();
		ul.setStyle({'top':'-'+ulHeight+'px'});
		if(iframe){
			iframe.setStyle({'top':'-'+ulHeight+'px'});
			iframe.setStyle({'height':ulHeight+'px'});
		}
		dropper.setStyle({'height':'0px'});
	},
	
	// animate a given dropper sliding up
	doSlideUp: function(dropper,dropperIndex,dropperHasItems){
		this.dropDownDisabledCheck();
		if(!dropperHasItems || window['dropDownMenusDisabled']==true){ // if there are no items, don't waste time or CPU on transitions
			this.states[dropperIndex]="closed";
			this.checkForNextAction(dropperIndex);
		} else {
			var iframe;
			if(this.iframesEnabled==true){
				iframe=dropper.getElementsBySelector("iframe")[0];
			}
			var ul=dropper.getElementsBySelector("ul")[0];
			var ulHeight=ul.getHeight();
			if(iframe && this.iframesEnabled==true){
				new Effect.Parallel([
					new Effect.Move(iframe,{
						'sync':true,
						'x':0,'y':-ulHeight,
						'mode':'absolute',
						'duration':this.upDelay/1000,
						'transition':Effect.Transitions.EaseFromTo
					}),
					new Effect.Move(ul,{
						'sync':true,
						'x':0,'y':-ulHeight,
						'mode':'absolute',
						'duration':this.upDelay/1000,
						'transition':Effect.Transitions.EaseFromTo,
						'beforeStart':function(effect){
							this.states[dropperIndex]="closing";				
						}.bind(this),
						'afterFinish':function(effect){
							dropper.setStyle({'height':'0px'});
							this.states[dropperIndex]="closed";
							this.checkForNextAction(dropperIndex);
						}.bind(this)
					})
				],{
					'duration':this.upDelay/1000				
				});
			} else {
				new Effect.Move(ul,{
					'x':0,'y':-ulHeight,
					'mode':'absolute',
					'duration':this.upDelay/1000,
					'transition':Effect.Transitions.EaseFromTo,
					'beforeStart':function(effect){
						this.states[dropperIndex]="closing";				
					}.bind(this),
					'afterFinish':function(effect){
						dropper.setStyle({'height':'0px'});
						this.states[dropperIndex]="closed";
						this.checkForNextAction(dropperIndex);
					}.bind(this)
				});
			}
		}
	},

	// animate a given dropper sliding down and out.
	doSlideDown: function(dropper,dropperIndex,dropperHasItems){
		this.dropDownDisabledCheck();
		if(!dropperHasItems || window['dropDownMenusDisabled']==true){ // if there are no items, don't waste time or CPU on transitions
			this.states[dropperIndex]="open";
			this.checkForNextAction(dropperIndex);			
		} else {
			var iframe;
			if(this.iframesEnabled==true){
				iframe=dropper.getElementsBySelector("iframe")[0];
			}
			var ul=dropper.getElementsBySelector("ul")[0];
			var ulHeight=ul.getHeight();
			if(iframe && this.iframesEnabled==true){
				new Effect.Parallel([
					new Effect.Move(iframe,{
						'sync':true,
						'x':0,'y':0,
						'mode':'absolute',
						'transition':Effect.Transitions.EaseFromTo,
						'duration':this.downDelay/1000
					}),
					new Effect.Move(ul,{
						'sync':true,
						'x':0,'y':0,
						'mode':'absolute',
						'transition':Effect.Transitions.EaseFromTo,
						'duration':this.downDelay/1000,
						'beforeStart':function(effect){
							dropper.setStyle({'height':ulHeight+'px'});
							this.states[dropperIndex]="opening";
							if(this.visibilityInitialized[dropperIndex]==false){
								this.visibilityInitialized[dropperIndex]=true;
								dropper.setStyle({'visibility':'visible'});
							}
						}.bind(this),
						'afterFinish':function(effect){
							this.states[dropperIndex]="open";
							this.checkForNextAction(dropperIndex);
						}.bind(this)
					})
				],{
					'duration':this.downDelay/1000
				});
			} else {
				new Effect.Move(ul,{
					'x':0,'y':0,
					'mode':'absolute',
					'duration':this.downDelay/1000,
					'transition':Effect.Transitions.EaseFromTo,
					'beforeStart':function(effect){
						dropper.setStyle({'height':ulHeight+'px'});
						this.states[dropperIndex]="opening";
						if(this.visibilityInitialized[dropperIndex]==false){
							this.visibilityInitialized[dropperIndex]=true;
							dropper.setStyle({'visibility':'visible'});
						}
					}.bind(this),
					'afterFinish':function(effect){
						this.states[dropperIndex]="open";
						this.checkForNextAction(dropperIndex);
					}.bind(this)
				});
			}
		}
	},
	
	// check if a next action exists for a given dropdown menu (id'd by dropperIndex) and if so, execute it, then clear it.
	checkForNextAction: function(dropperIndex){
		if(this.nextAction[dropperIndex]!=null && typeof(this.nextAction[dropperIndex])=='function'){
			// perform the next action by calling it, then remove it from the next action basket
			this.nextAction[dropperIndex]();
			this.nextAction[dropperIndex]=false;
		} else {
			// no next action to do 
		}
	}
};

if(detectBrowser.modernBrowser()){
	// dropdown menu bootstrap.
	document.observe("contentloaded",function(){
		if($('main-nav')) {
			var dd=new DropDownMenu($$('#main-nav div.dropper'),$$('#main-nav')[0]);
		}
	});
}
