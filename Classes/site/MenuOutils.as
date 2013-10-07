/**
 * @author Administrator    , pense-tete
 * 28 mars 08
 */
import Pt.Parsers.XmlTools;
import Pt.Parsers.DataStk;
import GraphicTools.MenuPlatXML;
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import GraphicTools.BOverOutPress;
import Pt.scan.Souris;
/**
 * 
 */
class site.MenuOutils extends EventDispatcher implements site.IMenuType {
	/**
	 * Un item dans les menus à été selectionné
	 * @param src: MenuLibre
	 * @param id: numero identifiant de menu
	 * @param i : numero d'item
	 * @param type : String , libre - guide - oeuvresAssociees
	 * ON_SELECT  (src:IMenuType,id:Number,i:Number,type:String)
	 */
	static var ON_SELECT:String="onSelect";
	private var imagesBtn:Object={IMG_OUT:1,IMG_OVER:3,IMG_PRESS:4,IMG_ON:4,IMG_OFF:1};
	private var clip:MovieClip;
	var xmlTool:XmlTools;
	private var menuXML:MenuPlatXML;
	private var btnOpen:BOverOutPress;
	private var souris:Souris;
	private var btnsouris:Souris;
	
	public function MenuOutils(clip:MovieClip,btnOpen:BOverOutPress) {
		super();
		this.clip=clip;
		clip._visible=false;
		menuArray=new Array();
		this.btnOpen=btnOpen;
		btnOpen.addEventListener(BOverOutPress.ON_RELEASE,open,this);
		souris=new Souris(clip);
		btnsouris=new Souris(btnOpen.getBtn());
		
	}
	
	public function initialise(){
		init();
	}
	
	private var menuArray:Array;
	
	private function init(){
		
		souris.addEventListener(Souris.ON_MOUSEMOVE,onMouseMove,this);
	}
	
	private function onMouseMove(){
		if (clip._visible) {
			if (!btnsouris.hasMouseOver() && !souris.hasMouseOver()) {
				close();
			}
		}
	}
	
	private function open(){
		for (var i : Number = 0; i < menuArray.length; i++) {
			menuArray[i].getClip().removeMovieClip();
			delete menuArray[i];
		}
		menuArray=new Array();
		initType("explorations");
		souris.startScan();
		clip._visible=true;
		for (var i : Number = 0; i < menuArray.length; i++) {
                menuArray[i].menuXML.reset();
        } 
	}
	
	private function close (){
		souris.stopScan();
		clip._visible=false;
		btnOpen.enable=true;
		
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
			
			var menuXML:MenuPlatXML=new  MenuPlatXML(menuliste,undefined,imagesBtn,arrMenu[i]);
			var index:Number=menuArray.push({menuXML:menuXML,type:typeMenu});
			menuXML.addEventListener(MenuPlatXML.ON_MENUINIT,Delegate.create(this, __onMenuInit,index-1),this);
			menuXML.addEventListener(MenuPlatXML.ON_MENUPRESS,_onMenuPress,this);
			menuXML.initialize();	
			
			
		}

	}

	private function _onMenuPress(src:MenuPlatXML,id:Number,data:Object) {
		for (var i : Number = 0; i < menuArray.length; i++) {
			if (menuArray[i].menuXML!=src) {
				menuArray[i].menuXML.reset();
				
			} else {
				// TODO menu selectionné : i eme, id : btn
				if (data.seq!=undefined) {
					SWFAddress.setSequence(data.seq);
					
				}
				
				dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[id,i,menuArray[i].type,data.rub]));
			}
			
		}
	}
	private function __onMenuInit(src:MenuPlatXML,null1,i:Number){
		

		//trace("site.MenuOutils.__onMenuInit(src, null1,"+i+" )");
		var courant:MovieClip=clip["menu_"+i];
		if (i>0) {
			/*
			var precedent:MovieClip= menuArray[i-1].menuXML.getClip();
			var courant:MovieClip= menuArray[i].menuXML.getClip();
			*/
			
			var precedent:MovieClip=clip["menu_"+(i-1)];
			
			//trace(precedent+" "+courant);
			
			courant._y=precedent._y+precedent._height;
		}
		//trace("courant :"+courant+" y:"+courant._y+" height:"+courant._height);
		clip.fond._height=courant._y+courant._height-4;
		//trace("fond :"+clip.fond+" "+clip.fond._heigh);
	}
	
	public function select(idMenu:Number,idBtn:Number,action:Boolean){
		for (var i : Number = 0; i < menuArray.length; i++) {
			if (i!=idMenu) {
				menuArray[i].menuXML.reset();
				
			} else {
				// TODO menu selectionné : i eme, id : btn
				menuArray[i].menuXML.setNoAction(idBtn);
			}
			
		}
	}
	public function destroy(){
		// TODO : remove listenners ...
	}
	
	
}