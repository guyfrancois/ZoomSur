/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */

import Pt.sequence.Element;
import Pt.Temporise;
import org.aswing.util.Delegate;
import media.FluxAudio;
import caurina.transitions.Tweener;
/**
 *  * produit une pause pour une durée;
 */
 
class Pt.sequence.Son extends Element {
	static var TYPE:String=site.DefTYPES.SON;
	private var src:String;
	private var fluxAudio:FluxAudio;
	private var volumeArray:Array;
	
	
	

	public function Son(dataXML:Object) {
		super(dataXML);
		src=dataXML.src;
		volumeArray=dataXML.volume;
		
		
		
		if (_isExclusif==undefined)	_isExclusif=true;
		if (_isParallel==undefined)	_isParallel=true;
	}
	public function init(){
		dispatchReady();
	}
	/**
	 * lance la lecture de l'element
	 */
	private function _start(){
		fluxAudio=new FluxAudio(src,true,_offset);
		fluxAudio.addEventListener(FluxAudio.ON_STOP,onEnd,this);
		fluxAudio.addEventListener(FluxAudio.ON_UPDATE,onAt,this);
		dispatchStart();
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
				/*	Tweener.addTween(fluxAudio.getSon(),obj={
						delay:at,
						_sound_volume:isNaN(valParam.set)?100:Number(valParam.set) ,
						time:isNaN(valParam.time)?0:Number(valParam.time/1000)
						 }
					);*/
					trace("twobj : delay "+obj.delay+" _sound_volume "+obj._sound_volume+" time "+obj.time);
					
				}
			}
		
	}
	
	private function onAt(){
		dispatchAt(fluxAudio.position()*1000);
	}
	
	private function onEnd(){
		
		dispatchEnd();
	}
	private function _reprise(){
		fluxAudio.offset=_offset;
		fluxAudio.play();
	
		//Tweener.resumeTweens(fluxAudio.getSon());
	}
	/**
	 * met en pause l'element 
	 */
	private function _pause(){
		fluxAudio.pause();
		
		_offset=fluxAudio.position();
		//Tweener.pauseTweens(fluxAudio.getSon());
	}
	/**
	 * arrête definitivement l'element
	 */
	private function _stop(){
		//trace("Pt.sequence.Son._stop()");
		fluxAudio.destroy();
		//Tweener.removeTweens(fluxAudio.getSon());
	}
	/** à lancer à la fin du chargement : dispatchReady()*/
	/** à lancer à la fin de la lecture de l'element : dispatchEnd()*/
	/** à lancer regulièrement au cours de la lecture : dispatchAt(time:Number)*/

	

}