/**
 * @author Administrator    , pense-tete
 * 27 mars 08
 */
import Pt.animate.Transition;
import Pt.Tools.Clips;
import Pt.Parsers.DataStk;
import Pt.Tools.Chaines;
import org.aswing.util.SuspendedCall;

/**
 * 
 */
class site.BarreCredits {
	private var clip:MovieClip
	private var trans:Transition;
	public function BarreCredits(clip:MovieClip) {
		this.clip=clip;
		trans=new Transition(clip);
		clip.btn_credits.texte.autoSize=Clips.getAutoSize(clip.btn_credits.texte);
		
		clip.btn_contact.texte.autoSize=Clips.getAutoSize(clip.btn_contact.texte);
		trace("site.BarreCredits.BarreCredits("+clip+")"+clip.btn_contact.texte);
		Clips.setTexteHtmlCss(clip.btn_credits.texte,"style.css",DataStk.dico("credits"));
		Clips.setTexteHtmlCss(clip.btn_contact.texte,"style.css",DataStk.dico("contact"));
		clip.btn_version.texte.autoSize=Clips.getAutoSize(clip.btn_version.texte);
		Clips.setTexteHtmlCss(clip.btn_version.texte,"style.css",DataStk.val("config").langue[0].text);
		if (Clips.getParam("swhx")=="true") {
			
			clip.btn_version.onRelease=function(){
				//getURL("null");
				//fscommand("lang",DataStk.val("config").langue[0].href);
				if (Chaines.getExt(DataStk.val("config").langue[0].href)=="html") {
					
					swhx.Api.call("backend.openLang",DataStk.val("config").langue[0].ref)
				} else {
					swhx.Api.call("backend.openLang",DataStk.val("config").langue[0].href)
				}
				site.Appli.CLOSE();
				
				SuspendedCall.createCall(function(){fscommand("exit")},this,500);
				
				//getURL("zoomsur_"+DataStk.val("config").langue[0].href+"swf");
				//fscommand("openLang",DataStk.val("config").langue[0].href);
			}
		} else {
			clip.btn_version.onRelease=function(){
				getURL(DataStk.val("config").langue[0].href);
			}
		}
		clip.btn_credits._visible=DataStk.isDico("credits");
		clip.btn_contact._visible=DataStk.isDico("contact");
		clip.btn_version._visible=DataStk.val("config").langue[0].text!=undefined;
	
		
	}
	
	public function open(){
		trans.open();
	}
	
	
}