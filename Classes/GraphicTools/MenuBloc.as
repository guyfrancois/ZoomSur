/**
 * @author Administrator    , pense-tete
 * 12 d�c. 07
 */
import GraphicTools.MenuV;
/**
 * 
 */
class GraphicTools.MenuBloc extends MenuV {
	
	public function MenuBloc(clip:MovieClip,arboMenu:Object,margeHaute:Number,autoSubOpen:Boolean) {
		super(clip,arboMenu,margeHaute,autoSubOpen);
	}
	
	/**
	 * met à jour la disposition des éléments de menu
	 */
	private function updateSize(){
	}
	
	
	private function createChild_feuille(child:MovieClip,decalageY:Number):GraphicTools.MenuFeuille{
		//trace("GraphicTools.MenuV.createChild_feuille("+child+","+decalageY+" ):"+child._y);
		var tm:GraphicTools.MenuFeuille= new GraphicTools.MenuFeuille(child,undefined,child._y-decalageY);
		return tm;
	}
	private function createChild_Menu(child:MovieClip,decalageY:Number,autoSubOpen:Boolean,struct:Object){
		var tm:GraphicTools.MenuV = new MenuV(child,struct,child._y-decalageY,autoSubOpen);
		tm.skipSubMenu(true);
		return tm;
	}
	
}