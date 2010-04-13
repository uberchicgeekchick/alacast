/*Following js files are clubbed in this file:
1. kids_club.js
2. setfilter.js
3. missions.js
4. ImageSet.js
5. image_gallery.js
6. StackedDeck.js
7. Calendar.js
8. launch_calendar.js
9. TagCloud.js
*/

/*----------------------------------------------------- kids_club.js starts ---------------------------------------------------*/
if(detectBrowser.modernBrowser()){

/* Test your knowledge */

var tykFormElement = $('tykForm');
var tykSubmitButton = $('tykSubmitButton');
var testYourKnowledgeElement = $('testYourKnowledge');

if(tykFormElement && tykSubmitButton && testYourKnowledgeElement){

	var tykAnswer = 1;
	var tykInfo = "The last NASA Mission to the moon was Apollo 17 in 1969.";

	var correctMsg1 = "Correct!";
	var correctMsg2 = "Good job! Try again tomorrow!";	
	var incorrectMsg1 = "Sorry... your answer is incorrect.";
	var incorrectMsg2 = "But that's okay, you can always try again tomorrow!";

	var tykVerify = function(){
		var tykChoice = tykChecked();
	
		if (tykChoice == tykAnswer) {
			tykCorrect();
		}else{
			tykIncorrect();
		}
	};
	var tykCorrect = function() {
		tykFormElement.setStyle({
		  display: 'none'
		});
		tykSubmitButton.setStyle({
		  display: 'none'
		});
	
		var correctMessage = new Element("div").addClassName('tykMessage');
		correctMessage.update('<p>' + correctMsg1 + '</p><p>' + tykInfo + '</p><p>' + correctMsg2 + '</p>');

		testYourKnowledgeElement.appendChild(correctMessage);
	};
	var tykIncorrect = function() {
		tykFormElement.setStyle({
		  display: 'none'
		});
		tykSubmitButton.setStyle({
		  display: 'none'
		});

	
		var correctMessage = new Element("div").addClassName('tykMessage');
		correctMessage.update('<p>' + incorrectMsg1 + '</p><p>' + tykInfo + '</p><p>' + incorrectMsg2 + '</p>');

		testYourKnowledgeElement.appendChild(correctMessage);
	};
	var tykChecked = function() {
		var tykRadios = tykFormElement.getInputs('radio');
	
		var tykCorrect = tykRadios.find(function(item){
			return item.checked == true;
		});
	
		if(typeof(tykCorrect)=='undefined') {
			tykCorrect = 0;
			return tykCorrect;
		}
		return parseInt(tykCorrect.value);
	};

	document.observe('contentloaded', function() {
		Event.observe(tykSubmitButton, 'click', function(event) {
		  tykVerify();
		  Event.stop(event);
		}, false);

	}, false);

}

}
/*----------------------------------------------------- kids_club.js ends -----------------------------------------------------*/

/*----------------------------------------------------- setfilter.js starts ---------------------------------------------------*/
if(detectBrowser.modernBrowser()){
	
var SetFilterFactory = Class.create();
SetFilterFactory.prototype = {
	initialize:function(){
		this.filters = $$('.setfilter').map(function(el){
			return new SetFilter(el);
		});
	}
};

/*
format for a filter checkbox:
<input type="checkbox" class="setfilter_check 40" />
*/
var SetFilter = Class.create();
SetFilter.prototype = {
	initialize:function(filterContainer,updateFilterClosure,listenEventAtContainer){
		if(filterContainer){
			var parseWeight = function(elem){ // parse classnames to find the weight of a given checkbox
				return $A(elem.classNames()).find(function(token){
					return parseInt(token) > -1;
				});
			};
			var getTotalWeight = function(){ // return the total weight of the checked checkboxes
				var checkedTotal = this.filterCheckboxes.inject(0,function(acc,filterCheck){
					return acc + parseInt(filterCheck.checked?parseWeight(filterCheck):0);
				});
				return (checkedTotal==0)?this.totalTotal:checkedTotal;
			}.bind(this);
			this.filterCheckboxes = filterContainer.getElementsBySelector("input.setfilter_check").map(function(fc){
				if(listenEventAtContainer){
					Event.observe(fc.parentNode,'click',function(ev){
						if(ev.target!=fc){
							fc.checked = !fc.checked;
						}
						updateFilterClosure(getTotalWeight()); // when a checkbox is checked, we recalculate the filter
					}.bind(this));								
				} else {
					Event.observe(fc,'click',function(ev){
						updateFilterClosure(getTotalWeight()); // when a checkbox is checked, we recalculate the filter
					}.bind(this));				
				}
				return fc;
			}.bind(this));
			this.totalTotal = this.filterCheckboxes.inject(0,function(acc,filterCheck){
				return acc + parseInt(parseWeight(filterCheck));
			});
			updateFilterClosure(getTotalWeight());
		}
	}
};

}
/*----------------------------------------------------- setfilter.js ends -----------------------------------------------------*/

/*----------------------------------------------------- missions.js starts ---------------------------------------------------*/
if(detectBrowser.modernBrowser()){

document.observe('contentloaded', function() {

	var allSubjects = $$('select.select_satellite').map(
	function(elm)
	{
		if(detectBrowser.whichBrowser() != 'ie')
		{
			return new SkinnedSelect(elm.parentNode,elm, function(){
				if(item.value != 0) {
					document.location.href = "missions_landing_page.shtml?satellite=" + item.value;
				}
			},'','blue');
		}
		else
		{
			elm.removeClassName('select_satellite');
			elm.addClassName('select_blue_ie');
		}
	}
	);

}, false);

}
/*----------------------------------------------------- missions.js ends -----------------------------------------------------*/


