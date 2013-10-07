/**
 * @author GuyF    , pense-tete
 * 4 f�vr. 2010
 */
import org.aswing.util.Delegate;
import org.aswing.EventDispatcher;
import GraphicTools.BOverOutPress;
import org.aswing.Event;
import Pt.Tools.ClipEvent;
/**
 * 
 */
class Pt.conteneur.accordeon.HeaderAccordeon extends EventDispatcher {
	static var ON_CHANGE:String="ON_CHANGE";
	private var clip:MovieClip;
	private var content:MovieClip;
	private var btn:BOverOutPress;
	
	public function toString():String {
			return "HeaderAccordeon "+clip;
	}

	public function HeaderAccordeon(clip:MovieClip) {
		super();
		//trace("Pt.conteneur.accordeon.HeaderAccordeon.HeaderAccordeon("+clip+")");
		this.clip=clip;
		clip.stop();
		ClipEvent.initialize(clip);
		ClipEvent.setEventsTrigger(clip,"onPress");
		clip.addEventListener("onPress",_onPress,this);
		
	}
	
	public function getHeight():Number{
		//trace("Pt.conteneur.accordeon.HeaderAccordeon.getHeight()"+clip._height+" "+clip);
		return clip._height;
	}

	public function open(){
		clip.gotoAndStop(2);
	}
	public function close(){
		clip.gotoAndStop(1);
	}
	
	
	private function _onPress(){
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE));
	}
	
}