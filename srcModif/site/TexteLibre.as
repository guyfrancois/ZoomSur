/**
 * @author Administrator    , pense-tete
 * 1 avr. 08
 */
import site.ITextType;
import Pt.Tools.ClipScoller; 
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
import site.texteLibre.BlocOuvrable;
import Pt.html.CssCollect;
import Pt.Parsers.DataStk;

/**
 *  utilise textScroller pour afficher les textes en continue, tout en html
 */
class site.TexteLibre implements site.ITextType {
	static var scrollType:String="scroller_texte";
	static var contentType:String="BloctexteLibre";
	private var clip:MovieClip;
	private var content:MovieClip;
	
	private var ltextScoller:ClipScoller;
	
	private var blocListe:Array;
	
	private var selTextListenner:Object;
	
	public function TexteLibre(clip:MovieClip) {
		this.clip=clip;
		selTextListenner=DataStk.event().addEventListener("SEL_TEXT",onSelText,this);
		
	}
	
	/** METHODES D'INTERFACES */
	function setTextes(dataXML:Object) {
		CssCollect.load("style.css",Delegate.create(this, _setTextes,dataXML));
	}
	private function _setTextes(css:TextField.StyleSheet,dataXML:Object) {
		blocListe=new Array();
		var chapitres:Array=dataXML.chapitre;
		//var texte:String="";
		
		
		content=clip.attachMovie(contentType,"content",1);
		for (var i : Number = 0; i < chapitres.length; i++) {
			var bloc:BlocOuvrable=new BlocOuvrable(content.texte);
			bloc.addEventListener(BlocOuvrable.ON_CHANGE,Delegate.create(this,onBlocChanged,i),this);
			blocListe.push(bloc);
			bloc.setTextes(chapitres[i]);
			
		}
		blocListe[0].open();
		ltextScoller=new ClipScoller(content,true,scrollType,0,0);
		ltextScoller.onChanged();
		
		
	}
	
	
	
	
	
	private function onBlocChanged(src:BlocOuvrable,isOpen:Boolean,numBloc:Number){
		trace("site.TexteLibre.onBlocChanged(src, "+isOpen+", "+numBloc+")");
		var afterChanged:Boolean=false; // après un bloc qui à changé de forme
		//var hasChange:Boolean=false;
		
		for (var i : Number = 0; i < blocListe.length; i++) {
			var courant:BlocOuvrable=blocListe[i];
			if (afterChanged) {
				var pred:BlocOuvrable=blocListe[i-1];
				courant.getClip()._y=pred.getClip()._y+pred.getClip()._height;
				ltextScoller.onChanged(true);
			}
			if (courant==src) {
				afterChanged=true;
				ltextScoller.onChanged(true);
			}
			if (isOpen && numBloc!=i) {
				courant.close();
			} else	if (courant.isOpen()) {
				
				//ltextScoller.onChanged(true);
				ltextScoller.moveTo(courant.getYPos(content.texte));
				//_tmpParagraph=undefined;
			}
			
		}
		//var ypos:Number=ltextScoller.getYPos();
		
		
		if (isOpen ) {
			ltextScoller.moveTo(src.getYPos(content.texte));
			
			
		}
		
		//if (hasChange==false) _tmpParagraph=undefined;
		//ltextScoller.replaceTo(ypos);
	}
	
	


	
	function destroy() {
		DataStk.event().removeEventListener(selTextListenner);
		ltextScoller.destroy();
		delete ltextScoller;
		content.removeMovieClip();
	}
	
	//private var _tmpParagraph:Number;
	public function openBloc(id:Number,idPara:Number){
		trace("site.TexteLibre.openBloc("+id+", "+idPara+")");
		var blocid:BlocOuvrable
		for (var i : Number = 0; i < blocListe.length; i++) {
			var bloc:BlocOuvrable=blocListe[i];
			if (i!=id) {
				bloc.closePara();
			} else {
				blocid=bloc;
				bloc.openPara(idPara);
				
				bloc.open();
				//
			}
		}
		
			ltextScoller.moveTo(blocid.getYPos(content.texte));
		
	}
	
	
	
	private function onSelText(src:DataStk,ibBloc:Number,idPara:Number){
		trace("site.TexteLibre.onSelText(src, "+ibBloc+", "+idPara+")");
		openBloc(ibBloc,idPara);
	}
	
	
	
}