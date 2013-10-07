/**
 * @author Administrator    , pense-tete
 * 13 nov. 07
 */
import mx.transitions.Transition;

import mx.transitions.TransitionManager;
import Pt.animate.TransformClip.I_TransParams;

import flash.geom.*;
/**
 * 
 */
class Pt.animate.TransformClip extends Transition {

	public var type:Object = TransformClip;
	public var className:String = "TransformClip";
	
	private var _colorTransform:ColorTransform;
	private var fromColorTrans:ColorTransform;

	private var colorTrans:ColorTransform;
	
	public function TransformClip(content:MovieClip, transParams:I_TransParams, manager:TransitionManager) {
		this.init(content, transParams, manager);
	}

	function init (content:MovieClip, transParams:I_TransParams, manager:TransitionManager):Void {
		super.init (content, transParams, manager);
		var tranf:Transform=new Transform(this._content);
		colorTrans=tranf.colorTransform;
		if (transParams.fromColorTransform==undefined) {
			var tranfb:Transform=new Transform(this._content);
			fromColorTrans=tranf.colorTransform;
		} else {
			fromColorTrans=transParams.fromColorTransform;
		}
		
		this._colorTransform = transParams.colorTransform;
		
	}
	private function lineaire(p:Number,mult:Number,base:Number):Number {
		return (mult-base)*p+base;
	}
	private function _render (p:Number):Void {
		if (p < 0) p = 0;
		var colorTransform:ColorTransform=_colorTransform;
		colorTrans.redMultiplier=lineaire(p,colorTransform.redMultiplier,fromColorTrans.redMultiplier);
		colorTrans.greenMultiplier=lineaire(p,colorTransform.greenMultiplier,fromColorTrans.greenMultiplier);
		colorTrans.blueMultiplier=lineaire(p,colorTransform.blueMultiplier,fromColorTrans.blueMultiplier);
		colorTrans.alphaMultiplier=lineaire(p,colorTransform.alphaMultiplier,fromColorTrans.alphaMultiplier);
		
		colorTrans.redOffset=lineaire(p,colorTransform.redOffset,fromColorTrans.redOffset);
		colorTrans.greenOffset=lineaire(p,colorTransform.greenOffset,fromColorTrans.greenOffset);
		colorTrans.blueOffset=lineaire(p,colorTransform.blueOffset,fromColorTrans.blueOffset);
		colorTrans.alphaOffset=lineaire(p,colorTransform.alphaOffset,fromColorTrans.alphaOffset);
		
		var tranf:Transform=new Transform(this._content);
		tranf.colorTransform = colorTrans;
	
	}


}