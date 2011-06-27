function showBlueIconRSS(placeholderid, rssurl) {
    var htmlVal='<a class="myOverlayRSS rss bottom null (none) icons_blue icon_rss" href="' + rssurl + '"><span class="hide">RSS</span></a>';
    document.getElementById(placeholderid).innerHTML=htmlVal;
    document.getElementById('curr_rssurl').value="";
}

function showBlackIconRSS(placeholderid, rssurl) {
       var htmlVal='<a class="myOverlayRSS rss bottom null (none) icons_black icon_rss" href="' + rssurl + '"><span class="hide">RSS</span></a>';
       document.getElementById(placeholderid).innerHTML=htmlVal;
       document.getElementById('curr_rssurl').value="";
}
