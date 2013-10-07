/**
 *
 */

 import Pt.Parsers.DataStk;
import org.aswing.util.Delegate;
import site.connexe.TransContent;
import org.aswing.Event;
import Pt.Parsers.SimpleXML;
import Pt.Tools.Clips;
import Pt.Tools.Chaines;
import Pt.image.ImageLoader;


/**
 * Gere l'affichage d'une popup crédit
 */
class site.connexe.Anim  implements site.connexe.I_connexeContenu {

	private var xmlFile:String;
	private var htmlZone:MovieClip;
	
	/**
	 * @param clip ecran qui contiendra le contenu	 */
	public function Anim(clip:MovieClip,src:String) {
	
		this.xmlFile=xmlFile;
		htmlZone=clip.createEmptyMovieClip("htmlZone",1);
	    var il:ImageLoader=new ImageLoader(htmlZone.createEmptyMovieClip("_img_",10),src,1015,420);
	   
	}

	/**
	 * suppression du contenu obsoléte	 */
	public function remove(){
		htmlZone.removeMovieClip();
	}

}