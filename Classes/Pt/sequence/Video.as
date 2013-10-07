/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */

import Pt.sequence.Element;
import Pt.Temporise;
import Pt.Zone.Controler;
import Pt.Zone.IContent;
import site.DefTargets;
import org.aswing.util.Delegate;
import media.FluxVideo;
import site.DefTYPES;
import caurina.transitions.Tweener;
/**
 * 
 * produit une pause pour une durée;
 * 
 * 
 * 
 * 
 * video problematique si suivie
 */
 //TODO : gere un resynchro si element synchonisé avec la vidéo (type son)
class Pt.sequence.Video extends Element {
	private var traceInfo:String="Video";  
	static var TYPE:String=DefTYPES.VIDEO;
	private var src:String;
	private var _target:String="";
	private var flux:FluxVideo;
	
	private var show:Number;
	private var hide:Number;
	private var close:Boolean;
	private var legende:String;

	private var oTarget:IContent;
	
	private var _cible:MovieClip;
	
	
	private var fluxListenner:Object;
	/*
	private var onEndListener:Object;
	private var onUpdatelistener:Object;
	*/
	
	private var volumeArray:Array;
	public function Video(dataXML:Object) {
		super(dataXML);
		
		if (dataXML.target==undefined) {
			_target=DefTargets.POPUP;
		} else {
			_target=dataXML.target;
		}
		
		
		hide=-1;
		src=dataXML.src;
		show=Number(dataXML.show);
		if (isNaN(show)) show=DEFAULTHIDE;
		
		close=false;
		if (dataXML.close=="true") {
			hide=DEFAULTHIDE;
			close=true;
		}
		volumeArray=dataXML.volume;
		if (dataXML.legende[0].text!=undefined) legende=dataXML.legende[0].text;
		if (!isNaN(dataXML.hide)) hide=Number(dataXML.hide);
		if (_isExclusif==undefined)	_isExclusif=true;
		if (_isParallel==undefined)	_isParallel=false;
	}
	
	
	
	
	public function init(){
		oTarget=Controler.getInstance().getContent(_target);
		
		_cible=oTarget.create(TYPE,src);
		_cible._users+=1;
		if (_cible.controler==undefined) {
			if (_target!=DefTargets.POPUP) {
				flux=new FluxVideo(true,_cible,DefTargets.FOND_VIDEO_SIZE.x,DefTargets.FOND_VIDEO_SIZE.y,FluxVideo.ALIGNCENTER,FluxVideo.ALIGNCENTER,FluxVideo.SCALLNONE);
			} else {
				flux=new FluxVideo(true,_cible);
			}
			
			_cible.controler=this;
		} else {
			flux=_cible.controler.getFluxPlayer();
		}
		
		dispatchReady();
	}
	
	
	private function removeListeners(){
		flux.removeEventListener(fluxListenner);
	}
	
	public function getFluxPlayer():FluxVideo {
		return flux;
	}
	
	/**
	 * lance la lecture de l'element
	 */
	 
	private function _start(){
		_cible._users-=1;
		
		if (_cible.controler.name!=src) {
			_cible.controler.name=src;
			//trace("Pt.sequence.Video._start() flux.clear()");
			flux.clear();
			dispatchStart();
			if (show==-1) {
				//on_start();
			} else {
				oTarget.open();
				oTarget.setLegende(legende);
				// TODO : initialisation de la legende pour une video
				site.targets.Fond.s_updatelegende(Pt.Tools.Clips.convertCheminToRef(src));
				oTarget.show(TYPE,show,Delegate.create(this, on_start));
			}
		} else {
			_isEnd=true;
			onEnd();
			
		}
		
		
	}
	
