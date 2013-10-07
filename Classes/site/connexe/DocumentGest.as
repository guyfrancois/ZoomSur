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

/**
 * 
 */
class site.connexe.DocumentGest extends EventDispatcher {
	private var imagesBtn:Object={IMG_OUT:1,IMG_OVER:3,IMG_PRESS:4,IMG_ON:1,IMG_OFF:1};
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
	
	
	private var mcDocuments:MovieClip
	
	private var menuDocument:MenuPlatXML;
	
	
	public function DocumentGest(mcDocuments:MovieClip) {
		super();
		if (Pt.Tools.Clips.getParam("swhx")=="true") { 
			mcDocuments._visible=false;
			return;
		}
		
		this.mcDocuments=mcDocuments;
		
		//menuArray=new Array();
		 xmlTool=new XmlTools(DataStk.val("menu"));
		 
		
        menuDocument=initMenu(mcDocuments,"Documents");
	}
	
	/**
	 * Afficher le menu à l'ouverture de l'interface
	 * parceque le menu de doit pas être visible ni réagire pendant l'ecran d'intro sauf pour
	 * plan, contact et Crédits
	 */
	public function showMenu(){
		this.mcDocuments._visible=true;
	}
	
	/**
	 * cacher le menu à la fermeture de l'interface
	 */
	public function hideMenu(){
		this.mcDocuments._visible=false;
	}
	
	
	/**
	 * initialisation des menus : focus / films /aTeliers 	 */
	
	private function initMenu(mcMenu:MovieClip,type:String):MenuPlatXML {
		var find:Object=xmlTool.find("menu","type",type)
		trace("site.connexe.ConnexeGest.initMenu("+mcMenu+", "+type+")"+find);
		if (find==undefined) {
			return null;
		}
		var menuXML:MenuPlatXML=new  MenuPlatXML(mcMenu,undefined,imagesBtn,find,true);
		menuXML.ToolTipMenu="infoBulleDocs";
        menuXML.addEventListener(MenuPlatXML.ON_MENUPRESS,Delegate.create(this,_onSelectMenu,mcMenu),this);
        menuXML.initialize(); 
        return menuXML;
	}
	

	/**
	 * Ouverture via l'un des menu	 */
	private function _onSelectMenu(src:MenuPlatXML,id:Number,data:Object,mcMenu:MovieClip){
		switch (mcMenu) {
			case mcDocuments:
				getURL(DataStk.val("config").repReperes[0].src+data.href,"_blank");
				//SWFAddress.openLink(DataStk.val("config").repReperes[0].src+data.href,"_blank");
				//connexeContener.create_focus(DataStk.val("config").repReperes[0].src+data.xml);
			break;
		
		}
	}
}