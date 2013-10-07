/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.Timer;
import org.aswing.util.Delegate;
import Pt.Parsers.DataStk;
/**
 *  * Abstract
 * Minimum de fonctionnement d'un élément d'un sequence
 */
 
class Pt.sequence.Element extends EventDispatcher {
	public static var OPTION_ALONE:String="ALONE";
	/**
	 * Definition des Evenements	 */
	 private var ltrace:Function = Pt.Out.p;
	/**
	 * l'element est prète à être lue (prèchargement)
	 */
	public static var ON_READY : String ="onReady";
	 /**
	  * l'element commence	  */
	public static var ON_START:String = "onStart";
	/**
	 * l'element est terminé	 */
	public static var ON_END:String = "onEnd";
	/**
	 * Element en cours de lecture, signalement de progression
	 * @param time : temps en miliseconde depuis le debut de l'anim	 */
	 public static var ON_AT:String="onAt"
	 
	 
	 public static var ON_PAUSE:String="onPause";
	 public static var ON_PLAY:String="onPlay";

	 
	 private var timer:Timer;
	 private var _isReady:Boolean; // est chargé ?
	 private var _isStart:Boolean; // a  commencé ?
	 private var _isPaused:Boolean; // est en pause
	 private var _isRessourceEnd:Boolean; // la ressource à terminé ?
	 private var _isEnd:Boolean; // est terminée ? (timer eventuel et ressource)
	 private var _startAsReady:Boolean; // commence dès que prêt
	 
	 private var _isParallel:Boolean; //  true : le suivant part à onStart , false : le suivant part à onEnd 
	 
	 private var _isExclusif:Boolean; // true :ne demarre que si tous les element precedent , dont les exclusifs sont terminé
	  								   // false : demarre si touts les elements !_isExclusif sont terminés
	 private var _isSync:Boolean;
	 
	 private var _sync:String;
	 
	 private var _at:Number=0;
	 
	 public function get at():Number {
	 	return _at;
	 }
	 
	 public var _atListener:Object;
	 
	 private var DEFAULTHIDE:Number;
	 
	 	private var _offset:Number=0;
	public function get offset():Number {
		return _offset;
	}

	public function set offset(_offset:Number):Void {
		this._offset = _offset;
	}
	
	  								   
	 /**
	  * par default :
	  * une animation : _isParallel=false, _isExclusif=false;
	  * un son : _isParallel=true; _isExclusif=true;
	  * une sequence (contenant son et animations) : _isParallel=false; _isExclusif=true;
	  * une video : _isParallel=false; _isExclusif=true;	  */
	 
	 private var duree:Number;
	 
	 private var traceInfo:String="ELEMENT";
	 public function reset(){
		_isStart=false;
		_isEnd=false;
		_isPaused=false;
		_isRessourceEnd=false;
		
	}
	 
	public function Element(dataXML:Object) {
		super();
		  DEFAULTHIDE=Number(DataStk.val("config").defaut_fade[0].alpha);
		_isReady=false;
		_isStart=false;
		_isEnd=false;
		_isPaused=false;
		_startAsReady=false;
		_isRessourceEnd=false;
		/*
		_isExclusif=false;
		_isParallel=false;
		*/
		
		if (!isNaN(dataXML.duree)) this.duree=dataXML.duree;
		if (dataXML.traceInfo!=undefined) this.traceInfo=dataXML.traceInfo;
		if (dataXML.sync!=undefined) {
			this._sync=dataXML.sync;	
			_isSync=true
			if (isNaN(dataXML.at)) {
				this._at=0;	
			} else {
				this._at=Number(dataXML.at);
			}
		} else {
			_isSync=false;
		}
		
		_offset=Number(dataXML.offset);
		if (isNaN(_offset)) _offset=0;
		
		if (dataXML.parallel=="true") {
			_isParallel=true;
		} 
		if (dataXML.parallel=="false") {
			_isParallel=false;
		} 
		if (dataXML.exclusif=="true") {
			_isExclusif=true;
		} 
		if (dataXML.exclusif=="false") {
			_isExclusif=false;
		} 




	}
	
	public function setExclusif(val:Boolean){
		_isExclusif=val;
	} 
	public function setParallel(val:Boolean){
		_isParallel=val;
	}
	
	/**
	 * initialisation de l'element, après l'appel des constructeurs, avant l'ecoute de l'evenement ON_READY
	 * lance le prè-chargement	 */
	public function init(){
		//trace("A DEFINIR : Pt.sequence.Element.init()");
		
	}
	
	
	public function get sync():String {
		return _sync;
	}
	public function get isSync() : Boolean {
		return _isSync;
	}
	
	public function get isExclusif() : Boolean {
		return _isExclusif;
	}
	public function get isParallel() : Boolean {
		return _isParallel;
	}
	public function get isReady():Boolean {
		return _isReady;
	}
	
