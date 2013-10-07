/**
 * @author Administrator    , pense-tete
 * 28 f�vr. 08
 */
import GraphicTools.BOverOutPress;
import org.aswing.util.Delegate;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import GraphicTools.I_Lecteur;
import Pt.image.SWFLoader;
import Pt.animate.ClipByFrame;
/**
 * 
 */
class GraphicTools.LecteurSWF extends EventDispatcher implements I_Lecteur {
	static var ON_STOP:String="onStop";
	
	private var btn_pause:BOverOutPress;
	private var btn_play:BOverOutPress;
	private var btn_stop:BOverOutPress;
	
	private var mc_progression:MovieClip;
	private var mc_streaming:BOverOutPress;
	
	

	
		/**
	 * taille d'origine des barres progession et streaming
	 */
	private var _barreWidth:Number;
	
	private var fichierFlux:String;
	
	private var swfloader:SWFLoader;
	private var cbf:ClipByFrame;
	private var cible:MovieClip;
	
	public static var prevInstance:LecteurSWF;
	
	
	
	private var maTrace:Function=Pt.Out.p;
	
	public function LecteurSWF(btn_pause:MovieClip,
	 								btn_play:MovieClip,
	 								btn_stop:MovieClip,
	 								fichierFlux:String,
	 								cible:MovieClip,
	 								mc_progression:MovieClip,
	 								mc_streaming:MovieClip,
	 								autoStart:Boolean)  {
	 	super();
	 	this.cible=cible;
	 	this.mc_progression=mc_progression;
	 	this._barreWidth=mc_progression._width;
		var depth=_root.getNextHighestDepth();
		initBtn(btn_pause,btn_play,btn_stop,mc_streaming);
		swfloader=new SWFLoader(cible,undefined,cible._width,cible._height,SWFLoader.ALIGNCENTER,SWFLoader.ALIGNBOTTOM,SWFLoader.SCALLIN,undefined,undefined)
		
		var locRef=this;
		if (fichierFlux!=undefined) {
			start(fichierFlux);
		}

		
	}
	
	private function initBtn (btn_pause:MovieClip,btn_play:MovieClip,btn_stop:MovieClip,mc_streaming:MovieClip){
		this.btn_play=new BOverOutPress(btn_play,false);
		this.btn_play.addEventListener(BOverOutPress.ON_RELEASE,this.player_onRelease,this);
		this.btn_stop=new BOverOutPress(btn_stop);
		this.btn_stop.addEventListener(BOverOutPress.ON_RELEASE,this.player_onRelease,this);
		this.btn_pause=new BOverOutPress(btn_pause);
		this.btn_pause.addEventListener(BOverOutPress.ON_RELEASE,this.player_onRelease,this);
		this.mc_streaming=new BOverOutPress(mc_streaming,true,false);
		this.mc_streaming.addEventListener(BOverOutPress.ON_RELEASE,this.player_onRelease,this);
	
		
		
	}
	
	private var listenning:Boolean=false;
	private function initListener(){
		if (listenning) return;
				listenning=true;
				swfloader.addEventListener(SWFLoader.ON_LOADPROGRESS,onLoadProgress,this);
				swfloader.addEventListener(SWFLoader.ON_LOADINIT,onLoadInit,this);
//				son.onSoundComplete=Delegate.create(this, stopped)
	}
	

	
	
	
	public function start(fichierFlux:String,swfWidth:Number,swfHeight:Number,param1) {

		initListener();
		if (this.fichierFlux!=fichierFlux) {
			
			this.fichierFlux=fichierFlux;
		//	son.loadSound(fichierFlux,true);
			swfloader.load(fichierFlux,swfWidth,swfHeight);
			
		} else {
			 play();
		}
		

		if (LecteurSWF.prevInstance!=this) {
            			LecteurSWF.prevInstance.stop();
            			LecteurSWF.prevInstance=this;
        }
		btn_stop.enable=true;
		btn_pause.enable=true;
		btn_play.enable=false;
	}
	
	
	
	private function player_onRelease(source:BOverOutPress):Void{
		//trace("GraphicTools.LecteurAudio.player_onRelease("+source.getBtn()+")");
		switch (source) {
			case btn_play :
			   this.play();
			break;
			case btn_stop :
				
				this.stop();
			break;
			case btn_pause :
				this.pause();
			break;
			case mc_streaming :
		//		offset=calcPos()*(son.duration/1000)/100;
				var fromFrame:Number=1+Math.floor(calcPos()*cible._totalframes/100);
				btn_stop.enable=true;
				btn_pause.enable=true;
				btn_play.enable=false;
				cbf.goto(cible._totalframes,fromFrame);
				
			break;
			
		}
	}
	
	public function play(){
		//trace("GraphicTools.LecteurAudio.play()");
		 if (LecteurSWF.prevInstance!=this) {
            			LecteurSWF.prevInstance.stop();
            			LecteurSWF.prevInstance=this;
        		}
		btn_stop.enable=true;
		btn_pause.enable=true;
		cbf.goto(cible._totalframes);


	}
	
	

	public function pause(){
		cbf.stop();
		btn_stop.enable=true;
		btn_play.enable=true;


	}
	
	public function stop() {
		maTrace("GraphicTools.LecteurAudio.stop()");
		btn_play.enable=true;
		btn_pause.enable=true;

		cbf.setTo(0);


		mc_progression._xscale=0;
	}
	
	private function onLoadInit(src:SWFLoader,target_mc:MovieClip) {
		cbf=new ClipByFrame(target_mc);
		cbf.addEventListener(ClipByFrame.ON_STOP,stopped,this);
		cbf.addEventListener(ClipByFrame.ON_NEXTFRAME,playheadUpdate,this);
		cbf.addEventListener(ClipByFrame.ON_PREVFRAME,playheadUpdate,this);
		cbf.goto(target_mc._totalframes);
	}
	
	private function onLoadProgress(src:SWFLoader,loadedBytes:Number, totalBytes:Number){
		var barre:MovieClip=mc_streaming.getBtn()
		barre._xscale=loadedBytes*100/totalBytes;
	}
	

	private function playheadUpdate() {
		//trace("GraphicTools.LecteurAudio.playheadUpdate()");
		updateTime(mc_progression);
		
	}
		/**
	 * calcul le pourcentage de lecture à atteindre au clip su le clip
	 */
	private function calcPos():Number {
		var pos:Number;
		var clip:MovieClip=mc_streaming.getBtn();
		pos= (clip._parent._xmouse-clip._x)*100/_barreWidth;
		maTrace("GraphicTools.LecteurMedia.calcPos():"+pos);
		return pos;
	}
	
	private function updateTime(barre:MovieClip) {
		//trace("GraphicTools.LecteurAudio.updateTime(barre="+barre+")");
		//trace("son.position:"+son.position+" son.duration"+son.duration);
//		
		barre._xscale=(cible._currentframe-1)*100/cible._totalframes;
		
	}

	
	private function stopped(){
		updateTime(mc_progression);
		if (cible._currentframe!=1) {
			maTrace("GraphicTools.LecteurAudio.stopped() return at 1st frame"+cible._currentframe);
			cbf.setTo(1);
			return;
		}
		maTrace("GraphicTools.LecteurAudio.stopped()");
		btn_stop.enable=false;
		btn_play.enable=true;
		btn_pause.enable=true;

		
		
		dispatchEvent(ON_STOP,new Event(this,ON_STOP));
	}
	
	public function destroy(){
		swfloader.destroy();
		this.stop();
//		intanceClip.removeMovieClip();
	}
	

}