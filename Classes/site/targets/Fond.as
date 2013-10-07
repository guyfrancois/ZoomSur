/**
 * @author Administrator    , pense-tete
 * 7 avr. 08
 */
import org.aswing.util.ArrayUtils;
import Pt.Tools.Chaines;
import GraphicTools.BOverOutPress;
import GraphicTools.ToolTip;
import Pt.Temporise;
import Pt.animate.CBFReplaceClip ;
import org.aswing.util.Delegate;
import Pt.Parsers.DataStk;
import Pt.Tools.Clips;
import site.Versions;
import Pt.html.Analyse;
import site.DefTYPES;
/**
 * 
 */
class site.targets.Fond extends Pt.Zone.ContentGest  {
	static var  s_updatelegende:Function;
	static var  s_updatelegendeT360:Function;
	static var NOM:String=site.DefTargets.FOND;
	
	private var currentFond:MovieClip;
	private var previousFond:MovieClip;
	
	private var cbfreplace:CBFReplaceClip;
	private var trans:Temporise;
	
	private var clipLegende:MovieClip;
	
	private var btnLegende:BOverOutPress;
	
	private var VIDEO:String="hdvideo"
	
	public function Fond(clip:MovieClip,clipLegende:MovieClip) {
		super(clip);
		s_updatelegende=Delegate.create(this,updateLegende);
		s_updatelegendeT360=Delegate.create(this,updateLegendeSimple);
		this.clipLegende=clipLegende;	
		btnLegende= new BOverOutPress(clipLegende,true,true);
		
	}
	
	public function create(contentType:String, chem:String):MovieClip{
		//trace("Pt.Zone.ContentGest.create("+contentType+", "+chem+")"+clip);
		if (contentType==DefTYPES.VIDEO) {
			if(clip[DefTYPES.VIDEO]==undefined) {
				var cible:MovieClip=clip.attachMovie(VIDEO,DefTYPES.VIDEO,clip.getNextHighestDepth());
				cible._users=0;
				cible.height=cible._height;
				cible._visible=false;
				return cible;
			} else {
				return clip[DefTYPES.VIDEO];
			}
		}
		
		var ref:String=convertCheminToRef(chem);
		if (clip[ref] == undefined) {
			var cible:MovieClip;
			cible=clip.attachMovie(contentType,ref,clip.getNextHighestDepth());
			if (cible==undefined) {
				cible=clip.attachMovie(DefTYPES.IMAGE,ref,clip.getNextHighestDepth());
			}
			//trace("create cible :"+cible)
			cible._visible=false;
			cible._users=0;
			return cible;
		} else {
			trace ("found "+clip[ref])
			clip[ref]._users=1;
			return clip[ref];
		}
		
	}
	
	private function removeClip(cible:MovieClip,users:Number) {
		if (cible._name=="texte") return;
		if ( cible._visible ) return;
		cible.controler.destroy();
		cible.removeMovieClip();
		delete cible;
		
	}
	
	public function hideAll() {
		for (var i : String in clip) {
			if (clip[i]._visible==false || clip[i]._alpha==0 ) {
				hideClip(clip[i],DEFAULTHIDE,Delegate.create(this, remove,clip[i],clip[i]._users));
			}
		}
	}
	
	
	
	public function hideAllForEnd(){
		hideAll();
	}
	
	
	private function setPrev(pclip:MovieClip) {
		previousFond=pclip;
		previousFond._visible=false;
		previousFond._alpha=0;
	}
	
	private function setCurrent(cClip:MovieClip) {
		currentFond=cClip;
		currentFond._visible=true;
		currentFond._alpha=100;
	}


	private var listenerOverLegende:Object;
	/**
	 * association legende - contenu affiché	 */
	
	/*
	private var listenerOverLegende:Object;
	public function setLegende(texte:String) {
		listenerOverLegende.elt.removeEventListener(listenerOverLegende.lstn);	
		clipLegende.removeMovieClip();
		ToolTip.dissocier();
		if (texte!=undefined) {
			//clipLegende._visible=true;
			clipLegende=clip.attachMovie("popUpLegende","legende",clip.getNextHighestDepth(),{_x:XTEXTESPOS});
			btnLegende= new BOverOutPress(clipLegende,true,true);
			updateTextePos();
			listenerOverLegende=ToolTip.associer(btnLegende,texte,'infoBulle',0,-24,clipLegende);
		} 
		
	}
	*/
	private function showClip(cible:MovieClip,duree:Number,CALLBACK:Function) {
		trace("site.targets.Fond.showClip("+cible+","+duree+" , CALLBACK)");
		if (cible._name=="video") {
			
			updateLegende(convertCheminToRef(cible.controler.getName()));
		} else {
			updateLegende(cible._name);
		}
		if (cible._visible==false) {
			cible._alpha=0;
			cible._visible=true;
		}
		if (cbfreplace!=undefined) { // transition interompue
            trace("transition interompue "+cbfreplace.getClip()+" "+cible);
			if (cbfreplace.getClip()==cible) {
				trans.destroy();
				cbfreplace =new CBFReplaceClip(cible,{_alpha:100},cible);
				trans=new Temporise(duree/_decoup,Delegate.create(this, _renderShow,_decoup,cbfreplace,CALLBACK),false)
				
				return;
			} else {
			 trans.destroy();
			 if (currentFond!=cible) {
				setPrev(currentFond);
			 } 
			 currentFond=cbfreplace.getClip();
			 cible._alpha=100-currentFond._alpha;
			 currentFond._alpha=100;
			}
		} else {
			trace("pas de transition en cours "+currentFond+" "+cible);
			if (currentFond==cible) {
				cible._alpha=100;
				trans=new Temporise(1,CALLBACK,true);
				//CALLBACK();
				return // rien à faire
			} 
		}
		
		//trace("showClip :"+cible+" "+currentFond);
		var top:Number=clip.getNextHighestDepth()-1;
		var topClip:MovieClip=clip.getInstanceAtDepth(top);
		cible.swapDepths(top);
		
		cbfreplace =new CBFReplaceClip(cible,{_alpha:100},cible);
		trans=new Temporise(duree/_decoup,Delegate.create(this, _renderShow,_decoup,cbfreplace,CALLBACK),false)
		
	}
	
