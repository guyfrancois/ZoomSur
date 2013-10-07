/**
 * @author Administrator    , pense-tete
 * 31 mars 08
 */

import org.aswing.IEventDispatcher;
import org.aswing.util.Delegate;
import Pt.Tools.Clips;
import flash.geom.Rectangle;
import org.aswing.geom.Point;
import Pt.scan.Souris;

/**
 * affichage d'un curseur alternatif
 * 
 * 	
 * 	ecoute les evenements "onOver", parametres :(object, clip)
 * 	ecoute les evenements "onOut", parametres :(object, clip)
 */
class GraphicTools.MouseCursor {
	

/**
 * 	ecoute les evenements "onOver", parametres :(object, clip)
 * 	ecoute les evenements "onOut", parametres :(object, clip)
 */
 
	public static var ON_OVER:String="onOver";
	public static var ON_OUT:String="onOut";
	
	private static var instance : MouseCursor;
	private var clipLvl:MovieClip;
	
	private var clipConteneur:MovieClip;
	private var depth:Number;
	
	private var lastTooltip:MovieClip;
	
	private var mouse:Souris;
	

	
	/**
	 * @return singleton instance of ToolTip
	 */
	public static function initialise(clipLvl:MovieClip, depth:Number) : MouseCursor {
		if (instance == null)
			instance = new MouseCursor(clipLvl, depth);
		return instance;
	}
	
	private function MouseCursor(clipLvl:MovieClip, depth:Number) {
		//trace("GraphicTools.MouseCursor.MouseCursor("+clipLvl+", "+depth+")");
		this.clipLvl=clipLvl;
		this.depth=depth;
		clear();
	}
	
	
	/**
	 * associe un Object IEventDispatcher generant des ON_OVER et ON_OUT à un tooltips.
	 * @param element : Objet lié
	 * @param info : texte du tooltip
	 * @param skin : clip de bibliothèque lié utilisé
	 * @param x : decalage en x du tooltip
	 * @param x : décalage en y du tooltip
	 * @param ref : clip utilisé pour placer le tooltip (si undefined : utilise la sourie	 */
	public static function associer(element:IEventDispatcher,skin:String,x:Number,y:Number,ref:MovieClip):Object {
		var listenerOn_Over:Object;
		if (x==undefined) x=0;
		if (y==undefined) y=0;
		if (ref==undefined) {
			listenerOn_Over=element.addEventListener(ON_OVER,Delegate.create(instance, instance.create,skin,x,y,ref));
		} else {
			
			listenerOn_Over=element.addEventListener(ON_OVER,Delegate.create(instance, instance.create,skin,x,y,ref));
		}
		
		return {elt:element,lstn:listenerOn_Over};
		
	}
	static var listenerOn_OUT:Object;
	
	static function dissocier(){
		instance._remove();
	}
	
	private function _remove(){
		mouse.stopScan();
		Mouse.show();
		listenerOn_OUT.elt.removeEventListener(listenerOn_OUT.lstn);
		lastTooltip.removeMovieClip();
	}
	private function create(element:IEventDispatcher,clip:MovieClip,skin:String,x:Number,y:Number){
		//trace("GraphicTools.MouseCursor.create(element, "+clip+", "+skin+")");
		_remove();
		
		lastTooltip=clipConteneur.attachMovie(skin,"MouseCursor",10);
		//trace(lastTooltip);
		if (lastTooltip!=undefined) {
			lastTooltip._visible=false;
			lastTooltip._x=instance.clipConteneur._xmouse+x;
			lastTooltip._y=instance.clipConteneur._ymouse+y;
			mouse=new Souris(lastTooltip);
			mouse.addEventListener(Souris.ON_MOUSEMOVE,Delegate.create(this,_onMouseMove,x,y),this)
			listenerOn_OUT={elt:element,lstn:element.addEventListener(ON_OUT,Delegate.create(this,remove,lastTooltip))};
			mouse.startScan()
			
			
		}
	}
	private function remove(element:IEventDispatcher,clip:MovieClip,cliptip:MovieClip){
		_remove();
	}
	

	private function dispose(cliptip:MovieClip) {
		var fond:MovieClip=cliptip.fond;
		cliptip._visible=true;
		Mouse.hide();
		ajusteAvecTaille(cliptip)
	}
	
	private function _onMouseMove(source:Souris,dx:Number,dy:Number,x:Number,y:Number) {
		//trace("GraphicTools.MouseCursor._onMouseMove(source, dx, dy, x, y)"+lastTooltip);
		lastTooltip._x=instance.clipConteneur._xmouse+x;
		lastTooltip._y=instance.clipConteneur._ymouse+y;
		dispose(lastTooltip);
	}
	
	private function ajusteAvecTaille(cliptip:MovieClip,maxWidth:Number,maxHeight:Number){
		 var bounds:Object= cliptip.getBounds(clipLvl);
		// trace(bounds.xMax+" "+clipLvl._width);
         //trace(bounds.yMax+" "+clipLvl._height);

         if (maxWidth==undefined) maxWidth=Stage.width;
         if (maxHeight==undefined) maxHeight=Stage.height;
         
        if (bounds.xMax > maxWidth) {
        	cliptip._x=cliptip._x-cliptip._width;
		} 
		
		if (bounds.yMax > maxHeight) {
        	cliptip._y=cliptip._y-cliptip._height;
		} 
	}
	
	public function clear(){
		_remove();
		clipLvl.tooltips.removeMovieClip();
		clipConteneur=clipLvl.createEmptyMovieClip("MouseCursor",depth);
		//trace("GraphicTools.MouseCursor.clear()"+clipConteneur);
	}
	
}
