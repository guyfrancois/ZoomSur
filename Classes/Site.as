/**
 * @author Administrator    , pense-tete
 * 12 nov. 07
 */
import Pt.Parsers.SimpleXML;
import Pt.image.SWFLoader;
import Pt.Parsers.DataStk;
import Pt.animate.Transition;
import org.aswing.util.Delegate;
import Pt.Tools.Clips; 
import GraphicTools.ToolTip;
import media.FluxAudio;


/**
 * 
 */
class Site {

	private var clip:MovieClip;
	
	private var introOeuvreIsReady:Boolean=false;
	private var interfaceIsloaded:Boolean=false;
	private var interfaceIsReady:Boolean=false;
	private var policeIsloaded:Boolean=true;
	private var allXMLLoaded:Boolean=false;
	
	
	private var introOeuvreTrans:Transition;
	
	private var appli:site.Appli;
	public static var debug:Boolean=false;
	private var kd:KeyDetection;
	public function Site(clip:MovieClip) {
		trace("Site.Site("+clip+")");
		
		this.clip=clip;
		var my_cm:ContextMenu = new ContextMenu ();
		for(var propName:String in my_cm.builtInItems) {
    		my_cm.builtInItems[propName]=false;
		}
		clip.menu = my_cm;
		
		
		
	
		loadConfig();
		/** charger le XML **/
		/** initialise le timer **/
		/** gere le chargement de l'application **/
		DataStk.event().addEventListener("MENU",_onCALLMENU,this);
		DataStk.event().addEventListener("CONNEXE",_onCALLCONNEXE,this);
		trace("debug : "+(debug=true));
		if (debug) {
			debugText=_root.createTextField("debugText",2666,0,0,1000,200);
			debugText.border=true;
			debugText.multiline=true;
			debugText.background=true;
			debugText.selectable=true;
			debugText._visible=false;
			_root.err=Delegate.create(this,logErr);
			kd=new KeyDetection();
			kd.addListener(this)
			
			kd.addCombination("debug", Key.CONTROL, 68);
		}
	}
	private function logErr(err:String) {
		trace("Site.logErr("+err+")");
		debugText.text+="\n"+err;
		debugText.scroll=debugText.maxscroll;
	}
	var debugText:TextField;
	private function onKeyCombination(combo_name:String) {
		switch (combo_name) {
			case "debug" :
				//_root.err("debug "+debugText._visible);
				if (debugText._visible==false) {
					debugText._visible=true;
				} else {
					debugText._visible=false;
				}
			break;
			default :
			break;
			
		}
		
	}
	
