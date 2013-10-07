/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */
import Pt.sequence.*;
import Pt.Parsers.SimpleXML;
import Pt.Parsers.DataStk;

import org.aswing.util.Delegate;
import org.aswing.util.ArrayUtils;
import site.DefTYPES;
import site.DefTargets;
import Pt.Zone.Controler;

// TODO :  verifier temps inclusion seqences 
//
/**
 * Prepare, organise et sequence des elements 
 * une sequence est egalement un elements
 */
class Pt.sequence.Sequence extends Element {
	private var traceInfo:String="Sequence"; 
	
	private var _dataXML:Object;
	
	private var arrElement:Array; // tableau des elements index:Number
	
	// liste des index des elements avec reference
	private var refList:Object;
	
	
	private var _currentExclusif:Element; // element exclusif en cours
//	private var _autreEnCours:Element; // element du flux en cours
	
	private var _fluxEnCours:Array; // elements du flux en cours
	
	private var tempsEnCours:Number;
	
	private var tempsExclusif:Number;
	private var tempsFluxEnCours:Number;
	private var tempsFlux:Number;
	
	private var racine:String;
	
	private var closePopup:Boolean;
	
	
	
	public function Sequence(dataXML:Object) {
		super(dataXML);
		refList=new Object();
		arrElement=new Array();
		_fluxEnCours=new Array();
		racine=DataStk.val("config").repSequences[0].src;
		this._dataXML=dataXML;
		tempsEnCours=0;
		tempsExclusif=0;
		tempsFlux=0;
		tempsFluxEnCours=0;
		closePopup=false;
		if (_isExclusif==undefined)	_isExclusif=true;
		if (_isParallel==undefined)	_isParallel=false;
		if (dataXML.closePopup=="true") {
			closePopup=true;
		} 
	}
	
	 public function reset(){
	 	super.reset();
		stop();
		
		for (var i : Number = 0; i < arrElement.length; i++) {
			arrElement[i].reset();
		}
		
	}

	
	public function init() {
		if (_dataXML.src!=undefined) {
			var loaderXML:SimpleXML=new SimpleXML("ressources");
			loaderXML.addEventListener(SimpleXML.ON_SUCCESS,successData,this)
			loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
			loaderXML.load(racine+_dataXML.src);
		} else {
			_init(_dataXML);
		}
	}
	
	private function successData(src:SimpleXML,data:Object) {
		_init(data);
	}
	
	private function failedData(src:SimpleXML,contener:Object,status,msg) {
		//trace("Pt.sequence.Sequence.failedData() "+_dataXML.src);
		_root.err("Sequence failedData"+src.getFile()+" "+msg);
		dispatchReady();
		dispatchEnd();
	}
	
	private function _init(dataXML:Object){
		
		var eltData:Object=dataXML.firstChild;
		while (eltData!=undefined) {
			createElement(eltData.nodeName,eltData.node);
			eltData=eltData.node.nextNode;
		}
		eltOnReady(undefined,null,0);
	}
	
	
	private function eltOnReady(src:Element,null1,index:Number){
		//trace("Pt.sequence.Sequence.eltOnReady(src, "+index+")");
		var elt:Element=arrElement[index];
		if (elt==undefined) {
			dispatchReady();
		} else {
			elt.addEventListener(Element.ON_READY,Delegate.create(this, eltOnReady,index+1));
			elt.init();
		}
		
	}
	
	
	
	private function createElement(nodeName,eltXML) {
		//trace("Pt.sequence.Sequence.createElement("+nodeName+", "+eltXML.traceInfo+")");
		var elt:Element;
		switch (nodeName) {
			case DefTYPES.SON :
				elt= new Son(eltXML);
			break;
			
			case DefTYPES.TEXTE :
				elt= new Texte(eltXML);
			break;
			
			case DefTYPES.PAUSE :
				elt=new Pause(eltXML);
			break;
			
			case DefTYPES.VIDEO:
				elt=new Pt.sequence.Video(eltXML);
			break;
			
			case DefTYPES.ANIM :
				elt=new Anim(eltXML);
			break;
			
			case DefTYPES.T360 :
				elt=new T360(eltXML);
			break;
			
			
			case DefTYPES.IMAGE :
				elt=new Image(eltXML);
			break;
			
			case DefTYPES.EFFET :
			break;
			
			case DefTYPES.CMD :
				elt= new Cmd(eltXML);
			break;
			
			case DefTYPES.SEQUENCE :
				elt=new Sequence(eltXML);
				
			break;
		}
		var lg:Number=arrElement.push(elt);
		var index:Number=lg-1;
		//var refList:Object=new Object();
		if (eltXML.ref!=undefined) {
			refList[eltXML.ref]=lg-1;
		}
		if (elt.isSync) { // synchronisation special (au debut de l'element pointé)
			var eltSync:Element=arrElement[refList[elt.sync]];
			if (elt.at==0) {
				eltSync.addEventListener(Element.ON_START,Delegate.create(this,onStartElementWithSync,elt),this);
			} else {
				elt._atListener=eltSync.addEventListener(Element.ON_AT,Delegate.create(this,onStartElementWithSyncAt,elt),this);
			}
			
			elt.addEventListener(Element.ON_END,Delegate.create(this, syncOnEndElt,index),this);
			//Element.ON_AT
			// TODO implementation de AT
		} else {	// syncro normal
			if (elt.isParallel) {
				// lance l'element suivant au debut si il n'est pas exclusif
				elt.addEventListener(Element.ON_START,Delegate.create(this, syncOnStartEltParallel,index),this);
			}
			/*
			if (elt.isExclusif) { 
				// à la fin, lance le prochain isExclusif si les tous les elt precedents sont terminés
				elt.addEventListener(Element.ON_END,Delegate.create(this, syncOnEndEltExclusif,index),this);
			} else { // lecture du suivant
			*/
				elt.addEventListener(Element.ON_END,Delegate.create(this, syncOnEndElt,index),this);
			//}
		}
		
	}
	

