/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */

import Pt.sequence.Element;
import Pt.Zone.Controler;
import Pt.Zone.IContent;
import site.DefTargets;
import Pt.image.SWFLoader;
import Pt.image.LoaderDefine;
import org.aswing.util.Delegate;

//import Pt.animate.ClipByFrame;
import Pt.Temporise;
import Pt.Tools.Chaines;
import site.Navigator;
import site.DefModes;
import Pt.scan.Souris;
/**
 *
 *	360 dans zoom
 *	en fond, le 360 est manipulable
 *	forcement en fond pour les versions
 *	1 seul 360 pour le momen
 *	pas en popup
 *	
 *	le fond 360 mise en loupe
 *	
 *	  */
 
class Pt.sequence.T360 extends Element {
	// TODO : Corriger le controleur de souris mal fichu 
	// voir zoom
	static var scan:Souris;
	static var getCurrentImage:Function;
	// parametres de image
	static var TYPE:String=site.DefTYPES.T360;
	
	private var _target:String="";
	private var src:String;
	private var nbImages:Number;
	private var show:Number;
	private var hide:Number;
	private var width:Number;
	private var height:Number;
	private var close:Boolean;
	
	//private var stopAt:Number;
	private var startAt:Number; // image affiché au départ
	private var rotate:Number;  // nombre d'images  et sens de la rotation 
	private var rotateTime:Number; // temps total pour faire la rotation
	
	
	private var legende:String;
	
	// interne
	//private var cfb:ClipByFrame; 
	private var oTarget:IContent;
	
	private var _ilArray:Array;// of SWFLoader;
	
	private var nagiv:Navigator;
	private var fond:String;
	private var hasBtn:Boolean;
	
	
	
	public function T360(dataXML:Object) {
		super(dataXML);
		getCurrentImage=Delegate.create(this,_getCurrentImage);
		/*
		nagiv=Navigator.getInstance();
		nagiv.addEventListener(Navigator.ON_MODE,onMode,this);
		*/
		hasBtn=(dataXML.hasBtn=="true"?true:false);
		if (dataXML.target==undefined) {
			_target=DefTargets.SCENE;
		} else {
			_target=dataXML.target;
		}
	
		
		src=dataXML.src;
		fond=dataXML.fond;
		nbImages=Number(dataXML.nbImages);
		if (dataXML.legende[0].text!=undefined) legende=dataXML.legende[0].text;
		
		show=Number(dataXML.show);
		if (isNaN(show)) show=DEFAULTHIDE;
		hide=Number(dataXML.hide);
		if (isNaN(hide)) hide=DEFAULTHIDE;
		width=Number(dataXML.width);
		height=Number(dataXML.height);
		
		rotate=Number(dataXML.rotate);
		if (isNaN(rotate)) rotate=0;
		startAt=Number(dataXML.startAt);
		if (isNaN(startAt)) startAt=0;
		
		rotateTime=Number(dataXML.rotateTime);
		if (isNaN(rotateTime)) rotateTime=0;
		
		
		if (dataXML.close=="true") {
			hide=DEFAULTHIDE;
			close=true;
		}
		if (_isExclusif==undefined)	_isExclusif=false;
		if (_isParallel==undefined)	_isParallel=false;
		trace("Pt.sequence.T360.T360()"+traceInfo);
	}
	
	//private var _users:Number;
	//private var _alpha:Number;
	//private var _visible:Boolean;
	private var _contener:MovieClip;
	private var _countInitNbImages:Number=0;
	private var _vuesArray:Array ; // of MovieClip
	
