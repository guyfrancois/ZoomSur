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
 * affichage d'information à le demande explicie sur un element
 * referme en sortie de zone sensible
 * 
 * 
 * definition :
 * 	il ne peut exister q'un seul infobulle à la fois
 * 	affiche du texte dynamique
 * 	s'efface en sortie de zone (dans l'infobulle)
 * 	autre interaction possible si la zone le permet 
 * 	se position par rapport à la souris ou à un point en coordonée global 
 * 	se dimmensionne en fonction du texte inclus et des options de format du texte
 * 	se positionne autour de ce point 
 * 				en bas à droite
 * 				si débordement de scene :
 * 						autour
 * 	utilise une feuille de style
 * 	le texte est au format html
 * 	utilise un clip de bibliotheque lié
 * 	le clip de bibliotheque contient :
 * 		un fond	(fond)
 * 		un champs texte (texte)
 * 		pointeurs (hd hg bd bg)
 * 		 
 * 	
 */
class GraphicTools.InfoBulle {
	

/**
 * 	ecoute les evenements "onOver", parametres :(object, clip)
 * 	ecoute les evenements "onOut", parametres :(object, clip)
 */
 

	
	private static var instance : InfoBulle;
	private var clipLvl:MovieClip;
	
	private var clipConteneur:MovieClip;
	private var depth:Number;
	
	private var lastTooltip:MovieClip;
	
	static var textMargeWidth:Number=4;
	static var textMargeHeight:Number=4;
	
	private var dx:Number;
	private var dy:Number;
	
	private var defaultSkin:String;
	private var dataNote:Array;
	
	/**
	 * @return singleton instance of ToolTip
	 */
	public static function initialise(clipLvl:MovieClip, depth:Number,dx:Number,dy:Number,skin:String,dataNote:Array) : InfoBulle {
		if (instance == null)
			instance = new InfoBulle(clipLvl, depth,dx==undefined?-10:dx,dy==undefined?-10:dy,skin,dataNote);
		return instance;
	}
	
	private function InfoBulle(clipLvl:MovieClip, depth:Number,dx:Number,dy:Number,skin:String,dataNote:Array) {
		//trace("GraphicTools.InfoBulle.InfoBulle("+clipLvl+", "+depth+", dx, dy, "+skin+", "+dataNote+")");
		this.clipLvl=clipLvl;
		this.depth=depth;
		this.dx=dx;
		this.dy=dy;
		defaultSkin=skin;
		this.dataNote=dataNote
		_clear();
	}
	
	

	static var listenerOn_OUT:Object;
	
	private function _remove(){
		listenerOn_OUT.elt.removeEventListener(listenerOn_OUT.lstn);
		lastTooltip.removeMovieClip();
	}

	/**
	 * creer l'infobulle.
	 * @param info : texte du tooltip
	 * @param skin : clip de bibliothèque lié utilisé
	 * @param x : decalage en x du tooltip
	 * @param x : décalage en y du tooltip
	 * @param ref : clip utilisé pour placer le tooltip (si undefined : utilise la souris
	 */
	
	public static function note(ref:String){
		//trace("GraphicTools.InfoBulle.note("+ref+")");
		for (var i : Number = 0; i < instance.dataNote.length; i++) {
			if (instance.dataNote[i].ref==ref) {
				/*
				var texte:String="<titre>"+instance.dataNote[i].titre[0].text+"</titre>";
				texte+="<texte>"+instance.dataNote[i].texte[0].text+"</texte>";
				*/
				instance._create(instance.dataNote[i].text,instance.defaultSkin);
				return;	
			}
		}
		
	}
	
