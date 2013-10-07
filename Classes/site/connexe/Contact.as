/**
 *
 */
import org.aswing.util.Delegate;
import org.aswing.Event;
 import Pt.Parsers.DataStk;
 import Pt.Tools.Chaines;
 //import com.asual.swfaddress.SWFAddress;
/**
 *
 */
class site.connexe.Contact implements site.connexe.I_connexeContenu {

    private var ecranContact:MovieClip;
	public function Contact(clip:MovieClip) {
		
		ecranContact=clip.attachMovie("ecranContact","ecranContact",1);
		ecranContact.cobjet.text=DataStk.dico("contactObjet");
		ecranContact.cemail.text=DataStk.dico("contactEmail");
		ecranContact.cnom.text=DataStk.dico("contactNom");
		ecranContact.ccorps.text=DataStk.dico("contactCorps");
		ecranContact.cenvoyer.text=DataStk.dico("contactEnvoyer");
		ecranContact.btn_envoyer.onRelease=Delegate.create(this,_onEnvoyer);
	}

	public function remove(){
		ecranContact.removeMovieClip();
	}
	private function _onEnvoyer (){
		SWFAddress.openLink(Chaines.mailto(ecranContact.email.text,ecranContact.nom.text,ecranContact.objet.text,ecranContact.corps.text,DataStk.dico("emailContact")));
		//SWFAddress.href();
	}
   
}