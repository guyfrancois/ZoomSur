/**
 * @author Administrator    , pense-tete
 * 28 f�vr. 08
 */
import GraphicTools.BOverOutPress;
import org.aswing.util.Delegate;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import Pt.Temporise;
import GraphicTools.I_Lecteur;
/**
 * 
 */
class GraphicTools.LecteurAudio extends EventDispatcher implements I_Lecteur {
	static var ON_STOP:String="onStop";
	
	private var btn_pause:BOverOutPress;
	private var btn_play:BOverOutPress;
	private var btn_stop:BOverOutPress;
	
	private var mc_progression:MovieClip;
	private var mc_streaming:BOverOutPress;
	private var playScan:Temporise;

	private var son:Sound;
	
	private var offset:Number=0;
	
		/**
	 * taille d'origine des barres progession et streaming
	 */
	private var _barreWidth:Number;
	
	private var fichierFlux:String;
	
	private var intanceClip:MovieClip;
	
	public static var prevInstance:LecteurAudio;
	
	private var maTrace:Function=Pt.Out.p;
	
	public function LecteurAudio(btn_pause:MovieClip,
	 								btn_play:MovieClip,
	 								btn_stop:MovieClip,
	 								fichierFlux:String,
	 								mc_progression:MovieClip,
	 								mc_streaming:MovieClip,
	 								autoStart:Boolean)  {
	 	super();
	 	this.mc_progression=mc_progression;
	 	this._barreWidth=mc_progression._width;
		var depth=_root.getNextHighestDepth();
		intanceClip=_root.createEmptyMovieClip("_mp3_"+depth,depth);
		initBtn(btn_pause,btn_play,btn_stop,mc_streaming);
		
		var locRef=this;
		son=new Sound(intanceClip);
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
				son.onSoundComplete=Delegate.create(this, stopped)
	}
	
	private function startScan(){
		playScan.remove();
		playScan= new Temporise(100,Delegate.create(this, playheadUpdate));
	}
	
	private function stopScan(){
		playScan.remove()
	}
	
	
	
	public function start(fichierFlux:String,null1,null2,null3) {
		offset=0;
		initListener();
		if (this.fichierFlux!=fichierFlux) {
			
			this.fichierFlux=fichierFlux;
			son.loadSound(Pt.Tools.Clips.convertURL(fichierFlux),true);
			startScan();
			
		} else {
			 play();
		}
		

		if (LecteurAudio.prevInstance!=this) {
            			LecteurAudio.prevInstance.stop();
            			LecteurAudio.prevInstance=this;
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
				offset=calcPos()*(son.duration/1000)/100;
				this.play();
			break;
			
		}
	}
	
	public function play(){
		//trace("GraphicTools.LecteurAudio.play():offset="+offset);
		 if (LecteurAudio.prevInstance!=this) {
            			LecteurAudio.prevInstance.stop();
            			LecteurAudio.prevInstance=this;
        		}
		btn_stop.enable=true;
		btn_pause.enable=true;
		son.start(offset,0);
		startScan();
	}
	
	

	public function pause(){
		//trace("GraphicTools.LecteurAudio.pause() :son.position="+son.position);
		btn_stop.enable=true;
		btn_play.enable=true;
		offset=son.position/1000;
		son.stop();
		stopScan();
	}
	
	public function stop() {
		//trace("GraphicTools.LecteurAudio.stop()");
		btn_play.enable=true;
		btn_pause.enable=true;
		offset=0;
		son.stop();
		stopScan();
		mc_progression._xscale=0;
	}
	

	private function playheadUpdate() {
		//trace("GraphicTools.LecteurAudio.playheadUpdate()");
		updateTime(mc_progression);
		updateSize(mc_streaming.getBtn());
	}
		/**
	 * calcul le pourcentage de lecture à atteindre au clip su le clip
	 */
	private function calcPos():Number {
		var pos:Number;
		var clip:MovieClip=mc_streaming.getBtn();
		pos= (clip._parent._xmouse-clip._x)*100/_barreWidth;
		//trace("GraphicTools.LecteurMedia.calcPos():"+pos);
		return pos;
	}
	
	private function updateTime(barre:MovieClip) {
		//trace("GraphicTools.LecteurAudio.updateTime(barre="+barre+")");
		//trace("son.position:"+son.position+" son.duration"+son.duration);
		barre._xscale=son.position*100/son.duration;
		
		
	}
	private function updateSize(barre:MovieClip) {
		//trace("GraphicTools.LecteurAudio.updateSize(barre="+barre+")");
		//trace("son.getBytesLoaded():"+son.getBytesLoaded()+" son.getBytesTotal():"+son.getBytesTotal());
		son.getPosition()
		barre._xscale=son.getBytesLoaded()*100/son.getBytesTotal();
		
	}
	
	private function stopped(){
		maTrace("GraphicTools.LecteurAudio.stopped()");
		btn_stop.enable=false;
		btn_play.enable=true;
		btn_pause.enable=true;
		offset=0;
		stopScan();
		dispatchEvent(ON_STOP,new Event(this,ON_STOP));
	}
	
	public function destroy(){
		maTrace("GraphicTools.LecteurAudio.destroy(enclosing_method_arguments)");
		this.stop();
		intanceClip.removeMovieClip();
	}
	

}