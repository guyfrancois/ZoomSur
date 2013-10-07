/**
 * @author Administrator    , pense-tete
 * 13 nov. 07
 */
import mx.transitions.Transition;

import mx.transitions.TransitionManager;
/**
 * 
 */
class Pt.animate.ReplaceClip extends Transition {

	public var type:Object = ReplaceClip;
	public var className:String = "ReplaceClip";
	
	private var _xscaleFinal:Number;
	private var _yscaleFinal:Number;
	private var _xscaleInitial:Number;
	private var _yscaleInitial:Number;
	
	private var _xFinal:Number;
	private var _yFinal:Number;
	private var _xInitial:Number;
	private var _yInitial:Number;
	
	private var d_x:Number;
	private var d_y:Number;
	private var d_xscale:Number;
	private var d_yscale:Number;
	
	
	public function ReplaceClip(content:MovieClip, transParams:Object, manager:TransitionManager) {
		this.init(content, transParams, manager);
	}

	function init (content:MovieClip, transParams:MovieClip, manager:TransitionManager):Void {
		trace ("Zoom.init()");
		super.init (content, transParams, manager);
		this._xscaleFinal = transParams._xscale;
		this._yscaleFinal = transParams._yscale;
		this._xFinal = transParams._x;
		this._yFinal = transParams._y;
		
		this._xscaleInitial = MovieClip(this.manager.contentAppearance)._xscale;
		this._yscaleInitial = this.manager.contentAppearance._yscale;
		
		this._xInitial = this.manager.contentAppearance._x;
		this._yInitial = this.manager.contentAppearance._y;
		
		this.d_x = this._xFinal- this._xInitial;
		this.d_y = this._yFinal- this._yInitial;
		this.d_xscale =this._xscaleFinal- this._xscaleInitial;
		this.d_yscale = this._yscaleFinal- this._yscaleInitial;
	}
	
	private function _render (p:Number):Void {
		if (p < 0) p = 0;
		if (p!=1) {
			this._content._xscale = this._xscaleInitial+p * this.d_xscale;
			this._content._yscale = this._yscaleInitial+p * this.d_yscale;
			this._content._x  = this._xInitial+p * this.d_x;
			this._content._y  = this._yInitial+p * this.d_y;
		} else {
			this._content._xscale = this._xscaleFinal ;
			this._content._yscale = this._yscaleFinal;
			this._content._x  = this._xFinal;
			this._content._y  = this._yFinal;
		}
	}
	
	
	public function abort(){
	//	this._twn.fforward();
		this.removeEventListener ("transitionInDone", this._manager);
		this.removeEventListener ("transitionOutDone", this._manager);
		this.removeEventListener ("transitionProgress", this._manager);
		this._twn.stop();
	
	}


}