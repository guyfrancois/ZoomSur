/**
 * @author GuyF , pense-tete.com
 * @date 8 mars 07
 * 
 */
import Pt.Tools.ClipEvent; 
import Pt.scan.Souris;
import Pt.Temporise;
import org.aswing.util.Delegate;

class Pt.Tools.TextScoller {
	private var IMG_OVER:Number=2;
	private var IMG_OUT:Number=1;
	private var IMG_PRESS:Number=3;
	
	private var clipTexte:MovieClip;
	private var _baseXText:Number;
	private var _baseYText:Number;
	private var _maxWidthText:Number;
	private var texte:TextField;
	
	private var scrollerMC:MovieClip;
	private var asScroller:String;
	
	private var droite:Boolean
	
	private var margeX:Number;
	private var margeY:Number;
	
	private var souris:Souris;
	private var wheelListener:Object;
	/**
	 * ClipTexte contient
	 * 	texte:TextField;
	 * 	@param clipTexte : clip contenant le champs text (textField) nommé "texte"
	 * 		le clip contiendra la barre de scroll
	 * 	@param droite si true barre a droite
	 * 	@param asScroller nom de liaison du clip à créér pour le scroller
	 * 		contient :
	 * 			clip "fond" pouvant être redimensionné en hauteur 
	 * 			un clip "manette"
	 * 			alignés en x=0;
	 */
	public function TextScoller(clipTexte:MovieClip,droite:Boolean,asScroller:String,margeX:Number,margeY:Number) {
		//trace("Pt.Tools.TextScoller.TextScoller("+clipTexte+", "+droite+", "+asScroller+")");
		if (margeX!=undefined) {
			this.margeX=margeX;
		} else {
			this.margeX=20;
		}
        if (margeY!=undefined) {
            this.margeY=margeY;
        } else {
            this.margeY=0;
        }

		if (droite) {
			this.droite=true;
		} else {
			this.droite=false;
		}
		this.asScroller=asScroller;
		this.clipTexte=clipTexte;
		texte=clipTexte.texte;
		_baseXText=texte._x;
		_baseYText=texte._y;
		_maxWidthText=texte._width;
		souris=new Souris(clipTexte);
		wheelListener=souris.addEventListener(Souris.ON_MOUSEWHEEL,this._onWheel,this);
		texte.onScroller = Delegate.create(this, ontextScrollChange)
	}
	
	
	private function ontextScrollChange(){
		//trace("Pt.Tools.TextScoller.ontextScrollChange()");
		//trace("maxscroll:"+texte.maxscroll+" _maxscroll:"+_maxscroll);
		if (_maxscroll!=texte.maxscroll) {
			onChanged();
		}
	}
	
	private function _onWheel(src:Souris,incr:Number){
		//trace("Pt.Tools.TextScoller._onWheel(src, "+incr+")");
		if (clipTexte==undefined) {
			src.stopScan();

		}
		if (src.hasMouseOver()) {
			scrollTo(getYPos()+scrollerMC.fond._y-incr*pas);
		}
	}
	/**
	 * le texte à changé
	 */
	 private var _maxscroll:Number;
	public function onChanged(){
		//trace("Pt.Tools.TextScoller.onChanged()");
		//trace(texte.maxscroll);
		_maxscroll=texte.maxscroll;
		_baseXText=texte._x;
		_baseYText=texte._y;
		_maxWidthText=texte._width;
		
		texte.scroll=1;
		if (texte.maxscroll>1) {
			if (scrollerMC==undefined) {
				addScroller();
			}
		} else {
			if (scrollerMC!=undefined) {
				removeScroller();
			}
		}
		if (scrollerMC!=undefined) {
				updateScoller();
		}
		
	}
	
	
	
