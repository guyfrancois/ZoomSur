/**
 * @author Administrator    , pense-tete
 * 13 nov. 07
 */

/**
 *  animComment=new CBFReplaceClip(clip.legende,{_x:-630,_y:-60,_xscale:100,_yscale:100,_alpha:100},clip.legende);
 *  
 *  
 *  animComment._render(1-(IMG_OPEN-currentframe)/5)
 *  
 *  animComment._render(1);
 *  
 */
class Pt.animate.CBFReplaceClip  {


	private var final:Object;
	private var initial:Object;
	private var d_final_initial:Object;
	
	private var _content:MovieClip;
	
	
	public function CBFReplaceClip(content:MovieClip, final:Object, initial:Object) {
		this.init(content, final, initial);
	}
	
	private function backUpFinal(oFinal:Object) {
		final=new Object();
		for (var i : String in oFinal) {
			final[i]=oFinal[i];
		}
		
	}

	public function getClip():MovieClip{
		return _content;
	}
	public function getInitial():Object {
		return initial;
	}
	
	public function getFinal():Object {
		return final;
	}
	
	public function update_dfi(){
		for (var i : String in final) {
			d_final_initial[i]=final[i]-initial[i];
			
		}
	}

	private function backUpInitial(oInitial:Object) {
		initial=new Object();
		d_final_initial=new Object();
		for (var i : String in final) {
			initial[i]=(oInitial[i]==undefined)?final[i]:oInitial[i];
			
			d_final_initial[i]=final[i]-oInitial[i];
			
		}
	}


	public function init (content:MovieClip,final:Object, initial:Object):Void {
		
		this._content=content;
		backUpFinal(final);
		backUpInitial(initial);

	}
	
/**
 * @param p : variation de 0 à 1 */
	public function _render (p:Number):Void {
//		//trace("Pt.animate.CBFReplaceClip._render("+p+")");
		if (p < 0) p = 0;
		if (p!=1) {
			for (var i : String in final) {
//				//trace(i);
				this._content[i]=initial[i]+ p* d_final_initial[i];
//			//trace(this._content[i]);
			}
		} else {
			for (var i : String in final) {
//			//trace(i);
				this._content[i]=final[i];
//			//trace(this._content[i]);
			}
		}
	}
	
	



}