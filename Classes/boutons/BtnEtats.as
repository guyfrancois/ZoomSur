/**
 * @author Administrator    , pense-tete
 * 19 juin 08
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import boutons.Btn;
/**
 * 
 */
class boutons.BtnEtats extends EventDispatcher {
	
	static var ON_CHANGE:String="onChange";
	
	static var ON_PRESS:String="onPress";
	
	static var ON_RELEASE:String="onRelease";
	
	static var ON_OVER:String="onOver";
	
	static var ON_OUT:String="onOut";
	
	
	private var autoDisable:Boolean;
	private var _etat:Boolean;
	private var btn:Btn;
	
	private var IMG_ON:Number=2;
	private var IMG_OFF:Number=1;
	private var IMG_OVER:Number=0;
	private var IMG_DISABLE:Number=3;
	private var IMG_PRESS:Number=0;
	
	public function BtnEtats(clip:MovieClip,etat:Boolean,enable:Boolean,autoDisable:Boolean,images:Object,methode:Function) {
		this.autoDisable=autoDisable;
		btn=new Btn(clip,enable,methode);
		
		btn.addEventListener(Btn.ON_OVER,_onOver,this);
		btn.addEventListener(Btn.ON_OUT,_onOut,this);
		btn.addEventListener(Btn.ON_RELEASE,_onRelease,this);
		btn.addEventListener(Btn.ON_PRESS,_onPress,this);
		btn.addEventListener(Btn.ON_CHANGE,_onChange,this);
		
		setImages(images);
		setEtat(etat);
		//btn.enable=enable;
		
	}
	
	public function set enable(val:Boolean) {
		btn.enable=val;
	}
	
	public function get enable():Boolean {
		return btn.enable;
	}
	
	public function set etat(val:Boolean) {
		setEtat(val);
	}
	public function get etat():Boolean {
		return _etat;
	}
	
	public function getClip():MovieClip {
		return btn.getClip();
	}
	
	public function setClip(clip:MovieClip) {
		 btn.setClip(clip);
	}
	
	/**
	 * images={IMG_ON:2,IMG_OFF:1,IMG_OVER:0,IMG_DISABLE:3,IMG_PRESS=0}	 */
	public function setImages(images:Object) {
		if (images==undefined) return;

		if (images.IMG_ON!=undefined) IMG_ON=images.IMG_ON;
		if (images.IMG_OFF!=undefined) IMG_OFF=images.IMG_OFF;
		if (images.IMG_OVER!=undefined) IMG_OVER=images.IMG_OVER;
		if (images.IMG_DISABLE!=undefined) IMG_DISABLE=images.IMG_DISABLE;
		if (images.IMG_PRESS!=undefined) IMG_PRESS=images.IMG_PRESS;
		setEtat(etat);
	}
	
	private function setEtat(val:Boolean){
		_etat=val;
		if (_etat) {
			
			if (autoDisable) {
				enable=false;// lancera _onChange 
			} else {
				btn.goto(IMG_ON);
			}
		} else {
			
			if (autoDisable) {
				enable=true; // lancera _onChange 
			} else {
				btn.goto(IMG_OFF);
			}
		}
	}
	
	private function _onOver(){
		
		if (IMG_OVER!=0) {
			btn.goto(IMG_OVER);
		}
		dispatchEvent(ON_OVER,new Event(this,ON_OVER));
		
	}
	private function _onOut(){
		if (IMG_OVER==0) return;
		if (enable) {
			if (_etat ) {
				btn.goto(IMG_ON);
			} else {
				btn.goto(IMG_OFF);
			}
		} else {
			btn.goto(IMG_DISABLE);
		}
		dispatchEvent(ON_OUT,new Event(this,ON_OUT));
		
	}
	
	private function _onRelease(){
		setEtat(!etat);
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE));
		dispatchEvent(ON_RELEASE,new Event(this,ON_RELEASE));
	}
	
	private function _onPress(){
		btn.goto(IMG_PRESS);
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE));
		dispatchEvent(ON_PRESS,new Event(this,ON_PRESS));
	}
	
	private function _onChange(){
		if (!enable) {
			btn.goto(IMG_DISABLE);
		} else {
			btn.goto(IMG_OFF);
			_etat=false;
		}
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE));
	}
	
	
	

}