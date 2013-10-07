/**
 *
 */
import org.aswing.EventDispatcher;
import Pt.Tools.ClipEvent;
import org.aswing.Event;
import org.aswing.util.Delegate;
import Pt.animate.ClipByFrame;

/**
 * bouton servant specifiquement de feuille à un menu
 */
class GraphicTools.MenuFeuille extends EventDispatcher {
	/**
	 * image du bouton pour l'état selectionné 	 */
	public static var BTN_SELECT:Number=7;
	/**
	 * image du bouton pour l'état "normal" 
	 */
	public static var BTN_OUT:Number=1;
	/**
	 * image du bouton au survol (et actif : pas selectionné)	 */
	public static var BTN_OVER:Number=3;
	/**
	 * Evenements du bouton	 */
	/**
	 * pression sur un bouton
	 * onPress(source:)
	 */	
	public static var ON_PRESS:String = "onPress";
	/**
	 * survol bouton
	 * onRollOver(source:)
	 */	
	public static var ON_ROLLOVER:String = "onRollOver";
	/**
	 * sortie du bouton
	 * onRollOver(source:)	 */
	public static var ON_ROLLOUT:String = "onRollOut";
	
	/**
	 * navigation vers un contenu
	 * onSelect(source:)
	 */	
	public static var ON_SELECT:String = "onSelect";
	/**
	 * initialisation contenu
	 * onInit(source:)
	 */	
	public static var ON_INIT:String = "onInit";
	/**
	 * fermeture effective du bouton	 */
	public static var ON_CLOSED= "onClosed";
	
	private var clip:MovieClip;
	
	private var margeHaute:Number;
	
	private var cbf:ClipByFrame;
	public function MenuFeuille(clip:MovieClip,pressed:Boolean,margeHaute:Number) {
		super();
		//trace("GraphicTools.MenuFeuille.MenuFeuille("+clip+", pressed,"+margeHaute+" )");
		this.clip=clip;
		this.cbf=new ClipByFrame(clip);
		this.margeHaute=margeHaute;
		initClipControle();
		if (pressed==true) {
			setPressed();
		} else {
			setUnpressed()
		}
	}
	
	public function getClip():MovieClip{
		return clip;
	}
	
	public function getName():String{
		return clip._name;
	}
	
	public function getMargeHaute():Number{
		return margeHaute;
	}
	
	private function initClipControle(){
		
		initialiseBtn(clip);
		dispatchEvent(ON_INIT,new Event(this,ON_INIT,[[getClip()]]));
	}
	
	private function initialiseBtn(btn_clip:MovieClip) {
		btn_clip.hitArea._visible=false;
		ClipEvent.initialize(btn_clip);
		setTriggers(btn_clip);
		
		btn_clip.addEventListener(ON_PRESS,_onPress,this);
		btn_clip.addEventListener(ON_ROLLOVER,_onRollOver,this);
		btn_clip.addEventListener(ON_ROLLOUT,_onRollOut,this);
		
	}
	
	private function setTriggers(btn_clip:MovieClip) {
		btn_clip.useHandCursor=true;
		ClipEvent.setEventsTrigger(btn_clip,ON_PRESS);
		ClipEvent.setEventsTrigger(btn_clip,ON_ROLLOVER);
		ClipEvent.setEventsTrigger(btn_clip,ON_ROLLOUT);
	}
	
	private function removeTriggers(btn_clip:MovieClip) {
		btn_clip.useHandCursor=false;
		ClipEvent.unsetEventsTrigger(btn_clip,ON_PRESS);
		ClipEvent.unsetEventsTrigger(btn_clip,ON_ROLLOVER);
		ClipEvent.unsetEventsTrigger(btn_clip,ON_ROLLOUT);
	}

	function setPressed(byPress:Boolean){
		//trace("GraphicTools.MenuFeuille.setPressed("+byPress+")"+getClip());
		cbf.goto(BTN_SELECT);
		removeTriggers(clip);
		
	}
	
	function setUnpressed(){
		//trace("GraphicTools.MenuFeuille.setUnpressed()"+getClip());
		cbf.goto(BTN_OUT);
		setTriggers(clip);
		dispatchEvent(ON_CLOSED,new Event(this,ON_CLOSED));
	}

	private function _onPress(btn:MovieClip) {
		//setPressed();
		dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[[getName()]]));
	}
	private function _onRollOver(btn:MovieClip) {
		cbf.goto(BTN_OVER);
	}
	private function _onRollOut(btn:MovieClip) {
		cbf.goto(BTN_OUT);
	}
	
	public function isOpen():Boolean {
		return clip._currentframe==BTN_SELECT;
	}
	
}