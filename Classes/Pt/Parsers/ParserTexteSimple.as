/**
* @class Parser
* @author <a href="mailto:guy@guyf.fr.st">guy-fran�ois DELATTRE</a>
* @version 0.1
* @description extends XML<p>
* charge un fichier XML et gen�re un objet 
* @usage   testParser:Dialogues.Parser=new Pareres.Parser("datas.xml")</pre>
* @param   fichierXml:String  fichier XML de dialogue a charg�
*/
class Pt.Parsers.ParserTexteSimple extends XML {
	private var FileName:String;
	private var moteur:MovieClip;
	var racine:String="_root.";
	public function ParserTexteSimple(conteneur:MovieClip,data:String) {
		super(data);
		maTrace("constructeur ParserTexteSimple");
		this.moteur=conteneur;
		ignoreWhite = true;
	}
	public function load(fichierXml:String){
		FileName = fichierXml;
		super.load(fichierXml);
	}
	function maTrace(datas:String) {
		//trace("--parser------->"+datas);
	}
	public function scanTexte(conteneur:MovieClip){
		if (conteneur==undefined) {
			//trace("<configTxt>");
			scanTexte(this.moteur);
			//trace("</configTxt>");			
			return;
		}
		
		for (var element:String in conteneur)  {
			maTrace(conteneur[element]+" "+ typeof(conteneur[element]));
			if ( typeof(conteneur[element])=="movieclip") {
				scanTexte(conteneur[element]);
			} else if (conteneur[element].variable !=undefined ) {
				var ident:String=conteneur[element].variable.substring(racine.length);
				
				trace ("<"+ident+">"+conteneur[element].text+"</"+ident+">");
			}
		}
		
	}
	private function erreur() {
		maTrace("fichier :"+FileName);
		switch (status) {
		case 0 :
			maTrace("Aucune erreur ; analyse achev�e avec succ�s.");
			break;
		case -2 :
			maTrace(" Une section CDATA n'a pas �t� correctement achev�e.");
			break;
		case -3 :
			maTrace(" La d�claration XML n'est pas correctement termin�e.");
			break;
		case -4 :
			maTrace(" La d�claration DOCTYPE n'est pas correctement termin�e.");
			break;
		case -5 :
			maTrace(" Un commentaire n'est pas correctement termin�.");
			break;
		case -6 :
			maTrace(" Un �l�ment XML n'est pas correctement form�.");
			break;
		case -7 :
			maTrace(" M�moire disponible insuffisante.");
			break;
		case -8 :
			maTrace(" Une valeur d'attribut n'est pas correctement termin�e.");
			break;
		case -9 :
			maTrace(" Une balise de d�but n'a pas de balise de fin.");
			break;
		case -10 :
			maTrace(" Une balise de fin a �t� rencontr�e sans balise de d�but correspondante.");
			break;
		default :
			maTrace("Status inconnu");
			break;
		}
	}
	private function onLoad(success:Boolean) {
		if (success) {
			//onLoad(setList(parametre));
			//maTrace(this);
			erreur();
			maTrace(childNodes[0].nodeName);
			//maTraceTabNoeud(childNodes);
			parse();
			moteur.onSuccessTxt();
		} else {
			//maTrace("failed");
			erreur();
			//gotoAndStop("�checDeLecture");
			throw new Error("�checDeLecture");
		}
	}
	private function parse() {
		for (var i = 0; i<childNodes.length; i++) {
			switch (childNodes[i].nodeName) {
			case "liste" :
				//maTrace("config");
				getAllTextes(childNodes[i],moteur);
				break;
			}
		}
	}
	// ****************************textes Interlocuteurs*******************
	private function noeudTexteClip (noeud:XMLNode){
				//trace(getTexteArray(noeud))
				return getTexteArray(noeud);
			
	}
	
	// ****************************animal ***************************************		
	
	private function getAllTextes(noeud:XMLNode,conteneur:Object):Object{
		var textes:Object;
		if (conteneur!=undefined) {
			textes=conteneur;
		} else {
			textes= new Object();
		}
			for (var i = 0; i<noeud.childNodes.length; i++) {
				textes[noeud.childNodes[i].nodeName]=getTexte(noeud.childNodes[i]);
			}			
			return textes;
	}
	private function getTexteArray(noeud:XMLNode):Array{
		var textes:Array = new Array();
			for (var i = 0; i<noeud.childNodes.length; i++) {
				textes[i]=getTexte(noeud.childNodes[i]);
			}			
			return textes;
	}	
	private function getTexte(noeud:XMLNode):String {
		return noeud.firstChild.nodeValue;
	}
}
