/**
 * @author GuyF , pense-tete.com
 * @date 8 mars 07
 * 
 */
import Pt.Tools.ClipEvent; 
import org.aswing.EventDispatcher;
import org.aswing.Event;
import org.aswing.util.Delegate;
import Pt.scan.Souris;
// TODO : ATTENTION PB PLACEMENT cf textScroller
class Pt.Tools.ClipScollerHeight extends EventDispatcher{
	/**
	 * Envoyé au commencement de déplacement (par scroller)	 */
	static var ON_MOVE:String="onMove";
	/**
	 * Envoyé lorsque un déplacement est terminer
	 * onMoveDone(src:ClipScoller,ypos:Number)	 */
	static var ON_MOVEDONE:String="onMoveDone";
	
	private var IMG_OVER:Number=2;
    private var IMG_OUT:Number=1;
    private var IMG_PRESS:Number=3;
    
	
	private var clipTexte:MovieClip;
	private var __baseXText:Number;
	private var __baseYText:Number;
	
	
	
	function get _baseXText():Number{
		return __baseXText;
	}
	function get _baseYText():Number{
        return __baseYText;
    }
	
	

	
	function get _maxHeightText():Number{
		return masque._height;
	}
	
	function get _maxWidthText():Number{
		return masque._width;
	}
	
	private var texte:MovieClip;
	private var masque:MovieClip;
	
	private var texte_height:Number;
	
	private var scrollerMC:MovieClip;
	private var asScroller:String;
	
	
		
	private var margeX:Number;
	private var margeY:Number;
	
