/**
 * @author Administrator    , pense-tete
 * 16 janv. 08
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import org.aswing.geom.Point;

/**
 * 
 */
class Pt.scan.Souris extends EventDispatcher {
	/**
	 * quand Souris bouge
	 * @param dx : deplacement en x
	 * @param dy : deplacement en y
	 * onMouseMove(source:Souris,dx:Number,dy:Number)
	 */	
	public static var ON_MOUSEMOVE:String = "onMouseMove";
	
	/**
	 * quand souris pressée
	 * onMouseDown(source:Souris)
	 */	
	public static var ON_MOUSEDOWN:String = "onMouseDown";
	
	 /**
	 * quand souris lachée
	 * onMouseUp(source:Souris)
	 */	
	public static var ON_MOUSEUP:String = "onMouseUp";
	
	/**
	 * quand molette souris tournée
	 * onMouseWheel(source:Souris,delta:Number)
	 */	
	public static var ON_MOUSEWHEEL:String = "onMouseWheel";
	
	
	
	private var clip:MovieClip;
	
	private var lastMousePos:Point;
	
	private var lastdMouse:Point;
	
	private var _listenning:Boolean;
	
	public function Souris(clip:MovieClip) {
		super();
		//trace("Pt.scan.Souris.Souris(clip)");
		this.clip=clip;
		_listenning=false;
	}
	
	public function getClip():MovieClip {
		return clip;
	}
	
	public function startScan(){
		initMouseL()
	}
	
	public function stopScan(){
		removeMouseL();
	}
	
	public function destroy(){
		//trace("Pt.scan.Souris.destroy()");
		listeners=new Array();
	}
	
	
	private function initMouseL(){
		if (_listenning) return;
		_listenning=true;
		lastMousePos=getMousePos();
		Mouse.addListener(this);
	}
	
	private function removeMouseL(){
		if (!_listenning) return;
		_listenning=false;
		Mouse.removeListener(this);
	}
	
	public function getDPoint():Point {
		
		return lastdMouse;
		
	}
	
	private var _isDown:Boolean=false;
	public function get isDown():Boolean {
		return _isDown;
	}
	
	public function onMouseMove	(){
	
		var MousePos:Point=getMousePos();
		lastdMouse=MousePos.substract(lastMousePos);
		lastMousePos=MousePos;
		dispatchEvent(ON_MOUSEMOVE,new Event(this,ON_MOUSEMOVE,[lastdMouse.x,lastdMouse.y]));
	}
	
	public function onMouseDown(){
		_isDown=true;
		dispatchEvent(ON_MOUSEDOWN,new Event(this,ON_MOUSEDOWN));
	}
	public function onMouseUp(){
		_isDown=false;
		dispatchEvent(ON_MOUSEUP,new Event(this,ON_MOUSEUP));
	}
	
	/**
	 * @param delta:Number [facultatif] - Nombre indiquant combien de lignes il convient de faire défiler chaque fois que l'utilisateur fait tourner la molette de la souris. Une valeur delta positive indique un défilement vers le haut ; une valeur négative indique un défilement vers le bas. Les valeurs types sont comprises entre 1 et 3 ; un défilement plus rapide peut générer des valeurs supérieures.
	 * @param scrollTarget:String [facultatif] - Paramètre indiquant l'occurrence de clip supérieure située sous le pointeur de la souris lorsque la molette est actionnée. Si vous souhaitez spécifier une valeur pour scrollTarget uniquement, mais pas pour delta, transmettez la valeur null à delta.
	 * 	 */
	public function onMouseWheel (delta:Number,scrollTarget:String){
		//trace("Pt.scan.Souris.onMouseWheel("+delta+","+scrollTarget+", )");
		dispatchEvent(ON_MOUSEWHEEL,new Event(this,ON_MOUSEWHEEL,[delta,scrollTarget]));
	}
	
	/**
	 * @return true si la souris survol le clip	 */
	public function hasMouseOver(bForme:Boolean):Boolean {
		
		var pos:Point=getMousePos();
		var p:MovieClip=clip._parent;
		p.localToGlobal(pos);
		return clip.hitTest(pos.x,pos.y, bForme);
	}
	
	public function getMousePos():Point {
		return new Point(clip._parent._xmouse, clip._parent._ymouse);
	}
	
	static function hitTF(tf:TextField) :Boolean {
		return (tf._xmouse<tf._width && tf._ymouse<tf._height && tf._xmouse>0 && tf._ymouse>0);
	}


}