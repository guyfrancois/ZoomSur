/**
 * @author Administrator    , pense-tete
 * 28 mars 08
 */
import Pt.Parsers.DataStk;
import GraphicTools.MenuPlatXML;
import org.aswing.util.Delegate;
import org.aswing.EventDispatcher;
import org.aswing.Event;
/**
 * 
 */
class site.ModeVisite extends EventDispatcher {
	/**
	 * onRelease(src:ModeVisite;ModeActif);	 */
	static var ON_RELEASE:String="onRelease"
	private var marge:Number=5;
	static var LIBRE:String=site.DefModes.LIBRE;
	static var GUIDE:String=site.DefModes.GUIDE;
	//private var currentMode;
	private var clip:MovieClip;
	private var menuMode:MenuPlatXML;
	
	public function ModeVisite(clip:MovieClip) {
		super();
		this.clip=clip;
//		currentMode=LIBRE;
	//	initBtn();
	//	init();
		initMenu();
		
	}
	
	private var IMG_BTN:Object={IMG_OUT:1,IMG_OVER:2,IMG_PRESS:2,IMG_ON:2,IMG_OFF:1};
	private function initMenu(){
		//trace("site.ModeVisite.initMenu():"+clip.clipMenu);
		var dataMenu:Object={
			skin:"btnMenuMode",
			btnHM:marge,
			
			btn:[]
		};
		if (DataStk.isDico(LIBRE)) {
			dataMenu.btn.push({
					ico:"traitVerticalSeparation" 
					, height : false
					, text : DataStk.dico(LIBRE)
				});
		}
		if (DataStk.isDico(GUIDE)) {
			dataMenu.btn.push({
					height : false
					, text : DataStk.dico(GUIDE)
				});
			}
		menuMode=new MenuPlatXML(clip.clipMenu, undefined,IMG_BTN,dataMenu,false);
		menuMode.setAttRef("id");
		menuMode.addEventListener(MenuPlatXML.ON_MENUPRESS,onMenuPress,this);
		menuMode.initialize();
		
		
	}
	
	/*
	private function initBtn(){
		clip.onPress=Delegate.create(this, onRelease);
	}
	
	// initialise en function du mode courant
	private function init(){
		clip.titre_0.autoSize=true;
		clip.titre_1.autoSize=true;
		switch (currentMode) {
			case LIBRE :
				clip.titre_0.text=DataStk.dico(LIBRE);
				clip.titre_1.text=DataStk.dico(GUIDE);
			break;
			case GUIDE :
				clip.titre_0.text=DataStk.dico(GUIDE);
				clip.titre_1.text=DataStk.dico(LIBRE);
			break;
		}
		var size0:Number=clip.titre_0._width;
		var size1:Number=clip.titre_1._width;
		clip.titre_0.autoSize=false;
		clip.titre_1.autoSize=false;
		clip.titre_0._width=size0;
		clip.titre_1._width=size1;
		clip.sep._x=clip.titre_0._width+clip.titre_0._x+marge;
		clip.titre_1._x=clip.sep._x+marge;
		clip.hitArea._x=clip.titre_1._x;
		clip.hitArea._width=clip.titre_1._width;
		
		
	}
	
	private function onRelease(){
		if (currentMode==LIBRE) {
			dispatchEvent(ON_RELEASE,new Event(this,ON_RELEASE,[GUIDE]));
		} else {
			dispatchEvent(ON_RELEASE,new Event(this,ON_RELEASE,[LIBRE]));
		}
		
		// TODO : evenement changer de mode
		
	}
	
	*/
	private function onMenuPress(source:MenuPlatXML, id:Number,data:Object){
		switch (id) {
			case 0 :
				dispatchEvent(ON_RELEASE,new Event(this,ON_RELEASE,[LIBRE]));
			break;
			case 1:
				dispatchEvent(ON_RELEASE,new Event(this,ON_RELEASE,[GUIDE]));
			break;
		}
	
	}
	public function setMode(mode:String){
//		currentMode=mode;
		switch (mode) {
			case LIBRE :
				menuMode.setNoAction(0);
			break;
			case GUIDE :
				menuMode.setNoAction(1);
			break;
		}
	}
	
	
	
	
}