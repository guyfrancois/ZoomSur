/**
 * @author Administrator    , pense-tete
 * 31 mars 08
 */

import org.aswing.IEventDispatcher;
import org.aswing.util.Delegate;
import Pt.Tools.Clips;
import flash.geom.Rectangle;
import org.aswing.geom.Point;

/**
 * affichage d'information au survol d'un element
 * 
 * definition :
 * 	il ne peut exister q'un seul tooltip à la fois
 * 	affiche du texte dynamique au survol d'un element
 * 	s'efface en sortie de survol de l'element
 * 	n'offre aucune autre interaction
 * 	se position par rapport à la souris ou à l'element survolé
 * 	se dimmensionne en fonction du texte inclus et des options de format du texte
 * 	utilise une feuille de style
 * 	le texte est au format html
 * 	utilise un clip de bibliotheque lié
 * 	le clip de bibliotheque contient :
 * 		un fond	(fond)
 * 		un champs texte (texte)
 * 		 
 * 	
 * 	ecoute les evenements "onOver", parametres :(object, clip)
 * 	ecoute les evenements "onOut", parametres :(object, clip)
 */
class GraphicTools.ToolTip {
	

/**
 * 	ecoute les evenements "onOver", parametres :(object, clip)
 * 	ecoute les evenements "onOut", parametres :(object, clip)
 */
 
	public static var ON_OVER:String="onOver";
	public static var ON_OUT:String="onOut";
	
	private static var instance : ToolTip;
	private var clipLvl:MovieClip;
	
	private var clipConteneur:MovieClip;
	private var depth:Number;
	
	private var lastTooltip:MovieClip;
	
	static var textMargeWidth:Number=4;
	static var textMargeHeight:Number=4;
	
	/**
	 * @return singleton instance of ToolTip
	 */
	public static function initialise(clipLvl:MovieClip, depth:Number) : ToolTip {
		if (instance == null)
			instance = new ToolTip(clipLvl, depth);
		return instance;
	}
	
	private function ToolTip(clipLvl:MovieClip, depth:Number) {
		//trace("GraphicTools.ToolTip.ToolTip("+clipLvl+", "+depth+")");
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
	public static function associer(element:IEventDispatcher,info:String,skin:String,x:Number,y:Number,ref:MovieClip):Object {
		//trace("GraphicTools.ToolTip.associer(element, "+info+", "+skin+", x, y, "+ref+")");
		var listenerOn_Over:Object;
		if (x==undefined) x=0;
		if (y==undefined) y=0;
		if (ref==undefined) {
			listenerOn_Over=element.addEventListener(ON_OVER,Delegate.create(instance, instance.create,info,skin,x,y,ref));
		} else {
			
			listenerOn_Over=element.addEventListener(ON_OVER,Delegate.create(instance, instance.create,info,skin,x,y,ref));
		}
		
		return {elt:element,lstn:listenerOn_Over};
		
	}
	static var listenerOn_OUT:Object;
	
	static function dissocier(){
		//trace("GraphicTools.ToolTip.dissocier()");
		instance._remove();
	}
	
	private function _remove(){
		//trace("GraphicTools.ToolTip._remove()");
		listenerOn_OUT.elt.removeEventListener(listenerOn_OUT.lstn);
		lastTooltip.removeMovieClip();
	}
	private function create(element:IEventDispatcher,clip:MovieClip,info:String,skin:String,x:Number,y:Number,ref:MovieClip){
		//trace("GraphicTools.ToolTip.create(element, "+clip+", "+info+", "+skin+")");
		_remove();
		
		lastTooltip=clipConteneur.attachMovie(skin,"tooltip",10);
		//trace(lastTooltip);
		if (lastTooltip!=undefined) {
			lastTooltip._visible=false;
			if (ref==undefined) {
				lastTooltip._x=instance.clipConteneur._xmouse+x;
				lastTooltip._y=instance.clipConteneur._ymouse+y;
				lastTooltip._xm=instance.clipConteneur._xmouse-x;
				lastTooltip._ym=instance.clipConteneur._ymouse-y;
			} else {
				var pointRef:Point= new Point();
				ref.localToGlobal(pointRef);
				instance.clipConteneur.globalToLocal(pointRef);
				lastTooltip._x=pointRef.x+x;
				lastTooltip._y=pointRef.y+y;
				lastTooltip._xm=pointRef.x-x+ref._width;
				lastTooltip._ym=pointRef.y-y+ref._height;
			}
			lastTooltip.texte.autoSize=Clips.getAutoSize(lastTooltip.texte);
			Clips.setTexteHtmlCss(lastTooltip.texte,"style.css",info,Delegate.create(this, dispose,lastTooltip));
			listenerOn_OUT={elt:element,lstn:element.addEventListener(ON_OUT,Delegate.create(this,remove,lastTooltip))};
			
		}
	}
	private function remove(element:IEventDispatcher,clip:MovieClip,cliptip:MovieClip){
		_remove();
	}
	

	private function dispose(cliptip:MovieClip) {
		var fond:MovieClip=cliptip.fond;
		var grid:Rectangle = new Rectangle(cliptip.texte._x, cliptip.texte._y, fond._width-cliptip.texte._x, fond._height-cliptip.texte._y);
		fond.scale9Grid = grid ;
		cliptip.texte._width+=8;//TODO:  la fin du texte est rognée par l'autoSize, pourquoi ?
		cliptip.fond._width=cliptip.texte.textWidth+2*cliptip.texte._x+textMargeWidth;
		cliptip.fond._height=cliptip.texte.textHeight+2*cliptip.texte._y+textMargeHeight;
		cliptip._visible=true;
		ajusteAvecTaille(cliptip)
	}
	
	
	private function ajusteAvecTaille(cliptip:MovieClip,maxWidth:Number,maxHeight:Number){
		 var bounds:Object= cliptip.getBounds(clipLvl);
		 //trace(bounds.xMax+" "+clipLvl._width);
         //trace(bounds.yMax+" "+clipLvl._height);
         var pt:Point=new Point(bounds.xMax,bounds.yMax);
         clipLvl.localToGlobal(pt);

         if (maxWidth==undefined) maxWidth=Stage.width;
         if (maxHeight==undefined) maxHeight=Stage.height;
         
        if (pt.x > maxWidth) {
        	cliptip._x=cliptip._xm-cliptip.fond._width;
		} 
		
		if (pt.y > maxHeight) {
        	cliptip._y=cliptip._ym-cliptip.fond._height;
		} 
		//trace("ajusteAvecTaille :"+cliptip._x+" "+cliptip._y);
	}
	
	public function clear(){
		_remove();
		clipLvl.tooltips.removeMovieClip();
		clipConteneur=clipLvl.createEmptyMovieClip("tooltips",depth);
		//trace("GraphicTools.ToolTip.clear()"+clipConteneur);
	}
	
}
