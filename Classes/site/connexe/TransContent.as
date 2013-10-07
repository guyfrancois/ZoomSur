/**
 *
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.animate.Transition;

/**
 *
 */
class site.connexe.TransContent extends EventDispatcher {
	/**
	 * quand evenement debut de fermeture
	 * ON_CLOSE_START(source:)
	 */	
	 
	 	/**
	 * quand evenement
	 * Transition.ON_OPEN(source:)
	 */	
	public static var ON_OPEN:String = Transition.ON_OPEN;
	public static var ON_CLOSE_START:String = Transition.ON_CLOSE_START;
	public static var ON_CLOSE_CONNEXE:String = "onCloseConnexe";
	
	private var clip:MovieClip;
	
	private var cbframe:Transition;
	private var btnFermer:GraphicTools.BOverOutPress;
	
	public function get ecran():MovieClip {
		return clip.ecran;
	}
		
	public function TransContent(clip:MovieClip,titreTag:String) {
		super();
		this.clip=clip;
		clip._visible=false;
		cbframe=new Transition(clip);
		cbframe.addEventListener(Transition.ON_CLOSE,onClose,this);	
		cbframe.addEventListener(Transition.ON_OPEN,onOpen,this);	
		cbframe.addEventListener(Transition.ON_CLOSE_START,onCloseStart,this);	
		btnFermer=new GraphicTools.BOverOutPress(clip.head.btn_fermer);
		btnFermer.addEventListener(GraphicTools.BOverOutPress.ON_RELEASE,onFermer,this);
		
		clip.head.texte.texte.autoSize=Pt.Tools.Clips.getAutoSize(clip.head.texte.texte);
		Pt.Tools.Clips.setTexteHtmlCss(clip.head.texte.texte,"style.css",Pt.Parsers.DataStk.dico(titreTag));
	}

	public function open(){
		cbframe.open();
		clip._visible=true;
	}
	
	public function close(){
		 cbframe.close();
		 /*
		if (cbframe.isOpen())
		*/
	}
	
	private function onClose(src:Transition) {
			onClosed();
	}
	
	private function onOpen(src:Transition) {
		dispatchEvent(ON_OPEN,new Event(this,ON_OPEN));
		// Initialisation sur demande d'ouverture
	}
	
	private function onFermer(){
		//trace("site.connexe.TransContent.onFermer()");
		dispatchEvent(ON_CLOSE_CONNEXE,new Event(this,ON_CLOSE_CONNEXE));
		close();
	}
	
	private function onClosed(){
		clip._visible=false;
		clip.removeMovieClip();
	}
	
	private function onCloseStart(){
		dispatchEvent(ON_CLOSE_START,new Event(this,ON_CLOSE_START));
	}
}