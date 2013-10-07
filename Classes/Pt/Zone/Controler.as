/**
 * @author Administrator    , pense-tete
 * 7 avr. 08
 */
import Pt.Zone.IContent;

/**
 * 
 */
class Pt.Zone.Controler {
	private var contentList:Object ; //<IContent >
	

		
		private static var instance : Controler;
		
		/**
		 * @return singleton instance of Controler
		 */
		public static function getInstance() : Controler {
			if (instance == null)
				instance = new Controler();
			return instance;
		}
		
		private function Controler() {
			contentList=new Object();
		}
	
	
	public function addContent(type:String,content:IContent){
		//trace("Pt.Zone.Controler.addContent("+type+", "+content+")");
		if (contentList[type]==undefined) {
			contentList[type]=content;
			content.transfert();
		} else {
			var transfertObject:Object=contentList[type].destroy();
			contentList[type]=content;
			
			content.transfert(transfertObject);
		}
	}
	
	public function getContent(type:String):IContent{
		if (contentList[type]==undefined) trace("ERREUR indefini Pt.Zone.Controler.getContent("+type+")");
		return contentList[type];
	}
	
	public function clear(){
		for (var i : String in contentList) {
			contentList[i].clear();
		}
		
	}
	
	public function clearForEnd(){
		for (var i : String in contentList) {
			contentList[i].removeForEnd();
		}
		
	}
	
	public function setInLoad(){
		for (var i : String in contentList) {
			contentList[i].setInLoad();
		}
		
	}
	public function setInPlay(){
		for (var i : String in contentList) {
			contentList[i].setInPlay();
		}
	}
	
	
}