/*----------------------------------------------------- ImageSet.js starts ---------------------------------------------------*/
if(detectBrowser.modernBrowser()){

//
// Set of image ranges, each of which has a subset of images.
//

var ImageSet = Class.create();
Object.extend(ImageSet.prototype, Enumerable);
Object.extend(ImageSet.prototype,{
	// construct an image set.
	// @element is an element within which to seek out already-loaded sets in the DOM
	initialize:function(element){

		// parse a range string like startToken_INT_INT
		function parseRange(classNames,startToken){
			var tokens = classNames.find(function(item){ return (typeof(item)=="string" && item.indexOf(startToken)==0); });
			return {'start':parseInt(tokens.split("_")[1]),'end':parseInt(tokens.split("_")[2])};
		}

		// return a set of sets
		this.loadedsets = element.getElementsBySelector("ol.images").map(function(imageList){
			var classnames = $A(imageList.classNames());
			return {
				'range':parseRange(classnames,"range_"),
				'extents':parseRange(classnames,"extents_"),
				'images':imageList.getElementsBySelector("li.image").map(function(imageListElement){
					// if we have a placeholder image, just return a stub
					if ($A(imageListElement.classNames()).include("placeholder")) return {'placeholder':true};
					// return a fully-formed image if we have a real image
					var result = {
						
						'versions':{
							'thumbnail_small':imageListElement.getElementsBySelector("a.thumbnail_small")[0].readAttribute("href").strip()
							
						}
					};
					imageListElement.getElementsBySelector("a").each(function(img){
						var imageKey = $A(img.classNames()).find(function(token){ // find first token matching INTxINT
							return token.split("x").length > 1 && parseInt(token.split("x")[0]) > -1 && parseInt(token.split("x")[1]) > -1;
						});
						// This image fits the pattern and is something like "1024x768". Append to result as another version.
						if(typeof(imageKey)!='undefined') result['versions'][imageKey] = img.readAttribute("href").strip();
					});
					return result;
				})
			};
		});
	},

	isRealImage:function(range,index){ // assumes range exists, assumes it is loaded
		return this.getRange(range)['images'][index]['placeholder']!=true;
	},

	getRangeIndex:function(range){	// assumes range exists
		for(var i=0;i<this.loadedsets.length;i++)
			if(ImageSet.prototype.compareRange(this.loadedsets[i]['range'],range))
				return i;
	},

	getRangeAfter:function(range){
		for(var i=0;i<this.loadedsets.length;i++)
			if(ImageSet.prototype.compareRange(this.loadedsets[i]['range'],range) && (i + 1 < this.loadedsets.length))
				return this.loadedsets[i + 1]['range'];
	},

	getRangeBefore:function(range){
		for(var i=0;i<this.loadedsets.length;i++)
			if(ImageSet.prototype.compareRange(this.loadedsets[i]['range'],range) && (i - 1 >= 0))
				return this.loadedsets[i - 1]['range'];
	},

	findRangeByImage:function(imageItem){
		var result;
		var matchingSet = this.loadedsets.find(function(loadedSet,i){ return loadedSet['images'].include(imageItem); });
		if(matchingSet) result = matchingSet['range'];
		// return undefined if not found
		return result;
	},

	// external code must be able to fetch the "first" range block. Return a range in format {start:int,end:int}
	getFirstRange:function(){
		return this.loadedsets[0]['range'];
	},

	// compare two ranges in format {start:int,end:int}, return true if they are the same
	compareRange:function(range1,range2){
		return typeof(range1)=='object' && typeof(range2)=='object' && range1!=null && range2!=null && parseInt(range1['start'])==parseInt(range2['start']) && parseInt(range1['end'])==parseInt(range2['end']);
	},

	getRange:function(range){
		var result = this.loadedsets.find(function(aSet){
			return ImageSet.prototype.compareRange(aSet.range,range);
		}.bind(this));
		
		if(!result){
			// TODO check if range is within the total extents, and load
		}
		
		return result;
	},

	loadRangeAsync:function(range,url,callbackFunc){
		console.debug("loadRangeAsync: loading range",range);
		// TODO load a range, run a callback function after finish.
		new Ajax.Request(url,{
			method:'get',
			onSuccess:function(transport){
				console.debug("results of query (transport object):",transport);
			}
		});
	},

	rangeLoaded:function(range){
		return typeof(this.loadedsets.find(function(aSet){ return ImageSet.prototype.compareRange(aSet.range,range); }.bind(this)))!='undefined';
	},

	// return all ranges in the entire extent, whether they are loaded or not.
	allRangesInExtent:function(iterator){
		var rangeLength = (parseInt(this.loadedsets[0]['range']['end']) - parseInt(this.loadedsets[0]['range']['start'])) + 1;
		// NB: this might break if rangelength is not a nice number like 10, 20, etc
		var rangeCeiling = Math.ceil(this.loadedsets[0]['extents']['end'] / rangeLength) * rangeLength;
		return $A($R(0,(rangeCeiling / rangeLength) - 1)).map(function(i){
			return {
				'start':(i*(rangeLength)) + 1,
				'end':((i+1)*(rangeLength))
			};
		});
	},

	// _each is a function required by the Enumerable mix-in
	// _each will iterate over each SUBSET of images, not all images
	_each: function(iterator) {
		for (var i = 0, length = this.loadedsets.length; i < length; i++) iterator(this.loadedsets[i]);
	}

});

}// end modern browser check

/*----------------------------------------------------- ImageSet.js ends -----------------------------------------------------*/

