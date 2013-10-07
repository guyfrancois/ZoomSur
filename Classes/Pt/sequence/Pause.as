/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */

import Pt.sequence.Element;
import Pt.Temporise;
import org.aswing.util.Delegate;
/**
 *  * produit une pause pour une durée;
 */
 
class Pt.sequence.Pause extends Element {
	private var pingSpace:Number=1000;
	private var ping:Temporise;
	public function Pause(xmlData:Object) {
		super(xmlData);
		if (_isExclusif==undefined)	_isExclusif=false;
		if (_isParallel==undefined)	_isParallel=false;
	}
	public function init(){
		dispatchReady();
	}
	/**
	 * lance la lecture de l'element	 */
	private function _start(){
		dispatchStart();
		ping=new Temporise(pingSpace,Delegate.create(this, _onPing));
		dispatchEnd();// rien à lire
	}
	
	private function _onPing(src:Temporise,count:Number){
		//trace("Pt.sequence.Pause._onPing(src, count)"+count*pingSpace+" "+traceInfo);
		dispatchAt(count*pingSpace);
	}
	private function _reprise(){
		ping=new Temporise(pingSpace,Delegate.create(this, _onPing));
	}
	/**
	 * met en pause l'element 	 */
	private function _pause(){
		//trace("Pt.sequence.Pause._pause()");
		ping.destroy();
	}
	/**
	 * arrête definitivement l'element	 */
	private function _stop(){
		//trace("Pt.sequence.Pause._stop()");
		dispatchAt(duree);
		ping.destroy();
	}
	/** à lancer à la fin de la lecture de l'element : dispatchEnd()*/
	/** à lancer regulièrement au cours de la lecture : dispatchAt(time:Number)*/
}