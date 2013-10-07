/**
 * @author Administrator    , pense-tete
 * 27 mars 08
 */
import Pt.Parsers.DataStk;
import Pt.Parsers.XmlTools;
import site.ModeVisite;
import site.MenuGuide;
import site.MenuLibre;
import site.TexteAccordeon;
/*
import site.TexteGuideABlocs;
import site.TexteLibre;
*/
import site.IMenuType;
import site.ITextType;
import GraphicTools.BOverOutPress;
import Pt.animate.ClipByFrame;
import org.aswing.util.Delegate;
import site.MenuOutils;

import org.aswing.Event;
import org.aswing.EventDispatcher;

/**
 * 
 */
class site.MenuTextes extends EventDispatcher {
	/**
	 * une sequence est selectionné depuis le menu principal
	 * onMenuSequence(source:site.IMenuType,seq:String)
	 * source : MenuGuide normalement 
	 * seq : String : sequence , nom de fichier xml
	 */	
	public static var ON_MENU_SEQUENCE:String = "onMenuSequence";
	private var clip:MovieClip;
	
	private var modeVisite:ModeVisite;
	private var btnExploration:BOverOutPress;
	
	private var menuType:IMenuType;
	private var textType:ITextType;
	private var xmlTRub:XmlTools;
	
	
	private var clipTexte:MovieClip; // clip qui recevera le texte
	private var clipMenuOutils:MovieClip;
	private var menuOutils:MenuOutils;
	
	public function MenuTextes(clip:MovieClip,clipMenuOutils:MovieClip) {
		//trace("site.MenuTextes.MenuTextes("+clip+","+clipMenuOutils+")");
		this.clip=clip;
		clip._visible=false;
		clipTexte=clip.clipTexte;
		this.clipMenuOutils=clipMenuOutils;
		xmlTRub=new XmlTools(DataStk.val("rubriques"));
		/*
		modeVisite=new ModeVisite(clip.modeVisite);
		modeVisite.addEventListener(ModeVisite.ON_RELEASE,_onModeRelease,this)
		*/
		initBtnExploration();
	}
	
	private function initBtnExploration(){
		clipMenuOutils._visible=clip.btn_outils._visible=DataStk.isDico("outils");
		if (!DataStk.isDico("outils")) {
				return;
		}
		var btnCBF:ClipByFrame=new ClipByFrame(clip.btn_outils);
		var imagesBtn:Object={IMG_OUT:1,IMG_OVER:5,IMG_PRESS:7,IMG_ON:7,IMG_OFF:1};
		btnExploration= new BOverOutPress(clip.btn_outils,true,true,Delegate.create(btnCBF, btnCBF.goto),imagesBtn);
		btnExploration.addEventListener(BOverOutPress.ON_RELEASE,onOutilsReleased,this);
//		var btnSize:Number=btnExploration.getBtn().texte.texte._width;
//		var btnx:Number=btnExploration.getBtn().texte.texte._x;
		btnExploration.getBtn().texte.texte.autoSize=Pt.Tools.Clips.getAutoSize(btnExploration.getBtn().texte.texte);
		Pt.Tools.Clips.setTexteHtmlCss(btnExploration.getBtn().texte.texte,"style.css",DataStk.dico("outils"));
		
		//btnExploration.getBtn().texte.texte.text=DataStk.dico("outils");
		//btnExploration.getBtn().texte.texte.autoSize=false;
//		btnExploration.getBtn().texte.texte._width=btnSize;
//		btnExploration.getBtn().texte.texte._x=btnx;
		
			btnExploration.getBtn().ico.attachMovie(DataStk.val(DataStk.DICO)["outils"][0].ico,"ico",1);
			menuOutils=new MenuOutils(clipMenuOutils,btnExploration);	
			menuOutils.initialise();
		
	
	}
	
	
	private function initMenu(type:String){
		clip.clipMenu.cmenu.removeMovieClip();
		var clipMenu:MovieClip=clip.clipMenu.createEmptyMovieClip("cmenu",1);
		menuType.destroy();
		
		delete menuType;
		switch (type) {
			case ModeVisite.LIBRE :
				menuType=new MenuLibre(clipMenu);
				menuType.addEventListener(MenuLibre.ON_SELECT,onMenuSelected,this);
				btnExploration.getBtn()._visible=true;
				textType.destroy();
				//textType=new TexteLibre(clipTexte);
				textType=new TexteAccordeon(clipTexte);
				textType.setTextes();
			break;
			case ModeVisite.GUIDE :
			
				menuType=new MenuGuide(clipMenu);
				menuType.addEventListener(MenuGuide.ON_SELECT,onMenuSelected,this);
				btnExploration.getBtn()._visible=true;
				textType.destroy();
			//	textType=new TexteGuide(clipTexte);
			//	textType=new TexteGuideABlocs(clipTexte);
				textType=new TexteAccordeon(clipTexte);
				textType.setTextes();
			break;
			
		}
		menuType.initialise();
	}
	
	public function open(type:String){
		if (type==undefined) {
			
			return;
		}
		clip._visible=true;
		modeVisite.setMode(type);
		initMenu(type);
		
	}
	
	public function select(idMenu,idRub) {
		menuType.select(idMenu,idRub,true);
	}
	
	
	public function close(){
		clip._visible=false;
	}
	/*
	private function _onModeRelease(src:ModeVisite,mode:String){
		SWFAddress.setMode(mode)
		//initMenu(mode);
	}
	*/
	/**
	 * 	 */
	// TODO : envoyer l'evenement au navigator
	// TODO : ecouter les evenement du navigator
	// TODO navigator : changement de mode, selection de menu , d'oeuvre
	private function onMenuSelected(src:IMenuType,id:Number,i:Number,type:String,rub:String,seq:String){
		switch (type) {
			case "libre" :
				textType.destroy();
				textType=new TexteAccordeon(clipTexte);
				textType.setTextes(xmlTRub.find("rubrique","ref",rub));
				var ta:TexteAccordeon;
				
			/*
				
				textType=new TexteLibre(clipTexte);
				 // TODO : effectuer une recherche par reference suivant la parametre de l'eltm de menu

				textType.setTextes(xmlTRub.find("rubrique","ref",rub));
			*/
				
			break;
			case "guide":
				textType.destroy();
				//textType=new TexteGuide(clipTexte);
				//textType=new TexteGuideABlocs(clipTexte);
				textType=new TexteAccordeon(clipTexte);
				
				textType.setTextes(xmlTRub.find("rubrique","ref",rub));

			
			break;
			case "oeuvresAssociees":
			
			break;
			
		}
		
		dispatchEvent(ON_MENU_SEQUENCE,new Event(this,ON_MENU_SEQUENCE,[seq]));
	}
	private function onOutilsReleased(src:BOverOutPress) {
		//SWFAddress.setMode("libre");
		// TODO : evenement ouvrire la liste des outils d'explorations
		// fournir ref vers le bouton pour le réactiver après selection
	}
	
	
	
	
	
}