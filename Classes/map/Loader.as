/**
 *
 */
import org.aswing.EventDispatcher;
import Pt.image.ImageLoader;
import org.aswing.Event;

import Pt.Parsers.XmlTools;


import Pt.Tools.Clips;

/**
 * chargement d'une map et d'une miniMap
 */
class map.Loader extends EventDispatcher {
	//onLoadInit  (source:MapLoader)
	// chargement de scene terminée
    static var ON_LOADINIT:String="onLoadInit";
    
    private var controlWidth:Number=130;
	private var controlHeight:Number=81;
	
	private var sceneWidth:Number=960;
	private var sceneHeight:Number=600;
	
	//private var xmlTools:XmlTools; 
	private var clipControl:MovieClip;
	private var clipScene:MovieClip;
	
	private var ilControl:ImageLoader;
	private var ilScene:ImageLoader;
	
	//private var path:String;
	private var srcControl:String;
	private var srcScene:String;
	//private var articleArray:Array;
  
	/**
	 * prepare les chargeurs pour la minimap et la carte
	 * @param clipControl : clip qui contiendra la minimap
	 * @param clipScene : clip qui contiendra la grande carte	 */
	public function Loader(clipControl:MovieClip,clipScene:MovieClip) {
		super();
		this.clipControl=clipControl;
		this.clipScene=clipScene;
		ilControl=new ImageLoader(this.clipControl.createEmptyMovieClip("_content",10),undefined,controlWidth,controlHeight,ImageLoader.ALIGNLEFT,ImageLoader.ALIGNTOP,ImageLoader.SCALLNONE) ;
		ilControl.addEventListener(ImageLoader.ON_LOADCOMPLETE,onLoadControlComplete,this);
		ilControl.addEventListener(ImageLoader.ON_LOADINIT,onLoadControlInit,this);
		ilScene=new ImageLoader(clipScene.createEmptyMovieClip("_content",10),undefined,sceneWidth,sceneHeight,ImageLoader.ALIGNLEFT,ImageLoader.ALIGNTOP,ImageLoader.SCALLNONE);
		ilScene.addEventListener(ImageLoader.ON_LOADINIT,onLoadSceneInit,this) ;
	}
	
	/**
	 * Appel le chargement des fichiers swf	 */
	public function load(srcControl:String,srcScene:String) {
		this.srcControl=srcControl;
		this.srcScene=srcScene;

		loadControl();
	}
	
	private function loadControl() {
		ilControl.load(srcControl);
	}
	
	private function loadScene(){
		ilScene.load(srcScene);
		
	}
	
	
	private function onLoadControlComplete(){
		
		
	}
	
	private function onLoadControlInit(src:ImageLoader,cible:MovieClip){
    	trace("cine.MapLoader.onLoadControlInit(src, "+cible+")");
    	//clipControl._content.chemin._visible=false;
     	//clipControl._visible=false;
     	loadScene();
    }
    
	private function onLoadSceneInit(src:ImageLoader,cible:MovieClip){
		trace("cine.MapLoader.onLoadSceneInit(src, "+cible+")");
		clipControl._visible=true;
		dispatchEvent(ON_LOADINIT,new Event(this,ON_LOADINIT,[cible]));
        
    }	

}