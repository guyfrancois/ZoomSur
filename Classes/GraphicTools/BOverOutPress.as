/**;
 * @author GuyF , pense-tete.com
 * @date 12 mars 07
 * 
 */
 
import Pt.Tools.ClipEvent;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import org.aswing.util.Delegate;
 
class GraphicTools.BOverOutPress   extends  EventDispatcher {
	private  static var TIMG_OVER:String="IMG_OVER";
	private  static var TIMG_OUT:String="IMG_OUT";
	private  static var TIMG_PRESS:String="IMG_PRESS";
	private  static var TIMG_ON:String="IMG_ON";
	private  static var TIMG_OFF:String="IMG_OFF";
	private  static var TIMG_DEAD:String="IMG_DEAD";
	
	
	private  var IMG_OVER:String="OVER";
	private  var IMG_OUT:String="OUT";
	private  var IMG_PRESS:String="PRESS";
	private  var IMG_ON:String="PRESS";
	private  var IMG_OFF:String="OUT";
	private  var IMG_DEAD:String="DEAD";
	
	static var ON_PRESS:String="onPress";
	
	static var ON_RELEASE:String="onRelease";
	
	static var ON_OVER:String="onOver";
	
	static var ON_OUT:String="onOut";
	
	static var ON_CHANGE:String="onChange";
	
	public var goto:Function;
	
	private var btn:MovieClip;
	private var _bascule:Boolean;
	
	private var _dead:Boolean;
	private var _reclic:Boolean;
	
	
	public function setMethode(methode:Function) {
		if (methode==undefined) {
			
			goto=Delegate.create(btn,btn.gotoAndStop);
		} else {
			goto=methode;
		}
	}
	
	/**
	 * constuit un bouton 
	 * @param btn clip associé
	 * @param enable : état par défault , true|undefined: actif ,false : inactif
	 * @param bascule : fonctionnement en bascule (désactivé quand selectionné ) , true|undefined: en mode bascule, false : toujours actif
	 * @param methode : methode de lecture du bouton , undefined :  gotoAndStop, utiliser : Delegate.create(btn,btn.gotoAndPlay); ou Delegate.create(btnCBF, btnCBF.goto);
	 * @param images : affecte les images à utiliser pour les états du bouton , {IMG_OUT:1,IMG_OVER:5,IMG_PRESS:7,IMG_ON:7,IMG_OFF:1,IMG_DEAD:0}
	 * 
	 * 	 */
	public function BOverOutPress(btn:MovieClip,enable:Boolean,bascule:Boolean,methode:Function,images:Object,reclic:Boolean) {
		// trace("GraphicTools.BOverOutPress.BOverOutPress("+btn+", "+enable+","+bascule+" ,"+methode+" images , reclic "+reclic+")");
		btn._obj=this;
		
		_dead=false;
		_reclic=(reclic==undefined)?false:reclic;

		btn.over._visible=false;
		if (bascule==false) {
			this._bascule=false;
		} else {
			this._bascule=true;
		}
		
		this.btn=btn;
		setMethode(methode)
		if (btn.hitArea_mc!=undefined) { 
		btn.hitArea_mc._visible=false;
		
		btn.hitArea=btn.hitArea_mc;
		} else {
			btn.hitArea._visible=false;
		}
		
		ClipEvent.initialize(btn);
		
		setEnable(enable==undefined?true:enable);
		/*
		if (enable!=false) {
			setEvents();
		} else {
			unsetEvents();
		}
		this
		outGo()
		*/
		
		btn.addEventListener("onPress",_onPress,this);
		btn.addEventListener("onRelease",_onRelease,this);
		btn.addEventListener("onReleaseOutside",_onReleaseOutside,this);
		btn.addEventListener("onRollOver",_onRollOver,this);
		btn.addEventListener("onRollOut",_onRollOut,this);
		btn.addEventListener("onDragOut",_onDragOut,this);
		btn.addEventListener("onDragOver",_onDragOver,this);
		setImages(images);
		
	}
	
