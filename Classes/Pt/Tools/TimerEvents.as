/**
 * @author GuyF , pense-tete.com
 * @date 26 mars 07
 * 
 */
import org.aswing.Event; 
class Pt.Tools.TimerEvents extends org.aswing.EventDispatcher {
	/**
	 * quand evenement : me moment est venu de lancer la boucle
	 * onCallLoop(source:)
	 */	
	public static var ON_CALLLOOP:String = "onCallLoop";
	
	/**
	 * quand evenement : un evenenent souris/clavier reveille l'appli
	 * onCallAppli(source:)
	 */	
	public static var ON_CALLAPPLI:String = "onCallAppli";
	
	/**
	 * quand evenement : le moment est venu d'envoyer une alerte
	 * onCallAlert(source:)
	 */	
	public static var ON_CALLALERT:String = "onCallAlert";
	
	static var ST_OPEN:Number=1;
	static var ST_LOOP:Number=2;
	
	private var tempo:Number=45000;// 1 minute
	private var alertTempo:Number=15000;
	//
	private var intervalTimer:Number;
	private var intervalAlert:Number;
	
	private var mouseListener:Object;
	private var keylistener:Object;
	
	
	private var etat:Number;
	
	
	private static var instance : TimerEvents;
		
		/**
		 * @return singleton instance of TimerEvents
		 */
	public static function getInstance() : TimerEvents {
			if (instance == null)
				instance = new TimerEvents();
			return instance;
	}
		
	private function TimerEvents() {
			super();
			initialize();
	}
	
	private function initialize(){
		etat=ST_LOOP;
		var locRef:TimerEvents=this;
		mouseListener=new Object();
		mouseListener.onMouseDown=function (){	
			 locRef.keep();
		}
		Mouse.addListener(mouseListener);
		keylistener=new Object();
		keylistener.onKeyDown =function (){locRef.keep();}
		Key.addListener(keylistener);
	}
	/**
	 * temporisation avant alerte	 */
	public function setTempo(val:Number) {
		tempo=val;
	}
	/**
	 * durée de l'alerte	 */
	public function setTempoAlert(val:Number) {
		alertTempo=val;
	}
	
/** gestion de command du timer **/	
/**
 * conserve ou reveille l'appli */
	public function keep(){
		//trace("Pt.Tools.Timer.keep()");
		if (etat==ST_OPEN) {
			if (intervalTimer!=undefined || intervalAlert != undefined) {
				start()
			}
		} else if (etat==ST_LOOP) {
			etat=ST_OPEN;
		//	//trace("Pt.Tools.TimerEvents.keep():ST_LOOP");
			dispatchEvent(ON_CALLAPPLI,new Event(this,ON_CALLAPPLI));
		}
	}
	/**
	 * lance ou relance le timer	 */
	public function start(){
		stopAlert();
		this.stop();
		etat=ST_OPEN;
		//trace("Pt.Tools.Timer.start()");
		intervalTimer=setInterval(this,"alert",tempo);
	}
	/**
	 * interomp le timer	 */
	public function stop() {
	//	//trace("Pt.Tools.Timer.stop()");
		clearInterval(intervalTimer);
		intervalTimer=undefined;
	}
	
	private function  alert(){
		this.stop();
		// affiche le clip d'alerte
		dispatchEvent(ON_CALLALERT,new Event(this,ON_CALLALERT));
		intervalAlert=setInterval(this,"resetAppl",alertTempo);
		
	}
	
	private function stopAlert(){
		if (intervalAlert!=undefined) {
			//trace("Pt.Tools.Timer.stopAlert()");
			// efface le clip d'alert
			_root.alert.removeMovieClip();
			clearInterval(intervalAlert);
			intervalAlert=undefined;
		}
	}
	
	private function resetAppl(){
	//	//trace("Pt.Tools.Timer.resetAppl");
		etat=ST_LOOP;
		stopAlert();
		// commande pour relancer l'application
		dispatchEvent(ON_CALLLOOP,new Event(this,ON_CALLLOOP));
	}
	
	
}