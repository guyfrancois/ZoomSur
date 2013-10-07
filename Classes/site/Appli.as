/**;
 * @author GuyF , pense-tete.com
 * @date 14 mai 07
 * 
 * 
 *
 * _root.xmlData contient les données XML de ressources
 */
import org.aswing.util.SuspendedCall;
import Pt.animate.Transition;
import Pt.animate.ClipByFrame;
import Pt.Parsers.DataStk;
import media.BarreLecteur;

import site.*;
import org.aswing.util.Delegate;

import site.connexe.ConnexeGest;
import site.connexe.DocumentGest;
import Pt.animate.CBFReplaceClip;
import Pt.Temporise;
import Pt.scan.Souris;
import GraphicTools.ToolTip;
import GraphicTools.InfoBulle;
import Pt.sequence.Sequenceur;
import Pt.Tools.Clips;
import swhx.Api;


class site.Appli {
	static var CMDPAUSE:String="CMDPAUSE";
	static var CMDREPRISE:String="CMDREPRISE";
	static var CMDSTOP:String="CMDSTOP";
	
	public static var CLOSE:Function;
	
	
	public var clip:MovieClip;
	private var nagiv:site.Navigator;

	
	private var oeuvre:Oeuvre;

	private var menuTextes:MenuTextes;
	private var titre:Titre;
	private var sequenceur:Sequenceur;
	private var barreLecteur:BarreLecteur;
	private var trans:Transition;
	private var findComdListenner:Object;
	private var selTextListenner:Object;
	private var barreLecteurListenner:Object;
	private var sequenceLectureListenner:Object;
	
	private var contenuConnexeGestionnaire:ConnexeGest;
	
	
	public function Appli(clip:MovieClip) {
		caurina.transitions.properties.SoundShortcuts.init();
		trace("site.Appli.Appli("+clip+")");
		DataStk.event().addEventListener("MENU",_onCALLMENU,this);
		DataStk.event().addEventListener("CONNEXE",_onCALLCONNEXE,this);
		findComdListenner=DataStk.event().addEventListener("FINDCMD",findComd,this);
		selTextListenner=DataStk.event().addEventListener("SEL_TEXT",onSelText,this);
		InfoBulle.initialise(clip,10,undefined,undefined,"infoBulle",DataStk.val("rubriques").note); 
		ToolTip.initialise(clip,2000);
		if (Clips.getParam("swhx")=="true") {
			Stage["displayState"] = "fullScreen";
			Key.addListener( {
				onKeyDown : Delegate.create(this,this.onKeyDown)
			})
			fscommand("ready");
		}
		this.clip=clip;
		SWFAddress.isModeGuide=Delegate.create(this,isModeGuide);
		//clip._visible=false;
		//initContent();
		initialize();
	}
	private function onAppliReady(){
		clip._parent.oSite.onAppliReady(this);
		initTimer();
		SuspendedCall.createCall(initConnection,this,100);
	}
	
	private function _onCALLMENU(src:DataStk,idMenu,idRub){
		contenuConnexeGestionnaire.close();
		menuTextes.select(idMenu,idRub)
	}
	
