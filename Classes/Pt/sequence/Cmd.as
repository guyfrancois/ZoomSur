/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */

import Pt.sequence.Element;
/**
 *  * envoi un evenement à travers l'interface;
 * 
 * 
 * liste des evenements det de leurs parametres :
 * 
 *  SEL_TEXT 
 *  	@param idBloc : bloc à selectionner
 *  	@param idParagraph : paragraph à selectionner
 *  	
 *  	
 */
 
class Pt.sequence.Cmd extends Element {
	
	private var eventToSend:String;
	public function getCmd():String {
		return eventToSend;
	}

	public function Cmd(xmlData:Object) {
		super(xmlData);
		eventToSend=xmlData.send;
		if (_isExclusif==undefined)	_isExclusif=true;
		if (_isParallel==undefined)	_isParallel=false;
	}
	public function init(){
		dispatchReady();
	}
	/**
	 * lance la lecture de l'element	 */
	private function _start(){
		dispatchStart();
		Send.event(eventToSend)
		dispatchEnd();// rien à lire
	}
	
	/** à lancer à la fin de la lecture de l'element : dispatchEnd()*/
	/** à lancer regulièrement au cours de la lecture : dispatchAt(time:Number)*/
}