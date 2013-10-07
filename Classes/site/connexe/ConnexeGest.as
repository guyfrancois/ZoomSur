/**
 * @author GuyF    , pense-tete
 * 26 f�vr. 2010
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import org.aswing.util.Delegate;
import Pt.Parsers.DataStk;

import GraphicTools.MenuPlatXML;
import Pt.Parsers.XmlTools;

import Pt.animate.ClipByFrame;
import site.connexe.*

/**
 * 
 */
class site.connexe.ConnexeGest extends EventDispatcher {
	private var imagesBtn:Object={IMG_OUT:1,IMG_OVER:3,IMG_PRESS:4,IMG_ON:4,IMG_OFF:1};
	private  var xmlTool:XmlTools;
	/**
	 * quand un contenu connexe est ouvert (premiere fois)
	 * demande l'arret du sequenceur
	 * onOpenConnexe(source:)
	 */	
	public static var ON_OPEN_CONNEXE:String = "onOpenConnexe";
	/**
	 * quand un contenu connexe est fermé
	 * onCloseConnexe(source:)
	 */	
	public static var ON_CLOSE_CONNEXE:String = "onCloseConnexe";
	
	//private var menuArray:Array;
	private var menuClips:Array;
	private var btnRessource:GraphicTools.BOverOutSelect;
	private var btnPlan:GraphicTools.BOverOutSelect;
	private var btnContact:GraphicTools.BOverOutSelect;
	private var btnCredits:GraphicTools.BOverOutSelect;
	
	private var mcFocus:MovieClip
	private var mcFilms:MovieClip
	private var mcAtelier:MovieClip
	private var mcRessources:MovieClip
	private var mcInfo:MovieClip
	
	
	private var menuFocus:MenuPlatXML;
	private var menuFilms:MenuPlatXML;
	private var menuAtelier:MenuPlatXML;
	
	private var connexeContener:ConnexeContener;
	
	
	public function ConnexeGest(mcFocus:MovieClip,mcFilms:MovieClip,mcAtelier:MovieClip,mcRessources:MovieClip,mcInfo:MovieClip,mcConteneurConnexe:MovieClip) {
		super();
		connexeContener=new ConnexeContener(mcConteneurConnexe);
		connexeContener.addEventListener(ConnexeContener.ON_CLOSE_CONNEXE,_onCloseConnexeByUser,this)
		
		this.mcFocus=mcFocus;
		this.mcFilms=mcFilms;
		this.mcAtelier=mcAtelier;
		this.mcRessources=mcRessources;
		this.mcInfo=mcInfo;
		
		//menuArray=new Array();
		 xmlTool=new XmlTools(DataStk.val("menu"));
		 
		mcFocus.texte.texte.htmlText="<i>"+DataStk.dico("Focus")+"</i>";
		mcFilms.texte.texte.htmlText="<i>"+DataStk.dico("Filmsetvideo")+"</i>";
		mcAtelier.texte.texte.htmlText="<i>"+DataStk.dico("Atelier")+"</i>";
		mcRessources.texte.texte.htmlText=DataStk.dico("Ressources");
		
		mcInfo.btn_plan.texte.texte.htmlText=DataStk.dico("plan");
		if (Pt.Tools.Clips.getParam("swhx")=="true") { 
			mcInfo.btn_contact._visible=false;
		}
		
		mcInfo.btn_contact.texte.texte.htmlText=DataStk.dico("contact");
		mcInfo.btn_credits.texte.texte.htmlText=DataStk.dico("credits");
		
		menuClips.push(mcFocus)
		
        menuFocus=initMenu(mcFocus,"Focus");
        menuFilms=initMenu(mcFilms,"Filmsetvideo");
        menuAtelier=initMenu(mcAtelier,"Atelier");
        
       	( btnRessource=initializeBtn(mcRessources.btnRessource)).addEventListener(GraphicTools.BOverOutSelect.ON_PRESS,_onBtn,this);
        ( btnPlan=initializeBtn(mcInfo.btn_plan)).addEventListener(GraphicTools.BOverOutSelect.ON_PRESS,_onBtn,this);
        ( btnContact=initializeBtn(mcInfo.btn_contact)).addEventListener(GraphicTools.BOverOutSelect.ON_PRESS,_onBtn,this);
        ( btnCredits=initializeBtn(mcInfo.btn_credits)).addEventListener(GraphicTools.BOverOutSelect.ON_PRESS,_onBtn,this);
	}
	
