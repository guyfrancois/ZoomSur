/**
 * @author GuyF , pense-tete.com
 * @date 10 mai 07
 * 
 */
 import org.aswing.util.SuspendedCall;
import  org.aswing.util.ArrayUtils;
import Pt.Tools.ClipEvent;
import org.aswing.Event;
import org.aswing.EventDispatcher;  


import com.asual.swfaddress.*;

class Pt.Navigator extends EventDispatcher {	
	
	static var ON_ACCUEIL:String="onAccueil";
	
	static var ON_RUBRIQUE:String="onRubrique";
	static var ON_PAROLES:String="onParoles";
	static var ON_REPERE:String="onRepere";
	static var ON_ZOOM:String="onZoom";
	static var ON_SOURCES:String="onSources";
	static var ON_VIDEO:String="onVideo";
	
	static var ON_CLOSE_ZOOMVIDEO:String="onCloseZoomVideo";
	
	
	
	/**
	 * Reference vers les adresses de contenu
	 */
	 //static var ACCUEIL:Number;
	 static var RUBRIQUE:Number=0;
	 static var REPERE:Number=1;
	 static var ZOOM:Number=2;
	 static var VIDEO:Number=2;
	 static var SOURCES:Number=3;
	 
	 static var maxRefLength:Number=4;


/**
  * arrAdd : tableau de l'addresse
  * 0 : RUBRIQUE 
  *     PARCOURS
  *     
  * 1 : REPERE
  *     
  *      
  *  2 : ZOOM / VIDEO
  *  
  *  
  */
    
    private var arrAdd:Array;
    
    private var cloneArrAdd:Array;
    	
	private static var instance : Navigator;
	

		
		/**
		 * @return singleton instance of Navigator
		 */
	public static function getInstance() : Navigator {
		if (instance == null)
			instance = new Navigator();
		return instance;
	}
	
	
	private function Navigator() {
		super();
		//SuspendedCall.createCall(_initialize,this,1);
		_initialize();
		
	}
	
	private var tagList:Array;
	private	function _initialize():Boolean{
		tagList=_root._tags.split(",");
		_root.tagList=tagList;
		cloneArrAdd=new Array();
        arrAdd=new Array();
        for (var i : Number = 0; i < maxRefLength; i++) {
            cloneArrAdd[i]=arrAdd[i]="";
        }
        SWFAddress.addEventListener(SWFAddressEvent.CHANGE, delegate(this, handleChange));
        return true;
    }
    
    public function handleChange(e:SWFAddressEvent):Void {
    	// e.value
    	/*
        _mc.home_mc.label_txt.textColor = (e.value == '/') ? 0xCCCCCC : 0xFFFFFF;
        _mc.about_mc.label_txt.textColor = (e.value == '/about/') ? 0xCCCCCC : 0xFFFFFF;
        _mc.contact_mc.label_txt.textColor = (e.value == '/contact/') ? 0xCCCCCC : 0xFFFFFF;

        var title = 'SWFAddress Website';
        for (var i = 0; i < e.pathNames.length; i++) {
            title += ' / ' + e.pathNames[i].substr(0,1).toUpperCase() + e.pathNames[i].substr(1);
        }
        SWFAddress.setTitle(title);
        */
        
           var addr:String = e.value;
        	var tmpNav:String;
            Pt.Out.hx("addr"+addr);
            if (addr.substr(addr.length - 1, 1) == '/') {
                setArrAdd(addr);
                 _onRubrique(getRubique(),cloneArrAdd);
                 _onRepere(getRepere(),cloneArrAdd);
  //              _onZoom(getZoom(),cloneArrAdd);
  //               _onSource(getSource(),cloneArrAdd);
            } else {
                setArrAdd("");
                _onAccueil(cloneArrAdd);
                
            }
            
 /*        var titre:String=formatTitle(addr);
         SWFAddress.setTitle(titre);
 */
         Pt.Out.hx("cine.Navigator.handleChange()+"+arrAdd);
         cloneArrAdd=ArrayUtils.cloneArray(arrAdd);
    }
    
