/**
 * @author GuyF , pense-tete.com
 * @date 6 nov. 07
 * 
 */
 
import org.aswing.EventDispatcher;
import org.aswing.Event;
import org.aswing.util.Delegate;
import Pt.animate.ClipByFrame;
import Pt.Parsers.XmlTools;
import Pt.Tools.Clips;


/**
 *  un menu à bascule sur n boutons de btn_0 à btn_n
 */
class GraphicTools.MenuP extends EventDispatcher {
	/**
	 * Evenement
	 * onMenuPress(source:Menu, id:Number,data:Object)
	 * un des boutons est relaché
	 * @param source : cet objet
	 * @param id : identifiant de l'element de menu , de 0 à n
	 * @param data : donnée associé au bouton
	 * 
	 */	
	public static var ON_MENUPRESS:String = "onMenuPress";
	
	public static var ON_MENUOVER:String = "onMenuOver";
	public static var ON_MENUOUT:String = "onMenuOut";

	/**
	 * quand le contenu texte d'un item est initialisé
	 * onItemInit(source:MenuPlat,item:MovieClip,index:Number)
	 */	
	public static var ON_ITEMINIT:String = "onItemInit";
	/**
	 * quand le menu est initialisé
	 * onItemInit(source:MenuPlat,item:MovieClip,index:Number)
	 */	
	public static var ON_MENUINIT:String = "onMenuInit";
	
	private var arr_btn:Array;/* GraphicTools.BOverOutSelect */
	
	private var resetEnable:Number;
	
	private var clip:MovieClip;
	
	private var imagesBtn:Object={IMG_OUT:1,IMG_OVER:5,IMG_PRESS:7,IMG_ON:7,IMG_OFF:1};
	
	private var xmlTools:XmlTools;
	
	private var _btnPrefix:String="btn_";
	
	private var _btnTag:String="btn";
	
	private var _attRef:String="ref";
	
	
	
	/**
	 * Constructeur du menu 
	 * @param clip : le clip contenant les clips servants de boutons
	 * @param resetEnable : index à activer sur reset
	 * @param imagesBtn : images d'animation des boutons
	 * @param dataXML : données sources du menu (textes) contient des noeud textes <btn ref="_"+index ...> texte</btn> 
	 */
	 private var reclic:Boolean;
	public function MenuP(clip:MovieClip,resetEnable:Number,imagesBtn:Object,dataXML:Object,withInitialise:Boolean, reclic:Boolean) {
		super();
		this.reclic=(reclic==undefined)?false:reclic;
		//trace("GraphicTools.MenuP.MenuP("+clip+", "+resetEnable+", "+imagesBtn+" , dataXML, "+withInitialise+" reclic"+reclic+")");
		xmlTools=new XmlTools(dataXML);
		this.resetEnable=resetEnable;
		this.clip=clip;
		if (imagesBtn!=undefined) {
			this.imagesBtn=imagesBtn;
		}
		if (withInitialise==true) return
		initialize(10);
		
	}
	public function setBtnPrefix($prefix:String) {
		_btnPrefix=$prefix;
	}
	public function setBtnTag($tag:String) {
		_btnTag=$tag;
	}
	
	public function setAttRef($ref:String) {
		_attRef=$ref;
	}
	public function getClip():MovieClip {
		return clip;
	}
	private var _size:Number;
	private var arrayBtnData:Array;
	public function initialize (defSize:Number){
		arrayBtnData=new Array();
		arr_btn=new Array();
		var size:Number=xmlTools.xml[_btnTag].length;
		//trace("GraphicTools.MenuP.initialize(defSize):"+size);
		if (size==undefined) {
			size=defSize;
		} 
		_size=size;
		
		for (var i : Number = 0; i < size; i++) {
			
			var lBtn:GraphicTools.BOverOutSelect=createBtn(i); // add btn to arr_btn
			
			lBtn.addEventListener(GraphicTools.BOverOutPress.ON_RELEASE,Delegate.create(this, __onMenu,i),this);
			lBtn.addEventListener(GraphicTools.BOverOutPress.ON_OVER,Delegate.create(this, __onMenuOver,i),this)
			lBtn.addEventListener(GraphicTools.BOverOutPress.ON_OUT,Delegate.create(this, __onMenuOut,i),this)
			//arr_btn.push(lBtn);
		}
		var surplus:Number=size;
		while (clip[_btnPrefix+surplus] !=undefined) {
			clip[_btnPrefix+surplus]._visible=false;
			surplus++;
		}
		
	}
	
	public function lock(){
		for (var i : Number = 0; i < arr_btn.length; i++) {
			var lBtn:GraphicTools.BOverOutSelect=arr_btn[i];
			lBtn.getBtn().enabled=false;
		}
		
	}
	
