/**
 * @author Administrator    , pense-tete
 * 29 janv. 08
 */
import GraphicTools.MenuPlat;
import org.aswing.Event;
/**
 * 
 */
class GraphicTools.MenuPlatXMLSsPress extends GraphicTools.MenuPlatXML {
	
	

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
	public function MenuPlatXMLSsPress(clip:MovieClip,resetEnable:Number,imagesBtn:Object,dataXML:Object,reclic:Boolean)  {
		super(clip, resetEnable, imagesBtn, dataXML, reclic);
		//arrayBtnData=new Array();
		//initialize();
		
	}


		/**
	 * evenement lancé au release d'un des boutons
	 */
	private function __onMenu(src:GraphicTools.BOverOutPress,clip:MovieClip,id:Number){
		//trace("GraphicTools.MenuPlat.__onMenu(src, clip, "+id+")");

		dispatchEvent(ON_MENUPRESS,new Event(this,ON_MENUPRESS,[id,xmlTools.find(_btnTag,_attRef,"_"+id)]));
		
	}
	
	private function disposeBtn(id:Number,menuParam:Object,noeud:Object) {
		super.disposeBtn(id, menuParam, noeud);
	}
	

	

	
}