/**
 * @author GuyF    , pense-tete
 * 1 mars 2010
 */
import org.aswing.Event;
import org.aswing.EventDispatcher;
import org.aswing.util.Delegate;
import site.connexe.*;
import Pt.Parsers.DataStk;

/**
 * 
 */
class site.connexe.ConnexeContener extends EventDispatcher {
	public static var ON_CLOSE_CONNEXE:String = "onCloseConnexe";
	
	public static var TAG_CONTACT:String="contact";	
	public static var TAG_CREDIT:String="credits";
	public static var TAG_PLAN:String="plan";
	public static var TAG_RESSOURCES:String="Ressources";

	public static var TAG_FILMS:String="Filmsetvideo";
	public static var TAG_FOCUS:String="Focus";
	public static var TAG_ATELIER:String="Atelier";
	
	private var currentTag:String
	
	private var currentContener:TransContent;
	private var clip:MovieClip;
	private var currentContentCloser:Function;
	
	public function toString():String {
			return "ConnexeContener "+clip;
	}
	
	/**
	 * @param clip : clipVide qui contiendra le / les transitions de contenu	 */
	public function ConnexeContener(clip:MovieClip) {
		//trace("site.connexe.ConnexeContener.ConnexeContener("+clip+")");
		this.clip=clip;
	}
	
	/**
	 * createur de contenu suivant le changement de TAG
	 * @param tag:String l'un des TAG static , defini l'action à effectuer en fonction du changement
	 * @param callBack:  methode local de creation effective	 */
	private function contenerCreater(tag:String,callBack:Function)  {
	
		//trace("site.connexe.ConnexeContener.contenerCreater("+tag+", callBack)"+currentTag);
		currentContentCloser();
		if (currentTag!=tag) {
			currentTag=tag;
			currentContener.close();
			var clipContener:MovieClip= clip.attachMovie("connexeContener","connexeContener_"+clip.getNextHighestDepth(),clip.getNextHighestDepth());
			currentContener=new TransContent(clipContener,tag);
			currentContener.addEventListener(TransContent.ON_OPEN,callBack,this);
			currentContener.addEventListener(TransContent.ON_CLOSE_CONNEXE,_onCloseConnexe,this);
			currentContener.open();
		} else {
			
			callBack(currentContener,undefined);
		}
	}
	
	public function create_credit() {
		contenerCreater(TAG_CREDIT,_create_credit)
	}
	
	public function create_contact() {
		contenerCreater(TAG_CONTACT,_create_contact);
	}
	public function create_plan() {
		contenerCreater(TAG_PLAN,_create_plan);
	}
	public function create_ressources(){
		contenerCreater(TAG_RESSOURCES,_create_ressources);
	}
	/**
	 * @param xml : chemin fichier xml
	 */
	public function create_films(xml:String,type:String) {
		contenerCreater(TAG_FILMS,Delegate.create(this,_create_films,xml,type));
	}
	/**
	 * @param xml : chemin fichier xml
	 */
	public function create_focus(xml:String,type:String){
		contenerCreater(TAG_FOCUS,Delegate.create(this,_create_focus,xml,type));
	}
	/**
	 * @param xml : chemin fichier xml
	 */
	public function create_atelier(xml:String,type:String){
		contenerCreater(TAG_ATELIER,Delegate.create(this,_create_atelier,xml,type));
	}
	
	public function close() {
		currentTag=undefined;
		currentContentCloser=undefined;
		currentContener.close();
	}
	
	

	private function _create_credit(src:TransContent) {
		//trace("site.connexe.ConnexeContener._create_credit(src)");
		var content:HtmlSeul=new HtmlSeul(src.ecran,DataStk.val("config").credits[0].src,"style.css");
		src.addEventListener(TransContent.ON_CLOSE_START,content.remove,content);
		currentContentCloser=Delegate.create(content,content.remove);
	}
	private function _create_contact(src:TransContent) {//Contact
		var content:Contact=new Contact(src.ecran);
		src.addEventListener(TransContent.ON_CLOSE_START,content.remove,content);
		currentContentCloser=Delegate.create(content,content.remove);
	}
	private function _create_plan(src:TransContent) {
		//trace("site.connexe.ConnexeContener._create_plan(src)");
		var content:HtmlSeul=new HtmlSeul(src.ecran,DataStk.val("config").plan[0].src,"style.css");
		src.addEventListener(TransContent.ON_CLOSE_START,content.remove,content);
		currentContentCloser=Delegate.create(content,content.remove);
	}
	private function _create_ressources(src:TransContent) {
		//trace("site.connexe.ConnexeContener._create_focus(src)");
		var content:MenuEtHtml=new MenuEtHtml(src.ecran,"ressources","style.css");
		src.addEventListener(TransContent.ON_CLOSE_START,content.remove,content);
		currentContentCloser=Delegate.create(content,content.remove);
	
	}
	
	
	
	private function _create_focus(src:TransContent,_null,fileXML:String,type:String) {
		_create_type(src,_null,fileXML,type==undefined?"MediaEtHtml":type);
	}
	private function _create_films(src:TransContent,_null,fileXML:String,type:String) {
		_create_type(src,_null,fileXML,type==undefined?"MediaEtHtml":type);
	}
	private function _create_atelier(src:TransContent,_null,fileXML:String,type:String) {
		_create_type(src,_null,fileXML,type==undefined?"MediaEtHtml":type);
	}
	
	private function _create_type(src:TransContent,_null,fileXML:String,type:String) {
		var content:I_connexeContenu;
		switch (type) {
			case "T360" :
				content=new ConnexeT360(src.ecran,fileXML,"style.css");
			break;
			case "MediaEtHtml":
				content=new MediaEtHtml(src.ecran,fileXML,"style.css");
			break;
			case "HtmlSeul":
				content=new HtmlSeul(src.ecran,fileXML,"style.css");
			break;
			case "MenuEtHtml":
				content=new HtmlSeul(src.ecran,fileXML,"style.css");
			break;
			case "Anim":
				content=new Anim(src.ecran,fileXML);
			break;
			case "DiapoEtHTML" :
				content=new DiapoMediaEtHtml(src.ecran,fileXML,"style.css");
			break;
			default :
				content=new MediaEtHtml(src.ecran,fileXML,"style.css");
				
			break;
			
		}
		src.addEventListener(TransContent.ON_CLOSE_START,content.remove,content);
		currentContentCloser=Delegate.create(content,content.remove);
		
	}
	
	/**
	 * fermeture depuis bouton fermer	 */
	private function _onCloseConnexe(src:TransContent) {
		currentTag=undefined;
		//trace("site.connexe.ConnexeContener._onCloseConnexe(src)");
		dispatchEvent(ON_CLOSE_CONNEXE,new Event(this,ON_CLOSE_CONNEXE));
	}
	

}