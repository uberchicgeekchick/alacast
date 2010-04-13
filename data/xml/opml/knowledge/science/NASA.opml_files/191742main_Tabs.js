if(detectBrowser.modernBrowser()){



// Tabs class. Usage: var dd = new TabFactory();
var TabFactory = Class.create();
TabFactory.prototype = {
	initialize:function(){
		this.tabs = $$('.tabs').map(function(el){ return new Tabs(el); });
	}
};

var Tabs = Class.create();
Tabs.prototype = {
	initialize:function(tabContainer){
		tabContainer = $(tabContainer);

		var classNames = $A(tabContainer.classNames());
		// Some elements look bizarre during initial load until javascript gets to them.
		// For those elements, we apply a class called "prejs" so that once the code is 
		// running it can remove that CSS class. This way, a "pre-rendered" state can be
		// seen by the user while the Javascript is still loading, and unsettled layout 
		// can be avoided.
		if(tabContainer.className.indexOf("prejs_")>-1){
			for(var j=0;j<classNames.length;j++){
				if(classNames[j].indexOf("prejs_") > -1){
					tabContainer.removeClassName(classNames[j]);
				}
			}
		}

		// 1. Seek out list items in container
		this.tabButtons = tabContainer.immediateDescendants().select(function(childNode){
			return (childNode.nodeName.toLowerCase()=="li");
		}).map(function(currentTab,i){
			currentTab.removeClassName((i==0)?"tab_inactive":"tab_active");
			currentTab.addClassName((i==0)?"tab_active":"tab_inactive");
			Event.observe(currentTab,'click',function(ev){
				ev.stop();
				for(var j=0;j<this.tabButtons.length;j++){
					var btn = this.tabButtons[j];
					var content = this.tabContents[j];					
					btn.removeClassName((btn==currentTab)?"tab_inactive":"tab_active");
					btn.addClassName((btn==currentTab)?"tab_active":"tab_inactive");
					content.removeClassName((btn==currentTab)?"tab_content_inactive":"tab_content_active");
					content.addClassName((btn==currentTab)?"tab_content_active":"tab_content_inactive");
				}
				return false;
			}.bind(this));
			return currentTab;
		}.bind(this));
		
		// 2. Seek out same-sized set of element.tab somewhere after tabContainer who share the same parent
		//    Make sure to only grab as many of these as there are actual tabs
		this.tabContents = tabContainer.up().immediateDescendants().select(function(childNode){
			return childNode.hasClassName("tab");
		}).map(function(item,i){
			return (i<this.tabButtons.length)?item:null;
		}.bind(this)).select(function(item){
			return (item!=null);
		});

		this.tabContents.each(function(item,i){
			// remove any classes that are meant for the moments of time before rendering kicks in
			var classNames = $A(item.classNames());
			// Some elements look bizarre during initial load until javascript gets to them.
			// For those elements, we apply a class called "prejs" so that once the code is 
			// running it can remove that CSS class. This way, a "pre-rendered" state can be
			// seen by the user while the Javascript is still loading, and unsettled layout 
			// can be avoided.
			if(item.className.indexOf("prejs_")>-1){
				for(var j=0;j<classNames.length;j++){
					if(classNames[j].indexOf("prejs_")>-1){
						item.removeClassName(classNames[j]);
					}
				}
			}

			// set up initial visual state for each tab's contents
			item.removeClassName((i==0)?"tab_content_inactive":"tab_content_active");
			item.addClassName((i==0)?"tab_content_active":"tab_content_inactive");
		});
	}
};

Event.observe(window, 'load', function() {
   var dd = new TabFactory();
});



}