/**
 * @author Administrator    , pense-tete
 * 28 f�vr. 08
 */
import org.aswing.util.Delegate;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import Pt.Temporise;
import GraphicTools.I_Lecteur;
import media.FluxUnique;
/**
 * 
 */
class media.FluxAudio extends FluxUnique implements I_Lecteur {
	static var ON_STOP:String="onStop";
	static var ON_UPDATE:String="onUpdate";
	
	private var playScan:Temporise;

	private var son:Sound;
	
	private var _offset:Number=0;
	public function get offset():Number {
		return _offset;
	}

	public function set offset(offset:Number):Void {
		this._offset = offset;
	}
	
	private var fichierFlux:String;
	
	private var intanceClip:MovieClip;
	
	
	
	private var maTrace:Function=Pt.Out.p;
	
	public function getSon():Sound {
		return son;
	}
	
	public function FluxAudio(fichierFlux:String,autoStart:Boolean,offset:Number)  {
	 	super();
	 	if (offset!=undefined)this._offset=offset
		var depth=_root.getNextHighestDepth();
		intanceClip=_root.createEmptyMovieClip("_mp3_"+depth,depth);
		son=new Sound(intanceClip);
		if (fichierFlux!=undefined) {
			start(fichierFlux);
		}

		
	}
	
	
	private var listenning:Boolean=false;
	private function initListener(){
		if (listenning) return;
				listenning=true;
				son.onSoundComplete=Delegate.create(this, stopped);
				son.onLoad=Delegate.create(this, onLoaded);
				
				
	}
	
	private function startScan(){
		playScan.remove();
		playScan= new Temporise(100,Delegate.create(this, playheadUpdate));
	}
	
	private function stopScan(){
		playScan.remove()
	}
	
	
	
	
	public function start(fichierFlux:String,null1,null2,null3) {
		_offset=0;
		initListener();
		if (this.fichierFlux!=fichierFlux) {
			
			this.fichierFlux=fichierFlux;
			son.loadSound(Pt.Tools.Clips.convertURL(fichierFlux),true);
			startScan();
			
		} else {
			 this.play();
		}
		setUnique();

	}
	
	
	public function play(){
		trace("media.FluxAudio.play():offset="+_offset);
		
		setUnique();
		trace("->"+son.position+" "+son.duration+" "+son.getBytesLoaded()+"/"+son.getBytesTotal());
		
		son.start(_offset/1000,0);
		trace("<-"+son.position+" "+son.duration+" "+son.getBytesLoaded()+"/"+son.getBytesTotal());
		
		startScan();
		
	}
	
	

	public function pause(){
		maTrace("media.FluxAudio.pause() :son.position="+son.position);
		_offset=son.position/1000;
		son.stop();
	}
	
	public function stop() {
		maTrace("GraphicTools.LecteurAudio.stop()");
		_offset=0;
		son.stop();
		stopScan();
	}
	
	public function position():Number{
		return son.position;
	}
	public function duration():Number{
		return son.duration;
	}
	public function getBytesLoaded():Number{
		return son.getBytesLoaded();
	}
	public function getBytesTotal():Number{
		return son.getBytesTotal();
	}

	private function playheadUpdate() {
		dispatchEvent(ON_UPDATE,new Event(this,ON_UPDATE));
	
	}
	
	private function onLoaded(success:Boolean){
		dispatchEvent(ON_UPDATE,new Event(this,ON_UPDATE));
		if (!success) {
			
			_root.err("ERREUR | AUDIO | "+Pt.Tools.Clips.convertURL(fichierFlux)+" | "+success);
		}
	}

	private function stopped(){
		maTrace("GraphicTools.LecteurAudio.stopped()");
		_offset=0;
		stopScan();
		dispatchEvent(ON_STOP,new Event(this,ON_STOP));
	}
	
	public function destroy(){
		this.stop();
		intanceClip.removeMovieClip();
	}
	


	

}