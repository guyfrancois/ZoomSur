/**
 * @author Administrator    , pense-tete
 * 1 avr. 08
 */
import site.ITextType;
import Pt.Tools.ClipScoller; 
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
import site.texteLibre.BlocOuvrableSsSequence;
import Pt.html.CssCollect;

/**
 *  utilise textScroller pour afficher les textes en continue, tout en html
 */
class site.TexteGuideABlocs extends site.TexteLibre {
	static var scrollType:String="scroller_texte";
	static var contentType:String="BloctexteGuideABloc";
	private var clip:MovieClip;
	private var content:MovieClip;
	
	private var ltextScoller:ClipScoller;
	
	private var blocListe:Array;
	public function TexteGuideABlocs(clip:MovieClip) {
		super(clip);
		
	}
	
	/** METHODES D'INTERFACES */
	
	
	private function _setTextes(css:TextField.StyleSheet,dataXML:Object) {
		blocListe=new Array();
		var chapitres:Array=dataXML.chapitre;
		var texte:String="";
		
		
		content=clip.attachMovie(contentType,"content",1);
		for (var i : Number = 0; i < chapitres.length; i++) {
			var bloc:BlocOuvrableSsSequence=new BlocOuvrableSsSequence(content.texte);
			bloc.addEventListener(BlocOuvrableSsSequence.ON_CHANGE,Delegate.create(this,onBlocChanged,i),this);
			blocListe.push(bloc);
			bloc.setTextes(chapitres[i]);
			
		}
		blocListe[0].open();
		ltextScoller=new ClipScoller(content,true,scrollType,0,0);
		ltextScoller.onChanged();
		
		
	}
	
	
	
	
	
}