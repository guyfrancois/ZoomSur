/**
 * @author guyf 26 oct. 2005
 */
 import org.aswing.util.SuspendedCall;
  import org.aswing.util.Delegate;
 import media.LecteurVideo;
 import media.BarreLecteur;
 import media.FluxUnique;
 import GraphicTools.I_Lecteur;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import Pt.Temporise;
 
class media.FluxVideo extends FluxUnique implements I_Lecteur {
	
	static var ON_STOP:String="onStop";
	static var ON_END:String="onStop";
	
	static var ON_PAUSE:String=LecteurVideo.ON_PAUSE;
	static var ON_PLAY:String=LecteurVideo.ON_PLAY;
	
	static var ON_UPDATE:String="onUpdate";
	
	static var ALIGNTOP:Number=0;
	static var ALIGNLEFT:Number=0;
	static var ALIGNCENTER:Number=1;
	static var ALIGNBOTTOM:Number=2;
	static var ALIGNRIGHT:Number=2;
	
	static var SCALLIN:Number=0; // à l'interieur
	static var SCALLOUT:Number=1; // à l'exterieur
	static var SCALLNONE:Number=-1; // pas de re-scall
	
	
	private var maxWidth:Number;
	private var maxHeight:Number;
	private var xInit:Number;
	private var yInit:Number;

	private var hAlign:Number=ALIGNCENTER;
	private var vAlign:Number=ALIGNCENTER;
	private var scaleMode:Number=SCALLNONE;
	

	//var controleur:Object;
	/**
	 * 
	 * 
	 * 
	 * exemple :
	 * GraphicTools.LecteurMedia(btn_pause, btn_play, btn_stop, maVideo, fichierFlux, controleur);
	 * 
	 */	
	private var _clip:MovieClip;
	private var barVideo:BarreLecteur;
	 
	private var lectv:LecteurVideo;
	private var barVideoListener:Object;
	private var lectvListener:Object;
	
	 
	public function FluxVideo(autoStart:Boolean,clip:MovieClip,width:Number,height:Number,hAlign:Number,vAlign:Number,scaleMode:Number) {
	 	this._clip=clip;
	 	trace("media.FluxVideo.FluxVideo( autoStart, "+clip+")");
		//this.controleur=controleur;
		//interface
				lectv=new LecteurVideo(_clip.maVideo,undefined,true,hAlign?hAlign:LecteurVideo.ALIGNCENTER,vAlign?vAlign:LecteurVideo.ALIGNCENTER,scaleMode?scaleMode:LecteurVideo.SCALLNONE,width,height);
				trace("BarreLecteur "+_clip.barre.barre);
				
				barVideo=new BarreLecteur(_clip.barre);
				barVideo.close();

				barVideoListener=lectv.addEventListener( barVideo);
				//lectv.addEventListener(LecteurVideo.ON_INFO,onInfoVideo,this);
				//lectv.addEventListener(LecteurVideo.ON_RESIZE,onResizeVideo,this);
				lectvListener=new Object();
				lectvListener[LecteurVideo.ON_HEADUPDATE]=Delegate.create(this,onUpdate);
				lectvListener[LecteurVideo.ON_STOP]=Delegate.create(this,onStop);
				lectvListener[LecteurVideo.ON_PAUSE]=Delegate.create(this,onPause);
				lectvListener[LecteurVideo.ON_PLAY]=Delegate.create(this,onPlay);
			
				lectv.addEventListener(lectvListener)
				barVideo.addEventListener(lectv);
		
		//sauvegardes des parametres de dimension et position par défaut
	
		
		
		//parametres
		
		
		//init_media(fichierFlux,autoStart);
	
	}
	/*
	function listen(evt:Object) {
		Log.addMessage("listen(evt)"+evt.type, Log.INFO,"GraphicTools.LecteurMedia");
		init_media();
	}
	*/
	
	
	public function position():Number{
		return lectv.getTimeCode();
	}
	
	public function clear(){
		trace("media.FluxVideo.clear()");
		lectv.clear();
	}
	
	public function getFichier():String {
		return lectv.getFichierFlux();
	}
	//private var tmp:Temporise;
	public function start(fichierFlux:String,autoPlay:Boolean,param2,param3){
		//lectv.clear();
		_clip._visible=true;
		//tmp.destroy();
		lectv.start(fichierFlux,autoPlay,param2,param3)
		
		//tmp=new Temporise(100,Delegate.create(barVideo, barVideo.close),true);
		//_clip.onRollOver=Delegate.create(this, this.showBarre);
		//_clip.onRollOut=Delegate.create(barVideo, barVideo.close);
		//this.startVideo(fichierFlux,autoPlay==undefined?true:autoPlay);
		barVideo.open();
		// TODO : suivant le mode de lecture, autoriser ou pas la navigation vidéo ??
		/*
		if (SWFAddress.isModeGuide()) {
			barVideo.close();
		} else {
			barVideo.
			barVideo.open();
		}
		*/
	}
	
	private function showBarre(){
		//tmp.destroy();
		barVideo.open();
	}
	
	public function getSon():Sound {
		return lectv.son;
	}
	
	public function duration():Number{
		return lectv.duration();
	}

	public function stop(){
		lectv.stopAct()
	}
	public function play(){
		lectv.play()
	}
	public function pause(){
		lectv.pause()
	}
	public function destroy(){
		lectv.destroy();
		lectv.removeEventListener(barVideoListener);
		lectv.removeEventListener(lectvListener);
		
		
	}
	
	private function onPause(){
		dispatchEvent(ON_PAUSE,new Event(this,ON_PAUSE));
	}
	
	private function onPlay(){
		dispatchEvent(ON_PLAY,new Event(this,ON_PLAY));
	}
	
	private function onStop(){
		dispatchEvent(ON_STOP,new Event(this,ON_STOP));
		
	}
	
	private function onEnd(){
		dispatchEvent(ON_END,new Event(this,ON_END));
	}
	
	private function onUpdate(){
		site.Appli.timer.reprise();
		dispatchEvent(ON_UPDATE,new Event(this,ON_UPDATE));
	}
	
	
	


	
}