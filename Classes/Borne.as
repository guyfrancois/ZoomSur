/**
 * @author Administrator    , pense-tete
 * 12 nov. 07
 */
import Pt.Tools.TimerEvents;
import Pt.Parsers.SimpleXML;
/**
 * 
 */
class Borne {
	private var clip:MovieClip;
	public function Borne(clip:MovieClip) {
		fscommand("fullscreen",true);
		this.clip=clip;
		clip.createEmptyMovieClip("content",1);
		boucle();
		loadContent();
		/** charger le XML **/
		/** initialise le timer **/
		/** gere le chargement de l'application **/
		
	}
	
	private function loadContent() {
		
		var loaderXML:SimpleXML=new SimpleXML("ressources");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,successData,this)
		loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		loaderXML.load("storyboard.xml");
		
		
		
	}
	
	private function successData(src:SimpleXML,conteneur:Object){

		trace("Borne.success(conteneur)");
		_root.xmlData=conteneur;
		initTimer();
	}
	
	private function failedData(conteneur:Object){
		trace("Borne.failed(conteneur)");
	}
	
	
	private function initTimer(){
		trace("Borne.initTimer()");
		trace(_root.xmlData.timer[0].tempoAlerte*1000);
		trace(_root.xmlData.timer[0].dureeAlerte*1000);
		TimerEvents.getInstance().setTempo(_root.xmlData.timer[0].tempoAlerte*1000);
		TimerEvents.getInstance().setTempoAlert(_root.xmlData.timer[0].dureeAlerte*1000);
		TimerEvents.getInstance().addEventListener(TimerEvents.ON_CALLAPPLI,lance,this);
		TimerEvents.getInstance().addEventListener(TimerEvents.ON_CALLLOOP,boucle,this);
		
	}
	
	private function boucle(){
		//fscommand("fullscreen",true);
		clip.content.loadMovie("boucle.swf");
	}
	
	private function lance(){
		//fscommand("fullscreen",true);
		clip.content.loadMovie(_root.xmlData.animation[0].href);
		TimerEvents.getInstance().start();
		
	}
}