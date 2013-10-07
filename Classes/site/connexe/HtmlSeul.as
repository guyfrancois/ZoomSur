/**
 *
 */
import Pt.html.Render;
 import Pt.Parsers.DataStk;
import org.aswing.util.Delegate;
import site.connexe.TransContent;
import org.aswing.Event;
import Pt.Tools.ClipScollerDerouleur;
import Pt.Parsers.SimpleXML;
import Pt.Tools.ClipScoller;

/**
 * Gere l'affichage d'une popup crédit
 */
class site.connexe.HtmlSeul implements site.connexe.I_connexeContenu {

	private var htmlContent:Render;
	
	private var xmlFile:String;
	private var cssFile:String;
	private var htmlZone:MovieClip
	
	private var asClipScollerb:Pt.Tools.ClipScoller;
	
	/**
	 * @param clip ecran qui contiendra le contenu	 */
	public function HtmlSeul(clip:MovieClip,xmlFile:String,cssFile:String) {
		super(clip);
		this.xmlFile=xmlFile;
		this.cssFile=cssFile;
		htmlZone=clip.attachMovie("ecranHTML","htmlZone",1);
		htmlContent=new Render(htmlZone.htmlContent.texte,cssFile);
        htmlContent.addEventListener(Render.ON_READY,_onUpdateContent,this);
       	asClipScollerb=new ClipScoller(htmlZone.htmlContent,true,"scroller_texte",0,-htmlZone.htmlContent._y);
       	asClipScollerb.addEventListener(ClipScoller.ON_MOVEDONE,_onMoveDone,this)
		htmlContent.clear();
		asClipScollerb.onChanged();
	    loadContent(xmlFile);
	
	}
	
	/**
	 * suppression du contenu obsoléte	 */
	public function remove(){
		htmlContent.clear();
		htmlZone.removeMovieClip();
	}
	
	/**
	 * chargement du XML	 */
	private function loadContent(xmlFile:String) {
		var loaderXML:SimpleXML=new SimpleXML("html");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,_successData,this)
		//loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		loaderXML.load(xmlFile);
	}
	
	/**
	 * un fois le contenu chargé : initialise le html avec sont contenu
	 */
	private function _afficheCredits(data){
    	htmlContent.initialise(data);
    }	
    
    /**
     * mise à jour du scroll au changement de contenu     */
 	private function _onUpdateContent(){
		asClipScollerb.onChanged();
	}
	
	/**
	 * sur commande de changement brutal de scroll :  correction du bug conservation du clic fantome des textfield	 */
	private function _onMoveDone(src:ClipScoller,ypos:Number){
		src.toHidePlace();
		htmlContent.regen(Delegate.create(src, src.replaceTo,ypos));
	}   

	/**
	 * chargement réussi du xml	 */
	private function _successData(src:SimpleXML,conteneur:Object){
		_afficheCredits(conteneur);
	}
}