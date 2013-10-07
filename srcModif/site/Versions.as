/**
 * @author Administrator    , pense-tete
 * 27 mars 08
 */
import Pt.Parsers.XmlTools;
import Pt.Parsers.DataStk;
import GraphicTools.MenuPlatXML;
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
import org.aswing.Event;
import org.aswing.EventDispatcher;
/**
 * 
 */
class site.Versions extends EventDispatcher implements site.IMenuType {

	      /**
     * Un item dans les menus à été selectionné
     * @param src: MenuLibre
     * @param id: numero identifiant de menu
     * @param i : numero d'item
     * @param type : String , libre - guide - oeuvresAssociees
     * ON_SELECT  (src:IMenuType,id:Number,i:Number,type:String)
     */
    static var ON_SELECT:String="onSelect";
    private var imagesBtn:Object={IMG_OUT:1,IMG_OVER:3,IMG_PRESS:4,IMG_ON:4,IMG_OFF:1};
    private var clip:MovieClip;
    var xmlTool:XmlTools;
    var btnZoom:MovieClip;
	
	 private  var fondRefArray:Array;
	public function Versions(clip:MovieClip,btnZoom:MovieClip) {
		DataStk.add("loupes",{});
		this.btnZoom=btnZoom;
		trace("site.Versions.Versions("+clip+")");
		this.clip=clip;
		clip._visible=false;
		fondRefArray=new Array();
		menuArray=new Array();
        
	}
	
	public function initialise(){
		init();
	}
	
	public function open(){
		clip._visible=true;
	}
	public function close(){
		trace("site.Versions.close()"+clip);
		clip._visible=false;
	}
	
	  
    private var menuArray:Array;
    
    private function init(){
        initType("vues");
        clip._visible=false;
        
    }
    //DataStk.val("loupes").fondRef
    private function initType(typeMenu:String){
        xmlTool=new XmlTools(DataStk.val("menu"));
        var arrMenu:Array=xmlTool.findSub("menu","type",typeMenu);
        
        for (var i : Number = 0; i < arrMenu.length; i++) {
            var menuItem:MovieClip=clip.createEmptyMovieClip("menu_"+menuArray.length,clip.getNextHighestDepth());
            var y:Number=0;
            if (arrMenu[i].titre!=undefined) {
                var titreMenu:MovieClip=menuItem.attachMovie("titreMenu","titre",1);
                titreMenu._y=y;
                Clips.setTexteHtmlCss(titreMenu.texte,"style.css",arrMenu[i].titre[0].text);
                y=titreMenu._y+titreMenu._height;
            }
            
            var menuliste=menuItem.createEmptyMovieClip("liste",2);
            menuliste._y=y;
            
            var menuXML:MenuPlatXML=new  MenuPlatXML(menuliste,undefined,imagesBtn,arrMenu[i]);
            var index:Number=menuArray.push({menuXML:menuXML,type:typeMenu});
            menuXML.addEventListener(MenuPlatXML.ON_MENUINIT,Delegate.create(this, __onMenuInit,index-1),this);
            menuXML.addEventListener(MenuPlatXML.ON_ITEMINIT,Delegate.create(this, __onItemInit,arrMenu[i],i),this);
            menuXML.addEventListener(MenuPlatXML.ON_MENUPRESS,_onMenuPress,this);
            menuXML.initialize();   
            
        }

    }
    
            /*
         var loupParam:Object= {
         src: "img/fonds/fond_1_01.jpg",
         hd : "img/fonds/fond_1_01.jpg",
         defaultZoom : "1",
         minZoom : "1",
        maxZoom : "3",
        pasZoom : "0.1"
        }
        */

    private function __onItemInit(src:MenuPlatXML,clipBtn:MovieClip,idBtn:Number,MenuObject:Object,idMenu:Number) {
    	var lxmlTool:XmlTools=new XmlTools(MenuObject);
    	var data:Object=lxmlTool.find("btn","ref","_"+idBtn);
    	data.SELECT=Delegate.create(this, select,idMenu,idBtn);
    	var fondRef:String=Clips.convertCheminToRef(data.src);
    	DataStk.val("loupes")[fondRef]=data;
    	fondRefArray[idBtn]=fondRef;
    	
    }
 
    private function _onMenuPress(src:MenuPlatXML,id:Number,data:Object) {
        for (var i : Number = 0; i < menuArray.length; i++) {
            if (menuArray[i].menuXML!=src) {
                menuArray[i].menuXML.reset();
                
            } else {
               
                if (data.hd!=undefined) {
                	btnZoom.onRelease=Delegate.create(SWFAddress, SWFAddress.setLoupe,Clips.convertCheminToRef(data.src));
                	btnZoom._visible=true;
                } else {
                    delete btnZoom.onRelease;
                    btnZoom._visible=false;
                }
                dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[data]));
            }
            
        }
    }
    private function __onMenuInit(src:MenuPlatXML,null1,i:Number){
        
        for (var j : Number = 0; j < arguments.length; j++) {
            trace("j"+j+" "+arguments[j])
        }
        var courant:MovieClip=clip["menu_"+i];
        trace("site.MenuGuide.__onMenuInit(src, "+i+")");
        if (i>0) {
            /*
            var precedent:MovieClip= menuArray[i-1].menuXML.getClip();
            var courant:MovieClip= menuArray[i].menuXML.getClip();
            */
            
            var precedent:MovieClip=clip["menu_"+(i-1)];
          
            trace(precedent+" "+courant);
            
            courant._y=precedent._y+precedent._height;
        }
       
        clip.fond._x= courant.getBounds(clip).xMin-5;
        clip._visible=false;
    }
    
    public function select(idMenu:Number,idBtn:Number,action:Boolean){
    	trace("site.Versions.select("+idMenu+", "+idBtn+")");
    	 var fondRef:String=fondRefArray[idBtn];
    	 var data:Object=DataStk.val("loupes")[fondRef];
        

    	 if (data.hd!=undefined) {
                    btnZoom.onRelease=Delegate.create(SWFAddress, SWFAddress.setLoupe,fondRef);
                } else {
                    delete btnZoom.onRelease;
          }
        for (var i : Number = 0; i < menuArray.length; i++) {
            if (i!=idMenu) {
                menuArray[i].menuXML.reset();
                
            } else {
                // TODO menu selectionné : i eme, id : btn
                menuArray[i].menuXML.setNoAction(idBtn);
            }
            
        }
    }
    public function destroy(){
        // TODO : remove listenners ...
    }
    
}