	public function get isStart():Boolean {
		return _isStart;
	}
	
	public function get isEnd():Boolean {
		return _isEnd;
	}
	
	public function get isPaused():Boolean {
		return _isPaused;
	}
	
	/**
	 * initialise la lecture de l'element suivant l'etat de l'element
	 * etat :
	 * 	_isEnd : l'element est marqué comme terminé , il ne devrais pas être utilisé
	 * 	_isStart : la lecture a déja commencé
	 * 	_isPause : l'element est en pause
	 * 	_isReady : l'element est près (entierement chargé et initialisé)
	 * 	_startAsReady : signal que l'element commencera dès qu'il serat près ( en carence sur un streaming)
	 * 	 */
	 private var _startOption;
	public function start(startOption){
		//trace("Pt.sequence.Element.start()"+this.traceInfo);
		if (_isEnd) trace("ERREUR : Pt.sequence.Element.start() _isEnd"+_isEnd+" "+this.traceInfo);
		_startOption=startOption;
		
		if (_isStart && _isPaused && _startOption!=Element.OPTION_ALONE) {
			// reprise après une pause
			timer.reprise();
			_isPaused=false;
			
			_reprise();
			
		} else	if (_isReady) {
			
			if (duree!=undefined) {
				timer=new Timer(duree,Delegate.create(this, timerCallBack))
			}
			_start(startOption);
			
		} else {
			_startAsReady=true;
		}
	}
	
	// Tduree : != duree si il y a eu pause (durée depuis la dernière pause)
	private function timerCallBack(src:Timer,Tduree:Number) {
		removeTimer();
		if (_isRessourceEnd ) {
			dispatchEnd();
		}
	}
	
	private function removeTimer(){
		//trace("Pt.sequence.Element.removeTimer()"+this.traceInfo);
		timer.destroy();
		delete timer;
		timer=undefined;
	}
	/**
	 * lance la lecture de l'element	 */
	private function _start(){
		//trace("A DEFINIR : Pt.sequence.Element._start()");
	}
	private function _reprise(){
		//trace("A DEFINIR : Pt.sequence.Element._reprise()");
	}
	
	/**
	 * met en pause l'element 	 */
	public function pause(){
		//trace("Pt.sequence.Element.pause()"+this.traceInfo);
		_isPaused=true;
		timer.pause();
		_pause();
	}
	private function _pause(){
		//trace("A DEFINIR : Pt.sequence.Element._pause()"+this.traceInfo);
	}
	/**
	 * arrête definitivement l'element	 */
	public function stop(){
		//trace("Pt.sequence.Element.stop()"+this.traceInfo);
		removeTimer();
		_stop();
	}
	
	private function _stop(){
		//trace("A DEFINIR : Pt.sequence.Element._stop()");
	}
	
	/** à lancer à la fin de l'initialisation de l'element (chargement)*/
	private function dispatchReady(){
		if (!_isReady) {
			_isReady=true;
			//trace("Pt.sequence.Element.dispatchReady()"+this.traceInfo);
			dispatchEvent(ON_READY,new Event(this,ON_READY));
			if (_startAsReady) {
				start(_startOption);
			}
		}
		
	}
	
	/** à lancer au debut de la lecture reel de l'element */
	private function dispatchStart(){
		_isStart=true;
		//trace("Pt.sequence.Element.dispatchStart()"+this.traceInfo);
		if (_startOption!=OPTION_ALONE) {
			dispatchEvent(ON_START,new Event(this,ON_START));
		}
	}
	
	/** à lancer à la fin de la lecture de l'element
	 * 
	 *  execute stop()	 */
	private function dispatchEnd(){
		if (timer!=undefined) {
			//trace("Pt.sequence.Element.dispatchEnd() timer!=undefined"+this.traceInfo);
			_isRessourceEnd=true;
			
		} else {
			_isEnd=true;
			this.stop();
			//trace("Pt.sequence.Element.dispatchEnd()"+this.traceInfo);
			if (_startOption!=OPTION_ALONE) {
				dispatchEvent(ON_END,new Event(this,ON_END));
			}
		}
	}
	
	/** à lancer regulièrement au cours de la lecture */
	private function dispatchAt(time:Number){	
		//trace("Pt.sequence.Element.dispatchAt()"+this.traceInfo);
		dispatchEvent(ON_AT,new Event(this,ON_AT,[time] ));
	}
	
	private function dispatchPause(){
		//trace("Pt.sequence.Element.dispatchPause()"+this.traceInfo);
		dispatchEvent(ON_PAUSE,new Event(this,ON_PAUSE));
		
	}
	private function dispatchPlay(){
		//trace("Pt.sequence.Element.dispatchPlay()"+this.traceInfo);
		dispatchEvent(ON_PLAY,new Event(this,ON_PLAY));
		
	}
	
	public function getName():String{
		return this.traceInfo;
	}
}