    public function delegate(target:Object, handler:Function):Function {
        var f = function() {
            var context:Function = arguments.callee;
            var args:Array = arguments.concat(context.initial);
            return context.handler.apply(context.target, args);
        }
        f.target = target;
        f.handler = handler;
        f.initial = arguments.slice(2);
        return f;
    }
    
    
	
   private function setArrAdd(addr:String) {
        arrAdd=addr.substr(1,addr.length - 2).split("/");
        for (var i : Number = 0; i < maxRefLength; i++) {
            if (arrAdd[i]==undefined) arrAdd[i]="";
        }
        
    }
	
	function onChange(){
        
        Pt.Out.hx("cine.Navigator.onChange()");
        var addr:String = SWFAddress.getValue();
        var tmpNav:String;
            Pt.Out.hx("addr"+addr);
            if (addr.substr(addr.length - 1, 1) == '/') {
                setArrAdd(addr);
                 _onRubrique(getRubique(),cloneArrAdd);
                 _onRepere(getRepere(),cloneArrAdd);
  //               _onZoom(getZoom(),cloneArrAdd);
  //               _onSource(getSource(),cloneArrAdd);
            } else {
                setArrAdd("");
                _onAccueil(cloneArrAdd);
                
            }
            
 /*        var titre:String=formatTitle(addr);
         SWFAddress.setTitle(titre);
 */
         Pt.Out.hx("cine.Navigator.onChange()+"+arrAdd);
         cloneArrAdd=ArrayUtils.cloneArray(arrAdd);
         
    }
	
	public function getRubique():String{
        return arrAdd[RUBRIQUE];
    }
	public function getRepere():String{
        return arrAdd[REPERE];
    }
    public function getZoom():String{
        return arrAdd[ZOOM];
    }
    
    public function getSource():String {
    	return arrAdd[SOURCES];
    }
    
    
	
	static var STR_RUBRIQUE:String="ETAPE_";
	
	public function setRubrique(addr) {
		Pt.Out.hx("cine.Navigator.setRubrique("+addr+")");
	
		if (addr==undefined) {
			arrAdd[RUBRIQUE]="";
		} else {
			arrAdd[RUBRIQUE]="ETAPE_"+addr;
		}
	}

    static var STR_REPERE:String="REPERE_";
	public function setRepere(addr){
		if (addr=="") {
			arrAdd[REPERE]="";
		} else {
			arrAdd[REPERE]="REPERE_"+addr;
		}
	}
	
	static var STR_PAROLES="PAROLES_";
	public function setParoles(addr){
		if (addr=="") {
			arrAdd[REPERE]="";
		} else {
			arrAdd[REPERE]="PAROLES_"+addr;
		}
	}

	/*
	public function setVideo(addr){
		if (addr=="") {
			arrAdd[VIDEO]="";
		} else {
		  arrAdd[VIDEO]="VIDEO_"+addr;
		}
		
	}
	
	public function setZoom(addr){
		if (addr=="") {
            arrAdd[ZOOM]="";
        } else {
            arrAdd[ZOOM]="ZOOM_"+addr;
		}
    }
    
    public function setSource(addr) {
    	if (addr=="") {
            arrAdd[SOURCES]="";
        } else {
            arrAdd[SOURCES]="SOURCES_"+addr;
		}
    }
	*/

   

	
	
	
	
	
	private function _onAccueil(cloneArrAdd:Array){
		
        Pt.Out.hx("cine.Navigator._onAccueil()");
        dispatchEvent(ON_ACCUEIL,new Event(this,ON_ACCUEIL,[cloneArrAdd]));
    }
	
	
	/**
	 * 	 * pour les statistiques de visites
	 *  SWFAddress.setTag(tagList[5]);	 */
	private function _onRepere(id:String,cloneArrAdd:Array){
        Pt.Out.hx("cine.Navigator._onRepere("+id+")");
        if (id != cloneArrAdd[REPERE] ) {
        	switch (id.split("_")[0]) {
        		case "REPERE" :
        			dispatchEvent(ON_REPERE,new Event(this,ON_REPERE,[id.substring(STR_REPERE.length),cloneArrAdd]));
        		break;
        		case "PAROLES" :
        			dispatchEvent(ON_PAROLES,new Event(this,ON_PAROLES,[id,cloneArrAdd]));
        		break;
        		default :
        		 if (id=="") {
        		 	dispatchEvent(ON_REPERE,new Event(this,ON_REPERE,[id,cloneArrAdd]));
        		 	dispatchEvent(ON_PAROLES,new Event(this,ON_PAROLES,[id,cloneArrAdd]));
        		 }
        	}            
        }
    }
    