/*----------------------------------------------------- image_gallery.js ends -----------------------------------------------------*/
if(detectBrowser.modernBrowser()){

// Image Gallery is loaded by both the "full screen" image 
// gallery page and the normal image gallery page


var ImageGallery = Class.create();
ImageGallery.prototype = {
	initialize:function(){
		
		this.container = $('image_gallery');
		if(!this.container) return;
		this.imageStackContainer = $('image_stack');
		this.imageContainer = $('gallery_image_area');
		this.captionContainer = $('caption_region');
		this.downloadContainer = $('download_image_box');
		this.toolbarContainer = $('gallery_toolbar');
		this.gridContainer = $('gallery_thumbgrid');
		this.gridContainerClose = $('gallery_thumbgrid_close');
		this.outsideCaptionContainer = $$('.image_gallery_fullscreen_outsidecaption')[0];
		
		
		this.imageSet = new ImageSet(this.container);
		this.previousRange = this.currentRange = this.imageSet.getFirstRange();
		this.endLabel = 0;
		this.imageIndex = 0;

		// pixel widths for stack of image ranges
		this.setStackSizes = { 'hiddenSize':67, 'openSize':414 };
		// pixel widths for image stack
		this.rangeStackSizes = { 'hiddenSize':27, 'openSize':120 };
		// delay in milliseconds that it takes the stack to respond
		this.responseDelay = 100;

		// Possible display modes : normal, fullscreen. Possible states: normal, grid
		this.displayMode = ($A(this.container.classNames()).include("image_gallery_fullscreen"))?"fullscreen":"normal";
		this.stackedDecks = [];
		
		this.drawComponents();
		
		
	},

	// return a stack of all sets
	getSetsStack:function(){
		var ul = new Element("ul");
		this.imageSet.each(function(dataset,i){
			// create deck panel with another stack of images inside of it
			var li = new Element("li",{'className':'setstackitem '+((i==0)?"active":"inactive")});
			var rangeStackUl = this.getRangeStack(dataset['range']);
			//this.imageStackContainer.appendChild(rangeStackUl);
			this.stackedDecks.push({
				'deck':(new StackedDeck(rangeStackUl.getElementsBySelector("li"),rangeStackUl,{'horizontal':true})),
				'range':dataset['range'],
				'deckIndex':i
			});
			if(i!=0){
				var rangetab_end = li.appendChild(new Element('div',{'className':'rangetab_end'}));
			}
			li.appendChild(new Element("span",{'className':'rangetitle'}).update(dataset['range']['start']+"-"+dataset['range']['end']));
			li.appendChild(rangeStackUl);
			ul.appendChild(li);
		}.bind(this));
		
		// add another panel at the end to 'cap' the set.
		var setsEndCap = new Element('li',{'className':'setstackitem inactive end_cap'});
		var endCaprangetab_end = setsEndCap.appendChild(new Element('div',{'className':'rangetab_end'}));
		setsEndCap.appendChild(new Element('span',{'className':'rangetitle'}).update(' '));

		
		[this.setStackSizes['hiddenSize'], this.setStackSizes['openSize'], this.responseDelay, "sideways", "imageset"].each(function(className){
			ul.addClassName(className);
		});
		return ul;
	},

	// create a stack of images for a given range
	getRangeStack:function(rangeToGet){
		var ul = new Element("ul");
		var imageSet = this.imageSet.getRange(rangeToGet);
		imageSet['images'].each(function(imageItem,i){
			if(imageItem['placeholder']==true){
				// do nothing.
			} else {
				// create deck panel with image and index inside of it
				var li = new Element("li",{'className':'stackitem '+((i==0)?"active":"inactive")});
				var img = li.appendChild(new Element("img",{'src':imageItem.versions.thumbnail_small,'alt':'Click here to view gallery image','title':'Click here to view gallery image'}));
				var span = li.appendChild(new Element("span",{}).update(rangeToGet['start']+i));
				// attach click handler to image
				Event.observe(li,'click',function(){
					//console.debug("Click detected in img");
					this.goToRangeAndImage(rangeToGet,i);
				}.bind(this));
				ul.appendChild(li);
			}
		}.bind(this));
		[this.rangeStackSizes['hiddenSize'], this.rangeStackSizes['openSize'], this.responseDelay, "sideways", "imagerange"].each(function(className){
			ul.addClassName(className);
		});
		return ul;
	},

	
	moveToImage:function(newImageIndex){
		var newRange = this.currentRange;
		if(newImageIndex<0 || newImageIndex>9) {
			newRange = (newImageIndex<0)?(this.imageSet.getRangeBefore(this.currentRange)):(this.imageSet.getRangeAfter(this.currentRange));
			if(newRange){ // if there is a previous range, go to it
				newImageIndex = (newImageIndex<0)?9:0;
			} else {
				newImageIndex = this.imageIndex;
				newRange = this.currentRange;
			}
		}
		this.goToRangeAndImage(newRange,newImageIndex);
		//this.getCurrentImageItem();
	},

	// Draw deck and refresh gallery UI for the first time.
	drawComponents:function(){ 
		this.hideThumbGrid();
		Event.observe(this.toolbarContainer.getElementsBySelector('#btn_allthumbnails')[0],'click',function(ev){
			ev.stop();
			this.showThumbGrid();
			return false;
		}.bind(this));
		
		if(this.displayMode=="normal"){
			var setsStackUl = this.imageStackContainer.appendChild(this.getSetsStack());
			this.setStack = new StackedDeck(setsStackUl.getElementsBySelector("li.setstackitem"),setsStackUl,{'horizontal':true});
			var imagesetLeft = this.imageStackContainer.appendChild(new Element("div",{'className':'imageset_left'}));
			var imagesetRight = this.imageStackContainer.appendChild(new Element("div",{'className':'imageset_right'}));
			Event.observe(imagesetLeft,'click',function(){
			this.subDiv = $('sub');			
			
			if(masterArrayBlockCurrentIndex >  0)
			 {
			
				
				masterArrayBlockCurrentIndex--;
				
				 if(this.subDiv)
				 {
				 
					this.subDiv .innerHTML='';
					document.getElementById("gallery_image_area").innerHTML='';
					
					document.getElementById("download_image_box").innerHTML='';
					document.getElementById("image_stack").innerHTML='';
					
					this.subDiv.innerHTML=masterArrayBlock[masterArrayBlockCurrentIndex];
				}
				
				
				 new ImageGallery();
			}
			
			
			}.bind(this));
			
			Event.observe(imagesetRight,'click',function(){
			this.subDiv = $('sub');			
			if( (masterArrayBlockCurrentIndex <  10 ) && ( (masterArrayBlockCurrentIndex+1) < masterArrayBlock.length ))
			 {
					 masterArrayBlockCurrentIndex++;
					 if(this.subDiv)
					 {
						 this.subDiv.innerHTML='';
						 document.getElementById("gallery_image_area").innerHTML='';
						 document.getElementById("download_image_box").innerHTML='';
						 document.getElementById("image_stack").innerHTML='';
						 
						 this.subDiv.innerHTML=masterArrayBlock[masterArrayBlockCurrentIndex];
					}
				
					 new ImageGallery();
					 
				
			 }
			}.bind(this));
		}
		// update onscreen elements
		this.refresh();
		// left and right (previous/next) image navigation
		if(this.displayMode == 'normal') {
			var previousImageButton = this.imageContainer.appendChild(new Element("div",{'className':'btn_image_prev'}));
			var nextImageButton = this.imageContainer.appendChild(new Element("div",{'className':'btn_image_next'}));
			
			
			Event.observe(previousImageButton,'click',function(){this.moveToImage(this.imageIndex - 1); }.bind(this));
			Event.observe(nextImageButton,'click',function(){ this.moveToImage(this.imageIndex + 1); }.bind(this));
			
		}else {
			var previousImageButton = this.imageContainer.appendChild(new Element("div",{'className':'btn_image_prev'}).insert(new Element("div",{'className':'btn_arrow_prev'})));
			var nextImageButton = this.imageContainer.appendChild(new Element("div",{'className':'btn_image_next'}).insert(new Element("div",{'className':'btn_arrow_next'})));
			
			Event.observe(previousImageButton,'click',function(){ this.moveToImage(this.imageIndex - 1); }.bind(this));
			Event.observe(nextImageButton,'click',function(){ this.moveToImage(this.imageIndex + 1); }.bind(this));
			
			var hideNav = this.imageContainer;
			var prevNav = this.imageContainer.getElementsBySelector("div.btn_image_prev")[0];
			var nextNav = this.imageContainer.getElementsBySelector("div.btn_image_next")[0];
		
	
		}
		
	},

	getCurrentImageItem:function(){
	
	var rangeObj = this.currentRange;
	var absImageIndex = this.imageIndex + 1;

	var imagePositionInListOfAllImages =  (rangeObj.start - 1) + this.imageIndex;
	var eachImage = new Array();
	var xmlPath = '';var htmlPath='';
	
	for(var i=0;i<listOfImages.length;i++)
	{
		eachImage = new Array();
		eachImage = listOfImages[i];

		if(imagePositionInListOfAllImages == i)
		{
			xmlPath = eachImage.detailedXMLPath;
			htmlPath = eachImage.detailedHTMLPath;
		}
	}
		
	var detailAssetURL = xmlPath;
	var retVal = false;
	 /* Inner Ajax */
	 
	 document.getElementById('btn_fullscreen').href=htmlPath;
	 
	new Ajax.Request(detailAssetURL,	
	  {
		 asynchronous:false,
	    method:'get',
	    onSuccess: function(transport,myIndex){		
		  
		   retVal = processDetailedRSS(transport.responseXML);
		    
		    
			    this.imageContainer = $('gallery_image_area');
	    },
	    onFailure: function(){ 
			//alert('Error Retrieving Source File ...');
			}
	   
	  });	  
	/* Inner Ajax */
	
	if(retVal == true)
	
	{
		var prevNav = this.imageContainer.getElementsBySelector("div.btn_image_prev")[0];
		var nextNav = this.imageContainer.getElementsBySelector("div.btn_image_next")[0];
				
		if(prevNav == null || prevNav == 'undefined') {
					
					
			prevNav = this.imageContainer.appendChild(new Element("div",{'className':'btn_image_prev'}));
			nextNav = this.imageContainer.appendChild(new Element("div",{'className':'btn_image_next'}));				
		}	
		Event.observe(prevNav,'click',function(){ this.moveToImage(this.imageIndex - 1); }.bind(this));
		Event.observe(nextNav,'click',function(){;this.moveToImage(this.imageIndex+ 1); }.bind(this));					
		
		if(this.displayMode=="normal" && typeof(this.captionScrollBar)=='undefined'){
			//do nothing - this scenario has already been handled
		}
		else
		{	
			this.captionScrollBar = new ScrollRegion(this.captionContainer.getElementsBySelector("div")[0]);
		}
		
	}
	else
	{
		// already handled
	}
	return this.imageSet.getRange(this.currentRange)['images'][this.imageIndex];
		
		
	},

	// fill in onscreen stuff including image, caption, title, download links
	// if replacementImageItem is not an image from some image set (i.e. undefined), fetch the "current" image and use that for refresh.
	refresh:function(replacementImageItem){
		if(typeof(replacementImageItem)=='undefined') replacementImageItem = this.getCurrentImageItem();

		if(this.displayMode=="normal"){
			// Slide outer slider: Go to the current range
			this.setStack.slideToIndex(this.imageSet.getRangeIndex(this.currentRange));

			// Slide slider: find inner slider, slide to it. NB: assumes that the slider exists!
			var innerStack = this.stackedDecks.find(function(slider){
				var rangeOfImage = this.imageSet.findRangeByImage(replacementImageItem);
				return ImageSet.prototype.compareRange(rangeOfImage,slider.range);
			}.bind(this));
			innerStack.deck.slideToIndex(this.imageIndex);
		}

		// update caption and title
		/*this.captionContainer.getElementsBySelector("p")[0].update(replacementImageItem['caption']);
		this.captionContainer.getElementsBySelector("h3")[0].update(replacementImageItem['title']);*/
		if(this.displayMode=="normal" && typeof(this.captionScrollBar)=='undefined'){
			
			this.captionScrollBar = new ScrollRegion(this.captionContainer.getElementsBySelector("div")[0]);
		}
		
		// update download links: remove current ones, add new ones
		/*this.downloadContainer.getElementsBySelector("span").invoke("remove");*/

		// update list of downloadable images
		$H(replacementImageItem['versions']).keys().reject(function(k){
			return k=='medium' || k=='thumbnail_large' || k=='thumbnail_small' || k=='fullscreen';
		}).each(function(key){
			
			// convert 1111x1111 into 1111 x 1111 and "Full_Size" into Full Size
			var displayedKey = key.split("_").join(" ").split("x").join(" x ");
			var downloadSpan = new Element("span");
			var downloadHref = new Element("a", { 'href':replacementImageItem['versions'][key]} ).update( displayedKey );
			downloadSpan.update( downloadHref );
			var downloadLink = new Insertion.Top(downloadSpan, "&rsaquo; ");
			/*this.downloadContainer.appendChild(downloadLink);*/

		}.bind(this));

		// Update image: create new image, remove old one, append new one to DOM
		this.previousRange = this.currentRange;
		
	},

	hideThumbGrid:function(){
		// TODO use the references to fetched elements from initialize() instead
		
		this.subDiv = $('sub');
		
		if(!this.subDiv)
		{
			var formElement = $('subDivForm');
			var sub = new Element("div", {'id': "sub"});
			
			formElement.insert(sub);
		}
		
		this.gridContainer.hide();
		if(this.displayMode=='fullscreen'){
			this.container.removeClassName("image_gallery_fullscreen_short");
			this.toolbarContainer.show();
			this.downloadContainer.show();
			this.captionContainer.show();
			this.imageContainer.show();
			this.outsideCaptionContainer.show();
		}
	},

	showThumbGrid:function(){
		//alert('Inside showThumbGrid');
		this.gridContainer.show();
		this.gridContainerClose.style.display="block";
		this.subDiv = $('sub');
		if(this.subDiv)	{this.subDiv.remove();}
		if(this.displayMode=='fullscreen'){
			this.container.addClassName("image_gallery_fullscreen_short");
			this.toolbarContainer.hide();
			this.downloadContainer.hide();
			this.captionContainer.hide();
			this.imageContainer.hide();
			this.outsideCaptionContainer.hide();
		}
		
		// clean out ranges
		this.imageSet.getRange(this.currentRange)['images'][this.imageIndex];
		var browserName  = navigator.appName;
		var rangesContainer = this.gridContainer.getElementsBySelector("#gallery_thumbgrid_ranges")[0];
		
		
		//alert("len = "+rangesContainer.childNodes.length + " and current range = "+this.currentRange.start  +" and browser = "+browserName+" and endLabel = "+this.endLabel);
		
		if( !((rangesContainer.childNodes.length == 2) && (this.currentRange.start == 1)  && (browserName == 'Microsoft Internet Explorer' )) )
		{
			/*if(this.currentRange.start  < this.endLabel)
			{*/
	
				while(rangesContainer.childNodes.length > 0)
				{
					rangesContainer.removeChild(rangesContainer.firstChild);
				}
				// clean out grid
				var grid = this.gridContainer.getElementsBySelector("#gallery_thumbgrid_grid")[0];
				while(grid.childNodes.length > 0)
				{	
					grid.removeChild(grid.firstChild);
				}
				// redraw ranges
				this.imageSet.allRangesInExtent().inGroupsOf(2).each(function(rangeGroup){
					var inRange = false;
					/*alert("rg0 start =" +rangeGroup[0].start + "rg0 end = "+rangeGroup[0].end +" and currentRange  = "+this.currentRange.start);*/
					if(ImageSet.prototype.compareRange(rangeGroup[0],this.currentRange) || ImageSet.prototype.compareRange(rangeGroup[1],this.currentRange)) {
						inRange = true;				
					}
					var rangeLabel = rangeGroup[0]['start'] + " - " + ((rangeGroup[1]!=null)?rangeGroup[1]['end']:rangeGroup[0]['end']);
					this.endLabel = rangeGroup[1]['end'];
					
					if(inRange)
					{
						while( (rangesContainer.childNodes.length -1) > 0)
						{
							rangesContainer.removeChild(rangesContainer.firstChild);
						}
						var rangeSpan = rangesContainer.appendChild(new Element("span",{})).update(rangeLabel);
					} 
					else 
					{
						while( (rangesContainer.childNodes.length -1) > 0)
						{
							rangesContainer.removeChild(rangesContainer.firstChild);
						}
						var rangeLink = rangesContainer.appendChild(new Element("a",{'href':'#'})).update(rangeLabel);
										
						Event.observe(rangeLink,'click',function(ev){
							this.currentRange = rangeGroup[0];
							this.imageIndex = 0;
							this.showThumbGrid();
							ev.stop();
							return false;
						}.bind(this));
						
					}
					
				}.bind(this));
				//alert('Redraw ranges finished');
				var closeBtn = this.gridContainer.getElementsBySelector('#gallery_thumbgrid_close a')[0];
				if(this.observedCloseBtn!=true){
					Event.observe(closeBtn,'click',function(ev){
						this.hideThumbGrid();
						ev.stop();
						return false;
					}.bind(this));
					this.observedCloseBtn = true;
				}
		
				// find the range pair that the current range is inside of, then render them both.
				var rangePair = this.imageSet.allRangesInExtent().inGroupsOf(2).find(function(rangeGroup){
					if(ImageSet.prototype.compareRange(rangeGroup[0],this.currentRange) || ImageSet.prototype.compareRange(rangeGroup[1],this.currentRange)) return true;
					//return false;
				}.bind(this));
		
				var range1 = this.imageSet.getRange(rangePair[0]);
				var range2 = this.imageSet.getRange(rangePair[1]);
				var combinedSet = (range2)?range1['images'].concat(range2['images']):range1['images'];
				combinedSet.each(function(imageItem,i){
					// create deck panel with image and index inside of it
					var imgContainer = new Element("div",{'className':'griditem g'+i});
					// ignore placeholder images
					if(imageItem['placeholder']!=true){
						var img = imgContainer.appendChild(new Element("img",{'src':(this.displayMode=="normal")?imageItem.versions.thumbnail_small:imageItem.versions.thumbnail_large,'alt':'Click here to view gallery image','title':'Click here to view gallery image'}));
						Event.observe(img,'click',function(ev){ // Image's click handler hides the grid and navigates to the image.
							this.hideThumbGrid();
							if(i>9) this.goToRangeAndImage(rangePair[1],i - 10);
							else this.goToRangeAndImage(rangePair[0],i);
							ev.stop();
							return false;
						}.bind(this));
					} else {
						var img = imgContainer.appendChild(new Element("div",{'className':'placeholder_thumbnail'}).update(" "));
					}
					
					grid.appendChild(imgContainer);
				}.bind(this));
			/*}*/
		//alert('Exiting showThumbGrid');
		}
	},

	goFullScreen:function(range,index){ // TODO link to fullscreen
		document.location.href = "#";
	},

	goToRangeAndImage:function(range,index){
		// Ignore movement if we are already at this index and range
		if(index==this.imageIndex && ImageSet.prototype.compareRange(range,this.currentRange)) return;
		// Asynchronously fetch an unloaded range
		var refreshFunc = function(loadedSuccessfully){
			if(loadedSuccessfully){
				if(this.imageSet.isRealImage(range,index)) { // check if this is a real image or just a placeholder in the set
					this.imageIndex = index;
					this.currentRange = range;
					this.refresh();
				}
			} else {
				// TODO present user with error
			}
		}.bind(this);
		
		if(!this.imageSet.rangeLoaded(range)){
			// TODO load a set with XHR before going to it if it's not loaded yet.
			// TODO figure out URL format for ranges
			this.imageSet.loadRangeAsync(range,url,refreshFunc);
		} else {
			refreshFunc(true);
		}
	}
};
}
/*----------------------------------------------------- image_gallery.js ends -------------------------------------------------------*/

