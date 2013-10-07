/**
 *
 */
import org.aswing.EventDispatcher;
import GraphicTools.BOverOutPress;
import org.aswing.Event;
import Pt.animate.ClipByFrame;
import org.aswing.util.Delegate;

/**
 *gere un ensemble de boutons
 *nommé de _0 à _nbBtn
 *chaque btn envoye un evenemment ON_OPEN avec son nom comme parametre
 */
class map.Controler extends EventDispatcher {
	/**
	 * onOpen(src:Controler, ref:String);	 */
    static var ON_OPEN:String="onOpen";
    /**
	 * onBtnInit(src:Controler, btn:BOverOutPress);
	 */
    static var ON_BTNINIT:String="onBtnInit";
	
	private var prefix:String="_";
	private var clip:MovieClip;
	private var btn_vueGlobal:BOverOutPress;
	
	private var nbBtn:Number;
	
	private var imagesBtn:Object={IMG_OUT:1,IMG_OVER:2,IMG_PRESS:3,IMG_ON:3,IMG_OFF:1};
	
	/**
	 * créer le gestionnaire
	 * @param clip : movieClip contenant les boutons	 */
	public function Controler(clip:MovieClip,nbBtn:Number,prefix:String,initListener) {
		super();
		addEventListener(initListener);
		this.clip=clip;
		if (prefix!=undefined) this.prefix=prefix;
		
		initialise(nbBtn);
	}
	
	private function createBtn(clipbtn:MovieClip):BOverOutPress{
		if (clipbtn==undefined) return undefined;
		var btnCBF:ClipByFrame=new ClipByFrame(clipbtn);
	//	return new GraphicTools.BOverOutSelect(lClip,true,true,Delegate.create(btnCBF, btnCBF.goto),imagesBtn);
		
		var btn:BOverOutPress=new BOverOutPress(clipbtn,undefined,true ,Delegate.create(btnCBF, btnCBF.goto),imagesBtn);
		btn.addEventListener(BOverOutPress.ON_RELEASE,zoneOnRelease,this);
		dispatchEvent(ON_BTNINIT,new Event(this,ON_BTNINIT,[btn]));
		
		return btn;
	}
	
	
	private function initialise(nbBtn:Number) {	
		this.nbBtn=nbBtn;
		for (var i : Number = 0; i < nbBtn; i++) {
			createBtn(clip[prefix+i]);
		}
		var surplus:Number=nbBtn;
		while (clip[prefix+surplus]!=undefined) {
			clip[prefix+surplus]._visible=false;
			surplus++;
		}
	}
	
	
	public function destroy(){
		for (var i:Number=0;i<nbBtn;i++) {
    	   var btn:BOverOutPress=clip[prefix+i]._obj ;
	   	   btn.enable=true;
	   	   btn.destroy();
          
	   }
	}
	
	private function zoneOnRelease(src:BOverOutPress) {
		dispatchEvent(ON_OPEN,new Event(this,ON_OPEN,[src.getBtn()._name]));
	}
	
	/**
	 * desactive le bouton correspondant 
	 * active les autres	 */
	public function open(ref:String) {
		trace("map.Controler.open("+ref+")");
		//desactive le bouton correspondant
	   	for (var i:Number=0;i<nbBtn;i++) {
    	   	var btn:BOverOutPress=clip[prefix+i]._obj ;
	   	   	if ( (prefix+i) == ref ) {
	   	   		btn.enable=false;
	   	   	} else { 
                btn.enable=true;
            }
	   }

	}
	public function getClip():MovieClip{
		return clip;
	}
	
	public function getBtn(ref:String):BOverOutPress{
		return clip[ref]._obj;
	}
	

}