	/**
	 * Afficher le menu à l'ouverture de l'interface
	 * parceque le menu de doit pas être visible ni réagire pendant l'ecran d'intro sauf pour
	 * plan, contact et Crédits
	 */
	public function showMenu(){
		this.mcFocus._visible=true;
		this.mcFilms._visible=true;
		this.mcAtelier._visible=true;
		this.mcRessources._visible=true;
		/*
		this.mcInfo._visible=true;
		*/
	}
	
	/**
	 * cacher le menu à la fermeture de l'interface
	 */
	public function hideMenu(){
		this.mcFocus._visible=false;
		this.mcFilms._visible=false;
		this.mcAtelier._visible=false;
		this.mcRessources._visible=false;
	}
	
	/**
	 * ferme le menu le volet en cours
	 */
	public function close(){
		connexeContener.close();
		closePrevBtn();
		closePrevEntry();
	}
	
	public function select(name:String,id:Number){
		switch (name) {
			case "focus" : 
				menuFocus.setAction(id);
			break;
			case "films" :
				menuFilms.setAction(id);
			break;
			case "atelier" :
				menuAtelier.setAction(id);
			break;
			case "ressources" :
				btnRessource._onPress();
			break;
			case "plan" :
				btnPlan._onPress();
			break;
			case "contact" :
				btnContact._onPress();
			break;
			case "credits" :
				btnCredits._onPress();
			break;
		}
		
	}
	/**
	 * initialisation des boutons (mcInfo : contact/credits/plan/ ressources
	 */
	private function initializeBtn(lClip): GraphicTools.BOverOutSelect{
		var lBtn:GraphicTools.BOverOutSelect;
		var btnCBF:ClipByFrame=new ClipByFrame(lClip);
		lBtn= new GraphicTools.BOverOutSelect(lClip,true,true,Delegate.create(btnCBF, btnCBF.goto),imagesBtn,false);
		//trace("GraphicTools.MenuPlat.initializeBtn("+lClip+") imagesBtn:"+imagesBtn);
//		arr_btn.push(lBtn);
		return lBtn;
		

	}
	
	/**
	 * initialisation des menus : focus / films /aTeliers 	 */
	
	private function initMenu(mcMenu:MovieClip,type:String):MenuPlatXML {
		var find:Object=xmlTool.find("menu","type",type)
		trace("site.connexe.ConnexeGest.initMenu("+mcMenu+", "+type+")"+find);
		if (find==undefined) {
			
			mcMenu.puce._visible=false;
			mcMenu.texte._visible=false;
			return null;
		}
		var menuXML:MenuPlatXML=new  MenuPlatXML(mcMenu.placeMenu,undefined,imagesBtn,find);
		menuXML.ToolTipMenu="infoBulleIco";
        menuXML.addEventListener(MenuPlatXML.ON_MENUPRESS,Delegate.create(this,_onSelectMenu,mcMenu),this);
        menuXML.initialize(); 
        return menuXML;
	}
	
	// Conservations de la derniere selection pour les bascules d'etats
	private var lastBtn:GraphicTools.BOverOutSelect;
	private var lastmcMenu:MovieClip
	private var lastxmlMenu:MenuPlatXML
	
	/**
	 * Ouverture via l'un des boutons	 */
	private function _onBtn(src:GraphicTools.BOverOutSelect){
		closePrevBtn(src);
		closePrevEntry(src.getBtn()._parent);
		switch (src) {
			case btnRessource:
				connexeContener.create_ressources();
			break;
			case btnContact:
				connexeContener.create_contact();
			break;
			case btnCredits:
				connexeContener.create_credit();
			break;
			case btnPlan:
				connexeContener.create_plan();
			break;
			
		}
		
		dispatchEvent(ON_OPEN_CONNEXE,new Event(this,ON_OPEN_CONNEXE));
	}
	
