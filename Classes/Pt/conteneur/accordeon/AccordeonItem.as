/**
 * @author GuyF    , pense-tete
 * 4 f�vr. 2010
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.conteneur.I_resizable;
import Pt.conteneur.accordeon.AccordeonContent;
import Pt.conteneur.accordeon.HeaderAccordeon;

/**
 * 
 */
class Pt.conteneur.accordeon.AccordeonItem extends EventDispatcher implements I_resizable {
	private var clip:MovieClip;
	public var isOpen : Boolean =false;
	public var header:HeaderAccordeon;
	public var content:AccordeonContent;
	private var _height:Number;
	
	public function toString():String {
		return "Pt.conteneur.accordeon.AccordeonItem "+clip;
	}
	public function AccordeonItem(clip:MovieClip,header:HeaderAccordeon,content:AccordeonContent) {
		this.clip=clip;
		this.header=header;
		this.content=content;
		content.y=header.getHeight();
		_init();
		
	}
	
	public function get y():Number {
		return clip._y
	}
	public function set y(val:Number) {
		clip._y=val;
	}
	
	private function _init(){
			header.close();
			header.addEventListener(HeaderAccordeon.ON_CHANGE,_select,this) ;
			//content.y=header.height;
			isOpen=false;
	
	}
	
	public function open(){
			_open();
		}
		
		private function _open(){
			isOpen=true;
			header.open();
			content.open();
			
			//addChild(content);
			resize(0,_height);
			
		}
		
		private function _close(){
			if (isOpen) {
				isOpen=false;
				header.close();
				//content.close();
			}
			
		}
		
		public function close(){
			_close();
		}
	

	public function getHeight():Number{
		//trace(this+" .getHeight():");
		//trace("isOpen :"+isOpen+" "+_height+" "+header.getHeight());
		
		return isOpen?_height:header.getHeight();
	}

	public function getWidth():Number{
		return null;
	}

	public function resize(width:Number, height:Number) {
		_height=height;
		content.resize(width,height-header.getHeight());

	}
	// EVENEMENTS //
	private function _select(src:HeaderAccordeon) {
		//trace("Pt.conteneur.accordeon.AccordeonItem._select("+src+")");
		dispatchEvent(HeaderAccordeon.ON_CHANGE,new Event(this,HeaderAccordeon.ON_CHANGE));
	}
		

}