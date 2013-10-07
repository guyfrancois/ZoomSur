/**
 * @author GuyF , pense-tete.com
 * @date 6 nov. 07
 * 
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.animate.ClipByFrame;

/**
 * gere la transition lié à l'ouverture / fermeture d'un contenu transversal
 * transfert de parametre entre le initialisation/debut et fin de transition
 */
class Pt.animate.Transition extends EventDispatcher {
	/**
	 * la zone initialise l'ouverture
	 * onOpen(source:Transition,consParametres[0]....[n],callParametres[0]....[n])
	 */	
	public static var ON_OPEN_START:String = "onOpenStart";
	
	/**
	 * la zone initialise la fermeture
	 * onClose(source:Transition,consParametres[0]....[n],callParametres[0]....[n])
	 */	
	public static var ON_CLOSE_START:String = "onCloseStart";
	
	/**
	 * la zone est ouverte
	 * onOpen(source:Transition,consParametres[0]....[n],callParametres[0]....[n])
	 */	
	public static var ON_OPEN:String = "onOpen";
	
	/**
	 * la zone est fermée
	 * onClose(source:Transition,consParametres[0]....[n],callParametres[0]....[n])
	 */	
	public static var ON_CLOSE:String = "onClose";
	/**
	 * quand on lit l'image precedente
	 * onPrevFrame(source:ClipByFrame,clip._currentframe,image)
	 */	
	public static var ON_PREVFRAME:String = "onPrevFrame";
	/**
	 * quand on lit l'image suivante
	 * onNextFrame(source:ClipByFrame,clip._currentframe,image)
	 */	
	public static var ON_NEXTFRAME:String = "onNextFrame";
	
	public static var ON_UPDATE:String = "onUpdate";
	
	private var IMG_OPEN:Number;
	private var IMG_CLOSE:Number;
	
	private var clip:MovieClip;
	
	/**
	 * controleur d'animation image par image	 */
	private var cbframe:ClipByFrame;
	
	/**
	 *  stockages des parametres pour transferts	 */
	// parametres du constructeur
	private var consParametres:Array;
	// parametres de l'appel
	private var callParametres:Array;
	
	/**
	 * contructeur de transition 
	 * @param clip : clip d'animation servant de transition
	 * @param imgOpen : image à atteindre pour ouvrir la transition
	 * @param imgClose : image à atteindre pour fermer la transition	 */
	public function Transition(clip:MovieClip,imgOpen:Number,imgClose:Number) {
		//trace("Pt.animate.Transition.Transition("+clip+", "+imgOpen+","+imgClose+" )");
		this.clip=clip;
		consParametres=arguments;
		this.IMG_OPEN=imgOpen;
		this.IMG_CLOSE=imgClose;
		if (this.IMG_CLOSE==undefined) {
			this.IMG_CLOSE=1;
		}
		if (this.IMG_OPEN==undefined) {
			this.IMG_OPEN=clip._totalframes;
		}
		cbframe=new ClipByFrame(clip);
		cbframe.addEventListener(ClipByFrame.ON_STOP,onStop,this);
		cbframe.addEventListener(ClipByFrame.ON_NEXTFRAME,onNextFrame,this);
		cbframe.addEventListener(ClipByFrame.ON_PREVFRAME,onPrevFrame,this);
	}
	
	public function getClip():MovieClip {
		return clip;
	}
	public function isOpen():Boolean {
		return (clip._currentframe==IMG_OPEN);
	}
	
	public function isClose():Boolean{
		return (clip._currentframe==IMG_CLOSE);
	}
	/**
	 * Ouvre à partie d'une image	 */
	public function open():Boolean{
		callParametres=arguments;
		if (!cbframe.goto(IMG_OPEN,arguments[0])) {
			dispatchOpenEvent();
			return false;
		} else {
			dispatchOpenStartEvent();
			return true;
		}
		
	}
	public function quickOpen():Boolean{
		callParametres=arguments;
		if (!cbframe.setTo(IMG_OPEN,arguments[0])) {
			dispatchOpenEvent();
			return false;
		} else {
			dispatchOpenStartEvent();
			return true;
		}
	}
	
	public function quickClose():Boolean{
		callParametres=arguments;
		
		if (!cbframe.setTo(IMG_CLOSE,arguments[0])) {
			dispatchCloseEvent();
			return false;
		} else {
			dispatchCloseStartEvent()
			return true;
		}
	}
	/**
	 * ferme à partie d'une image
	 */
	public function close():Boolean{
		callParametres=arguments;
		if (!cbframe.goto(IMG_CLOSE,arguments[0])) {
			dispatchCloseEvent();
			return false;
		} else {
			dispatchCloseStartEvent()
			return true;
		}
	}
	
	private function onPrevFrame(src,image,currentframe){
		dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME,[currentframe,image]));
		dispatchEvent(ON_UPDATE,new Event(this,ON_UPDATE,[currentframe,image]));
	}
	
	private function onNextFrame(src,image,currentframe){
		dispatchEvent(ON_NEXTFRAME,new Event(this,ON_NEXTFRAME,[currentframe,image]));
		dispatchEvent(ON_UPDATE,new Event(this,ON_UPDATE,[currentframe,image]));
	}
	

	/**
	 * evenement de fin d'animation i/images
	 */
	private function onStop(src:ClipByFrame,image:Number){
		//trace("Pt.animate.Transition.onStop("+src.getClip()+", "+image+")");
		
		switch (image) {
			case IMG_OPEN :
				dispatchOpenEvent();
			break;
			case IMG_CLOSE :
				dispatchCloseEvent();
			break;
		}
		
	}
	/**
	 * lanceur d'evenements	 */
	 private function dispatchCloseEvent(){
	 	//trace("Pt.animate.Transition.dispatchCloseEvent()");
	 	var param:Array=consParametres.concat(callParametres);
	 	dispatchEvent(ON_CLOSE,new Event(this,ON_CLOSE,param));
	 }
	 private function dispatchOpenEvent(){
	 	//trace("Pt.animate.Transition.dispatchOpenEvent()");
	 	var param:Array=consParametres.concat(callParametres);
		dispatchEvent(ON_OPEN,new Event(this,ON_OPEN,param));
	 }
	 
	 private function dispatchCloseStartEvent(){
	 	//trace("Pt.animate.Transition.dispatchCloseStartEvent()");
	 	var param:Array=consParametres.concat(callParametres);
	 	dispatchEvent(ON_CLOSE_START,new Event(this,ON_CLOSE_START,param));
	 }
	 private function dispatchOpenStartEvent(){
	 	//trace("Pt.animate.Transition.dispatchOpenStartEvent()");
	 	var param:Array=consParametres.concat(callParametres);
		dispatchEvent(ON_OPEN_START,new Event(this,ON_OPEN_START,param));
	 }
	 
	 public function destroy(){
	 	cbframe.stop();
	 	delete cbframe;
	 }
	
}