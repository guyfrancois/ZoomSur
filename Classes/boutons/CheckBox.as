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
class boutons.CheckBox extends EventDispatcher {
	
	static var ON_CHANGE:String="onChange";
	
	private var _etat:Boolean;
	private var btn:Btn;
	
	private var IMG_ON:Number=2;
	private var IMG_OFF:Number=1;
	private var IMG_OVER:Number=0;
	
	public function CheckBox(clip:MovieClip,etat:Boolean,enable:Boolean,images:Object) {
		btn=new Btn(clip,enable);
		btn.addEventListener(Btn.ON_OVER,_onOver,this);
		btn.addEventListener(Btn.ON_OUT,_onOut,this);
		btn.addEventListener(Btn.ON_RELEASE,_onRelease,this);
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
	 * images={IMG_ON:2,IMG_OFF:1,IMG_OVER:0}	 */
	var _images:Object;
	public function setImages(images:Object) {
		this._images=images;
		if (images==undefined) return;

		if (images.IMG_ON!=undefined) IMG_ON=images.IMG_ON;
		if (images.IMG_OFF!=undefined) IMG_OFF=images.IMG_OFF;
		if (images.IMG_OVER!=undefined) IMG_OVER=images.IMG_OVER;
		setEtat(etat);
	}
	
	public function getImages():Object {
		return this._images;
	}
	
	private function setEtat(val:Boolean){
		_etat=val;
		if (_etat) {
			btn.goto(IMG_ON);
		} else {
			btn.goto(IMG_OFF);
		}
	}
	
	private function _onOver(){
		
		if (IMG_OVER!=0) {
			btn.goto(IMG_OVER);
		}
		
	}
	private function _onOut(){
		if (IMG_OVER==0) return;
		if (_etat ) {
			btn.goto(IMG_ON);
		} else {
			btn.goto(IMG_OFF);
		}
		
	}
	
	private function _onRelease(){
		setEtat(!etat);
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE));
	}
	
	
	

}