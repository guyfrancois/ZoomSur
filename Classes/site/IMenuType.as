/**
 * @author Administrator    , pense-tete
 * 28 mars 08
 */
import org.aswing.IEventDispatcher;
/**
 * 
 */
interface site.IMenuType extends IEventDispatcher{
	
	
		public function initialise();
		public function select(idMenu:Number,idBtn:Number,action:Boolean);
		public function destroy();
	
}