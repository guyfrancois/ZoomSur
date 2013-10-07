/**
 * @author Administrator    , pense-tete
 * 7 d�c. 07
 */
import org.aswing.util.Delegate;
import org.aswing.util.ObjectUtils;

/**
 * retadre l'extecution de d'appels empillé jusqua callAll
 */
class Pt.Tools.Retardateur {
	var callArr:Array;
	var lock:Boolean;
	
	
	
	public function Retardateur() {
		callArr=new Array();
		lock=true;
	}
	
	public function lockIt(){
		lock=true;
	}
	
	/**
	 * addCall(func:Function);
	 * addCall(func:Function, obj:Object);
	 * addCall(func:Function, obj:Object, args:Array)
	 * 
	 * postponed function call until callAll.
	 *  @param func the function to call after the specified amount of frames
	 *  @param obj (optional) the scope to make a suspended call on. Default is <code>null</code>
	 *  @param args (optional) the arguments array to passed to the called function
	 */
	public function addCall(func:Function):Void {
		var obj:Object = null;
		var args:Array = null;
		var delay:Number = 1;
		
		if (arguments.length == 2) {
			obj = arguments[1];
		} else if (arguments.length == 3) {
			obj = arguments[1];
			args = (arguments[2] instanceof Array) ? arguments[2]: [arguments[2]];
		}
		
		// create a call
		var callF:Function = (obj != null || args != null) ?
		Delegate.createWithArgs(obj, func, args) : func;
		
		// add call to list
		if (lock) {
			callArr.push(callF);
		} else {
			callF();
		}
	}
	
	public function callAll(){
		lock=false;
		while (callArr.length>0) {
			var callF:Function=Function(callArr.shift());
			callF();
		}
	}	
	
}