// Begin Baynote Observer
function baynote_setAttributes(names) {
	var toCapture = names.split(",");
	var metas = document.getElementsByTagName("meta");
	if (!metas) {return;}
	
	for (var i = 0; i < toCapture.length; i++) { 
		for (var j = 0; j < metas.length; j++) {
			if (metas[j] && metas[j].name == toCapture[i]) {
				baynote_tag.docAttrs.pageType = metas[j].content;
			}
		}
	}
}

function baynote_removeHtml(raw) {
	raw = raw.replace(/\<[^>]*\>/g, "");
	raw = raw.replace(/\<.*/, "");
	raw = raw.replace(/\ /g, " ");
	raw = raw.replace(/^\s+/, "");
	raw = raw.replace(/\s+$/, "");
	raw = raw.replace(/\n/g, " ");
    raw = raw.replace(/&nbsp;/g, " ");
    raw = raw.replace(/&amp;/g, "&");
    
	return raw;
}
function baynote_isNotEmpty(name) {
	return (typeof(name) != "undefined") && (name != null) && (name != "");
}

baynote_tag.server="http://observer1.nasa.gov";
baynote_tag.customerId="nasa";
baynote_tag.code="gov";
baynote_tag.type="baynoteObserver";
baynote_globals.cookieDomain="nasa.gov";
var tmpTitle;
if (document.getElementsByTagName("title")[0])
{tmpTitle = document.getElementsByTagName("title")[0].innerHTML;}
if(baynote_isNotEmpty(tmpTitle)){
	baynote_tag.title = baynote_removeHtml(tmpTitle.replace(/^NASA - (.*)/, "$1"));
}
baynote_setAttributes("dc.type");

baynote_tag.show();
// End Baynote Observer