	private var __onCALLMENU:Function
	private function _onCALLMENU(){
		__onCALLMENU();
	} 
	private function _onCALLCONNEXE(){
		__onCALLMENU();
	} 
	private function loadConfig() {
		var lang:String=Clips.getParam("lang");
		if (lang==undefined) {
			lang="fr";
		}
		var loaderXML:SimpleXML=new SimpleXML("ressources");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,Delegate.create(this, successData,"config"),this)
		loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		loaderXML.load("config_"+lang+".xml");
	}
	private function loadData(type:String) {
		
		var loaderXML:SimpleXML=new SimpleXML("ressources");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,Delegate.create(this, successData,type),this)
		loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		loaderXML.load(DataStk.val("config")[type][0].src);
	}
	
	private function successData(src:SimpleXML,conteneur:Object,type:String){
		switch (type) {
			case "config" :
				DataStk.add("config",conteneur);
				
				loadData("dictionnaire")
			break;
			case "dictionnaire" :
				DataStk.add(DataStk.DICO,conteneur);
				lanceIntro();
				loadData("menu")
			break;
			case "menu" :
				DataStk.add("menu",conteneur);
				loadData("rubriques")
			break;
			case "rubriques" :
				DataStk.add("rubriques",conteneur);
				allXMLLoaded=true;
				tryCloseIntro();

				loadInterface();
			break;
		}
		trace("Site.success(conteneur,"+type+")");
		
	}
	
	private function failedData(conteneur:Object){
		trace("Site.failed(conteneur)");
	}
	
	
	private function loadInterface(){
		var fichierInterface:String=DataStk.val("config").application[0].src;
		var clipInterface:MovieClip=clip.createEmptyMovieClip("content",10);
		clipInterface._visible=false;
		var interfaceLoader:SWFLoader=new SWFLoader(clipInterface);
		interfaceLoader.addEventListener(SWFLoader.ON_LOADINIT,onInterfaceLoaded,this)
		interfaceLoader.load(fichierInterface);
		
	}	
	
	public function onAppliReady(appli:site.Appli) {
		//trace("Site.onAppliReady(appli)");
		this.appli=appli;
		//swfInterface._visible=true;
		interfaceIsloaded=true;
		tryCloseIntro();
	}
	
	public function onAppliClosed(){
		trace("Site.onAppliClosed()");
		introOeuvreTrans.getClip()._visible=true;
		introOeuvreTrans.open();
	}
	
	private function lanceIntro(){
		var clipIntro:MovieClip=clip.createEmptyMovieClip("intro",1);
		var fichierIntro:String=DataStk.val("config").introSite[0].src;
		var introLoader:SWFLoader=new SWFLoader(clipIntro);
		introLoader.addEventListener(SWFLoader.ON_LOADINIT,onIntroInit,this)
		introLoader.load(fichierIntro);
		
	}
	private var introTrans:Transition;
	private function onIntroInit(source:SWFLoader,cible:MovieClip){
		introTrans=new Transition(cible,Number(DataStk.val("config").introSite[0].IMG_OPEN),Number(DataStk.val("config").introSite[0].IMG_CLOSE));
		introTrans.addEventListener(Transition.ON_CLOSE,onIntroEnd,this);
		introTrans.addEventListener(Transition.ON_OPEN,onIntroOpen,this);
		introTrans.open();
		cible._visible=true;
		var clipIntro:MovieClip=clip.createEmptyMovieClip("introOeuvre",5);
		clipIntro._visible=false;
		var fichierIntro:String=DataStk.val("config").introOeuvre[0].src;
		var introLoader:SWFLoader=new SWFLoader(clipIntro);
		introLoader.addEventListener(SWFLoader.ON_LOADINIT,onIntroOeuvreInit,this)
		introLoader.load(fichierIntro);
		
		
		var fichierPolice:String=DataStk.val("config").police[0].src;
		var clipPolice:MovieClip=clip.createEmptyMovieClip("police",3);
		clipPolice._visible=false;
		/*
		var PoliceLoader:SWFLoader=new SWFLoader(clipPolice);
		PoliceLoader.addEventListener(SWFLoader.ON_LOADINIT,onPoliceLoaded,this)
		PoliceLoader.load(fichierPolice);
		*/
		
	}
	
	
	
	

	private function onIntroOpen(){
	
		
		
		//trace("Site.onIntroOpen()");
		tryCloseIntro();
	}
	private function onIntroEnd(source:Transition){
		source.getClip().removeMovieClip();
		
		//trace("Site.onIntroEnd()");
		swfInterface._visible=true;
		introOeuvreTrans.getClip()._visible=true;
		introOeuvreTrans.open();
	}
	
	private function tryCloseIntro(){
		if (!allXMLLoaded)return;
		if (!introTrans.isOpen()) return;
		if (!introOeuvreIsReady)	return;
		if (!interfaceIsloaded)	return;
		if (!policeIsloaded)	return;
		introTrans.close();
		appli.clip.mcInfo.gotoAndPlay(2);
	}
	
	

	private function onIntroOeuvreInit(source:SWFLoader,cible:MovieClip){
		cible._visible=false;
		introOeuvreTrans=new Transition(cible,Number(DataStk.val("config").introOeuvre[0].IMG_OPEN),Number(DataStk.val("config").introOeuvre[0].IMG_CLOSE));
		introOeuvreTrans.addEventListener(Transition.ON_OPEN,onIntroOeuvreOPEN,this);
		introOeuvreTrans.addEventListener(Transition.ON_CLOSE,onIntroOeuvreCLOSE,this);
		introOeuvreTrans.addEventListener(Transition.ON_NEXTFRAME,onIntroOeuvreOpenning,this);
		introOeuvreTrans.addEventListener(Transition.ON_PREVFRAME,onIntroOeuvreClosing,this);
		cible.setReady=Delegate.create(this, onIntroOeuvreReady)
		cible.lire();	
		
		// on CLiC sur un mode ->
		
		//tryCloseIntro();
	}
	private function onIntroOeuvreReady(){
		//trace("Site.onIntroOeuvreReady()");
		
		introOeuvreIsReady=true;
		tryCloseIntro();
		
	}
	private var audioIntro:FluxAudio;
	/*
	private function audioIntroStop(src:FluxAudio) {
		src.play();
	}
	*/
	private function onIntroOeuvreOPEN(source:Transition){
		//trace("Site.onIntroOeuvreOPEN()");
		//trace(source.getClip().menuIntro.btn_guide)
		//trace(source.getClip().menuIntro.btn_libre)
		if (DataStk.val("config")["introOeuvreAudio"][0].src) {
			audioIntro=new FluxAudio(DataStk.val("config")["introOeuvreAudio"][0].src,true);
			//audioIntro.addEventListener(FluxAudio.ON_STOP,audioIntroStop,this);
		}
		source.getClip().menuIntro.btn_guide.onRelease=Delegate.create(this, openAppliGuide,source);
	//	source.getClip().menuIntro.btn_libre.onRelease=Delegate.create(this, openAppliLibre,source);
		
		
		
		
		__onCALLMENU=Delegate.create(this, openAppliGuide,source);
	}
	/*
	private function openAppliLibre(transIntro:Transition){
		transIntro.close();
		appli.open("libre");
		
	}
	*/
	private function openAppliGuide(transIntro:Transition){
		trace("Site.openAppliGuide(transIntro)");
		if (audioIntro) {
			audioIntro.stop();
		}
		transIntro.close();
		appli.start();
	}
	private function onIntroOeuvreCLOSE(source:Transition){
		
		source.getClip()._visible=false;
		
	}
	
	private function setTextsIntro(menuIntro:MovieClip) {
		//var t:TextField;
		if (DataStk.isDico("guide") || DataStk.isDico("guideDetail")) {
			menuIntro.titre.htmlText=DataStk.dico("guide");
			menuIntro.btn_guide.texte.htmlText=DataStk.dico("guideDetail");
		} else {
			menuIntro.btn_guide._visible=false;
		}
		/*
		if (DataStk.isDico("libre") || DataStk.isDico("libreDetail") ) {
			menuIntro.btn_libre.titre.htmlText=DataStk.dico("libre")+" <<";
			menuIntro.btn_libre.texte.htmlText=DataStk.dico("libreDetail");
		} else {
			menuIntro.btn_libre._visible=false;
		}
		*/
		var listLang:Array=DataStk.val("config").langue
		var i : Number = 0;
		for (i=0; i < listLang.length; i++) {
			
			initializeBtn(menuIntro["lang_"+i],listLang[i].text,listLang[i].ref).addEventListener(GraphicTools.BOverOutSelect.ON_PRESS,Delegate.create(this,_onPressLang,listLang[i]),this)
			
			
		}
		

		for (;i<5;i++) {
			menuIntro["lang_"+i]._visible=false;
		}
		if (Clips.getParam("swhx")!="true") {
			var lesAutres:Object=DataStk.val("config").collectionZoom[0]
			initializeBtnCollection(menuIntro.lesAutres,lesAutres.text).addEventListener(GraphicTools.BOverOutSelect.ON_PRESS,Delegate.create(this,_onPressLesAutres,lesAutres),this)
			
			
		} else {
			var lesAutres:Object=DataStk.val("config").collectionZoom[0]
			initializeBtnCollection(menuIntro.lesAutres,lesAutres.text);		
		}
		
		// TODO : ajouter la gestion des langues
		/*
		Clips.setTexteHtmlCss(clip.btn_version.texte,"style.css",DataStk.val("config").langue[0].text);
		if (Clips.getParam("swhx")=="true") {
			
			clip.btn_version.onRelease=function(){
				//getURL("null");
				//fscommand("lang",DataStk.val("config").langue[0].href);
				if (Chaines.getExt(DataStk.val("config").langue[0].href)=="html") {
					
					swhx.Api.call("backend.openLang",DataStk.val("config").langue[0].ref)
				} else {
					swhx.Api.call("backend.openLang",DataStk.val("config").langue[0].href)
				}
				site.Appli.CLOSE();
				
				SuspendedCall.createCall(function(){fscommand("exit")},this,500);
				
				//getURL("zoomsur_"+DataStk.val("config").langue[0].href+"swf");
				//fscommand("openLang",DataStk.val("config").langue[0].href);
			}
		} else {
			clip.btn_version.onRelease=function(){
				getURL(DataStk.val("config").langue[0].href);
			}
		}
		*/
		
	}
	
	private function _onPressLesAutres(src:GraphicTools.BOverOutSelect,btn:MovieClip,lesAutres:Object){
		getURL(lesAutres.href,"_blank");
	}
	
	private function _onPressLang(src:GraphicTools.BOverOutSelect,btn:MovieClip,langData:Object) {
		if (Clips.getParam("swhx")=="true") {
			if (langData.ref!=undefined) {
					swhx.Api.call("backend.openLang",DataStk.val("config").langue[0].ref)
			} else {
				swhx.Api.call("backend.openLang",DataStk.val("config").langue[0].href)
			}
				/*
				site.Appli.CLOSE();
				
				SuspendedCall.createCall(function(){fscommand("exit")},this,500);
				*/
				
		} else {
			getURL(langData.href);
		}
		
	}
	
	private function initializeBtnCollection(lClip:MovieClip,texte:String,ref:String): GraphicTools.BOverOutSelect{
		var lBtn:GraphicTools.BOverOutSelect;
		lClip.attachMovie("flag_"+ref,"_flag_",1);
		lBtn= new GraphicTools.BOverOutSelect(lClip,true,false,undefined,undefined,true);
		if (texte!=undefined) {
		ToolTip.associer(lBtn,texte,"infoBulleIco",-30,-30,lClip);
		}
	
//		arr_btn.push(lBtn);
		return lBtn;
		

	}
	
	private function initializeBtn(lClip:MovieClip,texte:String,ref:String): GraphicTools.BOverOutSelect{
		var lBtn:GraphicTools.BOverOutSelect;
		lClip.attachMovie("flag_"+ref,"_flag_",1);
		lBtn= new GraphicTools.BOverOutSelect(lClip,true,true);
		if (texte!=undefined) {
		ToolTip.associer(lBtn,texte,"infoBulleIco",-1,-30,lClip);
		}
	
//		arr_btn.push(lBtn);
		return lBtn;
		

	}
	
	
	private function onIntroOeuvreOpenning(src:Transition,currentframe:Number,image:Number){
		if (currentframe==2){
			setTextsIntro(src.getClip().menuIntro);
		}
		if (currentframe == Number(DataStk.val("config").introOeuvre[0].titreAt)) {
			
			//trace("Site.onIntroOeuvreOpenning(src, "+currentframe+", image)");
			

			appli.showTitre();
		}
		var menuIntro:MovieClip=src.getClip().menuIntro;
		
		
		
	}
	
	private function onIntroOeuvreClosing(src:Transition,currentframe:Number,image:Number){
		if (currentframe == src.getClip()._totalframes-1) {
			
			//trace("Site.onIntroOeuvreOpenning(src, "+currentframe+", image)");
			
			setTextsIntro(src.getClip().menuIntro);
			appli.showTitre();
		}
		
	}
	
	var swfInterface:MovieClip;
	private function onInterfaceLoaded(source:SWFLoader,cible:MovieClip){
		
		cible._visible=false;
		swfInterface=cible;
		appli=new site.Appli(cible);
		
	}
	
	private function onPoliceLoaded(source:SWFLoader,cible:MovieClip) {
		policeIsloaded=true;
		cible.removeMovieClip();
		tryCloseIntro();
		loadInterface();
	}
	
	public function close(){
		appli.close();
	
	}
}