	private function _onRubrique(id:String,cloneArrAdd:Array){
        Pt.Out.hx("cine.Navigator._onRubrique("+id+")");
        
        if (id!=cloneArrAdd[RUBRIQUE]) {
        	//if (id.split("_")[0]=="RUBRIQUE") {
        	 dispatchEvent(ON_RUBRIQUE,new Event(this,ON_RUBRIQUE,[id.substring(STR_RUBRIQUE.length),cloneArrAdd]));	
        	//} 
            
        }
    }
    
    /*
    private function _onSource(id:String,cloneArrAdd:Array){
        Pt.Out.hx("cine.Navigator._onSource("+id+")");
        
        if (id!=cloneArrAdd[SOURCES]) {
        	//if (id.split("_")[0]=="RUBRIQUE") {
        	 dispatchEvent(ON_SOURCES,new Event(this,ON_SOURCES,[id.split("_")[1],cloneArrAdd]));	
        	//} 
            
        }
    }
	
	private function _onZoom(id:String,cloneArrAdd:Array){
		Pt.Out.hx("cine.Navigator._onZoom("+id+")");
		
		if (id!=cloneArrAdd[ZOOM]) {
			if (id=="") {
				dispatchEvent(ON_CLOSE_ZOOMVIDEO,new Event(this,ON_CLOSE_ZOOMVIDEO,[id.substring(5),cloneArrAdd]));
			} else	if (id.split("_")[0]=="ZOOM") {
			 dispatchEvent(ON_ZOOM,new Event(this,ON_ZOOM,[id.substring(5),cloneArrAdd]));
			} else {
			 
			 dispatchEvent(ON_VIDEO,new Event(this,ON_VIDEO,[id.substring(6),cloneArrAdd]));					
			}
		}
	}
	*/
	public function updateValue(){
        Pt.Out.hx("cine.Navigator.updateValue():"+cloneArrAdd[0]+" "+arrAdd);
        setValue('/'+arrAdd.join('/')+"/");
	}
	
	function setValue(addr:String) {
        Pt.Out.hx("cine.Navigator.setValue("+addr+")");
        SWFAddress.setValue(addr);
    }
	
	
	
	
	
	
	
	
	
	
	
	/**
	 * 
	 * 
	 * Gestion titre page
	 * 
	 * 
	 * 	 */
	
	
	/**format tools **/
     public static function replace(str:String, find:String, replace:String):String {
        return str.split(find).join(replace);
    }

    public static function toTitleCase(str:String):String {
        return str.substr(0,1).toUpperCase() + str.substr(1).toLowerCase();
    }

/*
    public static function formatTitle(addr:String):String {
        Pt.Out.hx("cine.Navigator.formatTitle("+addr+")");
       
        if (addr.length > 1 && addr!="/accueil" ) {
        	 
            var adAr:Array=addr.substring(1, addr.length - 1).split("/");
            var str:String=_root._titre+'»';
            
            if (adAr[RUBRIQUE]!="" && adAr[RUBRIQUE]!=undefined) {
             var titre:String= _root.xmlData.findArticle(adAr[RUBRIQUE],[]).titre[0].text;
             if (titre!=undefined) {
                str+=titre+" / ";
             } else {
             	str+=adAr[RUBRIQUE]+" / ";
             }
            }
            
            if (adAr[REPERE]!="" && adAr[REPERE]!=undefined) {
             var titre:String= _root.xmlData.findRepere(adAr[REPERE]).h1[0].text;
              if (titre!=undefined) {
                str+=titre+" / ";
             } else {
                str+=adAr[REPERE]+" / ";
             }
            }
            
            if (adAr[ZOOM]!="" && adAr[ZOOM]!=undefined) {
             
                str+=adAr[ZOOM]+" / ";
             
            }

            return str;
        } else {
            return _root._titre+'»'+_root._accueil;
        }
    }
*/

}