	private function onAtExclusif(src:Element,temps:Number) {
		//trace("Pt.sequence.Sequence.onAtExclusif(src, "+temps+")");
		tempsExclusif=temps;
		dispatchAt(tempsEnCours+Math.max(tempsExclusif,tempsFlux+tempsFluxEnCours))
		
	}
	private function onAtFlux(src:Element,temps:Number) {
		//trace("Pt.sequence.Sequence.onAtFlux(src,"+temps+")");
		tempsFluxEnCours=Math.max(temps,tempsFluxEnCours);
		dispatchAt(tempsEnCours+Math.max(tempsExclusif,tempsFlux+tempsFluxEnCours))
	}
	
	
	private function onStartElementWithSync(eltRef:Element,null1,eltSync:Element){
		
		startElement(eltSync);
	}
	private function onStartElementWithSyncAt(eltRef:Element,temps:Number,eltSync:Element){
		trace("Pt.sequence.Sequence.onStartElementWithSyncAt("+eltRef.getName()+" "+temps+" "+eltSync.at);
		if (temps>=eltSync.at && !isPaused) {
			eltSync.offset+=eltSync.at-temps;
			eltRef.removeEventListener(eltSync._atListener);
			startElement(eltSync);
		}
	}
	
	/**
	 * lancer un element non exclusif
	 * 	 */ 
	private function startElement(elt:Element) {
		//trace("Pt.sequence.Sequence.startElement(elt)"+elt);
		if (!elt.isEnd)  {
			//trace("!isEnd")
			elt.addEventListener(Element.ON_AT,onAtFlux,this);
			elt.addEventListener(Element.ON_PAUSE,dispatchPause,this);
			elt.addEventListener(Element.ON_PLAY,dispatchPlay,this)
			_fluxEnCours.push(elt);
		}
		elt.start();
	}
	/**
	 * lancer un element exclusif	 */
	private function lancerExclusif(elt:Element) {
		//trace("Pt.sequence.Sequence.lancerExclusif(elt)"+elt);
		//trace(( _currentExclusif==undefined || _currentExclusif.isEnd ) +" && " + ( _fluxEnCours.length==0) )
		if ( (_currentExclusif==undefined || _currentExclusif.isEnd ) &&  _fluxEnCours.length==0) {
			tempsEnCours+=Math.max(tempsExclusif,tempsFlux);
			
			_currentExclusif=elt;
			_fluxEnCours.push(elt);
			//trace("start")
			elt.start();
			elt.addEventListener(Element.ON_AT,onAtExclusif,this);
			elt.addEventListener(Element.ON_PAUSE,dispatchPause,this);
			elt.addEventListener(Element.ON_PLAY,dispatchPlay,this)
		} else {
			//trace("!start")
		}
		
	}
	
	
	
	/**
	 * synchonisation au lancement d'un element parallel	 */
	private function syncOnStartEltParallel(src:Element,null1,index:Number) {
		//trace("Pt.sequence.Sequence.syncOnStartEltParallel(src, null1, "+index+")");
		var suivant:Number=index+1;
		var eltSync:Element=arrElement[suivant];
		while (suivant<arrElement.length  && (eltSync.isStart || eltSync.isEnd || eltSync.isSync)  ) {
			
			//dans le tableau,  un élément synchronisé || erroné
			suivant++;

			eltSync=arrElement[suivant];
		}
		//trace("index a lancer :"+index)
		if (suivant==arrElement.length) {
			// pas d'element à lancer en même temps
			//trace("fin de sequence ")
			
		} else if (eltSync.isExclusif){
			// le prochain est exclusif
			//trace("suivant exclusif")
		} else {
			//trace("->startElement")
			startElement(eltSync);
		}
	}

