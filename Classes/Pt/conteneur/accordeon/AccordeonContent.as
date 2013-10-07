/**
 * @author GuyF    , pense-tete
 * 4 f�vr. 2010
 */
import org.aswing.EventDispatcher;
import Pt.conteneur.I_resizable;
import Pt.Tools.ClipScoller; 

/**
 * 
 */
class Pt.conteneur.accordeon.AccordeonContent extends EventDispatcher implements I_resizable {
	static var scrollType:String="scroller_texte";
	private var ltextScoller:ClipScoller;
	private var clip:MovieClip;
	
	
	public function get y():Number {
		return clip._y;
	}
	
	public function set y(val:Number) {
		clip._y=val;
	}
	public function toString():String {
			return "AccordeonContent "+clip;
	}
	
	public function open(){
		clip.texte._visible=true;
	}
	
	public function scrollTo(pos:Number) {
		ltextScoller.tween(pos);
	}
	
	
		
	public function AccordeonContent(clip:MovieClip) {
		
		this.clip=clip;
		clip.fond.useHandCursor=false;
		clip.fond.onRelease=function(){};
		ltextScoller=new ClipScoller(clip,true,scrollType,0,0);
		ltextScoller.addEventListener(ClipScoller.ON_MOVE,_onScoll,this);		//ltextScoller.ON_MOVE;
	}
	private function _onScoll (src:ClipScoller){
		//trace("_onScoll up");
		SWFAddress.setSequence(site.Appli.CMDPAUSE)
	}

	
	public function getHeight():Number {
		return ltextScoller.getHeight();
		
	}
	public function getWidth():Number {
		return ltextScoller.getWidth();
	}

	public function resize(width:Number, height:Number) {
		//trace("Pt.conteneur.accordeon.AccordeonContent.resize(width, "+height+")"+ltextScoller.getHeight());
		if (height!=ltextScoller.getHeight()) {
			ltextScoller.resize(undefined,height);
		}
	}

}