/**
 * @author Administrator    , pense-tete
 * 5 ao�t 08
 */
/**
 * 
 */
import flash.external.ExternalInterface;


class swhx.Api {
	private static var me = null;
	private static var base: Object;

	private function Api(base: Object) {
		if (Pt.Tools.Clips.getParam("swhx")!="true") return ;
		Api.base = base;
		ExternalInterface.addCallback("swhxCall",null,doCall);
		if( ExternalInterface.call(":connect","") != "ok" )
			trace("This SWF requires Screenweaver HX to run properly");
		
	}

	static private function doCall(funpath: String, argstr: String) {
		if (Pt.Tools.Clips.getParam("swhx")!="true") return null;
		var fun: Object = resolvePath(funpath, base);
		if (fun) {
			var args = swhx.Deserializer.run(argstr);
			return swhx.Serializer.run(fun.fun.apply(fun.obj, args));
		} else {
			return "x"+swhx.Serializer.run(funpath+": Failed to resolve.");
		}
	}
	
	

	static public function resolvePath(path: String, obj: Object): Object {
		with (obj) {
			return { fun: eval(path), obj: obj};
		}
	}

	static public function init(base: Object): Api {
		if (Pt.Tools.Clips.getParam("swhx")!="true") return null;
		trace("swhx.Api.init(base)");
		if (me)
			return me;
		else
			return me = new Api(base);
		
	}

	static public function call() {
		if (Pt.Tools.Clips.getParam("swhx")!="true") return null;
		var path = arguments.shift();
		var args = escapeString(swhx.Serializer.run(arguments));
		var result = ExternalInterface.call(String(path),args);
		return swhx.Deserializer.run(String(result));
	}
	
	static private function escapeString(str: String): String {
		return str.split("\\").join("\\\\").split("&").join("&amp;");
	}
}