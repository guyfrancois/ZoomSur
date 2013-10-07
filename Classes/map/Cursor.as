/**
 *
 */
import Pt.Tools.Clips;
import org.aswing.geom.Point;
import Pt.animate.ReplaceClip;
/**
 * associe un curseur à un ensemble de zones 
 * une zone signalé open (open(ref)) lance le déplacement du curseur dans son referenciel
 * propotionnelement à la position de la zone
 */
class map.Cursor {
	private var clip:MovieClip;
	private var cursor:MovieClip;
	
	private var _transitionManagerOpen:mx.transitions.TransitionManager;
	private var _transitionOpen:ReplaceClip;
	
	
	/**
	 * contruit le gestionnaire de curseur
	 * @param clip : le clip de zonnage (zones numerotes de _0 à _..) ref est ligne de formalisme
	 * @param cursor : le clip manipulé pour bouger	 */
	
	public function Cursor(clip:MovieClip,cursor:MovieClip) {
		trace("cine.MapCursor.MapCursor("+clip+", "+cursor+")");
		this.clip=clip;
		this.cursor=cursor;
		
	}
	
	
	/**
	 * lance la transition de zone pour le curseur	 */
	public function open(ref:String) {
		var cible:MovieClip;
		if (ref==undefined) {
			cible=clip["_0"];
		} else {
			cible=clip[ref];
		}
		zoomTo(cible);
	}
	private function zoomTo(inClip:MovieClip){
		var bkup:Object=copyCursor(cursor);
		defaultCusor(cursor);
        
        
		var objDep:Object=Clips.getDeplaceTo(cursor,inClip);
        restoreCursor(bkup,cursor);
   		_transitionOpen.abort();
   		_transitionManagerOpen= new mx.transitions.TransitionManager(cursor);
		_transitionOpen=ReplaceClip(_transitionManagerOpen.startTransition({type:ReplaceClip, direction:mx.transitions.Transition.IN, duration:0.5, easing:mx.transitions.easing.Regular.easeIn,
			 _x:objDep.point.x,_y:objDep.point.y,_xscale:objDep._xscale,_yscale:objDep._yscale}));
	}
	
	/**
	 * demande le placement immédiat par rapport à un clip
	 * annule la transition en cours	 */
	public function placeTo(inClip:MovieClip) {
		_transitionOpen.abort();
		defaultCusor(cursor);
		var objDep:Object=Clips.getDeplaceTo(cursor,inClip);
       
       // var objDep:Object=Clips.getDeplaceTo(cursor,inClip);
		restoreCursor(
			{_x:objDep.point.x,_y:objDep.point.y,_xscale:objDep._xscale,_yscale:objDep._yscale},
			cursor
		);
			
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
	
	private function restoreCursor(data:Object,cursor:MovieClip) {
		cursor._xscale=data._xscale;
        cursor._yscale=data._yscale;
        cursor._x=data._x;
        cursor._y=data._y;
		
	}
	
	private function defaultCusor(cursor:MovieClip) {
		cursor._xscale=100;
        cursor._yscale=100;
        cursor._x=0;
        cursor._y=0;
	}
}