/**
 * 
 */
import Pt.animate.ReplaceClip;
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.Tools.Clips;

/**
 *
 */
class map.Mover extends EventDispatcher {
	static var ON_MOVEDONE:String="onMoveDone";
	private var clip:MovieClip;
	private var clipCadrage:MovieClip;
	private var clipDesCadres:MovieClip;
	private var initialScale:Number;
	private var prefix:String="_";

	
	private var _transitionManagerOpen:mx.transitions.TransitionManager;
	private var _transitionOpen:ReplaceClip;
	
	public function Mover(clip:MovieClip,clipCadrage:MovieClip,prefix:String,clipDesCadres:MovieClip) {
		super();
		this.clipDesCadres=clipDesCadres==undefined?clip:clipDesCadres;
		this.clip=clip;
		this.clipCadrage=clipCadrage;
		if (prefix!=undefined) this.prefix=prefix;
		initialScale=clip._xscale;
	}
	
	
	private var ref:String ; // derniere cible appelé
	public function open(ref:String,duration:Number,easing:Function) {
		this.ref=ref;
		if (ref==undefined ) {
			vueGlobal(duration,easing)
		} else {
			zoomTo(ref,duration,easing);
		}
	}
	

	private function vueGlobal(duration:Number,easing:Function) {
		
		_transitionOpen.abort();


		_transitionManagerOpen= new mx.transitions.TransitionManager(clip);
		_transitionOpen=ReplaceClip(_transitionManagerOpen.startTransition({type:ReplaceClip, direction:mx.transitions.Transition.IN,
			 duration:duration==undefined?0.5:duration,
			 easing:easing==undefined?mx.transitions.easing.Regular.easeIn:easing,
				_x:0,_y:0,_xscale:initialScale,_yscale:initialScale}));
		_transitionOpen.addEventListener("transitionInDone", this);

	}
	

	private function zoomTo(ref:String,duration:Number,easing:Function){
		
		trace("map.Mover.zoomTo("+ref+")"+clipDesCadres[ref]);
		//var inClip:MovieClip=clip[ref];
		var altCadrage:Number=Number(_root.xmlData.etape[Number(ref.substring(1)) ].cadre)
		if (!isNaN(altCadrage)) {
			ref=prefix+altCadrage;
		}
		_transitionOpen.abort();
		
		
		var bkup:Object=copyCursor(clip);
		defaultCusor(clip);
		var objDep:Object=Clips.getDeplaceTo(clip,clipCadrage,undefined,undefined,clipDesCadres[ref]);
		restoreCursor(bkup,clip);

		_transitionManagerOpen= new mx.transitions.TransitionManager(clip);
		_transitionOpen=ReplaceClip(_transitionManagerOpen.startTransition({type:ReplaceClip, direction:mx.transitions.Transition.IN,
			 duration:duration==undefined?0.5:duration,
			 easing:easing==undefined?mx.transitions.easing.Regular.easeIn:easing,
			  _x:objDep.point.x,_y:objDep.point.y,_xscale:objDep._xscale,_yscale:objDep._yscale}));
		
		_transitionOpen.addEventListener("transitionInDone", this);
		
	}
	
	/**
	 * demande le placement immédiat par rapport à un clip(inclus dans la carte)
	 * annule la transition en cours
	 */
	public function placeTo(inClip:MovieClip) {
		trace("map.Mover.placeTo("+inClip+")");
		_transitionOpen.abort();
	  
	   
	   defaultCusor(clip);
       var objDep:Object=Clips.getDeplaceTo(clip,clipCadrage,undefined,undefined,inClip);
		restoreCursor(
			{_x:objDep.point.x,_y:objDep.point.y,_xscale:objDep._xscale,_yscale:objDep._yscale},
			clip
		);
		updateAfterEvent();
			
	}
	
	public function moveTo(inClip:MovieClip) {
		ref=Clips.getClipRef(inClip)
		
		trace("map.Mover.moveTo("+inClip+")");
		_transitionOpen.abort();
	    var bkup:Object=copyCursor(clip);
	    
	   defaultCusor(clip);
       var objDep:Object=Clips.getDeplaceTo(clip,clipCadrage,undefined,undefined,inClip);
	
		restoreCursor(bkup,clip);

		_transitionManagerOpen= new mx.transitions.TransitionManager(clip);
		_transitionOpen=ReplaceClip(_transitionManagerOpen.startTransition({type:ReplaceClip, direction:mx.transitions.Transition.IN, duration:2,
			 easing:mx.transitions.easing.Regular.easeInOut,
			  _x:objDep.point.x,_y:objDep.point.y,_xscale:objDep._xscale,_yscale:objDep._yscale}));
		
		_transitionOpen.addEventListener("transitionInDone", this);
			
	}
	
	private function transitionInDone (e:Object) {
		dispatchEvent(ON_MOVEDONE,new Event(this,ON_MOVEDONE,[ref]));
	}
	/**
	 * TOOLS	 */
	 private function copyCursor(cursor:MovieClip):Object {
		return {
			_xscale:cursor._xscale,
        	_yscale:cursor._yscale,
        	_x:cursor._x,
        	_y:cursor._y
		}
	}
	
	private function defaultCusor(cursor:MovieClip) {
		cursor._xscale=100;
        cursor._yscale=100;
        cursor._x=0;
        cursor._y=0;
	}
	
	private function restoreCursor(data:Object,cursor:MovieClip) {
		cursor._xscale=data._xscale;
        cursor._yscale=data._yscale;
        cursor._x=data._x;
        cursor._y=data._y;	
	}
	
	public function destroy(){
		//TODO : quoi suprimmer
		delete this;
	}
}