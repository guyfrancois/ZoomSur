/**
 * @author Administrator    , pense-tete
 * 28 f�vr. 08
 */
/**
 * 
 */
class Pt.Out {
	static function p(msg:String) {
		trace("->"+msg);
	}
	static function h(msg:Object) {
		trace("->"+msg);
	}
	static function hx(msg:Object ) {
		if (Pt.Tools.Clips.getParam("swhx")!="true") return h(msg);
		var rest:Object;
		trace("Pt.Out.hx("+msg+")");
		try {
			rest=swhx.Api.call("backend.lTrace",String(msg));
		} catch (e:Error) {
			p(String(msg));
		}
		
			//p(msg+" ret:"+rest);
		
	}

}