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

class Pt.Tools.Slider extends EventDispatcher{
	/**
	 * Envoyé au commencement de déplacement (par scroller)
	 */
	static var ON_MOVE:String="onMove";
	/**
	 * Envoyé lorsque un déplacement est terminer
	 * onMoveDone(src:ClipScoller,ypos:Number)
	 */
	static var ON_MOVEDONE:String="onMoveDone";
	
	private var IMG_OVER:Number=2;
    private var IMG_OUT:Number=1;
    private var IMG_PRESS:Number=3;
    private var lastDataVal:Number;
	
	
	private var scrollerMC:MovieClip;
	
	private var min:Number;
	private var max:Number;
	private var _pas:Number
	private var initial:Number;

	public function Slider(scrollerMC:MovieClip,pas:Number,min:Number,max:Number,initial:Number) {
		super();
		this.scrollerMC=scrollerMC;
		this.min=min;
		this.max=max;
		this._pas=pas*(scrollerMC.fond._height-scrollerMC.manette._height)/(max-min);
		this.initial=initial;
		moveTo(initial);
        lastDataVal=initial;
		initScrollerMover();
		

	}


    private function convertDataScroll(val:Number) :Number {
    	return (val-min)*(scrollerMC.fond._height-scrollerMC.manette._height)/(max-min);
    }
	
	
	private function convertScrollData(val:Number) :Number {
        var ret:Number= Math.round(val*(max-min)/(scrollerMC.fond._height-scrollerMC.manette._height) )+min;
        if (ret>max) return max;
        if (ret<min) return min;
        return ret;
    }
    
	
	private function  initScrollerMover(){
		
		
		
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
	//private var _scanning:Boolean;
	function startScan() {
		//if (_scanning) return;
		//trace("Pt.Tools.Slider.startScan()");
		dispatchEvent(ON_MOVE,new Event(this,ON_MOVE));
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onMouseMove");
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onRelease");
		ClipEvent.setEventsTrigger(scrollerMC.manette,"onReleaseOutside");
		manetteYMouse=scrollerMC.manette._ymouse;
		scrollerMC.manette.gotoAndStop(IMG_PRESS);
		//_scanning=true;
	
	}
	
	function stopScan() {
		//trace("Pt.Tools.Slider.stopScan()");
		//onOut(scrollerMC.manette);
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onMouseMove");
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onRelease");
		ClipEvent.unsetEventsTrigger(scrollerMC.manette,"onReleaseOutside");
		//onUpdateScroller();
		//_scanning=false;
	}
	
	private function onPressFond(){
	
		manetteYMouse=0;
		_onMouseMove();
		/*
	   if (scrollerMC.manette.hitTest(_root._xmouse,_root._ymouse,false) ) {
       	 startScan()
       }
       */
       
	}
	function get pas():Number {
	  	return _pas;
  
    }
    

    private function onHaut(clip:MovieClip){
    	//trace("Pt.Tools.ClipScoller.onHaut(clip)"+(getYPos()-pas));
    	//trace(getYPos());
    	//trace(pas);
    	
    
        clip.gotoAndStop(IMG_PRESS);
        scrollTo(scrollerMC.manette._y-pas);
        onUpdateScroller();
    }
    private function onBas(clip:MovieClip){
    	//trace("Pt.Tools.ClipScoller.onBas(clip)"+(getYPos()+pas));
    	    	//trace(getYPos());
    	//trace(pas);
    
        clip.gotoAndStop(IMG_PRESS);
        scrollTo(scrollerMC.manette._y+pas); 
        onUpdateScroller();   
    }
    /**
     * mettre avec replaceTo
     */
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
        }
       scrollerMC.fillBefore._height=scrollerMC.manette._y-scrollerMC.fillBefore._y;
       /*
       if (scrollerMC.hitTest(_root._xmouse,_root._ymouse,false)) {
       	scrollerMC.manette.onPress();
       } else {
       	scrollerMC.manette.onRelease();
       }
       */
       
    }
    
    
    private function onUpdateScroller(){
    //	//trace("Pt.Tools.Slider.onUpdateScroller()"+ convertScrollData(getYPos()));
    	var newval:Number=convertScrollData(getYPos());
    	if (lastDataVal!=newval) {
    	   dispatchEvent(ON_MOVEDONE,new Event(this,ON_MOVEDONE,[newval  ]));
    	   lastDataVal=newval;
    	}
    }
    
	private function _onMouseMove(){
	
		var nextY=scrollerMC.manette._parent._ymouse-manetteYMouse;
		scrollTo(nextY);
		onUpdateScroller();
	}

	
	public function moveTo(dataVal:Number) {
		stopScan();
		convertDataScroll(dataVal)	
		scrollTo(convertDataScroll(dataVal)   ) ;
	}
	

	
	
	

	function destroy(){
	
		stopScan();
	
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