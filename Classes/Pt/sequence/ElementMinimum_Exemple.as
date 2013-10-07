/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */

import Pt.sequence.Element;
/**
 *  * Abstract
 * Minimum de fonctionnement d'un élément d'un sequence
 */

class Pt.sequence.ElementMinimum_Exemple extends Element {
	public function ElementMinimum_Exemple(dataXML:Object) {
		super(dataXML);
	}
	public function init(){
		//trace("A DEFINIR : Pt.sequence.Element.init()");
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
	private function _pause(){
		//trace("A DEFINIR : Pt.sequence.Element._pause()");
	}
	/**
	 * arrête definitivement l'element	 */
	private function _stop(){
		//trace("A DEFINIR : Pt.sequence.Element._stop()");
	}
	/** à lancer au lancement : dispatchStart();
	/** à lancer à la fin du chargement : dispatchReady()*/
	/** à lancer à la fin de la lecture de l'element : dispatchEnd()*/
	/** à lancer regulièrement au cours de la lecture : dispatchAt(time:Number)*/
}