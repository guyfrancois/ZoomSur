/**
 * @author Administrator    , pense-tete
 * 26 mars 08
 */
 import org.aswing.EventDispatcher;
/**
 * stocker des données
 */
class Pt.Parsers.DataStk {
		static var DICO:String="DICO";
		static var CHEMIN:String="CHEMIN";
		static var EVENT:String="EVENT";
		static var contextMenuListener:Object=null;
		private var OStk:Object;
		private static var instance : DataStk;
		
		
		/**
		 * @return singleton instance of DataStk
		 */
		public static function getInstance() : DataStk {
			if (instance == null)
				instance = new DataStk();
			return instance;
		}
		
		private function DataStk() {
			OStk=new Object();
		}
		
		
		private function _add(name:String,data:Object) {
			if (OStk[name]!=undefined) trace("Pt.Parsers.DataStk._add("+name+", data) existe déjà" );
			if (data==undefined) trace("Pt.Parsers.DataStk._add("+name+", "+data+") donnée vide");
			OStk[name]=data;
		}
		private function _get(name:String):Object {
			return OStk[name];
		}
		
		public static function add(name:String,data:Object) {
			getInstance()._add(name,data);
		}
		
		public static function val(name:String):Object {
			return getInstance()._get(name);
		}
		
		public function _list():Object{
			for (var i : String in OStk) {
				//trace(" "+i+" "+OStk[i]);
			}
			return OStk;
		}
		
		public static function event():EventDispatcher {
			if (getInstance()._get(EVENT)==undefined) {
				var eventWarp:EventDispatcher=new EventDispatcher();
				DataStk.add("EVENT",eventWarp);
			}
			//trace("Pt.Parsers.DataStk.dico("+terme+")"+val(DICO)[terme][0].text);
			
			return EventDispatcher(getInstance()._get(EVENT));
		}
		
		public static function dico(terme:String):String {
			//trace("Pt.Parsers.DataStk.dico("+terme+")"+val(DICO)[terme][0].text);
			return val(DICO)[terme][0].text==undefined?terme:val(DICO)[terme][0].text;
		}
		
		public static function isDico(terme:String):Boolean {
			//trace("Pt.Parsers.DataStk.dico("+terme+")"+val(DICO)[terme][0].text);
			return val(DICO)[terme][0].text!=undefined;
		}
		
		public static function addChemin(liste:Array) {
			if (val(CHEMIN)==undefined) {
				add(CHEMIN,liste);
			} else {
				getInstance().OStk[CHEMIN]=getInstance().OStk[CHEMIN].concat(liste)
			}
		}
		
		public static function chemin(path:String):String {
			var ret:String=val(CHEMIN)[path][0].href
			if (ret==undefined) {
				//trace("Pt.Parsers.DataStk.chemin("+path+") pas trouvé");
				return path+"/";
			} else {
				return ret;
			}
			//return val(CHEMIN)[path][0].href==undefined?path:val(CHEMIN)[path][0].href;
		}
	}
	
