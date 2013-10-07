/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */

import Pt.sequence.Element;
import Pt.Zone.Controler;
import Pt.Zone.IContent;
import site.DefTargets;
import Pt.image.ImageLoader;
import Pt.image.LoaderDefine;
import org.aswing.util.Delegate;
/**
 *  * Abstract
 * Minimum de fonctionnement d'un élément d'un sequence
 */
 
class Pt.sequence.Texte extends Element {
	// parametres de image
	static var TYPE:String=site.DefTYPES.TEXTE;
	private var _target:String="";
	private var show:Number;
	private var hide:Number;
	private var close:Boolean;
	
	private var dataXML:Object; // pour les tags de textes
	
	
	// interne
	private var oTarget:IContent;
	
	private var il:ImageLoader
	
	
	public function Texte(dataXML:Object) {
		super(dataXML);
		if (dataXML.target==undefined) {
			_target=DefTargets.POPUP;
		} else {
			_target=dataXML.target;
		}
		
		this.dataXML=dataXML;
		
		show=Number(dataXML.show);
		if (isNaN(show)) show=DEFAULTHIDE;
		
		close=false;
		if (dataXML.texte[0].text==undefined) {
			hide=DEFAULTHIDE;
			show=-1;
		}
		if (dataXML.close=="true") {
			hide=DEFAULTHIDE;
			close=true;
		}
		
		if (!isNaN(dataXML.hide)) hide=Number(dataXML.hide);
		if (_isExclusif==undefined)	_isExclusif=false;
		if (_isParallel==undefined)	_isParallel=false;
	}
	
	private var _users:Number;
	private var _alpha:Number;
	private var _visible:Boolean;
	
	
	public function init(){
		oTarget=Controler.getInstance().getContent(_target);
	
		dispatchReady();
	}
	/**
	 * lance la lecture de l'element	 */
	private function _start(){
		dispatchStart();
		oTarget.setTexte(dataXML);
		if (duree==undefined && close) {
			dispatchEnd(); 
			oTarget.close();
			oTarget.hide("texte",hide,Delegate.create(this, on_stop));
			return;
		} else if (duree==undefined && dataXML.texte[0].text==undefined) {
			dispatchEnd(); 
			oTarget.hide("texte",hide,Delegate.create(this, on_stop));
			return;
		}
		if (show==-1) {
			on_start();
		} else {
			oTarget.open();
			oTarget.show("texte",show,Delegate.create(this, on_start));
		}
	}

	private function on_start(){
		//trace("Pt.sequence.Image.on_start()");
		dispatchEnd(); // rien a lire
		
	}
	
	
	private function _stop(){
		//trace("Pt.sequence.image._stop() close"+close+" "+this.traceInfo);
		if (duree!=undefined) {
			if (close) oTarget.close();
			oTarget.hide("texte",hide,Delegate.create(this, on_stop));
		}	
	}
	
	private function on_stop(){
		//trace("Pt.sequence.Image.on_stop()");
//		if (_cible._users==1)	oTarget.remove(src);
		
	}

	private function destroy(){
		il.destroy();
	}
	
	private function _reprise(){
		//oTarget.reprise();
	}
	
	private function _pause() {
		if (!isEnd) {
			//oTarget.pause()
		}
		super._pause();
		
	}

}