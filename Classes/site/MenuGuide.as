/**
 * @author Administrator    , pense-tete
 * 28 mars 08
 */
import Pt.Parsers.XmlTools;
import GraphicTools.BOverOutPress;
import Pt.Parsers.DataStk;
import GraphicTools.MenuPlatXML;
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import Pt.animate.ClipByFrame;
import site.Navigator;
import site.DefModes;
/**
 * 
 * 
 */
class site.MenuGuide extends EventDispatcher implements site.IMenuType {
	/**
	 * Un item dans les menus à été selectionné
	 * @param src: MenuLibre
	 * @param id: numero identifiant de menu
	 * @param i : numero d'item
	 * @param type : String , libre - guide - oeuvresAssociees
	 * @param seq : String  Sequence
	 * ON_SELECT  (src,id,i)
	  * ON_SELECT  (src:IMenuType,id:Number,i:Number,type:String,seq:String)
	 */
	static var ON_SELECT:String="onSelect";
	
	private var imagesBtn:Object={IMG_OUT:1,IMG_OVER:3,IMG_PRESS:4,IMG_ON:4,IMG_OFF:1};
	private var clip:MovieClip;
	var xmlTool:XmlTools;
	private var selTextListenner:Object;
	
	private var btnComplementaire:BOverOutPress;
	
	public function MenuGuide(clip:MovieClip) {
		
		this.clip=clip;
		menuArray=new Array();
		selTextListenner=DataStk.event().addEventListener("SEL_MENU",onSelMenu,this);
		
	}
	
	private function onSelMenu(src:DataStk,idMenu:Number,idBtn:Number){
		//trace("site.MenuGuide.onSelText(src, "+idMenu+","+idBtn+")");
		select(idMenu,idBtn,true);
		Send.event("FINDCMD,SEL_TEXT,"+0+","+0);
	}
	
	
	public function initialise(){
		init();
	}
	
	private var menuArray:Array;
	private function init(){
	    initBtnComplement();
		initType(DefModes.GUIDE);
		initType("oeuvresAssociees");
		
		
		
	}
	
	private function initBtnComplement(){
		var btn_repere:MovieClip=clip.attachMovie("complements_docu","btn_repere",clip.getNextHighestDepth());
		var btnCBF:ClipByFrame=new ClipByFrame(clip.btn_repere);
		var imagesBtn:Object={IMG_OUT:1,IMG_OVER:2,IMG_PRESS:2,IMG_ON:3,IMG_OFF:1};
		
		btnComplementaire= new BOverOutPress(btn_repere,Navigator.getInstance().getRepere()=="",true,Delegate.create(btnCBF, btnCBF.goto),imagesBtn);
		btnComplementaire.addEventListener(BOverOutPress.ON_RELEASE,onCallRepere,this);
		btnComplementaire.getBtn().texte.autoSize=Pt.Tools.Clips.getAutoSize(btnComplementaire.getBtn().texte);
		Pt.Tools.Clips.setTexteHtmlCss(btnComplementaire.getBtn().texte,"style.css",DataStk.dico("complements"));
		
		Navigator.getInstance().addEventListener(Navigator.ON_REPERE,onReperesReleased,this);
	}
	
	private function onCallRepere(){
		SWFAddress.setRepere("_0");
	}
	
	private function initType(typeMenu:String){
		xmlTool=new XmlTools(DataStk.val("menu"));
		var arrMenu:Array=xmlTool.findSub("menu","type",typeMenu);
		
		for (var i : Number = 0; i < arrMenu.length; i++) {
			var menuItem:MovieClip=clip.createEmptyMovieClip("menu_"+menuArray.length,clip.getNextHighestDepth());
			var y:Number=0;
			if (arrMenu[i].titre!=undefined) {
				var titreMenu:MovieClip=menuItem.attachMovie("titreMenu","titre",1);
				titreMenu._y=y;
				Clips.setTexteHtmlCss(titreMenu.texte,"style.css",arrMenu[i].titre[0].text);
				y=titreMenu._y+titreMenu._height;
			}
			
			var menuliste=menuItem.createEmptyMovieClip("liste",2);
			menuliste._y=y;
			
			var menuXML:MenuPlatXML=new  MenuPlatXML(menuliste,undefined,imagesBtn,arrMenu[i],typeMenu!=DefModes.LIBRE);
			var index:Number=menuArray.push({menuXML:menuXML,type:typeMenu});
			menuXML.addEventListener(MenuPlatXML.ON_MENUINIT,Delegate.create(this, __onMenuInit,index-1),this);
			menuXML.addEventListener(MenuPlatXML.ON_MENUPRESS,_onMenuPress,this);
			menuXML.initialize();	
			
		}

	}
		
	private function onReperesReleased(src:Navigator,id:String){
		if (id=="") {
			btnComplementaire.enable=true;
		}
	}
	private function _onMenuPress(src:MenuPlatXML,id:Number,data:Object) {
		for (var i : Number = 0; i < menuArray.length; i++) {
			if (menuArray[i].menuXML!=src) {
				menuArray[i].menuXML.reset();
				
			} else {
				// TODO menu selectionné : i eme, id : btn
				dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[id,i,menuArray[i].type,data.rub,data.seq]));
			}
			
		}
	}
	private function __onMenuInit(src:MenuPlatXML,null1,i:Number){
		

		//trace("site.MenuGuide.__onMenuInit(src, "+i+")");
		var courant:MovieClip=clip["menu_"+i];
		if (i>0) {

			
			var precedent:MovieClip=clip["menu_"+(i-1)];
			//trace(precedent+" "+courant);
			
			courant._y=precedent._y+precedent._height;
			if (menuArray[i-1].type!=menuArray[i].type) {
				courant._y+=15;
			}
		} else {
			src.setAction(0);
		}
		courant._y=Math.floor(courant._y);
		btnComplementaire.getBtn()._y=Math.floor(Math.max(courant._y+courant._height+15,btnComplementaire.getBtn()._y));
	}
	
	
	public function select(idMenu:Number,idBtn:Number,action:Boolean){
		for (var i : Number = 0; i < menuArray.length; i++) {
			if (i!=idMenu) {
				menuArray[i].menuXML.reset();
				
			} else {
				// TODO menu selectionné : i eme, id : btn
				if (action==true) {
					menuArray[i].menuXML.setAction(idBtn);
				} else {
					menuArray[i].menuXML.setNoAction(idBtn);
				}
			}
			
		}
	}
	public function destroy(){
		DataStk.event().removeEventListener(selTextListenner);
		// TODO : remove listenners ...
	}
	
}