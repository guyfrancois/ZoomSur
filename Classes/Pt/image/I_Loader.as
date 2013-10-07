/**
 * @author Administrator    , pense-tete
 * 29 f�vr. 08
 */
import org.aswing.IEventDispatcher;

/**
 * 
 */
interface Pt.image.I_Loader extends IEventDispatcher {
	
	//public function load(path:String,param1,param2);
	public function destroy();
	public function abort();
}