	private function on_start(){
		//trace("Pt.sequence.Video.on_start()"+this.traceInfo);
		if (!isPaused) {
			fluxListenner=new Object();
			fluxListenner[FluxVideo.ON_END]=Delegate.create(this,onEnd);
			fluxListenner[FluxVideo.ON_UPDATE]=Delegate.create(this,onAt);
			fluxListenner[FluxVideo.ON_PAUSE]=Delegate.create(this,onPause);
			fluxListenner[FluxVideo.ON_PLAY]=Delegate.create(this,onPlay);
			//fluxListenner[FluxVideo.ON_STOP]=Delegate.create(this,onFluxStop);
			
			flux.addEventListener(fluxListenner);
			flux.start(src);
			if (volumeArray!=undefined) {
				for (var i : Number = 0; i < volumeArray.length; i++) {
					var valParam:Object=volumeArray[i];
					var at:Number=isNaN(valParam.at)?0:Number(valParam.at/1000);
					/*
					if (at<0) {
						trace("flux.duration()"+flux.duration())
						at=flux.duration()+at;
					}
					*/
					var obj:Object;
					Tweener.addTween(flux.getSon(),obj={
						delay:at,
						_sound_volume:isNaN(valParam.set)?100:Number(valParam.set) ,
						time:isNaN(valParam.time)?0:Number(valParam.time/1000)
						 }
					);
					trace("twobj : delay "+obj.delay+" _sound_volume "+obj._sound_volume+" time "+obj.time);
					
				}
			}
		}
	}
	private function recallTween() {
		Tweener.removeTweens(flux.getSon());
		var pos:Number=flux.position()==undefined?0:flux.position();
		trace("recallTween at"+pos)
		if (volumeArray!=undefined) {
				for (var i : Number = 0; i < volumeArray.length; i++) {
					var valParam:Object=volumeArray[i];
					var at:Number=isNaN(valParam.at)?0:Number(valParam.at/1000);
					var __sound_volume:Number=isNaN(valParam.set)?100:Number(valParam.set);
					var time:Number=isNaN(valParam.time)?0:Number(valParam.time/1000);
					at=at-pos;
					if (at<0) {
						if (time+at<pos) {
							time=0
						} else {
							time=time+at-pos
						}
						at=0;
					}
					/*
					if (at<0) {
						trace("flux.duration()"+flux.duration())
						at=flux.duration()+at;
					}
					*/
					var obj:Object;
					Tweener.addTween(flux.getSon(),obj={
						delay:at,
						_sound_volume:__sound_volume ,
						time:time
						 }
					);
					trace("twobj : delay "+obj.delay+" _sound_volume "+obj._sound_volume+" time "+obj.time);
					
				}
			}
	}
	
	private function onFluxStop(){
		
	}
	private function onAt(){
		
	//	trace("video onAt");
		
		
		dispatchAt(flux.position()*1000);
	}
	
	private function onEnd(){
		//trace("Pt.sequence.Video.onEnd()"+flux.position()+" "+flux.duration()+" "+(flux.position()==flux.duration()));
		//if (flux.position()==flux.duration()) { 
			dispatchEnd();
		//}
		
	}
	private function _reprise(){
		if (flux==undefined) {
			on_start();
		} else {
			trace(pausePos+"->"+flux.position());
			if (pausePos!=flux.position()) {
				Tweener.removeTweens(flux.getSon());
				recallTween();
			} else {
				Tweener.resumeTweens(flux.getSon());
			}
			flux.play();
		}
	}
	/**
	 * met en pause l'element 
	 */
	 private var pausePos:Number=0;
	private function _pause(){
		pausePos=flux.position();
		Tweener.pauseTweens(flux.getSon());
		flux.pause();
	}
	/**
	 * arrête definitivement l'element
	 */

	private function _stop(){
		//trace("Pt.sequence.Video._stop() close"+close+" "+this.traceInfo);
		//trace("_isEnd : "+_isEnd)
		//flux.destroy();
		
		if (!_isEnd) {
			Tweener.removeTweens(flux.getSon());
			flux.destroy();	
			_cible.controler=undefined;
		}
		
		if (hide!=-1) {
			if (close) oTarget.close();
			oTarget.hide(TYPE,hide,Delegate.create(this, on_stop));
		} else {
			on_stop();
		}
	}
	
	private function on_stop(){
		Tweener.removeTweens(flux.getSon());
		removeListeners();
		flux.stop();
		//trace("Pt.sequence.Video.on_stop()");
		if (_cible._users==0 && hide!=-1)	{
			oTarget.remove(TYPE);	
			
		}
		
	}
	/** à lancer à la fin du chargement : dispatchReady()*/
	/** à lancer à la fin de la lecture de l'element : dispatchEnd()*/
	/** à lancer regulièrement au cours de la lecture : dispatchAt(time:Number)*/
	public function destroy(){
		//trace("Pt.sequence.Video.destroy()");
		_cible.controler=undefined
		flux.destroy();
	}
	
	public var name:String;
	public function getName():String{
		return name;
	}
	/** Evenement issus du contenu */
	private function onPause(){
		//trace("Pt.sequence.Video.onPause()");
		//SWFAddress.setSequence(site.Appli.CMDPAUSE)
		dispatchPause()
	}
	private function onPlay(){
		//trace("Pt.sequence.Video.onPlay()");
		dispatchPlay()
		
	}
	
}