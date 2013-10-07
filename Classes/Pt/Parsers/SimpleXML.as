/**
 * @author guyf
 * 
 * analyse des ressources XML
 * transforme une structure XML en arborescence de tableau associatif
 * les noeuds sont des tableaux du nom du noeud
 * les attributs sont des propriétées prefixé par un "_" (defini par ArrayDonnees)
 * stopper le parseur :
 * si le noeud contient l'attibut type="html" : le noeud contient une valeur .text=" ce que contient le noeud "
 * si le noeud est de type texte : le texte est dans la valeur .text
 * 
 * exemple d'un usage courant :
 * 	private function loadConfig() {
 *		var loaderXML:SimpleXML=new SimpleXML("diapo");
 *		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,successConfig,this)
 *		loaderXML.addEventListener(SimpleXML.ON_FAILED,failedConfig,this)
 *		loaderXML.load("config.xml");
 *	}
 *	private function failedConfigDiapo() {
 *	}
 *	private function successConfig(src:SimpleXML,conteneur:Object) {
 *		
 * 		if (conteneur.serveur[0].url!=undefined) {
 * 			diapo.Diapo.BASEURL=conteneur.serveur[0].url;
 * 		}
 * 		if (conteneur.definition[0].maxWidth!=undefined) {
 * 			maxWidth=Number(conteneur.definition[0].maxWidth);
 * 		}
 * 		if (conteneur.definition[0].maxHeight!=undefined) {
 * 			maxHeight=Number(conteneur.definition[0].maxHeight);
 * 		}
 * 		loadContent();
 * 	}
 * 
 */
 
 
import org.aswing.Event;
import org.aswing.EventDispatcher;
import Pt.Parsers.ArrayDonnees;

class Pt.Parsers.SimpleXML  extends EventDispatcher  {
	//onXMLLoadProgress(source:SimpleXML, bytesLoaded:Number,bytesTotal:Number,intervalID:Number)
	//levé regulièrement pendant le chargement
	static var ON_XMLLOADPROGESS:String="onXMLLoadProgress";
	
	//onXMLreset  (source:SimpleXML, intervalID:Number)
	//levé lorsque le chargement est terminé, juste avant la destruction de intervalID);
	static var ON_XMLRESET:String="onXMLreset";
	
	//onSuccess  (source:SimpleXML,conteneur:Object)
	//levé lorsque le chargement à reussi
	//le conteneur contient les données au format actionScript
	static var ON_SUCCESS:String="onSuccess";
	
	//onFailed  (source:SimpleXML, conteneur:Object, status:Number)
	//levé en cas d'échec du chargement
	//le conteneur contient les données au format actionScript (si il y en a)
	//status : le code d'erreur de chargement
	static var ON_FAILED:String="onFailed";
	
	//
	/**
	 * Initialise le parser XML
	 * @param firstTag  tag racine du XML à analyser
	 * @param conteneur (optionnel) receveur de l'arbo Objet	 */
	private var loaderXML:ArrayDonnees;
	public function getFile():String {
		return loaderXML.getFile();
	}
	function SimpleXML(firstTag:String,conteneur:Object) {
		super();
		loaderXML=new ArrayDonnees(this,firstTag,conteneur);
		
	}
	/**
	 * analyse des donnée en parametre
	* @param data donnée XML sous forme de chaine (optionnel)
	*/
	function parse(data:String):Object{
		loaderXML.parseXML(data);
		return loaderXML.parse();
		
	}
	
	/**
	 * charge un fichier et l'analyse
	 * @param file : le fichier au format XML
	 * @param conteneur (optionnel) surcharge le constructeur: objet qui recevera la structure de données après analyse  
	 * @param firstTag  (optionnel) surcharge le constructeur : noeud racine de l'arborescence XML	 */
	public function load(file:String,conteneur:Object, firstTag:String) {
		//Log.addMessage("load(file, conteneur, firstTag)", Log.INFO,"Pt.Parsers.SimpleXML");
		//trace("Pt.Parsers.SimpleXML.load("+file+", conteneur, "+firstTag+")"+Pt.Tools.Clips.convertURL(file));
		loaderXML.load(Pt.Tools.Clips.convertURL(file),conteneur, firstTag);
	}
	
	
	

	
	function success(conteneur:Object){
		//trace("Pt.Parsers.SimpleXML.success(conteneur)");
		dispatchEvent(ON_SUCCESS,new Event(this,ON_SUCCESS,[conteneur]));
		
	}
	function failed(conteneur:Object,status:Number){
		//trace("Pt.Parsers.SimpleXML.failed(conteneur, status)");
		_root.err("ERREUR | xml | "+getFile()+" | "+ArrayDonnees.erreur(status));
		dispatchEvent(ON_FAILED,new Event(this,ON_FAILED,[conteneur,status,ArrayDonnees.erreur(status)]));

	}
	
	function onXMLLoadProgress(bytesLoaded:Number,bytesTotal:Number,intervalID:Number){
			dispatchEvent(ON_XMLLOADPROGESS,new Event(this,ON_XMLLOADPROGESS,[bytesLoaded,bytesTotal,intervalID]));
		
	}
	function onXMLreset(intervalID:Number){
		dispatchEvent(ON_XMLRESET,new Event(this,ON_XMLRESET,[intervalID]));
		
	}
	
	public function getXMLData():XML {
		return loaderXML;
	}
}