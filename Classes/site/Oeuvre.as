/**
 * @author Administrator    , pense-tete
 * 27 mars 08
 */

/**
 * 
 */
class site.Oeuvre {
	private var clip:MovieClip
	
	public function Oeuvre(clip:MovieClip) {
		//trace("site.Oeuvre.Oeuvre("+clip+")");
		this.clip=clip;
		this.clip._visible=false;
	}
	
	public function open(){
		this.clip._visible=true;
		
	}
	public function close(){
		this.clip._visible=false;
		
	}
}