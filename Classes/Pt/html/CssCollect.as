/**
 * @author Administrator    , pense-tete
 * 26 f�vr. 08
 */

/**
 * 
 */
class Pt.html.CssCollect  {
	
	static var cssArray:Array;
	private static  var _instance:CssCollect;
	
	private function CssCollect() {
		super();
		initialise();
	}
	
	static function instance():CssCollect{
		if (_instance==undefined) {
			_instance = new CssCollect();
		}
		return _instance;
		
	}
	
	
	private function initialise(){
		if (cssArray==undefined) {
			cssArray=new Array();
		}
	}
	
	/**
	 * @param stylefile : chemin/nom del la feuille de style
	 * @param callBack : fonction retour  avec  1er param : StyleSheet
	 * loadCss("style.css",Delegate.Create(affectCSS,this);
	 * function affectCSS(css:StyleSheet) {
	 * 	
	 * }	 */
	private function loadCss(file:String,callBack:Function){

		
		var css:TextField.StyleSheet = new TextField.StyleSheet();
	    if (CssCollect.cssArray[file]==undefined) {
        	css = new TextField.StyleSheet();
			css.onLoad  = function(success:Boolean) {
		 		if (success) {
		 			CssCollect.cssArray[file]= css;
          			callBack(css);
     			} else {
     				callBack();
     			}
			}
		    css.load(Pt.Tools.Clips.convertURL(file));
		    
	    } else {
	    	callBack(CssCollect.cssArray[file]);
	    }
		
	}
	
	public static function load(file:String,callBack:Function) {
		instance().loadCss(file,callBack);
	}

}