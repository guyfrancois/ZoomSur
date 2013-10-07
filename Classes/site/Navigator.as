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

import Pt.Parsers.XmlTools;

class site.Navigator extends EventDispatcher {	
	
	static var ON_ACCUEIL:String="onAccueil";
	
	static var ON_RUBRIQUE:String="onRubrique";
	static var ON_PAROLES:String="onParoles";
	static var ON_REPERE:String="onRepere";
	static var ON_ZOOM:String="onZoom";
	static var ON_VIDEO:String="onVideo";
	static var ON_LOUPE:String="onLoupe";
	
	static var ON_SEQUENCE:String="onSequence";
	
	static var ON_CLOSE_ZOOMVIDEO:String="onCloseZoomVideo";
	
	static var ON_MODE:String="onMode";
	
	
	/**
	 * Reference vers les adresses de contenu
	 */
	 //static var ACCUEIL:Number;
	 static var RUBRIQUE:Number=0;
	 static var REPERE:Number=1;
	 static var ZOOM:Number=2;
	 static var VIDEO:Number=2;


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
    
    private var _currentMode:String;
    private var arrAdd:Array;
    
    private var cloneArrAdd:Array;
    	
	private static var instance : Navigator;
	
	private var xmlTools:XmlTools;
		
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
		xmlTools=new XmlTools(_root.xmlData);
	}
	
	private var tagList:Array;
	private	function _initialize():Boolean{
		tagList=_root._tags.split(",");
		_root.tagList=tagList;
		cloneArrAdd=new Array();
        arrAdd=new Array();
        for (var i : Number = 0; i < 3; i++) {
            cloneArrAdd[i]=arrAdd[i]="";
        }
        var swfDisp:mx.events.EventDispatcher=SWFAddress.getDispatcher();
        swfDisp.addEventListener("change",mx.utils.Delegate.create(this, onChange));
        return true;
	}
	
   private function setArrAdd(addr:String) {
        arrAdd=addr.substr(1,addr.length - 2).split("/");
        for (var i : Number = 0; i < 3; i++) {
            if (arrAdd[i]==undefined) arrAdd[i]="";
        }
        
    }
	
	function onChange(){
        
        trace("cine.Navigator.onChange()");
        var addr:String = SWFAddress.getValue();
        var tmpNav:String;
            trace("addr"+addr);
            if (addr.substr(addr.length - 1, 1) == '/') {
                setArrAdd(addr);
                 _onRubrique(getRubique(),cloneArrAdd);
                 _onRepere(getRepere(),cloneArrAdd);
                 _onZoom(getZoom(),cloneArrAdd);
            } else {
                setArrAdd("");
                _onAccueil(cloneArrAdd);
                
            }
            
         var titre:String=formatTitle(addr);
         SWFAddress.setTitle(titre);
         trace("cine.Navigator.onChange()+"+arrAdd);
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
    
   /*
	public function setMode(mode:String) {
		if (_currentMode!=mode) {
			_currentMode=mode;
			dispatchEvent(ON_MODE,new Event(this,ON_MODE,[mode]) );
		}
	}
	public function getMode():String {
		return _currentMode;
	}
	*/
	
	
	public function setRubrique(addr) {
		//trace("cine.Navigator.setRubrique("+addr+")");
	
		if (addr==undefined) {
			arrAdd[RUBRIQUE]="";
		} else {
			arrAdd[RUBRIQUE]="ETAPE_"+addr;
		}
	}

    
	public function setRepere(addr){
		if (addr=="") {
			arrAdd[REPERE]="";
		} else {
			arrAdd[REPERE]="REPERE"+addr;
		}
	}
	
	public function setParoles(addr){
		if (addr=="") {
			arrAdd[REPERE]="";
		} else {
			arrAdd[REPERE]="PAROLES"+addr;
		}
	}


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


   public function setSequence(file:String) {
   		onSequence(file);
   }
    public function setLoupe(file:String) {
        onLoupe(file);
   }
   
	private function onLoupe(file:String) {
		//trace("site.Navigator.onLoupe("+file+")");
		dispatchEvent(ON_LOUPE,new Event(this,ON_LOUPE,[file]));
	}
	
	private function onSequence(file:String) {
        trace("site.Navigator.onSequence("+file+")");
        dispatchEvent(ON_SEQUENCE,new Event(this,ON_SEQUENCE,[file]));
    }
	
	
	private function _onAccueil(cloneArrAdd:Array){
		SWFAddress.setTag(tagList[0]);
        trace("cine.Navigator._onAccueil()");
        dispatchEvent(ON_ACCUEIL,new Event(this,ON_ACCUEIL,[cloneArrAdd]));
    }
	
	
	/**
	 * 	 * pour les statistiques de visites
	 *  SWFAddress.setTag(tagList[5]);	 */
	private function _onRepere(id:String,cloneArrAdd:Array){
        trace("cine.Navigator._onRepere("+id+")");
        if (id != cloneArrAdd[REPERE] ) {
        	switch (id.split("_")[0]) {
        		case "REPERE" :
        			dispatchEvent(ON_REPERE,new Event(this,ON_REPERE,[id,cloneArrAdd]));
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
        trace("cine.Navigator._onRubrique("+id+")");
        
        if (id!=cloneArrAdd[RUBRIQUE]) {
        	//if (id.split("_")[0]=="RUBRIQUE") {
        	 dispatchEvent(ON_RUBRIQUE,new Event(this,ON_RUBRIQUE,[id.substring(6),cloneArrAdd]));	
        	//} 
            
        }
    }
	
	private function _onZoom(id:String,cloneArrAdd:Array){
		//trace("cine.Navigator._onZoom("+id+")");
		
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
	
	public function updateValue(){
        trace("cine.Navigator.updateValue():"+cloneArrAdd[0]+" "+arrAdd);
        setValue('/'+arrAdd.join('/')+"/");
	}
	
	function setValue(addr:String) {
        trace("cine.Navigator.setValue("+addr+")");
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

    public static function formatTitle(addr:String):String {
        trace("cine.Navigator.formatTitle("+addr+")");
       
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
    
    static function getRepereTitre() :String{
        var menuArbo:Object=_root.xmlData.arbo[0];
        return menuArbo.menu[2].menu[Navigator.getInstance().getRepere()].titre;
    }
	

}