	public function destroy(){
		
		
		ClipEvent.unsetEventsTrigger(btn,"onPress");
		ClipEvent.unsetEventsTrigger(btn,"onRelease");
		ClipEvent.unsetEventsTrigger(btn,"onRollOver");
		ClipEvent.unsetEventsTrigger(btn,"onRollOut");
		ClipEvent.unsetEventsTrigger(btn,"onDragOut");
		ClipEvent.unsetEventsTrigger(btn,"onReleaseOutside");
		ClipEvent.unsetEventsTrigger(btn,"onDragOver");
		
		ClipEvent.destroy(btn);
		delete btn._obj;
	}
	
	
	
	/**
	 * 
	 * @param images : affecte les images à utiliser pour les états du bouton , {IMG_OUT:1,IMG_OVER:5,IMG_PRESS:7,IMG_ON:7,IMG_OFF:1,IMG_DEAD:0}
	 * 	 */
	public function setImages(images:Object) {
		if (images==undefined) return;
		for (var i : String in images) {
			updateState(this[i],images[i],i);
		}
		/*
		if (images.IMG_OVER!=undefined) {updateState(IMG_OVER,images.IMG_OVER,TIMG_OVER);IMG_OVER=images.IMG_OVER;}
		if (images.IMG_OUT!=undefined) {updateState(IMG_OUT,images.IMG_OUT,TIMG_OUT);IMG_OUT=images.IMG_OUT;}
		if (images.IMG_PRESS!=undefined) {updateState(IMG_PRESS,images.IMG_PRESS);IMG_PRESS=images.IMG_PRESS;}
		if (images.IMG_ON!=undefined) {updateState(IMG_ON,images.IMG_ON);IMG_ON=images.IMG_ON;}
		if (images.IMG_OFF!=undefined) {updateState(IMG_OFF,images.IMG_OFF);IMG_OFF=images.IMG_OFF;}
		if (images.IMG_DEAD!=undefined) {updateState(IMG_DEAD,images.IMG_DEAD);IMG_DEAD=images.IMG_DEAD;}
		*/
	}
	
	private function updateState(from:String,to:String,T:String) {
		this[T]=to;
		if (_currentImage==T) _goto(T)
		
	}
	
	public function _onPress(){
		if (IMG_ON!=IMG_PRESS && !_bascule ) {
			_goto(TIMG_PRESS);
		}
		if (btn.over.enabled) btn.over._visible=true;
		dispatchEvent(ON_PRESS,new Event(this,ON_PRESS,[btn]));
		
	}
	public function viewOver(){
		_goto(TIMG_OVER);
		btn.over._visible=btn.over.enabled;
	}
	
	public function viewOutFast(){
		outGoFast()
	}
	
	public function viewOut(){
		outGo()
	}
	
	
	
	private function _onDragOver(){
		// trace("GraphicTools.BOverOutPress._onDragOver()"+btn);
		if(enable) {
			_goto(TIMG_OVER);
		}
		btn.over._visible=btn.over.enabled;
		dispatchEvent(ON_OVER,new Event(this,ON_OVER,[btn]));
	}
	
	private function _onRollOver(){
		// trace("GraphicTools.BOverOutPress._onRollOver()"+btn);
		if(enable) {
			_goto(TIMG_OVER);
		}
		btn.over._visible=btn.over.enabled;
		dispatchEvent(ON_OVER,new Event(this,ON_OVER,[btn]));
	}
	private function _onDragOut(){
		// trace("GraphicTools.BOverOutPress._onDragOut()");
		outGo()
		btn.over._visible=btn.over.enabled;
		dispatchEvent(ON_OUT,new Event(this,ON_OUT,[btn]));
	}
	private function _onReleaseOutside(){
		// trace("GraphicTools.BOverOutPress._onReleaseOutside()");
		outGo()
		btn.over._visible=btn.over.enabled;
		dispatchEvent(ON_OUT,new Event(this,ON_OUT,[btn]));
	}
	
