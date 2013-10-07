/**
 * @author Administrator    , pense-tete
 * 29 janv. 08
 */
import GraphicTools.MenuPlat;
import org.aswing.Event;
import Pt.animate.ClipByFrame;
import org.aswing.util.Delegate;
/**
 * 
 */
class GraphicTools.MenuPlatXMLLIBRE extends GraphicTools.MenuPlatXML {
	
	

	/**
	 * @param dataXML : structure du menu
	 * 		.skin : element de bibliotheque
	 * 		.maxChar : maximum de caractere d'un element
	 * 		.maxW : largeur max du menu avant retour à la ligne
	 * 		.btnHM : marge horizontal entre les btn si btnh pas defini
	 * 		.btnh : largeur (horizontal) des boutons , 0 pour faire une colonne
	 * 		.btnVM : marge vertical des boutons si btnv pas defini
	 * 		.btnv : taille (vertival) des boutons, 0 pour faire dune ligne
	 * 		
	 * 		.btn [
	 * 			{ico:nom de bib , img : image à charger, width:[false], height : [false] text : texte}
	 * 		]
	 * 		
	 * 			.width= false : empeche la redimension fond.forme en largeur
	 * 			.height= false : empeche la redimension fond.forme en hauteur	 */
	public function MenuPlatXMLLIBRE(clip:MovieClip,resetEnable:Number,imagesBtn:Object,dataXML:Object,reclic:Boolean)  {
		super(clip, resetEnable, imagesBtn, dataXML, reclic);
		//arrayBtnData=new Array();
		//initialize();
		
	}
	private function initializeBtn(lClip): GraphicTools.BOverOutSelect{
		var lBtn:GraphicTools.BOverOutSelect;
		var btnCBF:ClipByFrame=new ClipByFrame(lClip);
		lBtn= new GraphicTools.BOverOutSelect(lClip,true,false,Delegate.create(btnCBF, btnCBF.goto),imagesBtn,reclic);
		//trace("GraphicTools.MenuPlat.initializeBtn("+lClip+") imagesBtn:"+imagesBtn);
		arr_btn.push(lBtn);
		return lBtn;
		

	}

		/**
	 * evenement lancé au release d'un des boutons
	 */
	private function __onMenu(src:GraphicTools.BOverOutPress,clip:MovieClip,id:Number){
		//trace("GraphicTools.MenuPlat.__onMenu(src, clip, "+id+")");
		src.enable=!src.enable;
		dispatchEvent(ON_MENUPRESS,new Event(this,ON_MENUPRESS,[id,xmlTools.find(_btnTag,_attRef,"_"+id)]));
		
	}
	
	private function disposeBtn(id:Number,menuParam:Object,noeud:Object) {
		super.disposeBtn(id, menuParam, noeud);
	}
	

	

	
}