	private function _onCALLCONNEXE(src:DataStk,type:String,idRub) {
		contenuConnexeGestionnaire.select(type,idRub)
	}

	
	private var docu:DocumentGest;
	private function initContent(){
		CLOSE=Delegate.create(this,this.close)
		_root.loader=clip.loader;
		_root.loader._visible=false;
		trans=new Transition(clip);
		trans.addEventListener(Transition.ON_OPEN,onTransAppliOpen,this);
		trans.addEventListener(Transition.ON_OPEN_START,onTransAppliOpenStart,this)
		trans.addEventListener(Transition.ON_CLOSE_START,onTransAppliClosedStarting,this);
		trans.addEventListener(Transition.ON_CLOSE,onAppliClosed,this);
		trace("visage.Visage.initContent()");
//		reperes=new Reperes(clip.reperes,"style.css");
		
		oeuvre=new Oeuvre(clip.oeuvre);
		menuTextes=new MenuTextes(clip.menuTextes,clip.clipMenuOutils);
		menuTextes.addEventListener(MenuTextes.ON_MENU_SEQUENCE,_onMenuSelect,this);
		clip.loader.chargement.text=DataStk.dico("chargement");;
		titre=new Titre(clip.titre);
		
		sequenceur=new Sequenceur(clip.oeuvre);
		
		docu=new DocumentGest(clip.mcDocuments);
		docu.hideMenu();
		
		contenuConnexeGestionnaire=new ConnexeGest(
			clip.mcFocus,
			clip.mcFilms,
			clip.mcAtelier,
			clip.mcRessources,
			clip.mcInfo.mcInfo,
			clip.mcConteneurConnexe);
			contenuConnexeGestionnaire.addEventListener(ConnexeGest.ON_OPEN_CONNEXE,onCallOpenConnex,this)
		
		
		
//		ecranLoupe=new EcranLoupe(clip.ecranZoom);
		// TODO : DECONNECTER BARRELECTURE du sequencer general
		barreLecteur=new BarreLecteur(clip.barreLecteur);
		
		barreLecteurListenner=new Object();
		barreLecteurListenner[BarreLecteur.ONPLAYPRESS]=Delegate.create(this,reprise_playLastSequence);
		barreLecteurListenner[BarreLecteur.ONSTOPPRESS]=Delegate.create(this,onStopBarreLecture);
		barreLecteurListenner[BarreLecteur.ONPAUSEPRESS]=Delegate.create(this,onPauseBarreLecture);
		
		sequenceLectureListenner=new Object();
		sequenceLectureListenner[Sequenceur.ON_START]=Delegate.create(barreLecteur,barreLecteur.onPlay);
		sequenceLectureListenner[Sequenceur.ON_PAUSE]=Delegate.create(barreLecteur,barreLecteur.onPause);
		sequenceLectureListenner[Sequenceur.ON_STOP]=Delegate.create(barreLecteur,barreLecteur.onStop);
		
		
		barreLecteur.addEventListener(barreLecteurListenner);
		
		sequenceur.addEventListener(sequenceLectureListenner);
		
		/*
		barreLecteur.addEventListener(BarreLecteur.ONPLAYPRESS,reprise_playLastSequence,this);
		barreLecteur.addEventListener(BarreLecteur.ONSTOPPRESS,stopSequence,this);
		barreLecteur.addEventListener(BarreLecteur.ONPAUSEPRESS,pauseSequence,this);
		sequenceur.addEventListener(Sequenceur.ON_START,barreLecteur.onPlay,barreLecteur);
		sequenceur.addEventListener(Sequenceur.ON_PAUSE,barreLecteur.onPause,barreLecteur);
		sequenceur.addEventListener(Sequenceur.ON_STOP,barreLecteur.onStop,barreLecteur);
		*/
		sequenceur.addEventListener(Sequenceur.ON_READY,_onSequenceReady,this);
		sequenceur.addEventListener(Sequenceur.ON_STOP,_onSequenceStop,this);
		contenuConnexeGestionnaire.hideMenu();
		
		
		
		onAppliReady();
		
	}

	private function onTransAppliOpen(){
		titre.offTitre();
	}
	
	private function onTransAppliOpenStart(){
		contenuConnexeGestionnaire.showMenu();
		docu.showMenu();
	}
	public function overideItonAppliClosed(){
		
	}
	private function onTransAppliClosedStarting(){
		
	}
	private function onAppliClosed(){
		contenuConnexeGestionnaire.hideMenu();
		oeuvre.close();
		barreLecteur.close();
		menuTextes.close();
		titre.onTitre();
	}
	
	public function showTitre(){
		titre.open();
		
	}
	
