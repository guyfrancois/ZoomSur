/**
 * @author Administrator    , pense-tete
 * 14 janv. 08
 */
import GraphicTools.scrollinIt.I_vignettes;
import demoScrollIt.Demo;
import Pt.scan.Souris;
import org.aswing.EventDispatcher;
/**
 * 
 */
class demoScrollIt.Vignette extends EventDispatcher implements I_vignettes {
	private var clip:MovieClip;
	private	var souris:Souris;
	private var id:Number;
	
	public function Vignette(clip:MovieClip,demo:Demo,id) {
		this.clip=clip;
		this.id=id;
		souris=new Souris(clip);
		souris.addEventListener(Souris.ON_MOUSEMOVE,demo.onMouseMoveVignette,demo);
		souris.startScan();
	}

	public function setPos(val:Number) {
		clip._x=val;
	}

	public function getPos():Number{
		return clip._x;
	}

	public function getSize():Number{
		return clip._width;
	}

	public function remove() {
		souris.stopScan();
		clip.removeMovieClip();
	}
	
	public function getId():Number{
		return this.id;
	}

}