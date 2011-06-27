if(detectBrowser.modernBrowser()){


//
//
// Dropdown Select with skin and custom scrollbar
//
//

var SkinnedSelectFactory=Class.create();
SkinnedSelectFactory.prototype={
	intialize:function(){
		this.selects=$$('.selectize').map(function(selector){
			return new SkinnedSelect(selector.parentNode,selector);
		});
	}
};

var SkinnedSelectSearch=Class.create();
SkinnedSelectSearch.prototype={

	// return a drop down element
	initialize: function(containingElement,selectorElement,changeCallback,currentValue,scrollColor) {
		//alert(containingElement+ " : "+ selectorElement + " : "+ changeCallback +" : "+currentValue+" : " +scrollColor );
		if(typeof(selectorElement)!='object' || selectorElement==null) { return false; }

		if($A(selectorElement.classNames()).include("positioned")){
			this.positioned=true;
			$(containingElement).makePositioned();
			$(containingElement).absolutize();
			this.posy=$(containingElement).cumulativeOffset()[1];
			this.posx=$(containingElement).cumulativeOffset()[0];
			containingElement=new Element("div");
			containingElement.setStyle({
				'zIndex':'1000',
				'position':'absolute',
				'top':this.posy+'px',
				'left':this.posx+'px'
			});
			containingElement=$(document.body.appendChild(containingElement));
		} else {
			this.positioned=false;
		}

		var itemList;
		if(selectorElement['nodeType']==1 && selectorElement['nodeName'].toLowerCase()=="select"){
			// convert an (un)ordered list into a list that we can accept
			itemList=selectorElement.getElementsBySelector("option").map(function(item){
				return {
					'value':item.value,
					'label':item.innerHTML.strip()
				};
			});
		} else {
			return false;
		}

		this.changeCallback=changeCallback;

		var currentItem=this.getCurrentItem(itemList,currentValue);
	
		// container contains the entire dropdown selector, its activator button, its contents, etc
		var container=new Element("div",{'className':'dropdown_main_container_search'});

		var activation_button=new Element("div",{'className':'dropdown_btn_search'});
		activation_button.appendChild(document.createTextNode("v"));
		
		// label and the actual items
		var label=new Element("div",{'className':'dropdown_label_search' , 'id':'dropdown_search_label'});
		label.appendChild(document.createTextNode(currentItem.label));
	
		// contents are all the dropdown's options + scrollbar
		var contents=new Element("div",{'className':'dropdown_contents_search'});
		contents.setStyle({'display':'none'});

		// innerContents are all the dropdown's options (inner wrapper)
		var innerContents=contents.appendChild(new Element("div",{'className':'dropdown_contents_inner_search'}));
		// TODO measure if this region actually needs a scrollbar		
		//this.scroller=new ScrollRegion(innerContents);
	
		// dropdown selector hider function
		var hideFunc=function() { 
			contents.style.display="none"; 
			/*window['skinnedSelect']=null;*/
		};
	
		// populate contents container with items
		var currentItemHTMLElement;
	
		itemList.each(function(item,i){
			var e=this.createDropitem(
				item,
				hideFunc,
				function(labelText) {
					label.innerHTML="";
					label.appendChild(document.createTextNode(labelText));
				},
				selectorElement
			);
			if (i==currentItem.index) currentItemHTMLElement=e;
			innerContents.appendChild(e);
		}.bind(this));

		var clickHandler=function(ev) {
			if(contents.style.display=="none") { // reveal contents and scroll to current element			
				if(!window['skinnedSelect'] || window['skinnedSelect'] == null) {
					window['skinnedSelect']=contents;
				} else {
					if(window['skinnedSelect'].style.display == "block"){
						window['skinnedSelect'].style.display="none";
						window['skinnedSelect']=contents;
					}
				}
				contents.style.display="block";
				//this.scroller.resetScroll();
				//contents.scrollTop=currentItemHTMLElement.offsetTop;
			} else { // hide contents			
				contents.style.display="none";
				window['skinnedSelect']=null;
			}
			if(ev){
				ev.stop();
			}
			return false;
		}.bind(this);	
						
		// attach activation function to button
		activation_button.onclick=clickHandler;
		label.onclick=clickHandler;
		
		container.appendChild(label);
		container.appendChild(contents);

		containingElement.appendChild(container);
		containingElement.appendChild(activation_button);

		return;
		
		// Attach an event to the document that listens to click events and sees if we have clicked somewhere outside of the dropdown selector
		// NB: this behavior is a bit buggy so it appears after the return statement.
		Event.observe(document,'click',function(ev){
			if(!allElements.include(ev.target)){
				hideFunc();
			}
		}.bind(this));
	},

	createDropitem: function(item,hideFunc,setLabelFunction,selectorElement) {
		var d=new Element("div",{'className':'dropdown_item_search'});
		Event.observe(d,'click',function(){
			selectorElement.value=item.value;
			setLabelFunction(item.label);
			hideFunc();
			if(typeof(this.changeCallback)=='function'){
				this.changeCallback();
			}
		}.bind(this));
		Event.observe(d,'mouseover',function(){
			d.addClassName("dropdown_item_over_search");
		});
		Event.observe(d,'mouseout',function(){
			d.removeClassName("dropdown_item_over_search");
		});
		d.appendChild(document.createTextNode(item.label));
		return d;
	},

	// return current item from itemList where item's value==currentValue
	getCurrentItem: function(itemList,currentValue) {
		var foundIndex;
		var foundItem=itemList.find(function(item,i){ foundIndex=i; return item.value==currentValue; });
		if(!foundItem) {
			foundItem=itemList[0];
			foundIndex=0;
		}
		return {'index':foundIndex, 'value':foundItem.value, 'label':foundItem.label };
	}
};



}
