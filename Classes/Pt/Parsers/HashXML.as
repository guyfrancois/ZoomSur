/**
 * @author GuyF    , pense-tete
 * 4 nov. 2008
 */
import org.aswing.util.HashMap;
/**
 * 
 */
class Pt.Parsers.HashXML extends HashMap {
	
	public function HashXML(xmlDataArray:Array) {
		super();
		if (xmlDataArray!=undefined) {
			fromData(xmlDataArray, "ref");
		}
		
	}
	
	
	public function fromData(xmlDataArray:Array,ref:String) {
		for (var i : Number = 0; i < xmlDataArray.length; i++) {
			put(xmlDataArray[i][ref],xmlDataArray[i]);
		}
		
	}
	
	
	
}