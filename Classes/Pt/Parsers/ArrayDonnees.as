/**
 * @author guyf
 * 
 * 
 */
import Pt.Tools.Clips;
class Pt.Parsers.ArrayDonnees extends XML  {
	// caractere d'interne (firstChild, nextNode ,prevNode)
	static var FIRSTCHILD="firstChild";
	static var NEXTNODE="nextNode";
	static var PREVNODE="prevNode";
	static var RACINE="RACINE";
	
	static var ehypen:String="&amp;shy;"; // 
	static var chypen:String="\xAD";   // pas de retour à la ligne après le -
	//static var chypen:String="\x2D";
	
	private var attChar:String=""; // caractere d'attribut
	private var controleur:Object;
	private var conteneur:Object;
	private var firstTag:String;
	private var file:String;
	private var intervalID:Number // tempo de teste de chargement
	
	public function getFile():String {
		return file;
	}
	//
	/**
	 * Initialise le parser XML
	 * @param controleur : controleur de chargement
	 * {
	 * onXMLLoadProgress(bytesLoaded,bytesTotal,intervalID);
	 * onXMLreset(intervalID);
	 * success(conteneur);
	 * failed(conteneur);
	 * }
	 * @param firstTag  tag racine du XML à analyser
	 * @param conteneur (optionnel) receveur de l'arbo Objet
	 * @param data donnée XML sous forme de chaine (optionnel)	 */
	function ArrayDonnees(controleur:Object, firstTag:String,conteneur:Object,data:String) {
		super(data);
		ignoreWhite = true;
		
		this.conteneur = conteneur?conteneur:new Object();
		
		this.firstTag = firstTag;
		this.controleur = controleur;
		

	}
	
	private function onLoadProgress () {
    	 controleur.onXMLLoadProgress(getBytesLoaded(),getBytesTotal(),intervalID);
	}

	/**
	 * Lance le chargement des données (fichier XML)
	 * @param file nom complet du fichier XML à analyser
	 * @param conteneur Objet receveur des données (conteneur du constructeur par defaut)
	 * @param firstTag  tag racine du XML à analyser (firstTag du constructeur par defaut)
	 * 	 */
	function load(file:String,conteneur:Object, firstTag:String){
		intervalID=setInterval(this,"onLoadProgress", 100);
		controleur.onXMLinit(intervalID);
		
		
		this.conteneur =conteneur?conteneur:this.conteneur;
		this.firstTag = firstTag?firstTag:this.firstTag;
		this.file = file;
		if	(!super.load(file)) {
			controleur.failed(conteneur,1);
		}

	}
	
	static function maTraceErreur(datas:String) {
		//trace("--parser maTraceErreur------->"+datas);
	}
	
