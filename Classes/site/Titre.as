/**
 * @author Administrator    , pense-tete
 * 27 mars 08
 */
import Pt.animate.Transition;
import GraphicTools.ToolTip;
import Pt.Parsers.DataStk;
import org.aswing.util.Delegate;
import Pt.Tools.Clips;
import GraphicTools.BOverOutPress;
/**
 * 
 */
class site.Titre {
	private var clip:MovieClip
	private var trans:Transition;
	private var btnTitre:BOverOutPress;
	
	public function Titre(clip:MovieClip) {
		this.clip=clip;
		trans=new Transition(clip);
		//btnTitre=new BOverOutPress(clip.content.btnover,false,false);
		init();
		trans.addEventListener(Transition.ON_NEXTFRAME,onOpenning,this)
		
	}
	
	var OlistenerOver:Object;
	private function onOpenning (cbframe:Pt.animate.Transition,currentframe,imageFin) {
		//trace("site.Credits.onOpenning(cbframe,"+currentframe+" ,"+imageFin+" )");
		if (currentframe==2) {
	//		btnTitre.enable=true;
			
	//		OlistenerOver=ToolTip.associer(btnTitre,DataStk.dico("overTitre"),"infoBulle",0,60,btnTitre.getBtn());
		}
		
	}
	
	
	

	private function init(){
		//clip.content.zoom.text=DataStk.dico("zoom");
		//clip.content.zoomsur.text=DataStk.dico("zoomsur");
		clip.content.zoom.autoSize=Clips.getAutoSize(clip.content.zoom);
		clip.content.btnZoom.texte.autoSize=Clips.getAutoSize(clip.content.btnZoom.texte);
		Clips.setTexteHtmlCss(clip.content.zoom,"style.css",DataStk.dico("zoom"),Delegate.create(this, onZoomAdded,clip.content));
		Clips.setTexteHtmlCss(clip.content.btnZoom.texte,"style.css",DataStk.dico("zoomsur"),Delegate.create(this, onZoomAdded,clip.content));
		Clips.setTexteHtmlCss(clip.content.titre,"style.css",DataStk.dico("titreHTML"),Delegate.create(this, onTitreAdded,clip.content.titre));
		
	}
	
	private function onTitreAdded(clipContent){
		
	}
	
	private function onZoomAdded(clipContent){
		//trace("site.Titre.onZoomAdded("+clipContent+")");
		clipContent.zoom._y=clip.content.btnZoom._y+(clip.content.btnZoom._height-clipContent.zoom._height)/2
	}
	
	public function open(){
		trans.open();
	}
	
	public function offTitre(){
		//trace("site.Titre.offTitre()");
		btnTitre.enable=false;
		OlistenerOver.elt.removeEventListener(OlistenerOver.lstn);
		ToolTip.dissocier();
	}
	
	public function onTitre(){
		//trace("site.Titre.onTitre()");
//		btnTitre.enable=true;
//		OlistenerOver=ToolTip.associer(btnTitre,DataStk.dico("overTitre"),"infoBulle",0,60,btnTitre.getBtn());

	}
	
}