/*----------------------------------------------------- StackedDeck.js starts -------------------------------------------------------*/
if(detectBrowser.modernBrowser()){
//
// StackedDeck is a type of blind/accordion that uses z-index stacking and 
// either horizontal or vertical offsetting to accomplish its slide effect.
//
var StackedDeck = Class.create();
StackedDeck.prototype = {	
	initialize: function(elements,containerElement,options){
		var _openHeight = null;
		var _sliceHeight = null;
		var _springLoadingSpeed = null;
		var _baseZIndex = null;
		this.reversed = false;
		this.zIndexStep = 1;
		if(typeof(options)=='object'){
			if(options['horizontal']==true || options['sideways']==true){
				this.sideways=true;
			}
			if(parseInt(options['zstep']) > -1){
				this.zIndexStep = options['zstep'];
			}
			if(options['dead_endcap']==true){
				this.deadEndCap = true;
			}
			if(options['endcap_covers_last_item']==true){
				this.endCapCoversLastItem = true;
			}
			// hack which applies "active_first" as well as "active" to the first li when it is active
			// and "inactive_first" as well as "inactive" for inactive
			if(options['apply_first_class']==true){
				this.applyFirstClass = true;
			}
		}
		if(typeof(containerElement)!='undefined'){
			// get class and acquire height from class. Otherwise, we default to 40/80
			var params = this.getCSSParams(containerElement);
			_sliceHeight = params['sliceHeight'];
			_openHeight = params['openHeight'];
			_springLoadingSpeed = params['springLoadingSpeed'];
			_baseZIndex = params['baseZIndex'];
			if(!(_springLoadingSpeed>=0)) { _springLoadingSpeed = null; }
			
			if(this.sideways==true){
				var styleObj = {'width':(((elements.length - 1) * _sliceHeight) + _openHeight) + "px"};
				containerElement.setStyle(styleObj);
			} else {
				containerElement.setStyle({'height':(((elements.length - 1) * _sliceHeight) + _openHeight) + "px"});
			}
			if(containerElement.hasClassName("reversed")) { this.reversed = true; }
		}

		this.sliceHeight = (_sliceHeight!=null)?(_sliceHeight):(40);
		this.openHeight = (_openHeight!=null)?(_openHeight):(80);		
		this.springloadDelay = (_springLoadingSpeed!=null)?_springLoadingSpeed:75;
		this.springloaded = (parseInt(this.springloadDelay) <= 0)?false:true;
		this.currentOpenIndex = null;
		this.isAnimating = false;
		this.nextEffect = null;
		this.switchFlag = false;
		this.baseZIndex = (_baseZIndex==null)?100:_baseZIndex;
		this.springloaderBasket = null;
		this.activators = []; // an array of activation functions for the sliders which can be triggered with slideToIndex()
		this.makeSliders(elements);
	},

	getCSSParams: function(containerElement){
		if(typeof(containerElement)!='undefined'){ // type check must stay here since some callers will have not checked containerElement's validity
			var numericClassNames = $A(containerElement.classNames()).select(function(item){ return parseInt(item) > -1; });
			if(numericClassNames.length >= 2){
				return {
					'sliceHeight':parseInt(numericClassNames[0]),
					'openHeight':parseInt(numericClassNames[1]),
					'springLoadingSpeed':parseInt(numericClassNames[2]),
					'baseZIndex':parseInt(numericClassNames[3])
				};
			}
		}
		return {};
	},

	// create a set of accordion sliders that are associated with each other
	makeSliders: function(elements){
		this.currentOpenIndex = elements.length;
		elements.each(function(item,i){
			var topLocation = ((i==0)?(0):((this.sliceHeight * (i-1)) + (this.openHeight))) + 'px';
			if(this.reversed==true) { topLocation = ((this.sliceHeight * i)) + 'px'; }
			var sliderStyle = {
				'zIndex':this.reversed?(this.baseZIndex + elements.length - (i*this.zIndexStep)):(this.baseZIndex + (i*this.zIndexStep)),
				'position':'absolute'
			};
			if(this.sideways){
				sliderStyle['left'] = topLocation;
			} else {
				sliderStyle['top'] = topLocation;
			}
			$(item).setStyle(sliderStyle);

			var activationFunc;
			activationFunc = this.activators[i] = this.makeActivationEventHandlerFunc(this.makeSlideFunc(elements,item,i));
			// quick hack for mouseup and mouse over
			if(item.getElementsByClassName('rangetitle').length > 0){
				var eventAction = 'mouseup';

				// this is a "dead" end panel with no hovers, no clicks, etc
				if(this.deadEndCap==true && i==elements.length-1){
				} else {
					if(i==0 && this.applyFirstClass==true){
						var obj = new mouseOverClassify({
							'ignore_position':true,
							'adderFunction':function(element){
								if(element.hasClassName("inactive")){
									element.addClassName("setstackitem_hover_first_inactive");	
								} else {
									element.addClassName("setstackitem_hover_first_active");
								}
							},
							'removerFunction':function(element){
								element.removeClassName("setstackitem_hover_first_active");
								element.removeClassName("setstackitem_hover_first_inactive");
							}
						});
						obj.classify(item, null);//'setstackitem_hover_first');
					} else {
						var obj = new mouseOverClassify({'ignore_position':true});
						obj.classify(item, 'setstackitem_hover');
					}
				}
			}else{
				var eventAction = 'mouseover';
			}
			
			if(this.springloaded){
				// springload this slider activation by waiting a bit and then checking if we're still on top of the same item
				// this is a "dead" end panel with no hovers, no clicks, etc
				if(this.deadEndCap==true && i==elements.length-1){
					// do nothing
				} else {
					Event.observe(item, eventAction, 
						function(ev){
							this.springloaderBasket = item;
							setTimeout(function(e){
								if(this.springloaderBasket==item) { activationFunc(e); }
							}.bind(this,ev),this.springloadDelay);
						}.bind(this)
					);
				}
			} else {
				Event.observe(item, eventAction, activationFunc);				
			}
		}.bind(this));
	},
	
	// check for a queued effect. If one is present cancel the current one and start the new one
	checkForAnimationChange: function(effect){
		if(this.switchFlag==true){
			this.switchFlag=false;
			this.haveStoppedAnimating();
			effect.cancel();
			if(typeof(this.nextEffect)=='function') { this.nextEffect(); }
		}
	},

	// reset animation flags back to initial state before a transition has begun.
	resetFlagsAndClosures: function(){
		this.nextEffect = null;
		this.switchFlag = false;	
	},

	// queue up the next direction for the sliders
	signalAnimationChange: function(nextAnimationFunc){
		if(this.isAnimating==false){
			nextAnimationFunc();
			this.resetFlagsAndClosures();
		} else {
			this.nextEffect = nextAnimationFunc;
			this.switchFlag = true;
		}
	},
	
	// lock access to animation
	haveStartedAnimating: function(effect){
		this.isAnimating = true;
	},

	// unlock access to animation
	haveStoppedAnimating: function(effect,itemIndex){
		this.currentOpenIndex = itemIndex;
		this.isAnimating = false;
	},

	// create an event handler for accordion activation
	makeActivationEventHandlerFunc: function(runEffectFunc) {
		return function(ev){
			//Event.stop(ev);
			this.signalAnimationChange(runEffectFunc);
		}.bind(this);
	},

	slideToIndex: function(index){
		if(typeof(this.activators[index])=='function'){
			this.activators[index]();
		}
	},

	// create animation func for sliding effect
	makeSlideFunc: function(elements, currentElement, i){
		var getOpenLocation = function(j,sliceHeight,itemElement){
			return j * sliceHeight; // # of items "above/before" j is j items
		}.bind(this);
		
		var getClosedLocation = function(j,sliceHeight,openHeight,itemElement){
			if(j==0) { return this.reversed?(-sliceHeight):0; }
			// endCapCoversLastItem AND if this is the last panel AND previous panel is open
			if(this.endCapCoversLastItem && j==elements.length - 1 && itemElement.previous()==currentElement) {
				// end cap should cover last item of previous panel
				// We check how many elements less than 10 the previous set contains and nudge by however many
				// missing panels there are in the previous panel.
				var previousPanelContents = itemElement.previous().getElementsBySelector("ul.imagerange")[0];
				var params = this.getCSSParams(previousPanelContents);
				if(parseInt(params['sliceHeight']) > 0 && parseInt(params['openHeight']) > 0){
					// note: this won't work for a stack-in-a-stack-in-a-stack. It will only work for 2-deep. (stack-in-a-stack)
					var nudgeFactor = (10 - previousPanelContents.getElementsBySelector("li.stackitem").length) * (params['sliceHeight']);
					var result = this.reversed?((((j - 1) * sliceHeight) + openHeight)  - sliceHeight):(((j - 1) * sliceHeight) + openHeight);
					return result - nudgeFactor;
				} else {
					return this.reversed?((((j - 1) * sliceHeight) + openHeight)  - sliceHeight):(((j - 1) * sliceHeight) + openHeight);
				}
			}
			if(i < j) { return this.reversed?((((j - 1) * sliceHeight) + openHeight)  - sliceHeight):(((j - 1) * sliceHeight) + openHeight); }
			return this.reversed?((j * sliceHeight) - sliceHeight):(j * sliceHeight);
		}.bind(this);

		// return a function that makes element, the i'th element, slide to its open location. All other elements should slide to their locations too
		return function(){
			new Effect.Parallel(
				elements.collect(function(item,itemIndex){
					var fxOptions = {
						'x':(item==currentElement)?0:0,
						'y':((item==currentElement)?(getOpenLocation(itemIndex,this.sliceHeight,item)):(getClosedLocation(itemIndex,this.sliceHeight,this.openHeight,item))),
						'mode':'absolute',
						'sync':true,
						'beforeStart':function(effect){
							if(effect.element==currentElement){
								if(itemIndex==0 && this.applyFirstClass==true){
									effect.element.removeClassName("inactive_first");
									effect.element.addClassName("active_first");
								}
								effect.element.removeClassName("inactive");
								effect.element.addClassName("active");
							} else {
								if(itemIndex==0 && this.applyFirstClass==true){
									effect.element.removeClassName("active_first");
									effect.element.addClassName("inactive_first");
								}
								effect.element.removeClassName("active");
								effect.element.addClassName("inactive");
							}
						}.bind(this)
					};
					if(this.sideways){	// swap dimensions if we are travelling sideways
						var temp = fxOptions.y;
						fxOptions.y = fxOptions.x;
						fxOptions.x = temp;
					}
					return new Effect.Move(item,fxOptions);
				}.bind(this)),
				{
					'fps': 50, 'wait': false, 'duration': 200/1000, 
					'beforeUpdate': this.checkForAnimationChange.bind(this), 
					'beforeStart': this.haveStartedAnimating.bind(this), 
					'afterFinish': (function(itemIndex){
						return function(effect){
							this.haveStoppedAnimating(effect,itemIndex);
						}.bind(this);
					}.bind(this))(i)
				}
			);
		}.bind(this);
	}
};

}
/*----------------------------------------------------- StackedDeck.js ends ---------------------------------------------------------*/

