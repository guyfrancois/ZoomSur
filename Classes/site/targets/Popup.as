/**
 * @author Administrator    , pense-tete
 * 7 avr. 08
 */
import site.DefTYPES;
import Pt.animate.Transition;
import Pt.Tools.Clips;
import Pt.Tools.TFScroller; 
import org.aswing.util.Delegate;
import GraphicTools.BOverOutPress;
import GraphicTools.ToolTip;
/**
 * 
 */
class site.targets.Popup extends  Pt.Zone.ContentGest  {
	/**
	 * placement image :
	 * x: 8.0
	 * y: 40
	 * width : 366 
	 * V:ALGINTOP H:ALIGNCENTER
	 * sinon x:0/y:0
	 * 
	 * placement texte(s) : 
	 * content y + content height	 */
	 static var IMGDECX:Number=0;
	 static var IMGDECY:Number=0;
	 static var YTEXTESPACE:Number=20;
	 static var XTEXTESPACE:Number=5;
	 static var TEXTEMAXWIDTH:Number=360;
	 static var TEXTEMINPOS:Number=0;
	 static var TEXTEMAXHEIGHT:Number=430;
	 static var XTEXTESPOS:Number=IMGDECX+1; 
	 
	static var NOM:String=site.DefTargets.POPUP;
	
	private var clipPopup:MovieClip;
	private var trans:Transition;
	private var ltextScoller:TFScroller;
	private var clipLegende:MovieClip;
	
	
	
	
	public function Popup(clipPopup:MovieClip) {
		this.clipPopup=clipPopup;
		clipPopup.btn_fermer._visible=false;
		clipPopup.btn_fermer.onRelease=Delegate.create(this,_onBtnFermerRelease)
		this.clip=clipPopup.content.createEmptyMovieClip("_scene_"+clipPopup.content.getNextHighestDepth(),clipPopup.content.getNextHighestDepth());
		
		
		_tmpTransArr=new Array();
	}
	public function setInLoad() {
		clipPopup.content._visible=false;
	}
	public function setInPlay() {
		clipPopup.content._visible=true;
	}
	
	private function _onBtnFermerRelease(){
			
			//SWFAddress.setSequence(site.Appli.CMDSTOP);
			SWFAddress.setSequence(site.Appli.CMDPAUSE);
			clear();
		
	}
	
	public function create(contentType:String, chem:String):MovieClip{
		//trace("Pt.Zone.ContentGest.create("+contentType+", "+chem+")"+clip);
		if (contentType==DefTYPES.VIDEO) {
			if(clip[DefTYPES.VIDEO]==undefined) {
				var cible:MovieClip=clip.attachMovie(contentType,DefTYPES.VIDEO,clip.getNextHighestDepth());
				cible._x=IMGDECX;
				cible._y=IMGDECY;
				cible._users=0;
				cible.height=cible._height;
				cible._visible=false;
				return cible;
			} else {
				return clip[DefTYPES.VIDEO];
			}
		}
		// si ce n'est pas une video
		var ref:String=convertCheminToRef(chem);
		if (clip[ref] == undefined) {
			var cible:MovieClip;
			if (contentType==DefTYPES.IMAGE) {
				cible=clip.attachMovie(contentType,ref,clip.getNextHighestDepth());
				cible._x=IMGDECX;
				cible._y=IMGDECY;
			} else {
				cible=clip.attachMovie(contentType,ref,clip.getNextHighestDepth());
				if (cible==undefined) {
					cible=clip.attachMovie(DefTYPES.IMAGE,ref,clip.getNextHighestDepth());
				}
			}
			//trace("create cible :"+cible)
			cible._visible=false;
			cible._users=0;
			return cible;
		} else {
			trace ("found "+clip[ref]+" "+clip[ref]._users)
			//clip[ref]._users+=1;
			return clip[ref];
		}
		
	}
	// TODO : remplacer clip[j]._height par Bound et MaxY
	private function getTextPosY():Number {
		//trace("site.targets.Popup.getTextPosY()");
		var yPos:Number=TEXTEMINPOS;
		for (var j : String in clip) {
			//trace(j+" "+clip[j].getDepth()+" "+clip[j]._visible)
			if (j!="texte" && j!="legende" && clip[j].getDepth()>=0 && clip[j]._visible==true ){
				yPos=Math.max(yPos,clip[j].height+clip[j]._y);
				//trace("j :"+j+" yPos"+yPos+" "+clip[j].height+" "+clip[j]._y);
			}
		
		}
		return yPos;
	}
	
	
	public function updateTextePos(){
		//trace("site.targets.Popup.updateTextePos()");
		var baseImage:Number=getTextPosY();
		clipLegende._y=getTextPosY();
		if (clip["texte"]!=undefined) {
			clip["texte"]._y=baseImage+YTEXTESPACE;
			clip["texte"].texte._height=TEXTEMAXHEIGHT-clip["texte"]._y;
			//updateAfterEvent();
			ltextScoller.onChanged();
			
		}
		//trace(clip["texte"].x+" "+clip["texte"].y);
	}
	
