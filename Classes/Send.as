/**
 * @author GuyF    , pense-tete
 * 7 nov. 2008
 */
import  Pt.Parsers.DataStk;
/**
 * 
 */
 
class Send {
		
		public static function event() {
			trace("Pt.Parsers.DataStk.dispatchEvent("+arguments+")");
			if (arguments[0]==undefined) return;
			var args:Array=arguments;
			if (args.length==1) {
				args=arguments[0].split(",");
			}
			//dispatchEvent(ON_ACT,new Event(this,ON_ACT,[param]));
			
			DataStk.event().dispatchEvent(args[0],new  org.aswing.Event(null,args[0],args.slice(1)));	
		}
	
}