/*----------------------------------------------------- Calendar.js starts ----------------------------------------------------------*/
/*
 * @Class: Calendar
 * 
 * @Description: An interactive calendar widget
 * 
 * @Usage: new Calendar(containerElement)
 *	
 * @Methods: no public methods
 * 
 */

var Calendar = (!detectBrowser.modernBrowser())?function(){}:Class.create();
Calendar.prototype = (!detectBrowser.modernBrowser())?{}:{
	initialize: function(div) {
		// don't draw calendar if div doesn't exist
		if(!div){ return false; }

		// This is the element into which all of the calendar's DOM elements are inserted
		this.container = div;

		this.today = new Date();
		this.month = this.today.getMonth();
		this.year = this.today.getFullYear();

		// Back and forward buttons to navigate months
		this.backward = new Element("a", {"class": "backward",'href':'#'});
		Event.observe(this.backward, "click", function(e) {
			this.changeMonth(this.month - 1);
			Event.stop(e);
			return false;
		}.bind(this));
		this.forward = new Element("a", {"class": "forward",'href':'#'});
		Event.observe(this.forward, "click", function(e) {
			this.changeMonth(this.month + 1);
			Event.stop(e);
			return false;
		}.bind(this));

		this.display_month = new Element("span").insert(Calendar.prototype.monthNames[this.month]);
		this.display_year = new Element("span").insert(this.year);
	
		// navigational elements
//		var tableNav_wrapper = new Element("div",{'id':'tableNav_wrapper'});
		var tableNav_wrapper = $('tableNav_wrapper');
		tableNav_wrapper.innerHTML = "";
		var tableNav = new Element("div", {'id': "tableNav"});
		tableNav.insert(this.backward);
		tableNav.insert(this.forward);
		tableNav.insert(this.display_month);
		tableNav.insert(this.display_year);
		tableNav_wrapper.insert(tableNav);
		this.container.insertBefore(tableNav_wrapper, this.container.firstChild);

		var tableAlreadyExists = false;
		this.table = this.container.getElementsBySelector("table")[0];

		// collect of all the days in the entire month
		this.cells = this.table.getElementsBySelector("td");
		// collection of all the week rows (empty or not)
		this.rows = this.table.getElementsBySelector("tr");

		// lazy-loaded list of events
		this.monthEventLists = {};

		this.populateTable();
	},

	// draw calendar
	populateTable: function() {
		var date = new Date(this.year, this.month, "1");
		var firstDay = date.getDay();
		date.setFullYear(this.year, this.month, "32");
		var numDays = 32 - date.getDate();

		// use much faster direct node manipulation instead of prototype's innerHTML-based method
		var newDrawMethod = false;

		var cellTexts = [];

		// give calendar cells numbers and styles, style the cell for today.
		for(var i = 0; i < this.cells.length; i++) {
			if(newDrawMethod && this.cells[i].firstChild && this.cells[i].firstChild.nodeType==1 && $(this.cells[i].firstChild).hasClassName('this_day_wrap')){
				this.cells[i].innerHTML = "";
			}
			var cellDigits = ((i - firstDay + 1)>9)?(i - firstDay + 1):"0"+(i - firstDay + 1).toString();
			var cellText = (i >= firstDay && i < (numDays + firstDay))?(cellDigits):String.fromCharCode(160);
			cellTexts[i] = cellText;
			if(newDrawMethod){
				if(this.cells[i].firstChild){
					this.cells[i].firstChild.nodeValue = cellText;
				} else {
					this.cells[i].appendChild(document.createTextNode(cellText));
				}
			} else {
				this.cells[i].update(cellText);
			}

			if(this.cells[i].hasClassName("event")){
				this.cells[i].removeClassName("event");
			}
			if(this.cells[i].hasClassName("today")){
				this.cells[i].removeClassName("today");
			}
			this.cells[i].stopObserving();

/*
			// handle keyboard focus for the link inside of the cell
			Event.observe(
				this.cells[i].firstChild,
				'focus',
				(function(cellIndex){
					return function(ev){
						if(
							typeof(this.cellOverlayHandlers)=='object' 
							&& this.cellOverlayHandlers!=null 
							&& this.cellOverlayHandlers.length > 0 
							&& typeof(this.cellOverlayHandlers[cellIndex])=='function'
						){
							this.cellOverlayHandlers[cellIndex](ev);
						}
					}.bind(this)
				}.bind(this))(i)
			);

			// warning: Calling a Prototypical function here out of laziness -- Dependence on FloatingInfo class internals
			Event.observe(
				this.cells[i].firstChild,
				'blur',
				(function(cellIndex){
					return function(ev){
						FloatingInfo.prototype.hideOverlay();
						ev.stop();
					}.bind(this);
				}.bind(this))(i)
			);
*/

		}
	
		// Style "today's" cell properly, (if we're displaying the current month)
		if(this.month == this.today.getMonth() && this.year == this.today.getFullYear()){
			var thisDay = this.cells[this.today.getDate() + (firstDay - 1)];
			thisDay.addClassName("today");
			var thisDayWrap = new Element("div", {"class":"this_day_wrap"}).insert(thisDay.innerHTML);
			thisDay.innerHTML = "";
			thisDay.insert(thisDayWrap);
			var thisDayHeight = Math.round(this.table.getHeight() / 6);
			thisDayWrap.setStyle({
				'height':(thisDayHeight - 2) + 'px',
				'lineHeight':(thisDayHeight - 2) + 'px'
			});
		}

		// fetch events for this month and convert into a handy array of hashes
		//if(typeof(this.monthEventLists[this.month])=='undefined'){
			this.monthEventLists[this.month] = this.getEventListItems().select(function(listItem){
				var startDateElement = listItem.getElementsBySelector("abbr.dtstart")[0];
				var endDateElem = listItem.getElementsBySelector("abbr.dtstart")[0];
				var endDateAttrs = endDateElem?endDateElem.getAttribute("title").split("-"):null;
				var yearofevent=(endDateAttrs && endDateAttrs.length>=3)?parseInt(endDateAttrs[0]):undefined;
				return(startDateElement && startDateElement.getAttribute("title").indexOf("-"+(this.month+1)+"-") > -1
				&& yearofevent==this.year);
			}.bind(this)).collect(function(listItem){
				//
				// Parse hCalendar microformat
				//
				var linkElem = listItem.getElementsBySelector("a.url")[0];
				var startDateElem = listItem.getElementsBySelector("abbr.dtstart")[0];
				var endDateElem = listItem.getElementsBySelector("abbr.dtstart")[0];
				var summaryElem = listItem.getElementsBySelector("h3.summary")[0];
				var descriptionElem = listItem.getElementsBySelector("p.description")[0];
				var startDateAttrs = startDateElem?startDateElem.getAttribute("title").split("-"):null;
				var endDateAttrs = endDateElem?endDateElem.getAttribute("title").split("-"):null;
				return {
					'start_day':(startDateAttrs && startDateAttrs.length>=3)?parseInt(startDateAttrs[2]):undefined,
					'start_month':(startDateAttrs && startDateAttrs.length>=3)?parseInt(startDateAttrs[1]):undefined,
					'start_year':(startDateAttrs && startDateAttrs.length>=3)?parseInt(startDateAttrs[0]):undefined,
					'end_day':(endDateAttrs && endDateAttrs.length>=3)?parseInt(endDateAttrs[2]):undefined,
					'end_month':(endDateAttrs && endDateAttrs.length>=3)?parseInt(endDateAttrs[1]):undefined,
					'end_year':(endDateAttrs && endDateAttrs.length>=3)?parseInt(endDateAttrs[0]):undefined,
					'summary':summaryElem?summaryElem.innerHTML.strip():"",
					'description':descriptionElem?descriptionElem.innerHTML.strip():"",
					'url':linkElem?linkElem.getAttribute("href").strip():"#",
					'linktext':linkElem?linkElem.innerHTML.strip():""
				};
			}.bind(this));
		//}

		if(this.monthEventLists[this.month].length > 0) {
			// assign overlay events for any day cells that contain events

			// cellOverlayHandlers is an array that holds all the current closures that pop up overlays to show events
			this.cellOverlayHandlers = [];
			for(var i = 0; i < this.cells.length;i++) {
				if(i >= (firstDay)){
					var cell = this.cells[i];
					var dayIndex = i - firstDay;
					var calendarDay = dayIndex + 1;
					// grab all the events for this given day
					var todaysEvents = this.monthEventLists[this.month].select(function(item){return item.start_day==calendarDay;});

					if(todaysEvents.length > 0){

						// overlay closure to float information about this event
						var todaysEventOverlay = function(cellElement, private_month, eventCollection) {
							return function (event) {
								var currentEventIndex = 0;
								new FloatingInfo(cellElement, {
									'float':'auto',
									'padding':0,
									'floatDirection':'auto',
									'arrowClass':'float_arrow',
									'overlayClasses':{
										'top':'floatType_calendar_top',
										'inner':'floatType_calendar_inner',
										'bottom':'floatType_calendar_bottom'
									},
									// this function is called *once* by FloatingInfo in order to allow for custom rendering in the calendar overlay
									'contentRender':function(contentElement_){
										// this render function is called by the buttons in the calendar overlay
										this.renderOverlayContents(contentElement_,eventCollection,currentEventIndex);
									}.bind(this)
								});
								Event.stop(event);
							}.bind(this);
						}.bind(this)($(cell), this.month, todaysEvents);

						// for keyboard handling: the text of the cell has to be a link so that IE can focus on it (accessibility/508)
						cell.update("<a href='#'>" + cellTexts[i] + "</a>");

						// handle keyboard focus for the link inside of the cell
						Event.observe(
							this.cells[i].firstChild,
							'focus',
							(function(cellIndex){
								return function(ev){
									if(
										typeof(this.cellOverlayHandlers)=='object' 
										&& this.cellOverlayHandlers!=null 
										&& this.cellOverlayHandlers.length > 0 
										&& typeof(this.cellOverlayHandlers[cellIndex])=='function'
									){
										this.cellOverlayHandlers[cellIndex](ev);
									}
								}.bind(this)
							}.bind(this))(i)
						);

						// warning: Calling a Prototypical function here out of laziness -- Dependence on FloatingInfo class internals
						Event.observe(
							this.cells[i].firstChild,
							'blur',
							(function(cellIndex){
								return function(ev){
									FloatingInfo.prototype.hideOverlay();
									ev.stop();
								}.bind(this);
							}.bind(this))(i)
						);

						cell.addClassName("event");
						var hoverObj = new mouseOverClassify();
						hoverObj.classify(cell, 'eventHover');

						// hover a floating info overlay for day cells which have events associated with them
						Event.observe(cell, "mouseover", todaysEventOverlay);
						this.cellOverlayHandlers[i] = todaysEventOverlay;

					} else {
						this.cellOverlayHandlers[i] = null;
					}
				}
			} // end overlay assignment loop

		}

		// style calendar as 6 rows, always
		this.rows[4].className = "";
		this.rows[5].className = "";
		this.rows[6].className = "row_last";
		this.table.className = "rows_6";
	},
	
	renderOverlayContents:function(contentElement,eventCollection,currentEventIndex){
		contentElement.innerHTML = "";
		var eventObject = eventCollection[currentEventIndex];
		var title = new Element("h3",{});
		title.update(eventObject.summary);
		var body = new Element("p",{});
		body.update(eventObject.description);
		var link = new Element("a",{'className':'event_url','href':eventObject.url});
		if (eventObject.url == '#' ){}
		else {link.update("&rsaquo; "+eventObject.linktext);}
		//
		// Back/forward buttons on calendar overlay
		// these are only drawn if we have more than one event on this day
		//
		if(eventCollection.length > 1){
			var eventNavContainer = new Element("div",{'className':'event_nav_container'});
			var locationLabel = new Element("div",{'className':'event_label'});
			var prevBtn = new Element("a",{'href':'#','className':'event_prev'});
			var nextBtn = new Element("a",{'href':'#','className':'event_next'});
			// locationLabel is the label that says, for example: "Event 1 of 5"
			locationLabel.update("Event "+(currentEventIndex+1)+" of "+eventCollection.length);
			prevBtn.update(" ");
			nextBtn.update(" ");
			var callRender = function(incrementor){
				currentEventIndex = currentEventIndex + incrementor;
				Event.stopObserving(prevBtn,'click',prevFunc);
				Event.stopObserving(nextBtn,'click',nextFunc);
				//
				// re-render the inner content region of the calendar overlay
				//
				this.renderOverlayContents(contentElement,eventCollection,currentEventIndex); 
			}.bind(this);
			//
			// forward / back click event handlers
			//
			var prevFunc = function(ev){
				if(currentEventIndex>0){
					callRender(-1);
				} else {
					currentEventIndex = eventCollection.length - 1;
					callRender(0);
				}
				ev.stop();
				return false;
			};
			var nextFunc = function(ev){
				if(currentEventIndex < eventCollection.length - 1){
					callRender(1);
				} else {
					currentEventIndex = 0;
					callRender(0);
				}
				ev.stop();
				return false;
			};
			Event.observe(nextBtn,'click',nextFunc);
			Event.observe(prevBtn,'click',prevFunc);

			eventNavContainer.appendChild(prevBtn);
			eventNavContainer.appendChild(locationLabel);
			eventNavContainer.appendChild(nextBtn);
			contentElement.appendChild(eventNavContainer);
		}
		contentElement.appendChild(title);
		contentElement.appendChild(body);
		contentElement.appendChild(link);
	},

	// fetch the list item elements representing events
	getEventListItems:function(){
		if(typeof(this.eventListCache)=='undefined'){
			this.eventListCache = this.container.getElementsBySelector("ul.eventlist li");
		}
		return this.eventListCache;
	},

	// navigate to newMonth and redraw the calendar situated in newMonth
	changeMonth: function(newMonth) {
		this.month = newMonth;
	
		if(this.month == -1) {
			this.month = 11;
			this.year--;
		} else if(this.month == 12) {
			this.month = 0;
			this.year++;
		}
	
		this.display_month.update(Calendar.prototype.monthNames[this.month]);
		this.display_year.update(this.year);
	
		this.populateTable();
	},

	monthNames: [
		"January", 
		"February", 
		"March", 
		"April", 
		"May", 
		"June", 
		"July", 
		"August", 
		"September", 
		"October", 
		"November", 
		"December"
	]
};