	/*
	public function open(mode:String){
		LOG("OPEN");
		oeuvre.open();
		
		trans.open();
		SWFAddress.setMode(mode);
		clip.titre.content.btnZoom.onRelease=Delegate.create(this,this.close);
		if (Clips.getParam("swhx")=="true") {
			timer.destroy();
			if (DataStk.val("config").temporisation[0].val!=undefined) {
				timer=new Temporise(DataStk.val("config").temporisation[0].val,Delegate.create(this,close),true);
			}
		}
	}
	*/
	
	public function close(){
//		delete clip.titre.onRelease;
		if (trans.isOpen()) {
			LOG("CLOSE");
		}
		sequenceur.stop();
		sequenceur.load("intro.xml")
		//SWFAddress.setMode();
		trans.close();
		clip._parent.oSite.onAppliClosed(this);
		contenuConnexeGestionnaire.close();
		//timer.destroy();


	}
	
	
	
	private function initialize(){
		initContent();
		nagiv=Navigator.getInstance();
		
	//	nagiv.addEventListener(Navigator.ON_ZOOM,onZoom,this);
	//	nagiv.addEventListener(Navigator.ON_CLOSE_ZOOMVIDEO,onCloseZoomVideo,this);
	//	nagiv.addEventListener(Navigator.ON_RUBRIQUE,onRubrique,this);
		nagiv.addEventListener(Navigator.ON_ACCUEIL,onAccueil,this);
		nagiv.addEventListener(Navigator.ON_SEQUENCE,onSequence,this);
	//	nagiv.addEventListener(Navigator.ON_MODE,onMode,this);
	//	nagiv.addEventListener(Navigator.ON_LOUPE,onLoupe,this);
		
		clip.anticlic._visible=false;
		SWFAddress.setSequence("intro.xml");
		//___rubriqueSelectionne(undefined,0);
	}
	
	/*
	private function ___onEtapeSelected(src:Object,id:Number) {
		nagiv.setRubrique(id);
        nagiv.updateValue();
	}
	*/

	private var bentree:Boolean;

	/*
	public function onMode(nav:Navigator,mode:String) {
		bentree=true;
		if (mode==undefined) {
			sequenceur.stop()
		} else {
			SWFAddress.setSequence(mode+".xml");
		}
		if (mode==DefModes.GUIDE) {
			barreLecteur.open();
		} else {
			barreLecteur.close();
		}
		menuTextes.open(mode);
	}
	*/
	public function start(){
		bentree=true;
		LOG("OPEN");
		oeuvre.open();
		trans.open();
		barreLecteur.open();
		menuTextes.open(DefModes.GUIDE);
		clip.titre.content.btnZoom.onRelease=Delegate.create(this,this.close);
		if (Clips.getParam("swhx")=="true") {
			timer.destroy();
			if (DataStk.val("config").temporisation[0].val!=undefined) {
				timer=new Temporise(DataStk.val("config").temporisation[0].val,Delegate.create(this,close),true);
			}
		}
	}
	
	/*  EVENEMENT LANCEMENT DE SEQUENCE */
	//private var lastFileSequence:String;
	private var sequencePause:Boolean;
	private var sequenceDuMenu:String;
	private var sequenceDuMenuCmd:String;
	public function isModeGuide():Boolean {
		return (sequenceur.sequenceFile==sequenceDuMenu)
	}
	
	
	private function reprise_playLastSequence(){
		Send.event(site.TexteAccordeon.HIDEBTNSEQ)
		trace("Send.event(site.TexteAccordeon.HIDEBTNSEQ) site.Appli.reprise_playLastSequence()"+sequencePause+" "+sequenceur.isStarted+" "+sequenceur._cmdToStartWith);
		if (sequenceur.sequenceFile!=sequenceDuMenu) {
			sequenceur.removeEventListener(sequenceLectureListenner);
		 	sequenceur.addEventListener(sequenceLectureListenner);
			sequencePause=false;
			sequenceur.load(sequenceDuMenu,sequenceDuMenuCmd);
		} else {
			if (sequencePause) {
				Send.event(sequenceDuMenuCmd)//SELTEXT...
				sequenceur.reprise()
			} else if (sequenceur.isStarted==false) {
				sequenceur._cmdToStartWith=sequenceDuMenuCmd;
				sequenceur.start();
			} else {
				sequenceur.load(sequenceDuMenu,sequenceDuMenuCmd);
			}
		}
	}
	
		
	private function onStopBarreLecture() {
		if (sequenceur.sequenceFile==sequenceDuMenu) {
				stopSequence();
		}
	}
	
	
	private function stopSequence(){
		trace("site.Appli.stopSequence()");
		trace("0 Send.event(site.TexteAccordeon.SHOWBTNSEQ)")
			sequenceDuMenuCmd=undefined;
			Send.event(site.TexteAccordeon.SHOWBTNSEQ)
			Send.event("SEL_TEXT,0,0");
			sequencePause=false;
			sequenceur.stop();
			sequenceur.load(sequenceDuMenu)
			barreLecteur.onStop()
		
	}
	