	/**
	 * Ouverture via l'un des menu	 */
	private function _onSelectMenu(src:MenuPlatXML,id:Number,data:Object,mcMenu:MovieClip){
		//trace("select vue"+id)
		closePrevBtn();
		closePrevEntry(mcMenu,src)
		switch (mcMenu) {
			case mcFocus:
				connexeContener.create_focus(DataStk.val("config").repReperes[0].src+data.xml,data.conteneur);
			break;
			case mcFilms:
				connexeContener.create_films(DataStk.val("config").repReperes[0].src+data.xml,data.conteneur)
			break;
			case mcAtelier:
				connexeContener.create_atelier(DataStk.val("config").repReperes[0].src+data.xml,data.conteneur);
			break;
			
		}
		
		
		dispatchEvent(ON_OPEN_CONNEXE,new Event(this,ON_OPEN_CONNEXE));//,[id,data]));
		
		
	}
	
	/**
	 * fermeture depuis le btn fermer de la popup
	 * -> mettre à jour le menu	 */
	private function _onCloseConnexeByUser(src:ConnexeContener) {
		//trace("site.connexe.ConnexeGest._onCloseConnexeByUser(src)");
		closePrevBtn();
		closePrevEntry();
	}
	
	
	/**
	 * Logique de fermeture des elements menu	 */
	private function closePrevBtn(btn:GraphicTools.BOverOutSelect) {
		//trace("site.connexe.ConnexeGest.closePrevBtn("+btn.getBtn()+")"+(lastBtn!=btn));
		if (lastBtn!=btn) {
			lastBtn.enable=true
		}
		lastBtn=btn;
	}
	
	
	private function closePrevEntry(mcMenu:MovieClip,src:MenuPlatXML){
		//trace("site.connexe.ConnexeGest.closePrevEntry("+mcMenu+", src)");
		if (lastmcMenu!=mcMenu) {
			lastmcMenu.gotoAndStop(1);
		}
		if (lastxmlMenu!=src) {
			lastxmlMenu.setNoAction();
		}
		lastxmlMenu=src;
		lastmcMenu=mcMenu;
		mcMenu.gotoAndStop(2);
		
	}
	

	
	

	

	

	
	
	
	/*
			credits.transClose();
//		reperes.transClose();
	
	private var credits:Credits;
	private var contacts:Contact;
	
	nagiv=Navigator.getInstance();
		//	nagiv.addEventListener(Navigator.ON_REPERE,onRepere,this);
	
	
			credits=new Credits(clip.credits ,DataStk.val("config").credits[0].src,"style.css");
		contacts=new Contact(clip.contact);
	
	
	clip.mcInfo.btn_credits.onRelease=Delegate.create(this,onCallOpenCredit);
		
	  	clip.mcInfo.btn_contact.onRelease=Delegate.create(this,onCallOpenContact);
	  	
	  	
	  	clip.btnRepere.onRelease=Delegate.create(this,function (){SWFAddress.setRepere("_0");});
	  	
	 */
	 
	 /*
	public function onRepere(nav:Navigator,id:String,cloneArrAdd:Array){
		//trace("site.Appli.onRepere(nav, "+id+", cloneArrAdd)");
		if (id=="") {
			reperes.transClose();
		} else {
			sequenceur.stop();
			reperes.transOpen(id);
		}
    }
    */
      //public function onLoupe(nav:Navigator,fondRef:String){
    	/*
         var loupParam:Object= {
         src: "img/fonds/fond_1_01.jpg",
         hd : "img/fonds/fond_1_01.jpg",
         defaultZoom : "1",
         minZoom : "1",
        maxZoom : "3",
        pasZoom : "0.1"
        }
        */
           
            //ecranLoupe.transOpen( DataStk.val("loupes")[fondRef]);
  //}
  
  /*
	public function onZoom(nav:Navigator,idRubrique:String,cloneArrAdd:Array){
		//trace("onZoom(nav, "+idRubrique+", "+cloneArrAdd+")");
	//	zoom.transOpen(idRubrique);
	}
	*/
    

}