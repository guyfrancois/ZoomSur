/**
 * @author GuyF    , pense-tete
 * 7 nov. 2008
 */
/**
 * 
 */
class Pt.Tools.IncrementArray extends Array{
	
	
	
	
	function inc(val:String): Number {
		if (this[val]==undefined) {
			return this[val]=0;
		} else {
			this[val]++;
			return this[val];
		}
	}
	
}