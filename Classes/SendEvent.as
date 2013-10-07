/**
 * @author GuyF    , pense-tete
 * 23 mars 2009
 */
/**
 * 
 */
class SendEvent {
	/**
	 * envoyé par un lien href sur un clip
	 * Send.event(SendEvent.HREF,href)	 */
	// href(src:Send,$href:String);
	static var HREF:String="href";
	/**
	 * envoyer par une reference interne sur une icone
	 * pour renduHTML :
	 * 	asfunction:Send.event,ico,reference
	 * ico(src:Send,$reference:String,clipOrigine:MovieClip)	 */
	 static var ICO:String="ico";
	 /**
	 * une icone ajoutée
	 * pour renduHTML :
	 * 	asfunction:Send.event,ico,reference
	 * icoAdd(src:Send,$reference:assets.ico,)
	 */
	 static var ICOADD:String="icoAdd"
	 
	 
	 /**
	  *  asfunction:Send.event,cineSource,reference	  */
	 static var CINESOURCE:String="cineSource"
	 
	 /**
	  *  asfunction:Send.event,fichePerso,reference
	  */
	 
	 static var FICHEPERSO:String="fichePerso"
	 
	 /**
	  * fromEmail:String,fromNom:String,objet:String,corps:String,destinataire:String	  */
	 
	 static var MAILTO:String="mailto"
	 
	 /**
	  * asfunction:Send.event,nav,/RUBRIQUE_0////	  */
	 static var NAV:String="nav";
	  /**
	  * asfunction:Send.event,loupe,referenceLoupe (cheminToRef)
	  */
	 static var LOUPE:String="loupe";
	 
	 /**
	  * asfunction:Send.event,repere,indexRepere
	  */
	 static var REPERE:String="repere";
	 
	 
	 
}