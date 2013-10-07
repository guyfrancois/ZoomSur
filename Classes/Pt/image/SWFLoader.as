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
 
class Pt.image.SWFLoader extends LoaderDefine implements Pt.image.I_Loader {

// format du fichier SWF ou JPG
	private var type:Number;
// Dimension de reference de l'image
	private var maxWidth:Number;
	private var maxHeight:Number;
// taille d'origine de la ressource
// pour un swf : depend par priorité decroissant : definition width / height dans le flash, parametre du loader
	private var swfWidth:Number;
	private var swfHeight:Number;
	
// Mode d'alignement
	private var hAlign:Number=ALIGNLEFT;
	private var vAlign:Number=ALIGNTOP;
	
// Mode de redimentionnement
	private var scaleMode:Number=SCALLNONE;

// clip qui deviendra l'image chargée	
	private var cible:MovieClip;
	
// Position d'origine du clip de chargement	
	private var cible_Coord:org.aswing.geom.Point;
	
// Gestionnaire de chargement FLASH	
	var ml:MovieClipLoader;

// Loader standard	
	var imlClip:ImageLoaderClip;
	public function getClip():MovieClip {
		return cible;
	}
	
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
	 
	private var _visible:Boolean;
	
	public function SWFLoader(cible:MovieClip,path:String,maxWidth:Number,maxHeight:Number,hAlign:Number,vAlign:Number,scaleMode:Number,swfWidth:Number,swfHeight:Number) {

		super();
		
		if (scaleMode!=undefined) {
			this.scaleMode=scaleMode;
		}
		if (hAlign!=undefined) {
			this.hAlign=hAlign;
		}
		if (vAlign!=undefined) {
			this.vAlign=vAlign;
		}
		this.cible=cible;
		cible_Coord=new Point(cible._x,cible._y);
		this.maxHeight=maxHeight;
		this.maxWidth=maxWidth;
		
		ml=new MovieClipLoader();
		var testListener:Boolean=ml.addListener(this);
		imlClip=new ImageLoaderClip(cible._parent,maxWidth,maxHeight,cible._x,cible._y);
		ml.addListener(imlClip);
		
		trace("Pt.image.SWFLoader.SWFLoader("+cible+", "+path+", "+maxWidth+","+maxHeight+" ):testListener "+testListener);
		load(path,swfWidth,swfHeight);
		
		
		
	}
	
	/**
	 * charge une ressource	 */
	private var _path:String;
	public function load(path:String,swfWidth:Number,swfHeight:Number) {
		if (path==undefined) return;
		trace("Pt.image.SWFLoader.load("+path+","+swfWidth+","+swfHeight+")");
		
		this.swfWidth=swfWidth;
		if (this.swfWidth==undefined) {
			swfWidth=maxWidth;
		}
		this.swfHeight=swfHeight;
		if (this.swfHeight==undefined) {
			swfHeight=maxHeight;
		}
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
		_visible=cible._visible;
		cible._visible=false;
		ml.loadClip(_path=Pt.Tools.Clips.convertURL(path),cible);
		
	}
	
	
	

  private var _scale:Number;
  private function redim(target_mc:MovieClip) {
  	//trace("Pt.image.SWFLoader.redim(target_mc)");
  	trace("avant type:"+type+"swf WxH"+swfWidth+" "+swfHeight);
  	 trace("avant type:"+type+" WxH"+target_mc.width+" "+target_mc.height);
     if (type!=TYPESWF) {
        swfWidth=target_mc.width=target_mc._width;
        swfHeight=target_mc.height=target_mc._height;
     } else {
     	if (target_mc.width!=undefined) {
     		swfWidth=target_mc.width
     	}
     	if (target_mc.height!=undefined) {
     		swfHeight=target_mc.height
     	}
     	if (!isNaN(swfWidth)) {
     		target_mc.width=swfWidth;
     	}    
     	if (!isNaN(swfHeight)) {
     		target_mc.height=swfHeight;
     	} 	
     	/*
     	if (target_mc.width==undefined) {
     		target_mc.width=swfWidth;
     	}
     	if (target_mc.height==undefined) {
     		target_mc.height=swfHeight;
     	}
     	*/
     }
     trace("type:"+type+"swf WxH"+swfWidth+" "+swfHeight);
    trace("type:"+type+" WxH"+target_mc.width+" "+target_mc.height);
    _scale=getScaleFromTo(target_mc.width,target_mc.height,maxWidth,maxHeight,scaleMode);
	target_mc._xscale=_scale;
	target_mc._yscale=_scale;	
  }
  
		//alignement
  	private function align(target_mc:MovieClip){
  		//trace("Pt.image.SWFLoader.align(target_mc)");
		switch (vAlign) {
			case ALIGNCENTER :
				target_mc._y=cible_Coord.y+(maxHeight-target_mc.height*_scale/100)/2;
			break;
			case ALIGNTOP :
				target_mc._y=cible_Coord.y;
			break;
			case ALIGNBOTTOM :
				target_mc._y=cible_Coord.y+(maxHeight-target_mc.height*_scale/100);
			break;
		}
		switch (hAlign) {
			case ALIGNCENTER :
				target_mc._x=cible_Coord.x+(maxWidth-target_mc.width*_scale/100)/2;
			break;
			case ALIGNLEFT :
				target_mc._x=cible_Coord.x;
			break;
			case ALIGNRIGHT :
				target_mc._x=cible_Coord.x+(maxWidth-target_mc.width*_scale/100);
			break;
			
		}
  }


 
 private static var getScaleFromTo:Function= Pt.Tools.Clips.getScaleFromTo;
 	/**
 	 * --------------------------Listeners------------------------------------------------------ 	 */
 	 

 
/**
 * Appelé une fois les actions de la première image du clip chargé exécutées.
 * redimensionne la ressource
 */
 	 private function onLoadInit  (target_mc:MovieClip) {
 	 	//trace("Pt.image.SWFLoader.onLoadInit("+target_mc+")");
 	 	target_mc._visible=_visible;
		
		if (type==TYPEIMG) {
			redim(target_mc);
		} else {
			redim(target_mc);
			//target_mc._lockroot=true;
			
			
		}
		align(target_mc);
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
			_root.err("ERREUR | SWF | "+_path+" | "+errorCode+" "+httpStatus);
	}
	
	
 

}