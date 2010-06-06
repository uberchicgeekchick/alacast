if(detectBrowser.modernBrowser()){
	

	var PrettyCounter = Class.create();
	PrettyCounter.prototype = {
		initialize:function(container,numDigits,initialValue,dontAnimateUponInitialize){
			if(container){
				if(dontAnimateUponInitialize==true){
					this.dontAnimateOnce = true;
				}
				this.digitHeight=36;
				this.elements = $A($R(0,numDigits - 1)).map(function(i){
					var outerDiv = new Element("div",{'className':'prettycounter_outerdigit'});
					var innerDiv = outerDiv.appendChild(new Element("div",{'className':'prettycounter_innerdigit'}));
					return $(container.appendChild(outerDiv));
				});
				this.setNum(initialValue);
			} else {
				this.inactive = true;
			}
		},
		setNum:function(num,forceShortDuration){
			if(this.inactive!=true){
				var duration = 1.0;
				if(this.dontAnimateOnce || forceShortDuration==true){
					duration = 0.0;
					this.dontAnimateOnce = false;
				}
				var a = parseInt(num).toString().split("");// left-pad with zeros
				$A($R(0,(this.elements.length - 1) - a.length)).map(function(i){ return "0"; }).concat(a).each(function(numval,i){
					if(i<this.elements.length) new Effect.Move($(this.elements[i].firstChild),{'duration':duration,'x':0,'y':(-1*(parseInt(numval)*this.digitHeight)),'mode':'absolute'});
				}.bind(this));
			}
		}
	};
	

	
}