	private function addScroller(){
		
		if (droite) {
			scrollerMC=clipTexte.attachMovie(asScroller,"scrollerMC",10,{_x:_baseXText,_y:Math.floor(_baseYText+margeY)});
			
			//texte._width=_maxWidthText-scrollerMC._width-2;
			scrollerMC._x=Math.floor(texte._x+texte._width+margeX);
		
		} else {
			scrollerMC=clipTexte.attachMovie(asScroller,"scrollerMC",10,{_x:_baseXText,_y:Math.floor(_baseYText+margeY)});
			texte._x=Math.floor(_baseXText+scrollerMC._width+margeX);
			texte._width=_maxWidthText-scrollerMC._width-margeX;
		}
		//trace("Pt.Tools.TextScoller.addScroller():"+scrollerMC);
		initScrollerMover();
	}
	public function removeScroller(){
		//trace("Pt.Tools.TextScoller.removeScroller()");
		scrollerMC.removeMovieClip();
		scrollerMC=undefined;
		texte._x=_baseXText;
		texte._width=_maxWidthText;
		souris.stopScan()
		temopScroll.destroy();
	}

	
	private function  initScrollerMover(){
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onRollOver");
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onRollOut");
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onPress");
		ClipEvent.setEventsTrigger(scrollerMC.fond,"onPress");
		
		
		
		ClipEvent.setEventsTrigger(scrollerMC.btn_haut,"onRollOver");
        ClipEvent.setEventsTrigger(scrollerMC.btn_haut,"onRollOut");
        ClipEvent.setEventsTrigger(scrollerMC.btn_haut,"onPress");
        ClipEvent.setEventsTrigger(scrollerMC.btn_haut,"onRelease");
        ClipEvent.setEventsTrigger(scrollerMC.btn_haut,"onReleaseOutside");
        
        ClipEvent.setEventsTrigger(scrollerMC.btn_bas,"onRollOver");
        ClipEvent.setEventsTrigger(scrollerMC.btn_bas,"onRollOut");
        ClipEvent.setEventsTrigger(scrollerMC.btn_bas,"onPress");
        ClipEvent.setEventsTrigger(scrollerMC.btn_bas,"onRelease");
        ClipEvent.setEventsTrigger(scrollerMC.btn_bas,"onReleaseOutside");
        
        scrollerMC.btn_haut.addEventListener("onRollOver",onOver,this);
        scrollerMC.btn_haut.addEventListener("onRollOut",onOut,this);
        scrollerMC.btn_haut.addEventListener("onPress",onHaut,this);
        scrollerMC.btn_haut.addEventListener("onRelease",onOver,this);
        scrollerMC.btn_haut.addEventListener("onReleaseOutside",onOut,this);
        
        scrollerMC.btn_bas.addEventListener("onRollOver",onOver,this);
        scrollerMC.btn_bas.addEventListener("onRollOut",onOut,this);
        scrollerMC.btn_bas.addEventListener("onPress",onBas,this);
        scrollerMC.btn_bas.addEventListener("onRelease",onOver,this);
        scrollerMC.btn_bas.addEventListener("onReleaseOutside",onOut,this);
		
		
		scrollerMC.fond.addEventListener("onPress",onPressFond,this);
		
		//scrollerMC.fond.useHandCursor=false;
		scrollerMC.manette.gotoAndStop(IMG_OUT);
		scrollerMC.btn_bas.gotoAndStop(IMG_OUT);
		scrollerMC.btn_haut.gotoAndStop(IMG_OUT);
		
		scrollerMC.manette.addEventListener("onRollOver",onOver,this);
		scrollerMC.manette.addEventListener("onRollOut",onOut,this);
		scrollerMC.manette.addEventListener("onPress",startScan,this);
		
		scrollerMC.manette.addEventListener("onMouseMove",_onMouseMove,this);
		scrollerMC.manette.addEventListener("onRelease",stopScan,this);
		scrollerMC.manette.addEventListener("onReleaseOutside",stopScan,this);
		souris.startScan();
		
	}
	
	private var manetteYMouse:Number;

	
	
	function startScan() {
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onMouseMove");
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onRelease");
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onReleaseOutside");
		manetteYMouse=scrollerMC.manette._ymouse;
		scrollerMC.manette.gotoAndStop(IMG_PRESS);
	
	}
	
