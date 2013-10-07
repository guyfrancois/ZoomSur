/**
 *
 */
import Pt.html.Render;
 import Pt.Parsers.DataStk;
import org.aswing.util.Delegate;
import site.connexe.TransContent;
import org.aswing.Event;
import Pt.Tools.ClipScollerDerouleur;
import Pt.Parsers.SimpleXML;
import Pt.Tools.ClipScoller;
import Pt.Tools.Clips;


import Pt.Parsers.XmlTools;
import GraphicTools.MenuPlatXML;

/**
 * Gere l'affichage d'une popup crédit
 */
class site.connexe.MenuEtHtml implements site.connexe.I_connexeContenu {
	public static var imagesBtn:Object={IMG_OUT:1,IMG_OVER:3,IMG_PRESS:4,IMG_ON:4,IMG_OFF:1};

	private var htmlContent:Render;
	private var xmlTool:XmlTools;
	
	private var cssFile:String;
	private var htmlZone:MovieClip;
	
	// liste des menus (multi-menu)
	private var menuArray:Array;
	
	private var asClipScollerb:Pt.Tools.ClipScoller;
	
	/**
	 * @param clip ecran qui contiendra le contenu	 */
	public function MenuEtHtml(clip:MovieClip,type:String,cssFile:String) {
		super(clip);
		
		this.cssFile=cssFile;
		htmlZone=clip.attachMovie("ecranMenuHtml","htmlZone",1);
		htmlContent=new Render(htmlZone.htmlContent.texte,cssFile);
        htmlContent.addEventListener(Render.ON_READY,_onUpdateContent,this);
       	asClipScollerb=new ClipScoller(htmlZone.htmlContent,true,"scroller_texte",0,-htmlZone.htmlContent.masque._y);
       	asClipScollerb.addEventListener(ClipScoller.ON_MOVEDONE,_onMoveDone,this)
		htmlContent.clear();
		asClipScollerb.onChanged();
		initMenu(htmlZone.clipMenu,type);
	   // loadContent(xmlFile);
	
	}
	
	/**
	 * Initialisation du menu
	 * @param clipMenu : clip qui contiendra le menu
	 * @param type : entrée dans menu.xml	 */
	private function initMenu(clipMenu:MovieClip,type:String){
		menuArray=new Array();
		xmlTool=new XmlTools(DataStk.val("menu"));
		var arrMenu:Array=xmlTool.findSub("menu","type",type);
		
		for (var i : Number = 0; i < arrMenu.length; i++) {
			var menuItem:MovieClip=clipMenu.createEmptyMovieClip("menu_"+i,clipMenu.getNextHighestDepth());
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
			menuXML.addEventListener(MenuPlatXML.ON_MENUINIT,Delegate.create(this, __onMenuInit,i,clipMenu),this);
			menuXML.addEventListener(MenuPlatXML.ON_MENUPRESS,_onMenuPress,this);
			menuXML.initialize();
					
		}
		menuArray[0].menuXML.setAction(0);	
		
	}
	
	private function __onMenuInit(src:MenuPlatXML,null1,i:Number,clip:MovieClip){
		//trace("site.MenuGuide.__onMenuInit(src, "+i+")");
		if (i>0) {
			var precedent:MovieClip=clip["menu_"+(i-1)];
			var courant:MovieClip=clip["menu_"+i];
			//trace(precedent+" "+courant);
			courant._y=precedent._y+precedent._height;
		}
	}
	
	
	private function _onMenuPress(src:MenuPlatXML,id:Number,data:Object) {
		//trace("site.connexe.MenuEtHtml._onMenuPress(src, "+id+", "+data+")");
		for (var i : Number = 0; i < menuArray.length; i++) {
			if (menuArray[i].menuXML!=src) {
				menuArray[i].menuXML.reset();
				
			} else {
				if (data.href!=undefined) {
					popup(data.href);
				} else {
					genHtml(data.xml);
				}
			}
			
		}
		
	}
	
	
	
	
	
	/**
	 * ouverture d'un contenu en popup	 */
	 public function popup(lien:String) {

     	SWFAddress.openPopup(lien,"popup","toolbar=no,location=no,noborder,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=565,height=450,top=20,left=20");
     }
	
	

	
	private function genHtml(xmlFile:String){
				htmlContent.clear();
				asClipScollerb.onChanged();
			    loadContent(DataStk.val("config").repReperes[0].src+xmlFile);
	}
	
	/**
	 * suppression du contenu obsoléte	 */
	public function remove(){
		htmlContent.clear();
		htmlZone.removeMovieClip();
	}
	
	/**
	 * chargement du XML	 */
	private function loadContent(xmlFile:String) {
		//trace("site.connexe.MenuEtHtml.loadContent(xmlFile)");
		var loaderXML:SimpleXML=new SimpleXML("html");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,_successData,this)
		//loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		loaderXML.load(xmlFile);
	}
	
	/**
	 * un fois le contenu chargé : initialise le html avec sont contenu
	 */
	private function _afficheCredits(data){
    	htmlContent.initialise(data);
    }	
    
    /**
     * mise à jour du scroll au changement de contenu     */
 	private function _onUpdateContent(){
		asClipScollerb.onChanged();
	}
	
	/**
	 * sur commande de changement brutal de scroll :  correction du bug conservation du clic fantome des textfield	 */
	private function _onMoveDone(src:ClipScoller,ypos:Number){
		src.toHidePlace();
		htmlContent.regen(Delegate.create(src, src.replaceTo,ypos));
	}   

	/**
	 * chargement réussi du xml	 */
	private function _successData(src:SimpleXML,conteneur:Object){
		_afficheCredits(conteneur);
	}
}