	private var droite:Boolean
	/**
	 * ClipTexte contient
	 * 	texte:TextField;
	 * 	@param clipTexte : clip contenant
	 * 			le clip à scroller : content
	 * 			le masque : masque
	 * 		le clip contiendra la barre de scroll
	 * 	@param droite si true barre a droite
	 * 	@param asScroller nom de liaison du clip à créér pour le scroller
	 * 		contient :
	 * 			clip "fond" pouvant être redimensionné en hauteur 
	 * 			un clip "manette"
	 * 			alignés en x=0;	 */
	private var souris:Souris;
	private var wheelListener:Object;
	public function ClipScollerHeight(clipTexte:MovieClip,droite:Boolean,asScroller:String,margeX:Number,margeY:Number,textheight:Number) {
		super();
		//trace("Pt.Tools.ClipScoller.ClipScoller("+clipTexte+", "+droite+", "+asScroller+")");
		texte_height=textheight;
		clipTexte.scrollerMC.onUnload();
		clipTexte.scrollerMC.removeMovieClip();
		updateAfterEvent();
		if (margeX!=undefined) {
			this.margeX=margeX;
		} else {
			this.margeX=10;
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
		texte=clipTexte.content;
		masque=clipTexte.masque;
		
		__baseXText=texte._x;
		__baseYText=texte._y;
		/*
		_maxHeightText=masque._height;
		_maxWidthText=masque._width;
		*/
		//masque._x=texte._x;
		texte.setMask(masque);
		
	}
	/**
	 * Modifie la marge entre scroll et texte
	 * à effectuer avant toute création du scroll	 */
	public function setMarge(val:Number){
		this.margeX=val;
	}
	
	private function _onWheel(src:Souris,incr:Number){
		if (clipTexte==undefined) {
			src.stopScan();

		}
		if (src.hasMouseOver()) {
			scrollTo(getYPos()+scrollerMC.fond._y-incr*pas);
		}
	}
	/**
	 * le texte à changé	 */
	public function onChanged(textheight:Number,enPlace:Boolean){
		//trace("Pt.Tools.TextScoller.onChanged()"+texte);
		if (textheight!=undefined) texte_height=textheight;
		
		//trace(texte_height);
		//trace(_maxHeightText);
		
		var prevy=-texte._y;
		texte._x=_baseXText;
		texte._y=_baseYText;
		if (texte_height>_maxHeightText) {
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
				if (enPlace) {
					_moveTo(prevy);
				}
		}
		
	}
	
	
	
	private function addScroller(){
		souris.startScan();
		if (droite) {
			scrollerMC=clipTexte.attachMovie(asScroller,"scrollerMC",1000,{_x:_baseXText,_y:_baseYText});
			
			//texte._width=_maxWidthText-scrollerMC._width-2;
			scrollerMC._x=_baseXText+_maxWidthText+margeX;
			
		
		} else {
			scrollerMC=clipTexte.attachMovie(asScroller,"scrollerMC",1000,{_x:_baseXText,_y:_baseYText});
			//texte._x=_baseXText+scrollerMC._width+margeX;
			scrollerMC._x=_baseXText-(scrollerMC._width+margeX);
			
		}
		
		scrollerMC.onUnload=Delegate.create(this, restorTextPos)
		scrollerMC._y=_baseYText+this.margeY;
		//trace("Pt.Tools.TextScoller.addScroller():"+scrollerMC);
		initScrollerMover();
	}
	private function restorTextPos(){
		//trace("Pt.Tools.TextScoller.restorTextPos()");
		souris.stopScan();
		texte._x=_baseXText;
		texte._y=_baseYText;
		souris.removeEventListener(wheelListener);
		scrollerMC=undefined;
	}
	
	private function removeScroller(){
		souris.stopScan();
		//trace("Pt.Tools.TextScoller.removeScroller()");
		scrollerMC.removeMovieClip();
		texte._x=_baseXText;
		masque._x=_baseXText;
		//texte._width=_maxWidthText;
		souris.removeEventListener(wheelListener);
        scrollerMC=undefined;
	}

	
	private function  initScrollerMover(){
		
		souris=new Souris(scrollerMC);
		wheelListener=souris.addEventListener(Souris.ON_MOUSEWHEEL,this._onWheel,this);
		
		//scrollerMC.fond.useHandCursor=false;
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
        
        scrollerMC.manette.gotoAndStop(IMG_OUT);
        scrollerMC.btn_bas.gotoAndStop(IMG_OUT);
        scrollerMC.btn_haut.gotoAndStop(IMG_OUT);
        
        scrollerMC.manette.addEventListener("onRollOver",onOver,this);
        scrollerMC.manette.addEventListener("onRollOut",onOut,this);
        
		scrollerMC.manette.addEventListener("onPress",startScan,this);
		
		scrollerMC.manette.addEventListener("onMouseMove",_onMouseMove,this);
		scrollerMC.manette.addEventListener("onRelease",stopScan,this);
		scrollerMC.manette.addEventListener("onReleaseOutside",stopScan,this);
		
	}
	
	private var manetteYMouse:Number;
	function startScan() {
		dispatchEvent(ON_MOVE,new Event(this,ON_MOVE));
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onMouseMove");
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onRelease");
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onReleaseOutside");
		
		manetteYMouse=scrollerMC.manette._parent._ymouse-scrollerMC.manette._y;
		scrollerMC.manette.gotoAndStop(IMG_PRESS);
	
	}
	private function onPressFond(){
		dispatchEvent(ON_MOVE,new Event(this,ON_MOVE));
		manetteYMouse=0;
		_onMouseMove();
	}
	  function get pas():Number {
	  	return Math.floor((scrollerMC.fond._height-scrollerMC.manette._height)/(texte_height/30));
       // return 5;
    }
    

    private function onHaut(clip:MovieClip){
    	//trace("Pt.Tools.ClipScoller.onHaut(clip)"+(getYPos()-pas));
    	//trace(getYPos());
    	//trace(pas);
    	dispatchEvent(ON_MOVE,new Event(this,ON_MOVE));
    	temporiseScroll.destroy();
        clip.gotoAndStop(IMG_PRESS);
        scrollTo(scrollerMC.manette._y-pas);
    }
    private function onBas(clip:MovieClip){
    	//trace("Pt.Tools.ClipScoller.onBas(clip)"+(getYPos()+pas));
    	    	//trace(getYPos());
    	//trace(pas);
    	dispatchEvent(ON_MOVE,new Event(this,ON_MOVE));
    	temporiseScroll.destroy();
        clip.gotoAndStop(IMG_PRESS);
        scrollTo(scrollerMC.manette._y+pas);    
    }
    /**
     * mettre avec replaceTo     */
   public function getYPos():Number {
    	return scrollerMC.manette._y-scrollerMC.fond._y;
    	//return scrollerMC.manette._y;
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
	/*
    private function scrollTo(nextY:Number) {
    	//trace("Pt.Tools.ClipScoller.scrollTo("+nextY+")");
         if (nextY<scrollerMC.fond._y) {
         	temporiseScroll.destroy();
            scrollerMC.manette._y = scrollerMC.fond._y;
        } else if (nextY>(scrollerMC.fond._height+scrollerMC.fond._y-scrollerMC.manette._height)) {
        	temporiseScroll.destroy();
            scrollerMC.manette._y = scrollerMC.fond._height+scrollerMC.fond._y-scrollerMC.manette._height;  
        } else {
            scrollerMC.manette._y = nextY;

        }

        updateTextScoller(scrollerMC.fond._height-scrollerMC.manette._height,getYPos());
    }*/
    
    
	function _onMouseMove(){
		temporiseScroll.destroy();
		var nextY=scrollerMC.manette._parent._ymouse-manetteYMouse;
		scrollTo(nextY);
	}
	
	private function updateScoller(){
		/*
		var btnSpace:Number=scrollerMC.fond._y*2;
		scrollerMC.fond._height=Math.floor(_maxHeightText-btnSpace);
		scrollerMC.btn_bas._y=Math.floor(scrollerMC.fond._y+scrollerMC.fond._height+1);
		scrollerMC.manette._y=scrollerMC.fond._y;
		*/
		var btnSpace:Number=scrollerMC.fond._y*2;

		scrollerMC.fond._height=Math.floor(_maxHeightText-btnSpace);
		scrollerMC.btn_bas._y=Math.floor(scrollerMC.fond._y+scrollerMC.fond._height+1+scrollerMC.btn_bas._height);
		scrollerMC.manette._y=scrollerMC.fond._y;
		
		//trace("Pt.Tools.ClipScoller.updateScoller()"+texte.maxscroll);
		//var nbligneVisible:Number=texte.bottomScroll-texte.scroll;
		//trace("Pt.Tools.ClipScoller.updateScoller()"+nbligneVisible+" "+texte.maxscroll);
	
		scrollerMC.manette._height=scrollerMC.fond._height/(texte_height/_maxHeightText);    
		//trace("scrollerMC.fond._height:"+scrollerMC.fond._height)	;
		//trace("_maxHeightText:"+_maxHeightText)	 ;
		//trace("texte._heigh:"+texte_height)                                 ;//scrollerMC.fond._height*nbligneVisible/(nbligneVisible+texte.maxscroll);
		//trace("Pt.Tools.ClipScoller.updateScoller()"+scrollerMC.manette._height+" "+scrollerMC.manette._yscale);
		scrollerMC.manette.grip._yscale=100*100/scrollerMC.manette._yscale;
        
	}
	private function updateTextScoller(height:Number,ypos:Number){
		texte.onRollOver=function (){};
		texte._y=Math.floor(_baseYText-Math.floor(ypos*(texte_height-_maxHeightText)/height));
		//trace("updateTextScoller:"+texte._y);
		updateAfterEvent();
		delete texte.onRollOver;
	}
	
	/**
	 * deplace le scroll et clip de façon placer le point en haut de page	 */
	var temporiseScroll:Pt.Temporise;
	private function _moveTo(tagypos:Number){
		var height:Number=scrollerMC.fond._height-scrollerMC.manette._height;
		var ypos:Number;
		
		ypos=(tagypos)*height/(texte_height-_maxHeightText);
		temporiseScroll.destroy();
		/*
		if (ypos>scrollerMC.manette._y) {
			temporiseScroll=new Pt.Temporise(100,Delegate.create(this, this.animScrollDownTo,ypos));
		} else {
			temporiseScroll=new Pt.Temporise(100,Delegate.create(this, this.animScrollUpTo,ypos));
		}
		*/
		scrollTo(ypos);
		
		//trace("Pt.Tools.ClipScoller.moveTo("+tagypos+")");
		//texte._y=_baseYText-tagypos;
		//animScrollTo(ypos)
	}
	
	
	public function moveTo(tagypos:Number) {
		
		_moveTo(tagypos);
		
		dispatchEvent(ON_MOVEDONE,new Event(this,ON_MOVEDONE,[getYPos()]));
	}
	
	public function toHidePlace(){
		texte._y=Stage.height;
	}
	public function replaceTo(ypos:Number) {
		scrollTo(ypos+scrollerMC.fond._y);
	}
	
	public function animScrollDownTo(ypos:Number) {
		//trace("animScrollTo "+ypos+" "+scrollerMC.manette._y);
		if (ypos<=scrollerMC.manette._y+pas) {
			temporiseScroll.destroy();
			scrollTo(ypos);
		} else {
			scrollTo(Math.floor(scrollerMC.manette._y+pas));
		}
		
	}
	
	public function animScrollUpTo(ypos:Number) {
		//trace("animScrollTo "+ypos+" "+scrollerMC.manette._y);
		if (ypos>=scrollerMC.manette._y-pas) {
			temporiseScroll.destroy();
			scrollTo(ypos);
		} else {
			scrollTo(Math.floor(scrollerMC.manette._y-pas));
		}
		
	}
	
	
	
	function stopScan() {
		onOut(scrollerMC.manette);
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onMouseMove");
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onRelease");
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onReleaseOutside");
		dispatchEvent(ON_MOVEDONE,new Event(this,ON_MOVEDONE,[getYPos()]));
	
	}
	function destroy(){
		removeScroller();
		stopScan();
		souris.removeEventListener(wheelListener);
		temporiseScroll.destroy();
		scrollerMC.removeMovieClip();
		scrollerMC=undefined;
		delete this;
	}
	   private function onOver(clip:MovieClip){
        clip.gotoAndStop(IMG_OVER);
    }
    private function onOut(clip:MovieClip) {
        clip.gotoAndStop(IMG_OUT);
    }
}