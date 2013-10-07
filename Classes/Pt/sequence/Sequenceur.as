/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.Parsers.SimpleXML;
import Pt.Parsers.DataStk;

import Pt.sequence.Sequence;

import Pt.Zone.IContent;
import Pt.Zone.Controler;
import site.targets.*;
//import site.Versions;
import Pt.Temporise;


/**
 * 
 */
class Pt.sequence.Sequenceur extends EventDispatcher {
		/**
	 * quand evenement
	 * onAct(source:)
	 */	
	private var tempoLoader:Temporise;
	public static var ON_READY:String = "onReady";
	public static var ON_START:String = "onStart";
	public static var ON_STOP:String = "onStop";
	public static var ON_PAUSE:String = "onPause";
	
	private var clip:MovieClip;
	
	private var seq:Sequence;
	
	private var loaderXML:SimpleXML;
	var controler:Controler;
	private var btnZoom:MovieClip;
	
	private var racine:String;
	
	
	
	public function Sequenceur(clip:MovieClip) {
		super();
		
		this.clip=clip;
		racine=DataStk.val("config").repSequences[0].src;
		//var testeScene:IContent=new Scene(clip.clipScene);
		
		btnZoom=clip.btnZoom;
		controler=Controler.getInstance();
	//	controler.addContent(Scene.NOM,new Scene(clip.scene));
	//	controler.addContent(Popup.NOM,new Popup(clip.popup));
		
		controler.addContent(Fond.NOM,new Fond(clip.fond,clip.legende));

		loaderXML=new SimpleXML("ressources");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,successData,this)
		loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		
		
		
		
	}
	
	public function pause(){
		if (!seq.isEnd) {
			dispatchEvent(ON_PAUSE,new Event(this,ON_PAUSE));
			seq.pause();
			
		}
	}
	
	public function reprise(){
		if (!seq.isEnd && seq.isPaused) {
			dispatchEvent(ON_START,new Event(this,ON_START));
			seq.start();
			
		} 
	}
	
	private function onSeqPlay(){
		reprise()
	}
	
	private function onSeqPause(){
		pause();
	}
	
	public function stop(){
		tempoLoader.destroy();
		_root.loader._visible=false;
		//trace("Pt.sequence.Sequenceur.stop() seq.isEnd"+seq.isEnd);
		if (!seq.isEnd) {
			// TODO FERMER LES POPUPS
			seq.stop(); 
			
		}
		controler.clear();
		
		
		if (btnZoom.onRelease!=undefined) {
		  btnZoom._visible=true;
		} 
        //clipVersions._visible=true;
        dispatchEvent(ON_STOP,new Event(this,ON_STOP));
        
		//media.FluxVideo.prevInstance.stop();
	}
	
	private var _lastSequence:String;
	private var _lastSequenceContent:Object;
	public var _cmdToStartWith:String;
	public var isStarted:Boolean=false;
	
	public function get sequenceFile():String {
		return _lastSequence;
	}
	
	public function load(sequence:String,cmdToStartWith:String) {
		var wasStarted:Boolean=isStarted;
		isStarted=false;
		//trace("Pt.sequence.Sequenceur.load("+sequence+", "+cmdToStartWith+")");
		//trace("Pt.sequence.Sequenceur.load("+sequence+")");
		_cmdToStartWith=cmdToStartWith;
		this.stop();
		// Send.event("SEL_TEXT");
		 media.LecteurVideo.prevInstance.stop();
		 media.FluxVideo.prevInstance.stop();
	
		controler.addContent(Scene.NOM,new Scene(clip.scene));
		controler.addContent(Popup.NOM,new Popup(clip.popup));
		//clip.fond._visible=false;
		clip.scene._visible=false;
		clip.popup._visible=false;
		
		if (sequence!=undefined) {
			if (sequence==_lastSequence) {
				//if (wasStarted==false) {
					onReady()
				//} else {
					controler.setInLoad();
					tempoLoader=new Temporise(500,showLoader,true);
					successData(null,_lastSequenceContent)
				//}
			} else {
				_lastSequence=sequence;
				loaderXML.load(racine+sequence);
				controler.setInLoad();
				tempoLoader=new Temporise(500,showLoader,true);
				
			}
		} else {
			
				
			controler.clear();
		}
	}
	
	private function showLoader(){
		_root.loader._visible=true;
	}
//textg.setTextes(uneRubrique);
	function successData(src:SimpleXML,conteneur:Object) {
		//trace(conteneur);
		_lastSequenceContent=conteneur;
		seq=new Sequence(conteneur);
		seq.addEventListener(Sequence.ON_READY,onReady,this) ;
		seq.addEventListener(Sequence.ON_START,onStart,this) ;
		seq.addEventListener(Sequence.ON_END,onEnd,this) ;
		
		seq.addEventListener(Sequence.ON_AT,onAt,this) ;
		seq.addEventListener(Sequence.ON_PLAY,onSeqPlay,this);
		seq.addEventListener(Sequence.ON_PAUSE,onSeqPause,this);
		seq.init();
	}
	function failedData(src:SimpleXML,conteneur:Object,status:Number) {
		//trace("Pt.sequence.Sequenceur.failedData()");
		_root.err(src.getFile()+" status:"+Pt.Parsers.ArrayDonnees.erreur(status));
	}
	function onReady(src:Sequence) {
		//trace("Pt.sequence.Sequenceur.onReady(src)"+_cmdToStartWith);
		//clip.fond._visible=true;
		clip.scene._visible=true;
		clip.popup._visible=true;
		
		tempoLoader.destroy();
		_root.loader._visible=false;
		if (_cmdToStartWith==undefined) {
			seq.start(Sequence.OPTION_ALONE)
		}
		dispatchEvent(ON_READY,new Event(this,ON_READY,[_cmdToStartWith]));
	}
	
	
	public function start(){
		isStarted=true;
		controler.setInPlay();
		seq.start(_cmdToStartWith);	
	}
	function onStart(src:Sequence) {
		isStarted=true;
		//trace("Pt.sequence.Sequenceur.onStart(src)");
		btnZoom._visible=false;
		dispatchEvent(ON_START,new Event(this,ON_START));
		//clipVersions._visible=false;
	}
	function onEnd(src:Sequence) {
		//trace("Pt.sequence.Sequenceur.onEnd(src)");
	     if (btnZoom.onRelease!=undefined) {
          btnZoom._visible=true;
        } 
        //Send.event("SEL_TEXT");
		dispatchEvent(ON_STOP,new Event(this,ON_STOP));
		//clipVersions._visible=true;
		//controler.clear();
	}
	
	
	
	private function onAt(src:Sequence,time:Number){
		//trace("Pt.sequence.Sequenceur.onAt(src, "+time+")");
		site.Appli.timer.reprise();
		
	}
	
	
	
	
	

}