	static function maTrace(datas:String) {
		//trace("--parser------->"+datas);
	}
	static function erreur(status:Number):String {
		//maTrace("fichier :"+file);
		switch (status) {
		case 0 :
			return ("");//"Aucune erreur ; analyse achevée avec succès.");
			break;
		case -2 :
			return(" Une section CDATA n'a pas été correctement achevée.");
			break;
		case -3 :
			return(" La déclaration XML n'est pas correctement terminée.");
			break;
		case -4 :
			return(" La déclaration DOCTYPE n'est pas correctement terminée.");
			break;
		case -5 :
			return(" Un commentaire n'est pas correctement terminé.");
			break;
		case -6 :
			return(" Un élément XML n'est pas correctement formé.");
			break;
		case -7 :
			return(" Mémoire disponible insuffisante.");
			break;
		case -8 :
			return(" Une valeur d'attribut n'est pas correctement terminée.");
			break;
		case -9 :
			return(" Une balise de début n'a pas de balise de fin.");
			break;
		case -10 :
			return(" Une balise de fin a été rencontrée sans balise de début correspondante.");
			break;
		default :
			return("Status inconnu");
			break;
		}
	}
	private function onLoad(success:Boolean) {
		maTrace("onLoad fichier :"+file+" etat:"+success);
		controleur.onXMLLoadProgress(getBytesLoaded(),getBytesTotal(),intervalID);
		controleur.onXMLreset(intervalID);
		clearInterval(intervalID);
		if (success) {
			
			controleur.success(parse());
		} else {
			
			erreur(status);
			controleur.failed(conteneur,status);
			throw new Error("échecDeLecture");
		}
	}
	/**
	 * Lance (ou relance) l'analyse des donné
	 * déja effectué si load	 */
	function parse():Object {
		//trace("Pt.Parsers.ArrayDonnees.parse()"+childNodes.length);
		for (var i:Number = 0; i<childNodes.length; i++) {
			switch (childNodes[i].nodeName) {
				case firstTag :
					maTrace(firstTag);
					noeudConfig(childNodes[i], conteneur);
				break;
			}
		}
		conteneur.RACINE={firstTag:firstTag,file:file};
		return conteneur;
	}
	/**
	 * sortie type HTML d'un noeud XML	 */
	static function getHTML(noeud:XMLNode,cssClass:String,nodeName:String):String {
		var chaine:String="";
		for (var i:Number = 0; i<noeud.childNodes.length; i++) {
			chaine+=noeud.childNodes[i].toString();
		}
		chaine=chaine.split(ehypen).join(chypen);
		if (Clips.getParam("swhx")=="true") {
			//chaine=chaine.split('href="http://').join('href="asfunction:SWFAddress.hnote,http://');
			chaine=chaine.split('href="http://').join('null="http://');
		}
		if (cssClass!=undefined) {
			maTrace("Pt.Parsers.ArrayDonnees.getHTML() <span  class='"+cssClass+"'>"+chaine+"</span >" );
			return "<"+nodeName+"><span class='"+cssClass+"'>"+chaine+"</span ></"+nodeName+">";
		} else {
			maTrace("Pt.Parsers.ArrayDonnees.getHTML() <"+nodeName+">"+chaine+"</"+nodeName+">");
			return "<"+nodeName+">"+chaine+"</"+nodeName+">";
		}
	}
	private function noeudConfig(noeud:XMLNode, conteneur:Object) {
	    var prevConteneur:Object;
        var prevNodeName:String;
		for (var i:Number = 0; i<noeud.childNodes.length; i++) {
			var childNodes_i:XMLNode=noeud.childNodes[i];
			var nodeName:String=noeud.childNodes[i].nodeName;

			switch (childNodes_i.nodeType) {
			case 1 :
				// element XML
				if (conteneur[nodeName]==undefined ) {
					conteneur[nodeName]=new Array();
				}
				var attributs:Object=getAttributs(childNodes_i);
				var longueur:Number=conteneur[nodeName].push(attributs);
				
				if (attributs["type"]=="html" || attributs["class"]!=undefined) {
						maTrace("Pt.Parsers.ArrayDonnees.noeudConfig(noeud, conteneur)html" );
						conteneur[nodeName][longueur-1]["text"]=getHTML(childNodes_i,attributs["class"],nodeName);					
				} else {
						maTrace("Pt.Parsers.ArrayDonnees.noeudConfig(noeud, conteneur)!html "+nodeName+" "+conteneur[nodeName]["type"] );
						noeudConfig(childNodes_i, conteneur[nodeName][longueur-1]);
				}
				if (i==0) {
					//firstChild
					conteneur[FIRSTCHILD]= {nodeName:nodeName,node:conteneur[nodeName][longueur-1]};
					 
					 
				} else {
					//next
					prevConteneur[NEXTNODE]= {nodeName:nodeName,node:conteneur[nodeName][longueur-1]};
					conteneur[nodeName][longueur-1][PREVNODE]={nodeName:prevNodeName,node:prevConteneur};
				}
				prevConteneur=conteneur[nodeName][longueur-1];
				prevNodeName=nodeName;
				break;
			case 3 :
				// noeud texte
				maTrace("noeud texte "+noeud.nodeName);
				conteneur.text= childNodes_i.nodeValue;
				break;
			}
		}
	}
	
	private function getAttributs(noeud:XMLNode):Object {
		var conteneur:Object = new Object();
		for (var propriete:String in noeud.attributes) {
			conteneur[attChar+propriete] = noeud.attributes[propriete];
		}
		return conteneur;
	}
}