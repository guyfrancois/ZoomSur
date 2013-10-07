 /**
 * @author GuyF , pense-tete.com
 * @date 27 févr. 07
 * @date 31 mai 07
 * 
 */
 
import org.aswing.Event;
import org.aswing.EventDispatcher;
import Pt.image.ImageLoaderClip;
import Pt.image.LoaderDefine;
import org.aswing.geom.Point;
 
class Pt.image.ImageLoader extends LoaderDefine implements Pt.image.I_Loader {

	
	/* --------------------    */
	private var type:Number;
	
	
	private var maxWidth:Number;
	private var maxHeight:Number;
	private var hAlign:Number=ALIGNLEFT;
	private var vAlign:Number=ALIGNTOP;
	

	private var scaleMode:Number=SCALLNONE;
	
	public var cible:MovieClip;
	
	private var cible_Coord:org.aswing.geom.Point;
	
	public var lastPath:String;
	
	var ml:MovieClipLoader;
	
	var imlClip:ImageLoaderClip;
	
	private var _visibleAtLoad:Boolean;
	
	private var swfWidth:Number;
	private var swfHeight:Number;

	
	/**
	 * initie le chargement d'une image ou swf dans un clip, en respectant des tailles maximales
	 * une fois le chargement terminé, l'image est centré  (la cible est donc déplacée en x et y
	 * un swf doit contenir comme variable interne
	 * height et width , qui defini la taille à considerer pour l'animation
	 * cette classe de fourni pas de masque ou de fonds au animations
	 * 
	 * @param cible : cible dans lequel l'image sera chargée (movieClip)
	 * @param path : chemin vers la ressource à charger,(ne charge pas si undefined)
	 * @param maxWidth : largeur de reference de l'image
	 * @param maxHeight : hauteur de reference de l'image
	 * @param hAlign : alignement horizontal , ALIGNLEFT , ALIGNCENTER ,ALIGNRIGHT
	 * @param vAlign : alignement Vertical , ALIGNTOP , ALIGNCENTER ,ALIGNLEFT
	 * @param scaleMode : mode de redimensionnement , SCALLIN le cadre depresente la taille maximum de l'image;   SCALLOUT : la cadre represente la taille minimal de l'image	 */
	
	public function ImageLoader(cible:MovieClip,path:String,maxWidth:Number,maxHeight:Number,hAlign:Number,vAlign:Number,scaleMode:Number,swfWidth:Number,swfHeight:Number) {

		super();
		this.swfWidth=swfWidth;
		this.swfHeight=swfHeight;
		_visibleAtLoad=cible._visible;
		if (scaleMode!=undefined) {
			this.scaleMode=scaleMode;
		}
		if (hAlign!=undefined) {
			this.hAlign=hAlign;
		}
		if (vAlign!=undefined) {
			this.vAlign=vAlign;
		}
		//Log.addMessage("ImageLoader("+cible+","+path+", "+maxWidth+", "+maxHeight+")", Log.INFO,"marine.contenu.ImageLoader");
		
		this.cible=cible;
		cible_Coord=new Point(cible._x,cible._y);
		this.maxHeight=maxHeight;
		this.maxWidth=maxWidth;
		
		ml=new MovieClipLoader();
		var testListener:Boolean=ml.addListener(this);
		imlClip=new ImageLoaderClip(cible._parent,maxWidth,maxHeight,cible._x,cible._y);
		ml.addListener(imlClip);
		
		//trace("Pt.image.ImageLoader.ImageLoader("+cible+", "+path+", "+maxWidth+","+maxHeight+" ):testListener "+testListener);
		load(path);
		
		
		
	}
	
	public function getCibleCoord():org.aswing.geom.Point{
		return cible_Coord
	}
	