	private function onPauseBarreLecture(){
		if (sequenceur.sequenceFile==sequenceDuMenu) {
			sequencePause=true;
			sequenceur.pause();
		}
	}
	

	
	public function onSequence(nav:Navigator,file:String) {
		trace("site.Appli.onSequence(nav, "+file+")"+sequenceDuMenu);
		sequencePause=false;
		switch (file) {
			case CMDSTOP :
			/*
			 sequencePause=false;
			 sequenceur.stop();
			 */
			 stopSequence();
			break;
			case CMDPAUSE :
			if (sequenceur.isStarted) {
			 sequencePause=true;
			 sequenceur.pause();
			}
			break;
			case CMDREPRISE :
			Send.event(sequenceDuMenuCmd)//SELTEXT...
			 sequenceur.reprise();
			break;
			default :

			 sequenceur.removeEventListener(sequenceLectureListenner);
			 if (file==sequenceDuMenu) {
			 	sequenceur.addEventListener(sequenceLectureListenner);
			 }
			 
			 sequenceur.load(file);
			break;
		}
		
	}
	

	public function _onSequenceReady(src:Sequenceur,_cmdToStartWith:String){
	
		trace("site.Appli._onSequenceReady(src, "+_cmdToStartWith+")"+src.sequenceFile+" "+sequenceDuMenu+" "+bentree);
		if ( bentree) {
			trace("Send.event(site.TexteAccordeon.HIDEBTNSEQ)"+bentree)
			Send.event(site.TexteAccordeon.HIDEBTNSEQ)
		} 
		if (_cmdToStartWith!=undefined || src.sequenceFile!=sequenceDuMenu || bentree) {
			if (src.sequenceFile!=sequenceDuMenu) {
				trace("1 Send.event(site.TexteAccordeon.SHOWBTNSEQ)"+_cmdToStartWith+" "+src.sequenceFile+" "+sequenceDuMenu+" "+bentree);
				Send.event(site.TexteAccordeon.SHOWBTNSEQ)
			} else {
				trace("1 Send.event(site.TexteAccordeon.HIDEBTNSEQ)"+_cmdToStartWith+" "+src.sequenceFile+" "+sequenceDuMenu+" "+bentree)
				Send.event(site.TexteAccordeon.HIDEBTNSEQ)
			}
			src.start();
			bentree=false;
		} else {
				trace("2 Send.event(site.TexteAccordeon.SHOWBTNSEQ)"+_cmdToStartWith+" "+src.sequenceFile+" "+sequenceDuMenu+" "+bentree);
				
				Send.event(site.TexteAccordeon.SHOWBTNSEQ)
		}
	}
	
	public function _onSequenceStop(src:Sequenceur) {
		trace("site.Appli._onSequenceStop(src) Send.event(site.TexteAccordeon.SHOWBTNSEQ)");
		Send.event(site.TexteAccordeon.SHOWBTNSEQ)
	}
	
	/**
	 * evenement sequence du textes	 */
	
