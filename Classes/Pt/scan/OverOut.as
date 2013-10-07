/**
 * @author Administrator    , pense-tete
 * 16 janv. 08
 */
import org.aswing.EventDispatcher;
import Pt.scan.Souris;
import org.aswing.Event;

/**
 * 
 */
class Pt.scan.OverOut extends EventDispatcher {
	/**
	 * quand Souris bouge vers dessus
	 * onRollOver(source:OverOut)
	 */	
	public static var ON_ROLLOVER:String = "onRollOver";
	
	/**
	 * quand Souris bouge vers dehors
	 * onRollOut(source:OverOut)
	 */	
	public static var ON_ROLLOUT:String = "onRollOut";
	
	private var clip:MovieClip;
	
	private var souris:Souris;
	
	private var wasOver:Boolean;
	private var sourisListenner:Object;
	
	public function OverOut(clip:MovieClip) {
		super();
		this.clip=clip;
		souris=new Souris(clip);
		sourisListenner=souris.addEventListener(Souris.ON_MOUSEMOVE,_onMouseMove,this);
	}
	
	public function getClip():MovieClip {
		return clip;
	}
	
	private var bforme:Boolean;
	public function startScan(bforme:Boolean){
		this.bforme=bforme;
		souris.startScan();
		if (hasMouseOver()) {
			moveOver();
		} else {
			moveOut()
		}
	}
	
	public function hasMouseOver():Boolean {
		return souris.hasMouseOver(bforme);
	}
	
	public function stopScan(){
		souris.stopScan();
		
	}
	
	
	private function _onMouseMove(src:Souris) {
		
		if (hasMouseOver()) {
			if (!wasOver) {
				moveOver()
			}
		} else {
			if (wasOver) {
				moveOut()
			}
			
		}
	}
	
	
	private function moveOver(){
		wasOver=true;
		//trace("Pt.scan.OverOut.moveOver()");
		dispatchEvent(ON_ROLLOVER,new Event(this,ON_ROLLOVER));
	}
	
	private function moveOut(){
		wasOver=false;
		//trace("Pt.scan.OverOut.moveOut()");
		dispatchEvent(ON_ROLLOUT,new Event(this,ON_ROLLOUT));
	}
	
	public function destroy(){
		souris.stopScan();
		souris.removeEventListener(sourisListenner);
	}

}