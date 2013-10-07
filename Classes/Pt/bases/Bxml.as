/**
 * @author GuyF    , pense-tete
 * 4 nov. 2008
 */
import org.aswing.util.HashMap;
import Pt.Parsers.HashXML;

/**
 * 
 */
class Pt.bases.Bxml {

		private var OStk:Object;
		private static var instance : Bxml;
		
		
		/**
		 * @return singleton instance of DataStk
		 */
		public static function getInstance() : Bxml {
			if (instance == null)
				instance = new Bxml();
			return instance;
		}
		
		private function Bxml() {
			OStk=new Object();
		}
		
		
		private function _add(name:String,data:Object) {
			if (OStk[name]!=undefined) trace("Pt.bases.Bxml._add("+name+", data) existe déjà" );
			if (data==undefined) trace("Pt.bases.Bxml._add("+name+", "+data+") donnée vide");
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
		
	
		public static function addBase(name:String,data:Array){
			add(name,new HashXML(data));
		}
	
		private function _getData(path:String) {
			
			var pathArray:Array=path.split("/");
			var baseName=pathArray[0];
			
			var hash:HashMap=OStk[baseName];
			var tmpData=hash.get(pathArray[1]);
			basePath=pathArray[0]+"/"+pathArray[1];
			for (var i : Number = 2; i < pathArray.length; i++) {
				tmpData=tmpData[pathArray[i]]
				if (tmpData instanceof Array) {
					tmpData=tmpData[0];
				}
			}
			if (tmpData==undefined) return "";
			else return tmpData;
		}
		
		private var basePath:String;
		
		private function _setBasePath (path:String) {
			var pathArray:Array=path.split(",")[0].split("/");
			basePath=pathArray[0]+"/"+pathArray[1];
		}
		static public function setBasePath (path:String) {
			if (path!=undefined)	getInstance()._setBasePath(path);
		}
		
		private function _getBasePath ():String {
			return basePath;
		}
		
		static public function getBasePath ():String {
			return getInstance()._getBasePath();
		}
		//
		static public function getData(path:String,lastFullPath:String) {
			var ireplace:Number=path.indexOf("%");
			if (ireplace==-1) {
				
				return getInstance()._getData(path);
			} else if (ireplace==0) {
				if (lastFullPath!=undefined) getInstance().basePath=lastFullPath;
				return getInstance()._getData(getInstance().basePath+path.substring (1))
			}
		}
		
		
		
	
}