	private var moveListener:Object;
	
	
	public function init(){
		trace("Pt.sequence.T360.init()"+traceInfo);
		_ilArray=new Array();
		_vuesArray=new Array();
		oTarget=Controler.getInstance().getContent(_target);
		
		
		_contener=oTarget.create(TYPE,src);
		if (_contener==undefined) trace("***** ERREUR init _contener indisponnible "+traceInfo);
		//_users=contener._users;
		//_alpha=contener._alpha;
		//_visible=contener._visible;
		//trace("_contener :"+_contener);
		//trace(_contener._users);
		if (_contener._users==0) {
			if (_target==DefTargets.FOND) {
				scan=new Souris(_contener);
				moveListener=scan.addEventListener(Souris.ON_MOUSEMOVE,onMoveMove,this);
			}
			
			_contener._users+=1;
			_contener.controler=this;
			
			var fondL:SWFLoader=new SWFLoader( _contener.createEmptyMovieClip( "fond",0)
												,fond,undefined,undefined
												,LoaderDefine.ALIGNTOP,LoaderDefine.ALIGNLEFT,LoaderDefine.SCALLNONE);
			for (var i : Number = 0; i < nbImages; i++) {
				var id:Number= _vuesArray.push( _contener.createEmptyMovieClip( "V_"+i,i+1));
				 
				var il:SWFLoader=new SWFLoader( _vuesArray[id-1]
												,undefined,undefined,undefined
												,LoaderDefine.ALIGNTOP,LoaderDefine.ALIGNLEFT,LoaderDefine.SCALLNONE);
				_ilArray.push(il)
 				il.addEventListener(SWFLoader.ON_LOADINIT,onILInit,this);
 				var num:String=Chaines.untriml(String(i),3,"0");
 				var nomFichier:String=Chaines.scanf(src,num);
 				//trace("load :"+nomFichier)
				il.load(Chaines.scanf(src,num),width,height);
				trace( _vuesArray[id-1]+" "+nomFichier)
				//scan.destroy()
				//scan.stopScan();
				
				
			}
			
			
		} else {
			for (var i : Number = 0; i < nbImages; i++) {
				_vuesArray.push(_contener["V_"+i]);
			}
			_contener._users+=1;
//			_cible=contener;
//			_cible._users+=1;
			
			
			dispatchReady();
		}
		
	}
	
	//private var _cible:MovieClip;
	public function onILInit(src:SWFLoader,cible:MovieClip){
		cible.stop();
		cible._visible=false;
		_countInitNbImages++;
		if (_countInitNbImages>=nbImages) {
			
			dispatchReady();
		}
		
		
		// TODO : controler par code interne au swf
		// onReady(callBack)
		// lire
		// pause
		// reprise
		// onPause(callBack)??
		// onEnd(callBack)
		
//		cible._users=_users+1;
//		cible._alpha=_alpha;
//		cible._visible=_visible;
//		cible.controler=this;
		/*
		cible.height=cible._height;
		cible.width=cible._width;
		*/
		
		
	}
	
	/**
	 * affiche une image du 360 :	 */
	 
	 private function showImage(numImage:Number){
	 	trace("Pt.sequence.T360.showImage("+numImage+")");
	 	var i:Number=numImage%nbImages;
	 	
	 	if (i<0) {
	 		 i=nbImages+i;
	 	}
	 	//trace("Pt.sequence.T360.showImage("+numImage+")"+i);
	 	var currentImage:MovieClip;
	 	for (var j : Number = 0; j < _vuesArray.length; j++) {
	 		if (i==j) {
	 			currentImage=_vuesArray[j];
	 			_vuesArray[j]._visible=true;
	 			
	 			//trace("="+_vuesArray[j])
	 		} else {
	 			_vuesArray[j]._visible=false;
	 		}
	 	}
	 	if (hasBtn) {
			currentImage.btn_prev.onRelease=Delegate.create(this,__prevImage);
				

			currentImage.btn_next.onRelease=Delegate.create(this,__nextImage);
		} else {
			
		}
		
		if (_target==DefTargets.FOND) {
			var num:String=Chaines.untriml(String(i),3,"0");
			var nomFichier:String=Chaines.scanf(src,num);
			site.targets.Fond.s_updatelegendeT360(Pt.Tools.Clips.convertCheminToRef(nomFichier));
		}
		
		
	 }
	 
	 private function __nextImage(){
	 	showImage(_currentImage+1);
	 }
	 private function __prevImage(){
	 	showImage(_currentImage-1);
	 }
	
	/**
	 * signal la fin de lecture de l'animation	 */
	private function onCFFStop(){
		dispatchEnd(); // fin de lecture de l'animation
	}
	/**
	 * lance la lecture de l'element	 */
	private function _start(){
		//trace("Pt.sequence.T360._start()");
//		_cible._users-=1;
//		if (isNaN(startAt)) startAt=_cible._currentframe;
		// controlé par image
//		cfb=new ClipByFrame(_cible);
//		cfb.addEventListener(ClipByFrame.ON_STOP,onCFFStop,this);
//		if (stopAt==-1) stopAt=_cible._totalframes;
		if (SWFAddress.isModeGuide()) {
				_contener.controler.stopInteraction();
				
			} else {
				_contener.controler.initInteraction();
			}
		dispatchStart();
		if (show==-1) {
			//on_start();
		} else {
//			if (startAt!=_cible._currentframe) _cible.gotoAndStop(startAt);
			showImage(startAt);
			oTarget.open();
			oTarget.setLegende(legende);
			oTarget.show(src,show,Delegate.create(this, on_start));
		}
	}
	
