/**
 *
 */
import Pt.Parsers.DataStk;
import Pt.html.Render;
import media.FluxVideo;
import org.aswing.util.Delegate;
import site.connexe.TransContent;
import org.aswing.Event;

import Pt.Parsers.SimpleXML;
import Pt.Tools.ClipScoller;
import Pt.Tools.Chaines;


import Pt.Parsers.XmlTools;

import GraphicTools.MenuPlatXML;
import Pt.Tools.Clips;
import Pt.image.ImageLoader;
import org.aswing.EventDispatcher;

/**
 *
 */
class site.connexe.Reperes extends TransContent {
	static var ON_SELECT:String="onSelect";
	
	private var imagesBtn:Object={IMG_OUT:1,IMG_OVER:3,IMG_PRESS:4,IMG_ON:4,IMG_OFF:1};
	private var clip:MovieClip;
	private var xmlTool:XmlTools;
	
	private var clipMenu:MovieClip;
	private var clipHTML:MovieClip;
	private var clipDetail:MovieClip;
	private var htmlContent:Render;
	private var fluxVideo:FluxVideo;
	 /**
	 * quand fermeture
	 * onClose(source:)
	 */	

	public static var ON_CLOSE:String = "onClose";
	private var xmlFile:String;
	private var cssFile:String;
	private var asClipScollerb:Pt.Tools.ClipScoller;
	private var ecran:MovieClip;
	
	public function isOpen() : Boolean {
		return clip._visible;
	}
	
	public function Reperes(clip:MovieClip,cssFile:String) {
		super(clip);
		this.xmlFile=xmlFile;
		this.cssFile=cssFile;
		clip._visible=false;
		cbframe.addEventListener(Pt.animate.Transition.ON_NEXTFRAME,onOpenning,this);
		DataStk.event().addEventListener("onVideo",onVideo,this);
		
		
	}
	var selected:Number;
	private function onOpenning (cbframe:Pt.animate.Transition,currentframe,imageFin) {
		trace("site.Credits.onOpenning(cbframe,"+currentframe+" ,"+imageFin+" )");
		if (currentframe==2) {
			ecran=clip.ecran;
			clipMenu=clip.ecran.clipMenu;
			clipHTML=clip.ecran.clipHTML;
			clipDetail=clip.ecran.clipDetail;
			
			intitalise();
		
			
		}
		if (currentframe==4) {
			select(0,selected);
		}
	}
	
	private function intitalise(){
		clipDetail._visible=false;
		fluxVideo=new FluxVideo(true,clipDetail.clipVideo);
		
		clip.head.texte.texte.autoSize=Pt.Tools.Clips.getAutoSize(clip.head.texte.texte);
		Pt.Tools.Clips.setTexteHtmlCss(clip.head.texte.texte,"style.css",DataStk.dico("complements"));
		var htmlZone:MovieClip=clipHTML.attachMovie("clipsrollingRepere","htmlZone",1);
				htmlContent=new Render(htmlZone.texte,cssFile);
        	    htmlContent.addEventListener(Render.ON_READY,onUpdateContent,this);
       		    asClipScollerb=new ClipScoller(htmlZone,false,"scroller_texte",32);
       		    asClipScollerb.addEventListener(ClipScoller.ON_MOVEDONE,this.onMoveDone,this)
		menuArray=new Array();
		init();
	}
	
	  public function popup(lien:String) {

     	SWFAddress.openPopup(lien,"popup","toolbar=no,location=no,noborder,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=565,height=450,top=20,left=20");
     }
	
	private var menuArray:Array;
	
