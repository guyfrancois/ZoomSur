/**
 * @author Administrator    , pense-tete
 * 29 janv. 08
 */
import GraphicTools.MenuPlat;
import Pt.Parsers.XmlTools;
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
/**
 * 
 */
class GraphicTools.MenuPlatAuto extends MenuPlat {
	
	
	public function MenuPlatAuto(clip:MovieClip,resetEnable:Number,imagesBtn:Object,dataXML:Object)  {
		super(clip,resetEnable,imagesBtn,dataXML);
	}
	
	private function createBtn(i:Number):GraphicTools.BOverOutSelect {
		var skin:String=xmlTools.xml.skin;
		var marge:Number=Number(xmlTools.xml.marge);
		if (skin==undefined) skin="menuPlatAuto";
		if (isNaN(marge)) marge=10;
		var lClip:MovieClip=clip.attachMovie(skin,_btnPrefix+i,clip.getNextHighestDepth());
		lClip.texte.texte.autoSize="left";
		Clips.setTexteHtmlCss(lClip.texte.texte,"style.css",xmlTools.find(_btnTag,_attRef,"_"+i).text,Delegate.create(this, disposeBtn,i,marge));
		return initializeBtn(lClip);
	}
	
	
	private function disposeBtn(id:Number,marge:Number) {
		var courant:MovieClip=clip[_btnPrefix+id];
		courant.fond.forme._width=courant.texte._width;
		if (id==0) return;
		var precedent:MovieClip=clip[_btnPrefix+(id-1) ];
		
		courant._x=precedent._x+precedent._width+marge;
	}
	
}