	public function unlock(){
		for (var i : Number = 0; i < arr_btn.length; i++) {
			var lBtn:GraphicTools.BOverOutSelect=arr_btn[i];
			lBtn.getBtn().enabled=true;
		}
	}
	
	
	private function createBtn(i:Number):GraphicTools.BOverOutSelect {
		var noeud:Object=xmlTools.find(_btnTag,_attRef,"_"+i);
	
		arrayBtnData[i]=noeud;
		//trace("GraphicTools.MenuP.createBtn("+i+")"+clip);
		var lClip:MovieClip=clip[_btnPrefix+i];
		//if (lClip==undefined) break;
	//	lClip.texte.texte.autoSize="left";
		var btn	:GraphicTools.BOverOutSelect=initializeBtn(lClip);
		//lClip.texte.texte.autoSize=Clips.getAutoSize(lClip.texte.texte);
		//Clips.setTexteHtmlCss(lClip.texte.texte,"style.css",noeud.text,Delegate.create(this, disposeBtn,i));
		disposeBtn(i);
		return btn;
	}
	
	/**
	 * add btn to arr_btn
	 */
	private function initializeBtn(lClip): GraphicTools.BOverOutSelect{
		var lBtn:GraphicTools.BOverOutSelect;
		var btnCBF:ClipByFrame=new ClipByFrame(lClip);
		lBtn= new GraphicTools.BOverOutSelect(lClip,true,true,Delegate.create(btnCBF, btnCBF.goto),imagesBtn,reclic);
		//trace("GraphicTools.MenuP.initializeBtn("+lClip+") imagesBtn:"+imagesBtn);
		arr_btn.push(lBtn);
		return lBtn;
		

	}
	/**
	 * appelé lorsque le contenu d'un bouton est initialisé
	 */
	 private function disposeBtn(i:Number){
	 	//trace("GraphicTools.MenuP.disposeBtn("+i+")");
	 	var lClip:MovieClip=clip[_btnPrefix+i];
	 	dispatchEvent(ON_ITEMINIT,new Event(this,ON_ITEMINIT,[lClip,i]));
	 	if (_size==(i+1)){
	 		dispatchEvent(ON_MENUINIT,new Event(this,ON_MENUINIT));
	 	}
	 }
	
	/**
	 * evenement lancé au release d'un des boutons
	 */
	private function __onMenu(src:GraphicTools.BOverOutPress,clip:MovieClip,id:Number){
		//trace("GraphicTools.MenuP.__onMenu(src, clip, "+id+")");
		for (var i : Number = 0; i < arr_btn.length; i++) {
			if (i!=id) {
				arr_btn[i].enable=true;
				
			}
		}
		_lastNotEnableId=id;
		dispatchEvent(ON_MENUPRESS,new Event(this,ON_MENUPRESS,[id,xmlTools.find(_btnTag,_attRef,"_"+id)]));
		
	}
	
	private function __onMenuOver(src:GraphicTools.BOverOutPress,clip:MovieClip,id:Number){
		dispatchEvent(ON_MENUOVER,new Event(this,ON_MENUOVER,[id]));
		
	}
	private function __onMenuOut(src:GraphicTools.BOverOutPress,clip:MovieClip,id:Number){
		dispatchEvent(ON_MENUOUT,new Event(this,ON_MENUOUT,[id]));
		
	}
	
	
	/**
	 * active ou déactive les boutons
	 */
	public function enable(val:Boolean){
		for (var i : Number = 0; i < arr_btn.length; i++) {
			if (i!=resetEnable) {
				arr_btn[i].enable=val;
			}	else {
				arr_btn[i].enable=(! val);
			}
			if (!arr_btn[i].enable)_lastNotEnableId=i;
		}
	}
	
	public function reset(){
		for (var i : Number = 0; i < arr_btn.length; i++) {
				arr_btn[i].enable=true;
				_lastNotEnableId=undefined;
			
		}
	}
	public function getSize():Number {
		return arr_btn.length;
	}
	public function getBtn(index:Number):GraphicTools.BOverOutPress {
		return arr_btn[index];
	}
	/**
	 * active l'un des boutons , l'evenement sera lancé
	 * @param identifiant du bouton, numeroté de 0 à 2
	 */
	public function setAction(id:Number) {
		if (id==undefined) {
			 enable(true);
		} else {
			if (arr_btn[id].enable) {
				arr_btn[id].enable=false;	
				_lastNotEnableId=id;
				__onMenu(arr_btn[id],arr_btn[id].getBtn(),id);
			}
		}
		
	}
	
	private var _lastNotEnableId:Number;
	
	public function getNotEnableBtnId():Number{
		return _lastNotEnableId;
	}
	
	public function setNoAction(id:Number) {
		if (id==undefined) {
			 enable(true);
		} else {
			if (arr_btn[id].enable) {
				arr_btn[id].enable=false;
				_lastNotEnableId=id;
				for (var i : Number = 0; i < arr_btn.length; i++) {
					if (i!=id) {
						arr_btn[i].enable=true;
					}
				}	
				//__onMenu(arr_btn[id],arr_btn[id].getBtn(),id);
			}
		}
		
	}

	public function setVisible(val:Boolean) {
		for (var i : Number = 0; i < arr_btn.length; i++) {
			setBtnVisible(i,val);
		}
		
	}
	
	private function setBtnVisible(i:Number,val:Boolean):GraphicTools.BOverOutSelect {
		var lBtn:GraphicTools.BOverOutSelect=arr_btn[i];
		lBtn.getBtn()._visible=val;
		return lBtn;
	}
	
	public function getNodeFor(id:Number):Object {
		return arrayBtnData[id];
	}
	
	public function getXmlTools():XmlTools {
		return xmlTools;
	}
	
	
}