	/**
	 * syncronisation à la fin d'un element exclusif
	 
	private function syncOnEndEltExclusif(src:Element,null1,index:Number) {
		var suivant:Number=index+1;
		var eltSync:Element=arrElement[suivant];
		while (suivant<arrElement.length && (!arrElement[suivant].isExclusif)  ) {
			
			//dans le tableau, non exclusif
			suivant++;

			eltSync=arrElement[suivant];
		}
		if (suivant==arrElement.length) {
			// pas d'element à lancer en même temps
			
		} else if (eltSync.isExclusif){
			// le prochain est exclusif
			lancerExclusif(eltSync);
		} 
	}
	*/
	
	/**
	 * 	 * synchonisation à la fin d'un element non exclusif (standard)
	 * lance la lecture de l'element suivant si :
	 * 	pas d'exclusif en cours de lecture
	 * 	pas de !isParallel en cours de lecture	 */
	private function syncOnEndElt(src:Element,null1,index:Number){
		var fluxi:Number=ArrayUtils.removeFromArray(_fluxEnCours,src);
		
		if ( _fluxEnCours.length>0 ) {
			for (var i : Number = 0; i < _fluxEnCours.length; i++) { // cherche a poursuivre le flux si les elements !isParallel precedents sont terminés
				if (!_fluxEnCours[i].isParallel) return;
			}
		}
		
		// rechercher le suivant à lancer
		var suivant:Number=index+1;
		var eltSuivant:Element=arrElement[suivant];
		while (suivant<arrElement.length   && (eltSuivant.isStart || eltSuivant.isEnd || eltSuivant.isSync ) ) {
			//dans le tableau, non exclusif,  un élément synchronisé || erroné || parallel
				suivant++;
				//eltSync.start();
				eltSuivant=arrElement[suivant];
			
		}
		
		if (suivant==arrElement.length) {
			// fin de lecture de la sequence si le flux en cours est vide
			if (_fluxEnCours.length==0) {
				dispatchEnd();	
			}
		} else if (eltSuivant.isExclusif){
			lancerExclusif(eltSuivant);
		} else {
			startElement(eltSuivant)
		}

	}
	
	
	/**
	 * lance la lecture de l'element
	 */
	private var hasStartAlone:Boolean=false;
	private function _start(withCommand:String){
		if (arrElement.length==0) {
			dispatchEnd();
		} else {
			var elt=arrElement[0];
			if (withCommand==Element.OPTION_ALONE) {
				hasStartAlone=true;
				elt.start(Element.OPTION_ALONE);
				return;
			}
			if (hasStartAlone) {
				elt=arrElement[1];
			}
			if (withCommand!=undefined) {
				var eltc=getCommand(withCommand)
				//trace("elt==eltc"+elt==eltc)
				elt=eltc;
			}	
			if (elt.isExclusif) {
				lancerExclusif(elt);
			} else {
				startElement(elt);
			}
			dispatchStart();
			
		}
		
		
	}
	private function _reprise(){
		
		//_currentExclusif.start();
		for (var i : Number = 0; i < _fluxEnCours.length; i++) {
			_fluxEnCours[i].start();
		}
	}
	/**
	 * met en pause l'element 
	 */
	private function _pause(){
		//trace("Pt.sequence.Sequence._pause()");
		//_currentExclusif.pause();
		for (var i : Number = 0; i < _fluxEnCours.length; i++) {
			_fluxEnCours[i].pause();
		}
	}
	/**
	 * arrête definitivement l'element
	 */
	private function _stop(){
		//_currentExclusif.stop();
		for (var i : Number = 0; i < arrElement.length; i++) {
			arrElement[i].stop();
		}
		for (var i : Number = 0; i < _fluxEnCours.length; i++) {
			_fluxEnCours[i].stop();
		}
		
		if (closePopup) {
			Controler.getInstance().getContent(DefTargets.POPUP).clear();
		}
		
		arrElement=new Array();
		_fluxEnCours=new Array();
		delete _currentExclusif;

		
	}
	/** à lancer à la fin de la lecture de l'element : dispatchEnd()*/
	/** TODO : à lancer regulièrement au cours de la lecture : dispatchAt(time:Number)*/
	
	
	
	private function  getCommand(cmd:String):Cmd {
		//trace("Pt.sequence.Sequence.startWithCommand("+cmd+")");
		var elt:Element;
		var ocmd:Cmd;
		for (var i:Number=0;i<arrElement.length;i++) {
			elt=arrElement[i]
			if (elt instanceof Cmd) {
				
				if (arrElement[i].getCmd()==cmd) {
					ocmd=Cmd(elt);
				}
				elt.reset();
			} 
		}
		if (ocmd!=undefined) {
			//trace("commande trouvée :"+ocmd.getCmd());
		} else {
			//trace("pas de commande trouvée :"+cmd)
		}
		return ocmd
	}
}