if(detectBrowser.modernBrowser()){
	Event.observe(window, 'load', function() { 
	 	$$('.NASACalendar').each(function(calendarElement){
			var c = new Calendar(calendarElement);
		});
	});
}
/*----------------------------------------------------- Calendar.js ends ------------------------------------------------------------*/

/*----------------------------------------------------- launch_calendar.js starts ---------------------------------------------------*/
if(detectBrowser.modernBrowser()){


//                        year  mo day  hr  min sec
//
//
//											NOTE: 0 = january
//											11 = december
//
document.observe('contentloaded', function() {
	var clock_day = $("day");
	var clock_hour = $("hour");
	var clock_minute = $("minute");
	var clock_second = $("second");
	if(clock_day && clock_hour && clock_minute && clock_second){
		var launchDate = new Date(2007, 9, 31, 18, 30, 15, 0);

		function getDHMS(targetDate){
			var nowDate = new Date();
			var secondsTillLaunch = Math.floor(targetDate.getTime() / 1000) - Math.floor(nowDate.getTime() / 1000);
			var daysLeft = Math.floor(secondsTillLaunch / (60 * 60 * 24));
			var leftoverHours = Math.floor((secondsTillLaunch - (daysLeft * 60 * 60 * 24)) / (60 * 60));
			var leftoverMinutes = Math.floor( (secondsTillLaunch - (daysLeft * 60 * 60 * 24) - (leftoverHours * 60 * 60)) / 60);
			var leftoverSeconds = Math.floor( (secondsTillLaunch - (daysLeft * 60 * 60 * 24) - (leftoverHours * 60 * 60) - (leftoverMinutes * 60)));
			var pastFlag = false;
			if(secondsTillLaunch < 0){
				pastFlag = true;
			}
			return {
				'daysleft':daysLeft,
				'hoursleft':leftoverHours,
				'minutesleft':leftoverMinutes,
				'secondsleft':leftoverSeconds,
				'pastFlag':pastFlag
			};
		}
	
		new PeriodicalExecuter(function(){
			var d = getDHMS(launchDate);
			if(d.pastFlag){
				clock_day.update("00");
				clock_hour.update("00");
				clock_minute.update("00");
				clock_second.update("00");
			} else {
				if(d.daysleft < 10) clock_day.update("0" + d.daysleft);
				else clock_day.update(d.daysleft);

				if(d.hoursleft < 10) clock_hour.update("0" + d.hoursleft);
				else clock_hour.update(d.hoursleft);

				if(d.minutesleft < 10) clock_minute.update("0" + d.minutesleft);
				else clock_minute.update(d.minutesleft);

				if(d.secondsleft < 10) clock_second.update("0" + d.secondsleft);
				else clock_second.update(d.secondsleft);
			}
		}, 1);
	}
});

}
/*----------------------------------------------------- launch_calendar.js ends -----------------------------------------------------*/