	public static function hnote(ref:String){
		instance._create(ref,instance.defaultSkin);
		
	}
	public static function create(info:String,skin:String,x:Number,y:Number,ref:MovieClip){
		
		instance._create(info,skin,x,y,ref);
	}
	private function _create(info:String,skin:String,x:Number,y:Number,ref:MovieClip){
		//trace("GraphicTools.InfoBulle._create("+info+","+skin+" , "+x+", "+y+", "+ref+")");
		if (skin==undefined) skin=instance.defaultSkin;
		if (x==undefined) x=0;
		if (y==undefined) y=0;
		_remove();
		//trace("clipConteneur.attachMovie("+skin+",infobulle,15)+"+clipConteneur);
		lastTooltip=clipConteneur.attachMovie(skin,"infobulle",15);
		//trace("lastTooltip "+lastTooltip);
		if (lastTooltip!=undefined) {
			lastTooltip._visible=false;
			if (ref==undefined) {
				lastTooltip._x=instance.clipConteneur._xmouse+x+dx;
				lastTooltip._y=instance.clipConteneur._ymouse+y+dy;
			} else {
				var pointRef:Point= new Point();
				ref.localToGlobal(pointRef);
				instance.clipConteneur.globalToLocal(pointRef);
				lastTooltip._x=pointRef.x+x+dx;
				lastTooltip._y=pointRef.y+y+dy;
			}
			lastTooltip.texte.autoSize=Clips.getAutoSize(lastTooltip.texte);
			Clips.setTexteHtmlCss(lastTooltip.texte,"style.css",info,Delegate.create(this, dispose,lastTooltip));
		}
	}
	private function remove(element:IEventDispatcher,clip:MovieClip,cliptip:MovieClip){
		_remove();
	}
	

	private function dispose(cliptip:MovieClip) {
		var fond:MovieClip=cliptip.fond;
		//var grid:Rectangle = new Rectangle(cliptip.texte._x, cliptip.texte._y, fond._width-cliptip.texte._x, fond._height-cliptip.texte._y);
		//fond.scale9Grid = grid ;
		cliptip.texte._width+=8;//TODO:  la fin du texte est rognée par l'autoSize, pourquoi ?
		var dw:Number=cliptip.fond._width;
		var dh:Number=cliptip.fond._height;
		cliptip.fond._width=cliptip.texte.textWidth+2*(cliptip.texte._x-cliptip.fond._x)+textMargeWidth;
		cliptip.fond._height=cliptip.texte.textHeight+2*(cliptip.texte._y-cliptip.fond._y)+textMargeHeight;
		dw=cliptip.fond._width-dw;
		dh=cliptip.fond._height-dh;
		
		cliptip.hd._x+=dw;
		cliptip.bd._x+=dw;
		cliptip.bg._y+=dh;
		cliptip.bd._y+=dh;
		
		cliptip._visible=true;
		ajusteAvecTaille(cliptip)
		cliptip.onDragOut=cliptip.onRollOut=cliptip.fond.onReleaseOutside=Delegate.create(this,remove,lastTooltip);
		
	}
	
	
	private function ajusteAvecTaille(cliptip:MovieClip,maxWidth:Number,maxHeight:Number){
		cliptip.hg._visible=false;
		cliptip.hd._visible=false;
		cliptip.bg._visible=false;
		cliptip.bd._visible=false;
		
		 var bounds:Object= cliptip.getBounds(clipLvl);
		 trace(bounds.xMax+" "+clipLvl._width);
         trace(bounds.yMax+" "+clipLvl._height);

         if (maxWidth==undefined) maxWidth=Stage.width;
         if (maxHeight==undefined) maxHeight=Stage.height;
         var pointeChaine:String="";
        if (bounds.xMax > maxWidth) {
        	cliptip._x=cliptip._x-cliptip.fond._width-2*dx;
        	pointeChaine+="d"
		} else {
			pointeChaine+="g"
		}
		
		if (bounds.yMax > maxHeight) {
        	cliptip._y=cliptip._y-cliptip.fond._height-2*dy-2*cliptip.fond._y;
        	pointeChaine="b"+pointeChaine;
		}  else {
			pointeChaine="h"+pointeChaine;
		}
		cliptip[pointeChaine]._visible=true;
		
		
	}
	
	
	static function clear(){
		instance._clear();
	}
	private function _clear(){
		_remove();
		clipLvl.infobulle.removeMovieClip();
		clipConteneur=clipLvl.createEmptyMovieClip("infobulle",depth);
		//trace("GraphicTools.Infobulle.clear()"+clipConteneur);
	}
	
}
