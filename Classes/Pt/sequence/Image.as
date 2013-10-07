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
import site.DefTYPES;
/**
 *  * Abstract
 * Minimum de fonctionnement d'un élément d'un sequence
 */
 
class Pt.sequence.Image extends Element {
	static var TYPE:String=DefTYPES.IMAGE;
	// parametres de image
	private var _target:String="";
	private var src:String;
	private var show:Number;
	private var hide:Number;
	private var close:Boolean;
	private var legende:String;
	
	
	
	// interne
	private var oTarget:IContent;
	
	private var il:ImageLoader
	
	
	public function Image(dataXML:Object) {
		super(dataXML);
		if (dataXML.target==undefined) {
			_target=DefTargets.SCENE;
		} else {
			_target=dataXML.target;
		}
		
		src=dataXML.src;
		show=Number(dataXML.show);
		if (isNaN(show)) show=DEFAULTHIDE;
		
		close=false;
		if (dataXML.close=="true") {
			hide=DEFAULTHIDE;
			close=true;
		}
		if (dataXML.legende[0].text!=undefined) legende=dataXML.legende[0].text;
		if (!isNaN(dataXML.hide)) hide=Number(dataXML.hide);
		if (_isExclusif==undefined)	_isExclusif=false;
		if (_isParallel==undefined)	_isParallel=false;
	}
	
	private var _users:Number;
	private var _alpha:Number;
	private var _visible:Boolean;
	
	
	public function init(){
		
		oTarget=Controler.getInstance().getContent(_target);
		
		var contener:MovieClip=oTarget.create("image",src);
		_users=contener._users;
		_alpha=contener._alpha;
		_visible=contener._visible;
		if (_users==0) {
		il=new ImageLoader(contener,undefined,undefined,undefined,LoaderDefine.ALIGNTOP,LoaderDefine.ALIGNLEFT,LoaderDefine.SCALLNONE);
 		il.addEventListener(ImageLoader.ON_LOADINIT,onILInit,this);
		il.load(src);
		} else {
			_cible=contener;
			_cible._users+=1;
			dispatchReady();
		}
		
	}
	private var _cible:MovieClip;
	public function onILInit(src:ImageLoader,cible:MovieClip){
		cible._users=_users+1;
		cible._alpha=_alpha;
		cible._visible=_visible;
		cible.controler=this;
		cible.height=cible._height;
		cible.width=cible._width;
		_cible=cible;
		dispatchReady();
	}
	/**
	 * lance la lecture de l'element	 */
	private function _start(){
		trace("Pt.sequence.Image._start()"+this.traceInfo);
		trace("src :"+src)
		dispatchStart();
		_cible._users-=1;
		if (duree==undefined && close) {
			dispatchEnd(); 
			oTarget.close();
			oTarget.hide(src,hide,Delegate.create(this, on_stop));
			return;
		}
		if (show==-1) {
			on_start();
		} else {
			oTarget.open();
			oTarget.setLegende(legende);
			oTarget.show(src,show,Delegate.create(this, on_start));
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
			oTarget.hide(src,hide,Delegate.create(this, on_stop));
		}	
	}
	
	private function on_stop(){
		//trace("Pt.sequence.Image.on_stop()");
		if (_cible._users==0)	oTarget.remove(src);
		
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
	
	public function getName():String{
		return src;
	}

}