	private function _renderShow(src:Temporise,count:Number,ecart:Number,cbfreplace:CBFReplaceClip,CALLBACK:Function){
		cbfreplace._render(count/_decoup);
		
		if (count==_decoup) { // fin de transition  
			setPrev(currentFond); 
			setCurrent(cbfreplace.getClip()) ;
			
			
			
			CALLBACK();
			src.destroy();
			cbfreplace=undefined;
			this.cbfreplace=undefined;
		}
	}
	
	/*
	private function showClip(cible:MovieClip,duree:Number,CALLBACK:Function) {

		var top:Number=clip.getNextHighestDepth()-1;
		var topClip:MovieClip=clip.getInstanceAtDepth(top);
		cible.swapDepths(top);

		if (topClip==cible || topClip._visible==false || old._alpha==0 ) {
			old=undefined;
		}
		
		if (duree==0) {
			cible._alpha=100;
			old._alpha=0;
			old._visible=false;
			CALLBACK();
			return;
		}
		//cible._alpha=0;
		var cbfreplace:CBFReplaceClip =new CBFReplaceClip(cible,{_alpha:100},cible);
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr.destroy();
		}
		_tmpTransArr=new Array();
		var tmpTrans:Temporise=new Temporise(duree/_decoup,Delegate.create(this, _renderWithOld,cbfreplace,_decoup,old,CALLBACK),false)
		_tmpTransArr.push(tmpTrans);
		
	}
	*/
	
	/*
	private function hideClip(cible:MovieClip,duree:Number,CALLBACK:Function) {
		if (cible == undefined) return; 
		
		var prev:Number=cible.getDepth()-1;
		var old:MovieClip=clip.getInstanceAtDepth(prev);
		
		
		
		if (old==cible)  {
			old=undefined;
		} 
		old._visible=false;
		old._alpha=0;
		
		if (duree==0 || cible._alpha==0 || cible._visible==false ) {
			cible._alpha=0;
			cible._visible=false;
			old._visible=true;
			old._alpha=100;
			if (old!=undefined)cible.swapDepths(old);
			CALLBACK();
			return;
		}
		var cbfreplace:CBFReplaceClip =new CBFReplaceClip(cible,{_alpha:0},cible);
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr.destroy();
		}
		_tmpTransArr=new Array();
		var tmpTrans:Temporise=new Temporise(duree/_decoup,Delegate.create(this, _renderWithOld,cbfreplace,_decoup,old,CALLBACK),false)
		_tmpTransArr.push(tmpTrans);
	}
	*/
	
	function close(){
		
	}

	public function setInLoad() {
		
	}
	public function setInPlay() {
		
	}
	
	public function destroy() {
		
	}
	
	private function updateLegendeSimple(ref:String) {
		//trace("site.targets.Fond.updateLegendeSimple("+ref+")");
		var src:String=convertRefToChemin(ref);
		var maxChar:Number=0;
		var _textLegende:String;
		for (var i : Number = 0; i < legendeArray.length; i++) {
			if(legendeArray[i].src==src ) {
				//trace("LEGENDE OK i:"+i+" legendeArray[i].src"+legendeArray[i].src+" src:"+src)
				//trace("LEGENDE OK^")
				_textLegende=legendeArray[i].text;
				if(!isNaN(legendeArray[i].maxChar)) maxChar=Number(legendeArray[i].maxChar);
			}
		}
		
		if (_textLegende==textLegende || _textLegende==undefined) return;
		
		textLegende=_textLegende;
		listenerOverLegende.elt.removeEventListener(listenerOverLegende.lstn);
		ToolTip.dissocier();	
		
		if (textLegende!=undefined) {
			
			var texte:String=textLegende;
			if (maxChar >=0) {
				var htmlAna:Analyse=new Analyse(texte);
				var iHtml:Number=htmlAna.HtmlIToString(maxChar);
				if (iHtml<texte.length ) {
					//trace("couper à "+iHtml)
					//trace (htmlAna.getLastTagList());
					texte=Chaines.cutLastWord(texte,iHtml,">< ",DataStk.dico("caractereETC"));
					texte+=htmlAna.genLastTagClosure();
					texte+=DataStk.dico("caractereETC");
				}
			}
			clipLegende.texte.autoSize=Clips.getAutoSize(clipLegende.texte);
			Clips.setTexteHtmlCss(clipLegende.texte,"style.css",texte,undefined,undefined,36);
			//trace("site.targets.Fond.updateLegende:"+clipLegende.texte._OVERSIZE+" "+(texte!=textLegende));
			if (clipLegende.texte._OVERSIZE==true || texte!=textLegende) {
				listenerOverLegende=ToolTip.associer(btnLegende,textLegende,'infoBulleLegende',0,clipLegende._height,clipLegende);
			}
		} else {
			MovieClip.texte.text="";
		}
	}
	private function updateLegende(ref:String){
		if (ref=="video") {
		//	ref=
			// TODO : recuperer la reference et je chemain ver vidéo
			return;
		}
		
		updateLegendeSimple(ref);
		
	}
}