	/**
	 * charge une ressource	 */
	 private var _path:String;
	public function load(path:String,null1,null2) {
		//trace("Pt.image.ImageLoader.load("+path+")");
		if (path==undefined) return;
		lastPath=path;
		cible._x=cible_Coord.x;
		cible._xscale=100;
		cible._yscale=100;
		cible._y=cible_Coord.y;
		if (path.substr(path.length-3,path.length).toUpperCase()=="SWF"){
			//cible._lockroot = true;
			
			type=TYPESWF;
		} else {
			type=TYPEIMG;
		}
		ml.loadClip(_path=Pt.Tools.Clips.convertURL(path),cible);
	}
	
	
	


 
 /**
  * Appelé une fois les actions de la première image du clip chargé exécutées.
  * redimensionne la ressource  */
  
  private function redim(target_mc:MovieClip) {
  	var scale:Number=100;
     if (type!=TYPESWF) {
        target_mc.width=target_mc._width;
        target_mc.height=target_mc._height;
       
     } else {
     	//trace("Pt.image.ImageLoader.redim(target_mc)");
     	if (!isNaN(swfWidth) && target_mc.width==undefined ) {
     		target_mc.width=swfWidth;
     	}    
     	if (!isNaN(swfHeight) && target_mc.height==undefined) {
     		target_mc.height=swfHeight;
     	} 
     	//trace(target_mc.width);
     	//trace(target_mc.height);
     }
        scale=getScaleFromTo(target_mc.width,target_mc.height,maxWidth,maxHeight,scaleMode);
		target_mc._xscale=scale;
		target_mc._yscale=scale;
		//alignement
		switch (vAlign) {
			case ALIGNCENTER :
				
				target_mc._y=cible_Coord.y+(maxHeight-target_mc.height*scale/100)/2;
				//trace("Pt.image.ImageLoader.redim(target_mc)+vAlign :ALIGNCENTER"+(cible_Coord.y+(maxHeight-target_mc.height*scale/100)/2));
			break;
			case ALIGNTOP :
				//trace("Pt.image.ImageLoader.redim(target_mc)+ALIGNTOP");
				target_mc._y=cible_Coord.y;
			break;
			case ALIGNBOTTOM :
				target_mc._y=cible_Coord.y+(maxHeight-target_mc.height*scale/100);
			break;
		}
		switch (hAlign) {
			case ALIGNCENTER :
				//trace("Pt.image.ImageLoader.redim(target_mc)+hAlign :ALIGNCENTER"+(cible_Coord.x+(maxWidth-target_mc.width*scale/100)/2));
				target_mc._x=cible_Coord.x+(maxWidth-target_mc.width*scale/100)/2;
			break;
			
			case ALIGNLEFT :
				target_mc._x=cible_Coord.x;
			break;
			case ALIGNRIGHT :
				//trace("Pt.image.ImageLoader.redim(target_mc)+ALIGNRIGHT");
				target_mc._x=cible_Coord.x+(maxWidth-target_mc.width*scale/100);
			break;
			
		}
		
		
  }

	static var getScaleFromTo:Function= Pt.Tools.Clips.getScaleFromTo;


	private function onLoadInit  (target_mc:MovieClip) {
		target_mc._visible=	_visibleAtLoad;
		//trace("Pt.image.ImageLoader.onLoadInit("+target_mc+")");
		if (type==TYPEIMG) {
			redim(target_mc);
		} else {
			redim(target_mc);
			//target_mc._lockroot=true;
			
			
		}
		dispatchEvent(ON_LOADINIT,new Event(this,ON_LOADINIT,[target_mc]));

	}
 
 
 
 /**
  * Appelé chaque fois que le contenu est écrit sur le disque dur au cours du processus de chargement (c'est-à-dire entre MovieClipLoader.onLoadStart et MovieClipLoader.onLoadComplete).
  */
	function onLoadProgress  (target_mc:MovieClip, loadedBytes:Number, totalBytes:Number) {
		target_mc._visible=false;
	
	}
 
 /**
  * Appelé lorsqu'un appel de MovieClipLoader.loadClip() a commencé à charger un fichier.
  */
	function onLoadStart  (target_mc:MovieClip) {
		
		target_mc._visible=false;
	
	}
	
	function onLoadError  (target_mc:MovieClip, errorCode:String, httpStatus:Number) {
			_root.err("ERREUR | IMG | "+_path+" | "+errorCode+" "+httpStatus);
	}
	

 
	
}