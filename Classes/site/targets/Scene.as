/**
 * @author Administrator    , pense-tete
 * 7 avr. 08
 */
import site.DefTYPES;
import site.Versions;
import Pt.Parsers.DataStk;
import site.targets.Fond;
/**
 *  gestionnaire d'affichage dans la zone de scene
 *  
 */
class site.targets.Scene extends Pt.Zone.ContentGest  {
	static var NOM:String=site.DefTargets.SCENE;
	private static var ANIMDECX:Number=0;
	private var VIDEO:String="hdvideo";
	
	
	public function Scene(clip:MovieClip) {
		super(clip.createEmptyMovieClip("_scene",1));
		
	}
	
	/**
	 * création ou fourniture du conteneur pour l'affichage
	 * 
	 * 
	 * DefTYPES.VIDEO : utilisation du clip de bibliotheque "hdvideo"
	 * DefTYPES.ANIM : décalage de ANIMDECX (-383)
	 * 
	 * 
	 * 
	 * 	 */
	
	public function create(contentType:String, chem:String):MovieClip{
		//trace("Pt.Zone.ContentGest.create("+contentType+", "+chem+")"+clip);
		if (contentType==DefTYPES.VIDEO) {
			if(clip[DefTYPES.VIDEO]==undefined) {
				var cible:MovieClip=clip.attachMovie(VIDEO,DefTYPES.VIDEO,clip.getNextHighestDepth());
				cible._users=0;
				cible.height=cible._height;
				cible._visible=false;
				return cible;
			} else {
				return clip[DefTYPES.VIDEO];
			}
		}
		
		var ref:String=convertCheminToRef(chem);
		if (clip[ref] == undefined) {
			var cible:MovieClip;
			if (contentType==DefTYPES.ANIM) {
				cible=clip.attachMovie(DefTYPES.ANIM,ref,clip.getNextHighestDepth());
				cible._x=ANIMDECX;
			} else {
				cible=clip.attachMovie(contentType,ref,clip.getNextHighestDepth());
				if (cible==undefined) {
					cible=clip.attachMovie(DefTYPES.IMAGE,ref,clip.getNextHighestDepth());
				}
			}
			//trace("create cible :"+cible)
			cible._visible=false;
			cible._users=0;
			return cible;
		} else {
			trace ("found "+clip[ref])
			//clip[ref]._users+=1;
			return clip[ref];
		}
		
	}
	
	public function setInLoad() {
		clip._parent._visible=false;
	}
	public function setInPlay() {
		clip._parent._visible=true;
		
	}
	
	public function show(chem:String,duree:Number,CALLBACK:Function) {
		
		super.show(chem, duree, CALLBACK);
		
		var ref:String=convertCheminToRef(chem);
		Fond.s_updatelegende(ref);
		//trace("site.targets.Scene.show(chem, duree, CALLBACK)"+ref);
		
	}
	

	
	
	
}