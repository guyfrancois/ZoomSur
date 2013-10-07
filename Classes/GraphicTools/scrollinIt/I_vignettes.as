/**
 * @author Administrator    , pense-tete
 * 11 janv. 08
 */
 import org.aswing.IEventDispatcher;
/**
 * 
 */
interface GraphicTools.scrollinIt.I_vignettes extends IEventDispatcher {
	
	public function getId():Number;
	public function setPos(val:Number);
	public function getPos():Number;
	public function getSize():Number;
	public function remove();
	
	

}