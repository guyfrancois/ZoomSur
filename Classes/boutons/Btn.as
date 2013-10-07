/**
 * @author Administrator    , pense-tete
 * 19 juin 08
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import org.aswing.util.Delegate;
import Pt.Tools.ClipEvent;

/**
 * 
 */
class boutons.Btn extends EventDispatcher {
	static var ON_PRESS:String="onPress";
	static var ON_RELEASE:String="onRelease";
	
	static var ON_OVER:String="onOver";
	static var ON_OUT:String="onOut";
	
	static var ON_CHANGE:String="onChange";
	
	
	
	private var btn:MovieClip;
	public var goto:Function;
	
	private var currentImage:Object;
	
	public function Btn(btn:MovieClip,enable:Boolean,methode:Function) {
		super();
		this.btn=btn;
		btn._obj=this;
		
		if (methode==undefined) {
			
			goto=Delegate.create(btn,btn.gotoAndStop);
		} else {
			goto=methode;
		}
		ClipEvent.initialize(btn);
		
		setEnable(enable==undefined?true:enable);
		
		
		btn.addEventListener("onPress",_onPress,this);
		btn.addEventListener("onRelease",_onRelease,this);
		btn.addEventListener("onReleaseOutside",_onReleaseOutside,this);
		btn.addEventListener("onRollOver",_onRollOver,this);
		btn.addEventListener("onRollOut",_onRollOut,this);
		btn.addEventListener("onDragOut",_onDragOut,this);
		
	}
	
	public function setClip(btn:MovieClip,methode:Function) {
		this.btn=btn;
		btn._obj=this;
		if (methode==undefined) {
			
			goto=Delegate.create(btn,btn.gotoAndStop);
		} else {
			goto=methode;
		}
		
		ClipEvent.initialize(btn);
		
		setEnable(enable==undefined?true:enable);
		
		btn.addEventListener("onPress",_onPress,this);
		btn.addEventListener("onRelease",_onRelease,this);
		btn.addEventListener("onReleaseOutside",_onReleaseOutside,this);
		btn.addEventListener("onRollOver",_onRollOver,this);
		btn.addEventListener("onRollOut",_onRollOut,this);
		btn.addEventListener("onDragOut",_onDragOut,this);
		
	}
	
	public function destroy(){
		ClipEvent.unsetEventsTrigger(btn,"onPress");
		ClipEvent.unsetEventsTrigger(btn,"onRelease");
		ClipEvent.unsetEventsTrigger(btn,"onRollOver");
		ClipEvent.unsetEventsTrigger(btn,"onRollOut");
		ClipEvent.unsetEventsTrigger(btn,"onDragOut");
		ClipEvent.unsetEventsTrigger(btn,"onReleaseOutside");
		ClipEvent.destroy(btn);
		delete btn._obj;
	}
	
	public function get enable():Boolean {
		return etat;
	}
	
	public function set enable(val:Boolean) {
		setEnable(val);
	}
	
	public function getClip():MovieClip{
		return btn;
	}
	
	
	
	
	/** Lanceur d'evenements */
	private function _onPress(){
		dispatchEvent(ON_PRESS,new Event(this,ON_PRESS,[btn]));
		
	}
	private function _onRollOver(){
		dispatchEvent(ON_OVER,new Event(this,ON_OVER,[btn]));
	}
	private function _onDragOut(){
		dispatchEvent(ON_OUT,new Event(this,ON_OUT,[btn]));
	}
	private function _onReleaseOutside(){
		dispatchEvent(ON_OUT,new Event(this,ON_OUT,[btn]));
	}
	
	
	private function _onRollOut(){
		dispatchEvent(ON_OUT,new Event(this,ON_OUT,[btn]));
	}
	private function _onRelease(){
		dispatchEvent(ON_RELEASE,new Event(this,ON_RELEASE,[btn]));
	}
	
	
	private var etat:Boolean;
	private function setEnable(etat:Boolean) {
			this.etat=etat;
			if (etat) {
				setEvents();
			} else {
				unsetEvents();
			}
	}
	
	public function gotoImg(val:Object){
		currentImage=val;
		goto(val);
	}
	
	
	
	private function unsetEvents(){
			ClipEvent.unsetEventsTrigger(btn,"onPress");
			ClipEvent.unsetEventsTrigger(btn,"onRelease");
			btn.useHandCursor=false;
		/*
		ClipEvent.unsetEventsTrigger(btn,"onRollOver");
		ClipEvent.unsetEventsTrigger(btn,"onRollOut");
		ClipEvent.unsetEventsTrigger(btn,"onDragOut");
		ClipEvent.unsetEventsTrigger(btn,"onReleaseOutside");
		btn.enabled=false;
		*/
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE,[btn]));
	}
	
	
	private function setEvents(){
		ClipEvent.setEventsTrigger(btn,"onPress");
		ClipEvent.setEventsTrigger(btn,"onRelease");
		ClipEvent.setEventsTrigger(btn,"onRollOver");
		ClipEvent.setEventsTrigger(btn,"onRollOut");
		ClipEvent.setEventsTrigger(btn,"onDragOut");
		ClipEvent.unsetEventsTrigger(btn,"onReleaseOutside");
		//btn.enabled=true;
		btn.useHandCursor=true;
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE,[btn]));
	}
	
	


}