/*----------------------------------------------------- TagCloud.js ends -----------------------------------------------------*/
if(detectBrowser.modernBrowser()){



document.observe("contentloaded",function(){

	/* seedable random number functionality */

	var RandSeed = 0;
	var initRandSeed=null;

	// used by seedble random number functionality
	function PrfxTo(S, L, C) {
		S += ""
		if (C.length>0){
			while (S.length<L) {
				S = C + S ;
			}
		}
		return S;
	}

	// used by seedble random number functionality
	function StrU(X, M, N) { // X > -0.5e-N ; to M digits point N digits
		var S = String(Math.round(X*Math.pow(10, N)));

		if (/\D/.test(S)){
			return SpcsTo(X, M+N+1); // cannot cope
		}
		S = PrfxTo(S, M+N, '0');
		var T = S.length - N;
		return S.substring(0, T) + '.' + S.substring(T);
	}

	// used by seedble random number functionality
	function SpcsTo(S, L) {
		S += "" // SpcsTo is a reduction of PrfxTo
		while (S.length<L) {
			S = " " + S;
		}
		return S;
	}

	// used by seedble random number functionality
	function StrT(X, M, N) {
		return SpcsTo(StrU(X, 1, N), M+N+2);
	}

	// used by seedble random number functionality
	function RRN2(_initseed) {
		if(initRandSeed==null){
			initRandSeed = _initseed;
		}
		var Q
		var XX = [];
		var rnge = Math.pow(2, 32);
		function SeedRand() {
			return (RandSeed = ((134775813*initRandSeed)*RandSeed+1)%rnge)/rnge;
		}
		for (var Q = 0; Q < 9; Q++){
			XX[Q] = StrT(SeedRand(), 1, 3);
		}
		return XX[XX.length - 1];
	}


	function drawCloud(container){
		var words = container.getElementsBySelector("li a").map(function(item){
			var h = $H({ name: item.innerHTML.strip(), href: item.readAttribute('href') });
			return h;
		});

		// start up the random generator using our word list as the seed
		var randInit = (Math.round(RRN2(words.join("").split("").inject(0,function(acc,n){
			return (acc = acc + n.charCodeAt(0));
		})) * 12));

		var basketHeight = 45;

		var tagCloudWrapperContainer = new Element("div");

		for(var i=0;i<words.length;i++){

			var d = new Element("div");
			d.appendChild(new Element("div"));
			d.firstChild.appendChild(new Element("a",{'href':words[i]['href']}));
			d.firstChild.firstChild.appendChild(document.createTextNode(words[i]['name']));
			d.setStyle({
				'height':'45px',
				'float':'left'
			});

			var link = $(d.firstChild.firstChild);
			(function(elem){
				Event.observe(elem,"mouseover",function(){
					elem.setStyle({'color':'#99ccff'});
				});
				Event.observe(elem,"mouseout",function(){
					elem.setStyle({'color':'#ffffff'});
				});
			})(link);
			link.setStyle({'color':'#ffffff'});

			// TODO : this text size will not be randomized but rather depend on a priority attribute on the tags from eTouch.
			var textsize = 12 + Math.round(RRN2() * 13);
			$(d.firstChild).setStyle({
				'fontSize':textsize+'px',
				'lineHeight':textsize+'px',
				'whiteSpace':'nowrap',
				'paddingLeft':'8px',
				'paddingRight':'8px',
				'paddingTop':Math.round(RRN2() * (basketHeight - textsize)) + "px"
			});
			tagCloudWrapperContainer.appendChild(d);
		}
		
		container.appendChild(tagCloudWrapperContainer);
	}

	//
	// tag cloud boot strap
	//
	$$('.tag_cloud').each(function(container){
		drawCloud(container);
	});

});

}
/*----------------------------------------------------- TagCloud.js ends -----------------------------------------------------*/






