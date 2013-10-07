/**
 * @author Administrator    , pense-tete
 * 15 avr. 08
 */
 import GraphicTools.BOverOutPress;
  import Pt.Tools.Slider;
  import Pt.scan.OverOut;
/**
 * 
 */
class media.ControlVolume {
	private var clipVolume:MovieClip;
	private var volumeSlide:MovieClip;
	private var btn_volume:BOverOutPress;
	private var monSlide:Slider;
	private var son:Sound;
	private var souris:OverOut;
	
	static var imagesBtn:Object={IMG_OUT:1,IMG_OVER:2,IMG_PRESS:3,IMG_ON:4,IMG_OFF:1};
	
	
	
	public function ControlVolume(clipVolume:MovieClip,volumeSlide:MovieClip) {
		
		this.clipVolume=clipVolume;
		this.volumeSlide=volumeSlide;
		
		initBtn();
	
		souris=new OverOut(volumeSlide);
		souris.addEventListener(OverOut.ON_ROLLOUT,onRollOutSlide,this)
		
	}
	
	
	private function initBtn() {
		if (clipVolume!=undefined) {
		volumeSlide._visible=false;
		//btn_volume=new BOverOutPress(clipVolume);
		
		btn_volume=new BOverOutPress(clipVolume,true,true,Pt.animate.ClipByFrame.delegateCreate(clipVolume) ,imagesBtn);
		
		btn_volume.addEventListener(BOverOutPress.ON_RELEASE,volume_onRelease,this);
		}
		
		son=new Sound();
		monSlide=new Slider(volumeSlide,0,0,100,son.getVolume()) ;
		monSlide.addEventListener(Slider.ON_MOVEDONE,this.onMoveScroll,this);
		
	}
	
	private function onMoveScroll(src:Slider,val:Number){
		son.setVolume(val);
	}
	
	private function volume_onRelease(src:Slider,val:Number){
		volumeSlide._visible=true;
		souris.startScan();
		
	}
	
	private function onRollOutSlide(){
		souris.stopScan()
		btn_volume.enable=true;
		volumeSlide._visible=false;
	}
	
}