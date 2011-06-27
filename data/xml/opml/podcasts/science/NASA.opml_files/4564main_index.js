// Banner Navigation Links
function flashURL(id) {
  var s='';
  if(id==0) {
	  s='#';
	} else if(id==1) {
		s='#';
	} else if(id==2) {
		s='#';
	}
	window.location.href=s;
}

// Left Navigation Links
//Correct links updated by Venu
function homeNav(id) {
  var s='';
  if(id==0) {
	  s='/audience/forkids/home/index.html';
	} else if(id==1) {
	  s='/audience/forstudents/k-4/home/index.html';
	} else if(id==2) {
	  s='/audience/forstudents/5-8/features/index.html';
	} else if(id==3) {
	  s='/audience/forstudents/9-12/features/index.html';
	} else if(id==4) {
	  s='/audience/forstudents/postsecondary/features/index.html';
	} else if(id==5) {
	  s='/audience/foreducators/k-4/features/index.html';
	} else if(id==6) {
	  s='/audience/foreducators/5-8/features/index.html';
	} else if(id==7) {
	  s='/audience/foreducators/9-12/features/index.html';
	} else if(id==8) {
	  s='/audience/foreducators/postsecondary/features/index.html';
	} else if(id==9) {
	  s='/audience/foreducators/informal/features/index.html';
	} else if(id==10) {
	  s='/audience/formedia/features/index.html';
	} else if(id==11) {
	  s='/audience/forresearchers/features/index.html';
	} else if(id==12) {
	  s='/audience/foremployees/index.html';
	} else if(id==13) {
	  s='/audience/forindustry/home/index.html';
	}
	window.location.href=s;
}

// Left Navigation Links for ForKids Leftnav
function kidsNav(id) {
  var s='';
  if(id==0) {
	  s='/audience/forkids/games/index.html';
	} else if(id==1) {
	  s='/audience/forkids/artsstories/index.html';
	} else if(id==2) {
	  s='/audience/forkids/activities/index.html';
	} else if(id==3) {
	  s='/audience/forkids/kidsclub/flash/index.html';
	} else if(id==4) {
	  s='#';
	} else if(id==5) {
	  s='#';
	} else if(id==6) {
	  s='#';
	} else if(id==7) {
	  s='#';
	} else if(id==8) {
	  s='#';
	}
	window.location.href=s;
}


// Banner Select Code
var sBanner=0;
function switchBanner(id) {
  swapImg('banner','/images/banner/home/banner_'+id+'.jpg');
	sBanner=id;
}

// Navigation Item String Concat
function getNavItem(nm,alt,idx) {
  var s='<a href="javascript:homeNav('+idx+');" onmouseover="swapImg(\'navli'+idx+'\',\'/images/navigation/leftnav/home/nav_left_'+nm+'_1.gif\');" ';
	s+='onmouseout="swapImg(\'navli'+idx+'\',\'/images/navigation/leftnav/home/nav_left_'+nm+'_0.gif\');">';
	s+='<img src="/images/navigation/leftnav/home/nav_left_'+nm+'_0.gif" alt="'+alt+'" title="'+alt+'" border="0" name="navli'+idx+'" id="navli'+idx+'" /></a>';
	return s;
}