	private function init(){
		xmlTool=new XmlTools(DataStk.val("menu"));
		var arrMenu:Array=xmlTool.findSub("menu","type","reperes");
		
		for (var i : Number = 0; i < arrMenu.length; i++) {
			var menuItem:MovieClip=clipMenu.createEmptyMovieClip("menu_"+i,clip.getNextHighestDepth());
			var y:Number=0;
			if (arrMenu[i].titre!=undefined) {
				var titreMenu:MovieClip=menuItem.attachMovie("titreMenu","titre",1);
				titreMenu._y=y;
				Clips.setTexteHtmlCss(titreMenu.texte,"style.css",arrMenu[i].titre[0].text);
				y=titreMenu._y+titreMenu._height;
			}
			
			var menuliste=menuItem.createEmptyMovieClip("liste",2);
			menuliste._y=y;
			var menuXML:MenuPlatXML=new  MenuPlatXML(menuliste,undefined,imagesBtn,arrMenu[i]);
			menuArray.push({menuXML:menuXML,type:"reperes"});
			menuXML.addEventListener(MenuPlatXML.ON_MENUINIT,Delegate.create(this, __onMenuInit,i),this);
			menuXML.addEventListener(MenuPlatXML.ON_MENUPRESS,_onMenuPress,this);
			menuXML.initialize();			
		}
	}
	
	
	private function _onMenuPress(src:MenuPlatXML,id:Number,data:Object) {
		for (var i : Number = 0; i < menuArray.length; i++) {
			if (menuArray[i].menuXML!=src) {
				menuArray[i].menuXML.reset();
				
			} else {
				if (data.href!=undefined) {
					popup(data.href);
					
				} else {
					SWFAddress.setRepere("_"+id);
				}
			}
			
		}
		
	}
	
	public function transOpen(chaineInfo:String) {
		var arrayInfo:Array=chaineInfo.split("_");
		trace("site.Reperes.transOpen("+chaineInfo+")");
		select(0,Number(arrayInfo[1]));
		selected=Number(arrayInfo[1]);
	//	super.transOpen();
	}
	
	private function __onMenuInit(src:MenuPlatXML,null1,i:Number){
		trace("site.MenuGuide.__onMenuInit(src, "+i+")");
		if (i>0) {
			var precedent:MovieClip=clip["menu_"+(i-1)];
			var courant:MovieClip=clip["menu_"+i];
			trace(precedent+" "+courant);
			courant._y=precedent._y+precedent._height;
		}
	}
	
	public function select(idMenu:Number,idBtn:Number){
		for (var i : Number = 0; i < menuArray.length; i++) {
			if (i!=idMenu) {
				menuArray[i].menuXML.reset();
				
			} else {
				// TODO menu selectionné : i eme, id : btn
				menuArray[i].menuXML.setNoAction(idBtn);
				genRepere(menuArray[i].menuXML.getNodeFor(idBtn).xml);
			}
			
		}
	}
	public function destroy(){
		// TODO : remove listenners ...
	}
	
	private function genRepere(xmlFile:String){
				clipDetail._visible=false;
				fluxVideo.stop();
				htmlContent.clear();
				asClipScollerb.onChanged();

			    loadContent(DataStk.val("config").repReperes[0].src+xmlFile);
		
		
	}
	
    private function initbtn(){
    	super.initbtn();
    	//

    }
    
    private function afficheCredits(data){
    	htmlContent.initialise(data);
    }
    
	private function onUpdateContent(){
		
		asClipScollerb.onChanged();
	}
	
	private function onMoveDone(src:ClipScoller,ypos:Number){
		src.toHidePlace();
		htmlContent.regen(Delegate.create(src, src.replaceTo,ypos));
	}
    
    private function loadContent(xmlFile) {
		
		var loaderXML:SimpleXML=new SimpleXML("html");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,successData,this)
		//loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		loaderXML.load(xmlFile);
	}
	
	private function successData(src:SimpleXML,conteneur:Object){

		trace("Site.success(conteneur)");
		
		afficheCredits(conteneur);
		
		
	}
	
	private function onVideo(src:EventDispatcher,param1:String) {
		trace("site.Reperes.onVideo("+param1+")");
		if (Chaines.fileIsPhoto(param1) || Chaines.fileIsAnim(param1)) {
			fluxVideo.stop();
			clipDetail._visible=true;
			clipDetail.clipVideo._visible=false;
			clipDetail.createEmptyMovieClip("_img_",10);
			//cible:MovieClip,path:String,maxWidth:Number,maxHeight:Number,hAlign:Number,vAlign:Number,scaleMode:Number,swfWidth:Number,swfHeight:Number
			var il:ImageLoader=new ImageLoader(clipDetail.createEmptyMovieClip("_img_",10),param1,260,291,ImageLoader.ALIGNLEFT,ImageLoader.ALIGNTOP,ImageLoader.SCALLNONE);
			
		} else {
			clipDetail._img_.removeMovieClip();
			clipDetail._visible=true;
			fluxVideo.start(param1,true);
		}
		
	}
	private function onClosed() {
		clipDetail._visible=false;
		fluxVideo.destroy();
		super.onClosed();
		SWFAddress.setRepere("");
	}
	
	

}