	private function onPressFond(){
		//trace("Pt.Tools.TextScoller.onPressFond()");
		manetteYMouse=0;
		 _onMouseMove();
	}
	function get pas():Number {
		return Math.floor((scrollerMC.fond._height-scrollerMC.manette._height)/texte.maxscroll);
	}
	
	
	private function onHaut(clip:MovieClip){
		clip.gotoAndStop(IMG_PRESS);
		scrollTo(scrollerMC.manette._y-pas);
	}
	private function onBas(clip:MovieClip){
		clip.gotoAndStop(IMG_PRESS);
        scrollTo(scrollerMC.manette._y+pas);    
	}
	function getYPos():Number {
    	return scrollerMC.manette._y-scrollerMC.fond._y;
    }
    
	private function scrollTo(nextY:Number) {
		if (nextY<scrollerMC.fond._y) {
            scrollerMC.manette._y = Math.floor(scrollerMC.fond._y);
        } else if (nextY>(scrollerMC.fond._height+scrollerMC.fond._y-scrollerMC.manette._height)) {
            scrollerMC.manette._y = Math.floor(scrollerMC.fond._height+scrollerMC.fond._y-scrollerMC.manette._height);  
        } else {
            scrollerMC.manette._y = Math.floor(nextY);
//          locRef.texte._y=locRef.rapportTexte_y();
//          locRef.update();
        }
        updateTextScoller(scrollerMC.fond._height-scrollerMC.manette._height,getYPos());
	}
	
	function _onMouseMove(){
		var nextY=scrollerMC.manette._parent._ymouse-manetteYMouse;
		//trace("Pt.Tools.TextScoller._onMouseMove()");
		//trace("> nextY "+nextY);
		//trace("> min "+scrollerMC.fond._y);
		//trace("> max "+(scrollerMC.fond._height+scrollerMC.fond._y-scrollerMC.manette._height));
		scrollTo(nextY)
	}
	private function updateScoller(){
		var btnSpace:Number=scrollerMC.fond._y*2;

		scrollerMC.fond._height=Math.floor(texte._height-btnSpace);
		scrollerMC.btn_bas._y=Math.floor(scrollerMC.fond._y+scrollerMC.fond._height+1);
		scrollerMC.manette._y=scrollerMC.fond._y;
	}
	private var temopScroll:Temporise;
	private function updateTextScoller(height:Number,ypos:Number){
		//trace("Pt.Tools.TextScoller.updateTextScoller("+height+","+ypos+" )");
		//trace("scroll=1+"+(ypos*(texte.maxscroll)/height));
		texte.scroll=Math.round(ypos*(texte.maxscroll)/height)+1;
		/*
		var scroll=Math.floor(ypos*(texte.maxscroll)/height)+1;
		temopScroll.destroy();
		if (scroll!=texte.scroll) {
			temopScroll=new Temporise(1,Delegate.create(this, scrolling,scroll))
		}
		*/
	}
	
	private function scrolling(targetScroll:Number){
		//trace("Pt.Tools.TextScoller.scrolling("+targetScroll+")"+texte.maxscroll);
		if (texte.scroll==undefined || texte.scroll==targetScroll ||(targetScroll==0 && texte.scroll==1)  ) {
			temopScroll.destroy();
		} else {
			if (targetScroll>texte.scroll) {
				texte.scroll++;
			} else {
				texte.scroll--;
			}
		}
		//updateAfterEvent();
	}

	
	function stopScan() {
		onOut(scrollerMC.manette);
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onMouseMove");
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onRelease");
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onReleaseOutside");
	
	}
	
	
	private function onOver(clip:MovieClip){
		clip.gotoAndStop(IMG_OVER);
	}
	private function onOut(clip:MovieClip) {
		clip.gotoAndStop(IMG_OUT);
	}
	
	function destroy(){
		removeScroller();
		stopScan()
		souris.removeEventListener(wheelListener);
	}
}
