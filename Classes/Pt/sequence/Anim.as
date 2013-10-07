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

import Pt.animate.ClipByFrame;
/**
 *  * Abstract
 * Minimum de fonctionnement d'un élément d'un sequence
 */
 
class Pt.sequence.Anim extends Element {
	// parametres de image
	static var TYPE:String=site.DefTYPES.ANIM;
	private var _target:String="";
	private var src:String;
	private var show:Number;
	private var hide:Number;
	private var width:Number;
	private var height:Number;
	private var close:Boolean;
	
	private var stopAt:Number;
	private var startAt:Number;
	private var legende:String;
	
	// interne
	private var cfb:ClipByFrame; 
	private var oTarget:IContent;
	
	private var il:SWFLoader;
	
	
	
	public function Anim(dataXML:Object) {
		super(dataXML);
		if (dataXML.target==undefined) {
			_target=DefTargets.SCENE;
		} else {
			_target=dataXML.target;
		}
	
		
		src=dataXML.src;
		if (dataXML.legende[0].text!=undefined) legende=dataXML.legende[0].text;
		show=Number(dataXML.show);
		if (isNaN(show)) show=DEFAULTHIDE;
		hide=Number(dataXML.hide);
		if (isNaN(hide)) hide=DEFAULTHIDE;
		width=Number(dataXML.width);
		height=Number(dataXML.height);
		stopAt=Number(dataXML.stopAt);
		if (isNaN(stopAt)) stopAt=-1;
		startAt=Number(dataXML.startAt);
		
		if (dataXML.close=="true") {
			hide=DEFAULTHIDE;
			close=true;
		}
		if (_isExclusif==undefined)	_isExclusif=false;
		if (_isParallel==undefined)	_isParallel=false;
	}
	
	private var _users:Number;
	private var _alpha:Number;
	private var _visible:Boolean;
	
	
	public function init(){
		
		oTarget=Controler.getInstance().getContent(_target);
		
		var contener:MovieClip=oTarget.create(TYPE,src);
		_users=contener._users;
		_alpha=contener._alpha;
		_visible=contener._visible;
		contener._visible=false;
		if (_users==0) {
			il=new SWFLoader(contener,undefined,undefined,undefined,LoaderDefine.ALIGNTOP,LoaderDefine.ALIGNLEFT,LoaderDefine.SCALLNONE);
 			il.addEventListener(SWFLoader.ON_LOADINIT,onILInit,this);
			il.load(src,width,height);
		} else {
			_cible=contener;
			_cible._users+=1;
			dispatchReady();
		}
	}
	
	private var _cible:MovieClip;
	public function onILInit(src:SWFLoader,cible:MovieClip){
		cible.stop();
		
		// TODO : controler par code interne au swf
		// onReady(callBack)
		// lire
		// pause
		// reprise
		// onPause(callBack)??
		// onEnd(callBack)
		
		cible._users=_users+1;
		cible._alpha=_alpha;
		cible._visible=_visible;
		cible.controler=this;
		/*
		cible.height=cible._height;
		cible.width=cible._width;
		*/
		_cible=cible;
		dispatchReady();
	}
	
	private function onCFFStop(){
		dispatchEnd(); // fin de lecture de l'animation
	}
	/**
	 * lance la lecture de l'element	 */
	private function _start(){
		_cible._users-=1;
		if (isNaN(startAt)) startAt=_cible._currentframe;
		// controlé par image
		cfb=new ClipByFrame(_cible);
		cfb.addEventListener(ClipByFrame.ON_STOP,onCFFStop,this);
		cfb.addEventListener(ClipByFrame.ON_NEXTFRAME,onFrame,this)
		if (stopAt==-1) stopAt=_cible._totalframes;
		
		dispatchStart();
		if (show==-1) {
			//on_start();
		} else {
			if (startAt!=_cible._currentframe) _cible.gotoAndStop(startAt);
			oTarget.open();
			oTarget.setLegende(legende);
			oTarget.show(src,show,Delegate.create(this, on_start));
		}
	}
	
	private function onFrame(src:ClipByFrame,imgCible:Number,currentFrame:Number){
		
		dispatchAt(currentFrame*24);
	}

	private function on_start(){
		//trace("Pt.sequence.Anim.on_start()"+this.traceInfo);
		if (!isPaused) {
			
			//trace("!isPaused");
			if (cfb.goto(stopAt,startAt)==false) {
				dispatchEnd(); // rien a lire
			}
		}
		
		
	}
	
	
	private function _stop(){
		//trace("Pt.sequence.anim._stop() close"+close+" "+this.traceInfo);
		cfb.stop();
		if (hide!=-1) {
			if (close) oTarget.close();
			oTarget.hide(src,hide,Delegate.create(this, on_stop));
		} else {
			on_stop();
		}
			
	}
	
	private function on_stop(){
		//trace("Pt.sequence.anim.on_stop()");
		if (_cible._users==0 && _cible._visible==false)	oTarget.remove(src);
		
		
	}

	private function destroy(){
		il.destroy();
	}
	
	private function _reprise(){
		cfb.goto(stopAt,Math.max(cfb.getClip()._currentframe,startAt));
		//oTarget.reprise();
	}
	
	private function _pause() {
		if (!isEnd) {
			if (show!=-1) {
			//on_start();
				startAt=Math.max(cfb.stop(),startAt);
			}
			
			//oTarget.pause()
		}
		super._pause();
		
	}

}