	 private function _onMenuSelect (src:IMenuType,seq:String){
		trace("_onMenuSelect up"+seq);
		sequenceDuMenu=seq;
		
		if (seq!=undefined) {
				Send.event("SEL_TEXT");
				SWFAddress.setSequence(seq);
		}
		
	}
	
	private function onSelText(src:DataStk,ibBloc:Number,idPara:Number){
		trace("site.Appli.onSelText(src, "+ibBloc+", "+idPara+")");
		if (ibBloc!=undefined && idPara !=undefined) {
			sequenceDuMenuCmd="SEL_TEXT,"+ibBloc+","+idPara;
		} else {
			sequenceDuMenuCmd=undefined;
		}
	}
	/**
	 * lance sur une commande	 */
	private function findComd(src:DataStk,param1,param2,param3){
		trace("site.Appli.findComd(src, "+param1+", "+param2+", "+param3+") Send.event(site.TexteAccordeon.HIDEBTNSEQ)");
		Send.event(site.TexteAccordeon.HIDEBTNSEQ)
		
		sequenceur.removeEventListener(sequenceLectureListenner);
	 	sequenceur.addEventListener(sequenceLectureListenner);
		
		sequenceur.load(sequenceDuMenu,param1+","+param2+","+param3);
		sequenceDuMenuCmd=sequenceur._cmdToStartWith
	}
	
	/* ECRANS SUPPLEMENTAIRES */
	private function onCallOpenConnex() {
		bentree=false; // pas de mise en lecture auto si un clic vite sur le menu bas
		sequenceur.pause();
	}

	
	
	/*  EVENEMENTS D'OUTILS */
	public static function infoBulle(info:String,x:Number,y:Number,ref:MovieClip){
		InfoBulle.create(info,"infoBulle",x,y,ref);
	}
	
	
   
   /**
    * le menu des vues va alimenter le stock de loupes dans DataStk
    */
    


	public function onAccueil(nav:Navigator,cloneArrAdd:Array) {
		trace("cine.Cine.onAccueil(nav, cloneArrAdd)");
	}
	
	/*
	public function  onCloseZoomVideo(nav:Navigator,idRubrique:String,cloneArrAdd:Array){
       trace("cine.Cine. onCloseZoomVideo(nav, "+idRubrique+", "+cloneArrAdd+")");
        //zoom.transClose();
    }
	*/
	

	/*
	public function onRubrique(nav:Navigator,id:String,cloneArrAdd:Array){
		trace("visage.Visage.onRubrique(nav,"+id+" , cloneArrAdd)");
		if (id=="") { // retour accueil
			//carte.transClose();
			rubrique.transClose();
			
		} else {
		
			rubrique.transRubrique()
		}
       
	}
	*/
	
	
    
    // couche EXE
    
    public function initConnection(){
		if (Clips.getParam("swhx")=="true") {
			swhx.Api.init(this);
			trace("swhx.Api.init(this);")
		}
	}
	
    private function onKeyDown() {
		 if ( Key.getCode() == Key.ESCAPE) {
    		fscommand("exit");
   		 }
	}
	
    public static function LOG(data:String) {
		if (Clips.getParam("swhx")=="true") {
			fscommand("log",Clips.getParam("lang")+";"+data);
		}
	}
	
	/** gestion du timer */
	public static var timer:Temporise;
	private var mouseScan:Souris;
	private function initTimer(){
		if (Clips.getParam("swhx")=="true") {
			mouseScan=new Souris();
			mouseScan.addEventListener(Souris.ON_MOUSEMOVE,timerOnMouseMove,this);
			mouseScan.startScan();
			timer.destroy();
			if (DataStk.val("config").temporisation[0].val!=undefined) {
				timer=new Temporise(DataStk.val("config").temporisation[0].val,Delegate.create(this,close),true);
			}
			
		}
		
	}
	
	private function timerOnMouseMove(){
		Stage["displayState"] = "fullScreen";
		timer.reprise();
	}
    
    
    


	
	



}