	private function outGo(){
		if (_dead) {
			// trace("GraphicTools.BOverOutPress.outGo()"+btn+" IMG_DEAD"+IMG_DEAD);
			_goto(TIMG_DEAD)
		} else {
			if (enable) {
				_goto(TIMG_OUT);
				// trace("GraphicTools.BOverOutPress.outGo()"+btn+" IMG_OUT"+IMG_OUT);
			} else {
				_goto(TIMG_ON);
				// trace("GraphicTools.BOverOutPress.outGo()"+btn+" IMG_ON"+IMG_ON);
			}
		}
	}
	
	private function outGoFast(){
		if (_dead) {
			// trace("GraphicTools.BOverOutPress.outGo()"+btn+" IMG_DEAD"+IMG_DEAD);
			_goto(TIMG_DEAD,TIMG_DEAD)
		} else {
			if (enable) {
				_goto(TIMG_OUT,TIMG_OUT);
				// trace("GraphicTools.BOverOutPress.outGo()"+btn+" IMG_OUT"+IMG_OUT);
			} else {
				_goto(TIMG_ON,TIMG_ON);
				// trace("GraphicTools.BOverOutPress.outGo()"+btn+" IMG_ON"+IMG_ON);
			}
		}
	}
	
	private function _onRollOut(){
		outGo()
		/*
		if (enable) {
			goto(IMG_OUT);
		} else {
			goto(IMG_ON);
		}
		*/
		btn.over._visible=btn.over.enabled;
		dispatchEvent(ON_OUT,new Event(this,ON_OUT,[btn]));
	}
	public function _onRelease(){
		if (_bascule) {
			setEnable(false);
		} 
		btn.over._visible=btn.over.enabled;
		dispatchEvent(ON_RELEASE,new Event(this,ON_RELEASE,[btn]));
	}
	private var _enable:Boolean;
	private function unsetEvents(){
		// trace("GraphicTools.BOverOutPress.unsetEvents()"+btn+"IMG_ON"+IMG_ON+" _reclic "+_reclic);
		btn.over._visible=false;
		
		
		if (!_reclic) {
			ClipEvent.unsetEventsTrigger(btn,"onPress");
			ClipEvent.unsetEventsTrigger(btn,"onRelease");
			btn.useHandCursor=false;
		}
		/*
		ClipEvent.unsetEventsTrigger(btn,"onRollOver");
		ClipEvent.unsetEventsTrigger(btn,"onRollOut");
		ClipEvent.unsetEventsTrigger(btn,"onDragOut");
		ClipEvent.unsetEventsTrigger(btn,"onReleaseOutside");
		btn.enabled=false;
		*/
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE,[btn]));
		
	}
	
	public function desactive(){
		ClipEvent.unsetEventsTrigger(btn,"onPress");
		ClipEvent.unsetEventsTrigger(btn,"onRelease");
		ClipEvent.unsetEventsTrigger(btn,"onRollOver");
		ClipEvent.unsetEventsTrigger(btn,"onRollOut");
		ClipEvent.unsetEventsTrigger(btn,"onDragOut");
		ClipEvent.unsetEventsTrigger(btn,"onReleaseOutside");
	}
	private function setEvents(){
		btn.over._visible=false;
		if (_dead) return;
		// trace("GraphicTools.BOverOutPress.setEvents()"+btn+"IMG_OFF"+IMG_OFF);
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
	
	private function setEnable(etat:Boolean) {
		//if (_enable!=etat) {
			_enable=etat;
			outGo()
			
			if (etat) {
				setEvents();
			} else {
				unsetEvents();
			}
			
		//}
			
	}
	
	public function set dead(val:Boolean){
		_dead=val;
		outGo()
		if (_dead) {
			unsetEvents();
		} else {
			setEvents();
		}
		//setEnable(!val);
	}
	
	public function get dead():Boolean{
		return _dead;
	}
	
	public function get enable():Boolean {
		return _enable;
	}

	public function set enable(enable:Boolean):Void {
		setEnable(enable);
		
	}
	
	public function getBtn():MovieClip {
		return btn;
	}

	
	public function dispatchAction(onSomeThing:String){
		dispatchEvent(onSomeThing,new Event(this,onSomeThing,[btn]));
	}
	
	private var _currentImage:String;
	private function _goto(TImage:String) {
		_currentImage=TImage;
		goto(this [TImage]);
	}
}