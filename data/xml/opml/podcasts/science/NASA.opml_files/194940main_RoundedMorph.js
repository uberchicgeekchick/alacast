if(detectBrowser.modernBrowser()){




/*
 * @Class: RoundedMorph
 * 
 * @Description: A class which re-implements Scriptaculous' Effect.Morph 
 * 
 * @Usage: See scriptaculous' usage of Effect.Morph
 * 
 */

Effect.RoundedMorph=Class.create();
Object.extend(Object.extend(Effect.RoundedMorph.prototype, Effect.Base.prototype), {
  initialize: function(element) {
    this.element=$(element);
    if(!this.element) throw(Effect._elementDoesNotExistError);
    var options=Object.extend({
      style: {}
    }, arguments[1] || {});
    if (typeof options.style == 'string') {
      if(options.style.indexOf(':') == -1) {
        var cssText='', selector='.' + options.style;
        $A(document.styleSheets).reverse().each(function(styleSheet) {
          if (styleSheet.cssRules) cssRules=styleSheet.cssRules;
          else if (styleSheet.rules) cssRules=styleSheet.rules;
          $A(cssRules).reverse().each(function(rule) {
            if (selector == rule.selectorText) {
              cssText=rule.style.cssText;
              throw $break;
            }
          });
          if (cssText) throw $break;
        });
        this.style=cssText.parseStyle();
        options.afterFinishInternal=function(effect){
          effect.element.addClassName(effect.options.style);
          effect.transforms.each(function(transform) {
            if(transform.style != 'opacity')
              effect.element.style[transform.style]='';
          });
        };
      } else this.style=options.style.parseStyle();
    } else this.style=$H(options.style);
    this.start(options);
  },
  setup: function(){
    function parseColor(color){
      if(!color || ['rgba(0, 0, 0, 0)','transparent'].include(color)) color='#ffffff';
      color=color.parseColor();
      return $R(0,2).map(function(i){
        return parseInt( color.slice(i*2+1,i*2+3), 16 );
      });
    };
    this.transforms=this.style.map(function(pair){
      var property=pair[0], value=pair[1], unit=null;

      if(value.parseColor('#zzzzzz') != '#zzzzzz') {
        value=value.parseColor();
        unit ='color';
      } else if(property == 'opacity') {
        value=parseFloat(value);
        if(Prototype.Browser.IE && (!this.element.currentStyle.hasLayout))
          this.element.setStyle({zoom: 1});
      } else if(Element.CSS_LENGTH.test(value)) {
          var components=value.match(/^([\+\-]?[0-9\.]+)(.*)$/);
          value=parseFloat(components[1]);
          unit=(components.length == 3) ? components[2] : null;
      }

      var originalValue=this.element.getStyle(property);
      return { 
        style: property.camelize(), 
        originalValue: unit=='color' ? parseColor(originalValue) : parseFloat(originalValue || 0), 
        targetValue: unit=='color' ? parseColor(value) : value,
        unit: unit
      };
    }.bind(this)).reject(function(transform){
      return (
        (transform.originalValue == transform.targetValue) ||
        (
          transform.unit != 'color' &&
          (isNaN(transform.originalValue) || isNaN(transform.targetValue))
        )
      );
    });
  },
  update: function(position) {
    var style={}, transform, i=this.transforms.length;
    while(i--)
      style[(transform=this.transforms[i]).style]=
        transform.unit=='color' ? '#'+
          (Math.round(transform.originalValue[0]+
            (transform.targetValue[0]-transform.originalValue[0])*position)).toColorPart() +
          (Math.round(transform.originalValue[1]+
            (transform.targetValue[1]-transform.originalValue[1])*position)).toColorPart() +
          (Math.round(transform.originalValue[2]+
            (transform.targetValue[2]-transform.originalValue[2])*position)).toColorPart() :
        Math.round(transform.originalValue + Math.round(
          ((transform.targetValue - transform.originalValue) * position) * 1000)/1000) + transform.unit;
    this.element.setStyle(style, true);
  }
});

document.observe('contentloaded',function(){
	if(window['ast']==true){
		var maxheight=34;
		var maxwidth=34;
		var extents={};
		var updateExtents=function() {
			var xoffset=document.viewport.getScrollOffsets()[0];
			var yoffset=document.viewport.getScrollOffsets()[1];
			var d=document.viewport.getDimensions();
			extents.miny=yoffset + 34;
			extents.y=d.height + yoffset;
			extents.minx=xoffset + 34;
			extents.x=d.width + xoffset;
		};
		updateExtents();
		Event.observe(window,'resize',updateExtents);
		Event.observe(window,'scroll',updateExtents);
		$A($R(0,10)).each(function(i){
			//
			//     1
			//  4     2
			//     3
			//
			var getNextFace=function(except){
				var nextFace=Math.round(Math.random()*3)+1;
				while(nextFace==except){ nextFace=Math.round(Math.random()*3)+1; }
				return nextFace;
			};
			var getFaceLocation=function(whichFace){
				var nextx;
				var nexty;
				if(whichFace==1){
					nexty=extents.miny;
					nextx=extents.minx + (Math.random()*(extents.x - extents.minx));
				} else if(whichFace==3){
					nexty=extents.y;
					nextx=extents.minx + (Math.random()*(extents.x - extents.minx));
				} else if(whichFace==2){
					nextx=extents.x;
					nexty=extents.miny + (Math.random()*(extents.y - extents.miny));
				} else { //4
					nextx=extents.minx;
					nexty=extents.miny + (Math.random()*(extents.y - extents.miny));
				}
				return [nextx,nexty];
			};
			
			var x=Math.round(Math.random()*(extents.x));
			var y=Math.round(Math.random()*(extents.y));
			var aclicked=false;
			var a=new Element("div",{});
			var face=Math.round(Math.random()*3)+1;

			a.setStyle({
				'position':'absolute',
				'zIndex':9999,
				'left':x+'px',
				'top':y+'px',				
				'width':(Math.round(Math.random()*20)+10)+'px',
				'height':(Math.round(Math.random()*20)+10)+'px',
				'lineHeight':'1px',
				'fontSize':'1px'
			});
			a=$(document.body.appendChild(a));
			Event.observe(a,'click',function(ev){
				if(ev.target==a){
					aclicked=true;
					ev.stop();
				}
			});
			var makeNext=function(nx,ny){
				new Effect.Move(a,{
					'mode':'absolute',
					'transition':Effect.Transitions.linear,
					'x':nx,
					'y':ny,
					'duration':(6+(Math.random()*8)),
					'beforeUpdate':function(effect){
						if(aclicked){
							effect.element.setStyle({'display':'none'});
							effect.stop();
						}
					},
					'afterFinish':function(effect){
						face=getNextFace(face);
						var nextLocation=getFaceLocation(face);
						makeNext(nextLocation[0],nextLocation[1]);
					}
				});				
			};

			var initialLocation=getFaceLocation(face);

		});
	}
});






}
