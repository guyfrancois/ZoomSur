/**
 *
 */
import org.aswing.IEventDispatcher;

/**
 *
 */
interface GraphicTools.IMenuObject extends IEventDispatcher {
	public function getBaseHeight():Number ;
	public function calcBaseHeight(NextX:Number) ;
	public function gety():Number ;
	public function getName():String;
	public function getMargeHaute():Number;
	function setPressed(byPress:Boolean);
	function setUnpressed();
	public function isOpen():Boolean;
}