/**
 * @author Administrator    , pense-tete
 * 15 avr. 08
 */
import GraphicTools.BOverOutPress;
import org.aswing.EventDispatcher;
import org.aswing.Event;
import media.ControlVolume;
import Pt.animate.ClipByFrame;
import Pt.animate.Transition;
/**
 * 
 */
class media.BarreLecteur extends EventDispatcher {
	static var ONPLAYPRESS:String="onPlayPress";
	static var ONPAUSEPRESS:String="onPausePress";
	static var ONSTOPPRESS:String="onStopPress";
	static var ONGOTOPRESS:String="onGotoPress";
	
	static var imagesBtn:Object={IMG_OUT:1,IMG_OVER:2,IMG_PRESS:3,IMG_ON:4,IMG_OFF:1};
	
	
	private var clip:MovieClip;
	
	private var btn_pause:BOverOutPress;
	private var btn_play:BOverOutPress;
	private var btn_stop:BOverOutPress;
	private var btn_streaming:BOverOutPress;
	
	private var ctrlVol:ControlVolume
	
	private var mc_progression:MovieClip;
	
	private var totalSize:Number;
	
	private var cbfBarre:Transition;
	
	public function BarreLecteur(clip:MovieClip) {
		super();
		this.clip=clip;
	
		
		clip._visible=false;
		ctrlVol=new ControlVolume(clip.volume,clip.volumeSlide);
		initBtn(clip.barre.btn_pause,clip.barre.btn_play,clip.barre.btn_stop,clip.barre.progression,clip.barre.streaming)
	}
	
	public function open(){
		clip._visible=true;
	}
	
	public function close(){
		clip._visible=false;
	}
	
	
	
	
	private function initBtn (btn_pause:MovieClip,btn_play:MovieClip,btn_stop:MovieClip,mc_progression:MovieClip,mc_streaming:MovieClip){
		totalSize=Math.max(mc_progression._width,mc_streaming._width);
		this.mc_progression=mc_progression;
		this.btn_play=new BOverOutPress(btn_play,true,false,ClipByFrame.delegateCreate(btn_play) ,imagesBtn);
		this.btn_play.addEventListener(BOverOutPress.ON_RELEASE,this.player_onRelease,this);
		this.btn_stop=new BOverOutPress(btn_stop,true,false,ClipByFrame.delegateCreate(btn_stop) ,imagesBtn);
		this.btn_stop.addEventListener(BOverOutPress.ON_RELEASE,this.player_onRelease,this);
		this.btn_pause=new BOverOutPress(btn_pause,true,false,ClipByFrame.delegateCreate(btn_pause) ,imagesBtn);
		this.btn_pause.addEventListener(BOverOutPress.ON_RELEASE,this.player_onRelease,this);
		this.btn_streaming=new BOverOutPress(mc_streaming,true,false);
		this.btn_streaming.addEventListener(BOverOutPress.ON_RELEASE,this.player_onRelease,this);
		
	}
	
	
	private function player_onRelease(source:BOverOutPress):Void{
		trace("media.BarreLecteur.player_onRelease("+source.getBtn()+")");
		switch (source) {
			case btn_play :
			 	dispatchEvent(ONPLAYPRESS,new Event(this,ONPLAYPRESS));
			break;
			case btn_stop :
				dispatchEvent(ONSTOPPRESS,new Event(this,ONSTOPPRESS));
			break;
			case btn_pause :
				dispatchEvent(ONPAUSEPRESS,new Event(this,ONPAUSEPRESS));
			break;
			case btn_streaming :
				trace("calcPos:"+calcPos())
				dispatchEvent(ONGOTOPRESS,new Event(this,ONGOTOPRESS,[calcPos()]));
			break;
			
		}
	}
	
	public function onPlay(){
		trace("media.BarreLecteur.onPlay()");
		btn_play.enable=false;
		btn_stop.enable=true;
		btn_pause.enable=true;
	}
	
	
	public function onPause(){
		trace("media.BarreLecteur.onPause()");
		btn_pause.enable=false;
		btn_stop.enable=true;
		btn_play.enable=true;
	}
	
	public function onStop() {
		trace("media.BarreLecteur.onStop()");
		btn_stop.enable=false;
		btn_play.enable=true;//!src.isEnd();
		btn_pause.enable=false;
	}
	
	public function onHeadUpdate(src:Object,pc:Number) {
		//trace("media.BarreLecteur.onHeadUpdate("+pc+")"+mc_progression);
		mc_progression._width=pc*totalSize/100;
		//trace(mc_progression._width+" "+btn_streaming.getBtn()._width);
		
	}
	
	public function onLoadUpdate(src:Object,pc:Number) {
		//trace("media.BarreLecteur.onLoadUpdate("+pc+")"+btn_streaming.getBtn());
		btn_streaming.getBtn()._width=pc*totalSize/100;
	}
	
	private function calcPos():Number{
		return (mc_progression._parent._xMouse-mc_progression._x)*100/totalSize;
	}
	
	
	
}