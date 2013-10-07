/**
 * @author GuyF , pense-tete.com
 * @date 6 nov. 07
 * 
 */
import org.aswing.util.Delegate;
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.Temporise;

/**
 *
 */
class Pt.animate.ClipByFrame extends EventDispatcher {
	/**
	 * en fin d'animation
	 * @param image : image d'arrêt;
	 * onStop(source:ClipByFrame,image)
	 */	
	public static var ON_STOP:String = "onStop";
	/**
	 * quand on lit l'image precedente
	 * onPrevFrame(source:ClipByFrame,image,clip._currentframe)
	 */	
	public static var ON_PREVFRAME:String = "onPrevFrame";
	/**
	 * quand on lit l'image suivante
	 * onNextFrame(source:ClipByFrame,image,clip._currentframe)
	 */	
	public static var ON_NEXTFRAME:String = "onNextFrame";
	
	
	private var clip:MovieClip
	public function ClipByFrame(clip:MovieClip) {
		super();
		this.clip=clip;
	}
	
	public function isSetTo(image):Boolean {
		return (clip._currentframe==image)
	}
	
	
	/**
	 * positionne la tete de lecture à l'image
	 * l'evenement onStop sera lancé à t+1 frame
	 * @param image de destination
	 * @return true si une navigation est lancée, false si l'animation est déja sur l'image ou vide
	 */
	public function setTo(image:Number):Boolean{
		if (clip==undefined) {
			return false;
		}
		var locRef:ClipByFrame = this;
		if (clip.onEnterFrame!=undefined) {
			delete clip.onEnterFrame;
		}
		if (clip._currentframe!=image) {
			clip.gotoAndStop(image);
			clip.onEnterFrame = function (){
				locRef.__set(image);
			}
			return true
		} else {
			return false
		}
	}
	
	public function stop():Number{
		if (clip.onEnterFrame!=undefined) {
			delete clip.onEnterFrame;
		}
		return clip._currentframe;
	}
	/**
	 * demande une navigation vers une image
	 * @param index de l'image
	 * @return true si une navigation est lancée, false si l'animation est déja sur l'image
	 */
	
	public function goto(image:Number,fromImage:Number):Boolean{
		traceLoc("Pt.animate.ClipByFrame.goto("+image+", "+fromImage+")"+clip);
		if (clip==undefined) {
			return false;
		}
		if (clip.onEnterFrame!=undefined) {
			delete clip.onEnterFrame;
		}
		if (fromImage!=undefined && fromImage!=clip._currentframe) {
			clip.gotoAndStop(fromImage)	;
			//var tp:Temporise=new Temporise(100,Delegate.create(this,goto,image),true);
			//return true;
			
		} else {
			fromImage=clip._currentframe;
		}
		
		traceLoc("Pt.animate.ClipByFrame.goto("+image+")"+clip._currentframe+" fromImage:"+fromImage+" "+(clip._currentframe>image)+"");
		if (fromImage>image) {
			rewind(Math.min(image,clip._totalframes));
			return true;
		} else if (fromImage<image) {
			forward(Math.min(image,clip._totalframes));
			return true;
		} else {
			return false;
		}
		
	}
	
	private function rewindFrom(){
		
	}
	private function forwardFrom(){
		
	}
	
	private function rewind(image:Number){
		var locRef:ClipByFrame = this;
	    clip.onEnterFrame = function (){
			locRef.__rewinding(image);
		}
	}
	
	
	function __set(image:Number){
			delete clip.onEnterFrame;
			dispatchEvent(ON_STOP,new Event(this,ON_STOP,[image]));
	
	}
	function __rewinding(image:Number){
		traceLoc("Pt.animate.ClipByFrame.__rewinding("+image+")"+clip._currentframe);
		//if (clip._currentframe>image) {
			clip.prevFrame();
			
			dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME,[image,clip._currentframe]));
			
		if (clip._currentframe==image) {
			delete clip.onEnterFrame;
			dispatchEvent(ON_STOP,new Event(this,ON_STOP,[image]));
		}
		//updateAfterEvent();
	}
	
	private function forward(image:Number) {
		traceLoc("Pt.animate.ClipByFrame.forward("+image+")");
		var locRef:ClipByFrame = this;
	    clip.onEnterFrame = function (){
			locRef.__forwarding(image);
		}
	}
	
	function __forwarding(image:Number){
		traceLoc("Pt.animate.ClipByFrame.__forwarding("+image+")"+clip._currentframe);
		//if (clip._currentframe<image) {
		
			clip.nextFrame();
			
			dispatchEvent(ON_NEXTFRAME,new Event(this,ON_NEXTFRAME,[image,clip._currentframe]));
		traceLoc("updateAfterEvent Pt.animate.ClipByFrame.__forwarding("+image+")"+clip._currentframe);
		//} else {
		if (clip._currentframe>=image)	{
			delete clip.onEnterFrame;
			//trace("delete clip.onEnterFrame");
			dispatchEvent(ON_STOP,new Event(this,ON_STOP,[image]));
		}
		//updateAfterEvent();
	}
    function getClip():MovieClip {
    	return clip;
    }
    
    private function traceLoc(val) {
    	//trace(val);
    }
    
    static function create(clip:MovieClip):ClipByFrame {
    	return new ClipByFrame(clip);
    }
    
    static function delegateCreate(clip:MovieClip):Function {
    	var cfb:ClipByFrame=new ClipByFrame(clip);
    	return Delegate.create(cfb, cfb.goto);
    }
}