	private function rotateTempo (tempo:Temporise,count:Number){
		//trace("Pt.sequence.T360.rotateTempo(tempo, "+count+")");
		if (rotate==0) {
			//trace("end tempo")
			_contener.controler.initInteraction();
			dispatchEnd();
			
			tempo.remove();	
		} else {
			var inc:Number=rotate/Math.abs(rotate);
			startAt+=inc;
			rotate-=inc;
			//trace("startAt:"+startAt+" rotate:"+rotate);
			showImage(startAt);
		}
		
		
	}
	var tempo:Temporise;
	private function on_start(){
		//trace("Pt.sequence.T360.on_start()"+this.traceInfo);
		if (!isPaused) {
			
			//trace("!isPaused");
			if (rotate==0) {  // rien a lire
				//trace("rien a lire");
				
				dispatchEnd();
			} else {
				//trace(rotateTime+" "+Math.abs(rotate)+" "+(rotateTime/Math.abs(rotate)));
				var delai:Number=(rotateTime/Math.abs(rotate));
				tempo.destroy();
				tempo=new Temporise(delai,Delegate.create(this, rotateTempo),false);
			}
//			if (cfb.goto(stopAt,startAt)==false) {
//				dispatchEnd(); // rien a lire
//			}
		}
		
		
	}
	
	
	private function _stop(){
		//trace("Pt.sequence.anim._stop() close"+close+" "+this.traceInfo);
//		cfb.stop();
		tempo.destroy();
		if (hide!=-1) {
			if (close) oTarget.close();
			oTarget.hide(src,hide,Delegate.create(this, on_stop));
		} else {
			on_stop();
		}
			
	}
	
	private function on_stop(){
		//trace("Pt.sequence.T360.on_stop()");
		tempo.destroy();
		
		//scan.stopScan();
		//scan.removeEventListener(moveListener);
		if (_contener._users==0 && _contener._visible==false)	{
			_contener.controler.stopInteraction();
			oTarget.remove(src);
			
		}
		
		
	}

	private function destroy(){
		_contener.controler.stopInteraction();
		tempo.destroy();
		
		//scan.destroy()
		//scan.removeEventListener(moveListener);
		//delete scan;
		//scan=undefined;
		
		for (var i : Number = 0; i < _ilArray.length; i++) {
			_ilArray[i].destroy();
		}
	
	}
	
	private function _reprise(){
		tempo.reprise()
//		cfb.goto(stopAt,startAt);
		//oTarget.reprise();
	}
	
	private function _pause() {
		if (!isEnd) {
			if (show!=-1) {
			//on_start();
//				startAt=Math.max(cfb.stop(),startAt);
				tempo.pause();
			}
			
			//oTarget.pause()
		}
		super._pause();
		
	}
	
	
	/** gestion de l'interaction */
	
	
	public function onMode(nav:Navigator,mode:String) {
		
		if (SWFAddress.isModeGuide()) {
				_contener.controler.stopInteraction();
				
			} else {
				_contener.controler.initInteraction();
			}

		
	}
	
	
	public function initInteraction(){
		//trace("Pt.sequence.T360.initInteraction()"+scan);
		if (hasBtn) {
			
		} else {
			scan.startScan();
		}
	}
	
	public function stopInteraction(){
		//trace("Pt.sequence.T360.stopInteraction()"+scan);
		scan.stopScan();
	}
	
	
	private function _getCurrentImage():Number {
		for (var i : Number = 0; i < _vuesArray.length; i++) {
				if (_vuesArray[i]._visible) {
					return i;
				}
		}
	}
	
	function get _currentImage():Number{
		return _getCurrentImage();
	}	
	
	var incdx:Number=0;
	private function onMoveMove(src:Souris,dx:Number,dy:Number){
		
		if (src.isDown && src.hasMouseOver() && _contener._visible ) {
			//trace("Pt.sequence.T360.onMoveMove(src, "+dx+", "+dy+")");
			incdx+=dx;
			if (Math.abs(incdx/10)>1) {
				
				if (src.hasMouseOver()) {
					//TODO gerer l
				} else {
			
				}
				showImage(_currentImage+Math.floor(incdx/10));
				incdx=0;
			}
		}
	}

}