	// BUG de detection de maxScroll ????
	private function updateTextAfterShow(CALLBACK:Function){
		updateTextePos();
		CALLBACK();
	}
	
	private function showClip(cible:MovieClip,duree:Number,CALLBACK:Function) {
		super.showClip(cible,duree,Delegate.create(this, updateTextAfterShow,CALLBACK));
		updateTextePos();
	}
	
	public function setTexte(dataXML:Object):MovieClip {
		//trace("site.targets.Popup.setTexte("+dataXML+")");
		if (clip["texte"]==undefined ) {
			clip.attachMovie("popUpTextes","texte",clip.getNextHighestDepth());
			clip["texte"]._visible=false;
			clip["texte"]._x=XTEXTESPOS;
			ltextScoller=new TFScroller(clip["texte"].texte,true,scrollType,0,0);
		}
		//trace(clip["texte"])
		var clipTexte:TextField=clip["texte"].texte;
		var clipConsigne:MovieClip=clip["texte"].consigne;
		if (dataXML==undefined) {
			return clip["texte"];
		}
		//ltextScoller.removeScroller();
		updateTextePos();
		//clipTexte.textHeight
		
		if (dataXML.consigne[0].text!=undefined) {
			clipConsigne._visible=true;
			clipTexte._x=clipConsigne._x+clipConsigne._width+XTEXTESPACE;
			clipTexte._width=TEXTEMAXWIDTH-(clipConsigne._width+XTEXTESPACE);
			clipConsigne.texte.autoSize=Clips.getAutoSize(clipConsigne.texte);
			Clips.setTexteHtmlCss(clipConsigne.texte,"style.css",dataXML.consigne[0].text);
		} else {
			clipConsigne._visible=false;
			clipTexte._x=clipConsigne._x;
			clipTexte._width=TEXTEMAXWIDTH;
		}
		if (dataXML.texte[0].text!=undefined) {
				Clips.setTexteHtmlCss(clipTexte,"style.css",dataXML.texte[0].text,Delegate.create(this, updateTextePos));
			} else {
				updateTextePos();
				//ltextScoller.onChanged();
		}
		
		
		
		return clip["texte"];
	}
	

	
	
	public function close() {
		//trace("site.targets.Popup.close()");
		ToolTip.dissocier();
		trans.close();
		clipPopup.btn_fermer._visible=false;
		/*
		clipPopup.btn_fermer.onRelease=function (){
			SWFAddress.setSequence(site.Appli.CMDSTOP);//site.Appli.CMDSTOP);	
		}
		*/

	}

	public function open() {
		if (trans.isOpen()) {
			onTransOpen();
		} else {
			trans.open();
		}
	}
	
	
	
	private function onTransOpen(){
		
		//if (SWFAddress.getMode()==site.DefModes.LIBRE)	clipPopup.btn_fermer._visible=true;
		if (!SWFAddress.isModeGuide()) {
			clipPopup.btn_fermer._visible=true;
		}
		
	}
	
		
	public function clear(){
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr[i].trans.destroy();
		}
		_tmpTransArr=new Array();
		hideAll();
		close();
	}
	
	private var listenerOverLegende:Object;
	public function setLegende(texte:String) {
		listenerOverLegende.elt.removeEventListener(listenerOverLegende.lstn);	
		clipLegende.removeMovieClip();
		ToolTip.dissocier();
		if (texte!=undefined) {
			//clipLegende._visible=true;
			clipLegende=clip.attachMovie("popUpLegende","legende",clip.getNextHighestDepth(),{_x:XTEXTESPOS});
			//.substring(0,texte.indexOf("<br/>"))
			Clips.setTexteHtmlCss(clipLegende.texte,"style.css",texte);
			
			updateTextePos();
			trace("site.targets.Popup.setLegende("+texte+")"+texte.indexOf("<br />"));
			if (texte.indexOf("<br />")>-1||texte.indexOf("<br/>")>-1) {
				var btnLegende:BOverOutPress= new BOverOutPress(clipLegende,true,true);
				listenerOverLegende=ToolTip.associer(btnLegende,texte,'infoBulle',0,-24,clipLegende);
			}
		} 
		
	}
	
	public function destroy():Object {
		//trans.destroy();
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr[i].trans.destroy();
		}
		trans.removeEventListener(_onTransOpenListener);
		clip.removeMovieClip();
		return {trans:trans};
	}
	
	private var _onTransOpenListener:Object;
	public function transfert(o:Object) {
		if (o.trans==undefined) {
			trans=new Transition(clipPopup);
			_onTransOpenListener=trans.addEventListener(Transition.ON_OPEN,onTransOpen,this);
		} else {
			trans=o.trans;
			trans.addEventListener(Transition.ON_OPEN,onTransOpen,this);
		}
	}

}