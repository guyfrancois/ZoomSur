/**
 * @author GuyF , pense-tete.com
 * @date 30 mai 07
 * 
 */
import GraphicTools.BOverOutPress;
import GraphicTools.BOverOutSelect;
import Pt.image.ImageLoader;
import Pt.Tools.TextScoller; 
import site.Navigator;
import org.aswing.util.Delegate;
import Pt.Tools.Clips;
import Pt.Parsers.XmlTools;
//import Pt.Tools.Chaines;
import site.MediaContent;
import GraphicTools.MenuPlat;
import Pt.animate.Transition;
import org.aswing.EventDispatcher;
import org.aswing.Event;

class site.RubContent extends EventDispatcher{
	static var ON_CLOSE : String="onClose";
	static var BTN_IMG:Object={IMG_OUT:1,IMG_OVER:4,IMG_PRESS:7,IMG_ON:7,IMG_OFF:1};
	/**
	 * le contenu n'a que du texte	 */
	static var REFTYPE:String="etape";
	static var DEFFORMAT:String="RessText"

	// contient un prefix pour le type de rubrique
	private var rubPref:String; 
	// scroll de bibliotheque
	private var scrollType:String;


	private var clip:MovieClip;
	
	private var ltextScoller:TextScoller;
	
	private var xmlTools:XmlTools;

	private var imgArray:Array;
	private var mediaContent:MediaContent;
	private var content:MovieClip;
	private var maTrace:Function=Pt.Out.p;
	private var xmlArray:Array;
	private var defaultTitre:String;
	
	private var trans:Transition;
	
	public function RubContent(clip:MovieClip,scrollType:String,rubPref:String) {
		super();
		maTrace("site.RubContent.RubContent("+clip+", "+scrollType+", "+rubPref+")");
		trans=new Transition(clip);
		trans.addEventListener(Transition.ON_CLOSE,onClose,this);
		this.clip=clip.ecran;
		this.clip._visible=false;
		this.rubPref=rubPref;
		this.scrollType=scrollType
		if (this.rubPref==undefined) {
			this.rubPref="";
		}
	
		
	}
	
	/**
	 * @param data : Object {xmlData:Array ,  defaultTitre:String}	 */
	public function setContent(data:Object) {
		
		xmlArray=data.xmlData;
		defaultTitre=data.defaultTitre;
		setContentId(undefined,undefined ,0);
		
	}
	/** regle de titrage pour les rubriques  chronique journal(le 1er) portrait theme temoignage:
	si ni titre ni  titreBtn : titre de ressources
	si titre seul:  
		le bouton  -> titre
		son survol eventuel -> desactivé
		la rubrique -> titre
	si titreOver seul : 
		le bouton ->  titre de ressources
		son survol eventuel(theme et temoignage) -> titreOver
		la rubrique -> titreOver
	si titre et titreOver
		le bouton ->  titre
		son survol eventuel(theme et temoignage) -> titreOver
		la rubrique -> titreOver
	
	 */
	private function setContentId(src,btnClip,id:Number) {


		xmlTools=new XmlTools(xmlArray[id]);

		imgArray=xmlArray[id].ress;
		
		var format:String=xmlTools.xml.format;
		if (format==undefined) {
			format=DEFFORMAT;
		}
		
		if (imgArray==undefined) {
			content=clip.attachMovie(rubPref+REFTYPE+format,"content",1);
			mediaContent.removeContent();
			delete mediaContent;
			mediaContent=undefined;
		} else {
			content=clip.attachMovie(rubPref+REFTYPE+format,"content",1);
			mediaContent=new MediaContent(content.media);
			mediaContent.setContent(xmlTools.xml.ress);
		}
		
		if (xmlArray.length-1>id) {
			var btn_suiv:BOverOutSelect=new BOverOutSelect(content.suiv,undefined,false,undefined,BTN_IMG);	
			btn_suiv.addEventListener(BOverOutSelect.ON_RELEASE,Delegate.create(this, setContentId,id+1));
		} else {
			content.suiv._visible=false;
		}
		if (xmlArray.length>1) {
			content.compt.text=(id+1)+"/"+xmlArray.length;
		} else {
			content.compt.text="";
		}
		if (id>0) {
			var btn_prec:BOverOutSelect=new BOverOutSelect(content.prec,undefined,false,undefined,BTN_IMG);	
			btn_prec.addEventListener(BOverOutSelect.ON_RELEASE,Delegate.create(this, setContentId,id-1));
		} else {
			content.prec._visible=false;
		}
		
		maTrace("TITRE--->"+xmlTools.xml.titre[0]);
		maTrace("TEXTE--->"+xmlTools.xml.texte[0]);
		
		ltextScoller=new TextScoller(content,true,scrollType,15,0);
		var titreText:String=xmlTools.xml.titreOver[0].text;
		if (titreText==undefined) {
			titreText=xmlTools.xml.titre[0].text;
		}
		if (titreText==undefined) {
			titreText=defaultTitre;
		}
		clip.titre.texte.autoSize=Clips.getAutoSize(clip.titre.texte);
		Clips.setTexteHtmlCss(clip.titre.texte,"styleTitre.css",titreText,Delegate.create(this, onTitreAdded,clip.titre));
		Clips.setTexteHtmlCss(content.texte,"style.css",xmlTools.xml.texte[0].text,Delegate.create(ltextScoller, ltextScoller.onChanged));		
		clip._visible=true;
		trans.open();
	}
	
	private function onTitreAdded (clipTexte:MovieClip){
		//var height=clipBtn.texte._height
		var tf:TextField=clipTexte.texte;
		
		tf._y=-tf.textHeight-4;
		clipTexte.fond._y=tf._y;
		clipTexte.fond._height=tf.textHeight+4;
		clipTexte.fond._width=tf.textWidth+4;
		
	}
	
	public function transClose():Boolean{
		return trans.close();
		
	}
	
	public function onClose(){
		mediaContent.removeContent();
		delete mediaContent;
		mediaContent=undefined;
		content.removeMovieClip();
		clip._visible=false;
		content.texte.text="";
		ltextScoller.onChanged();
		dispatchEvent(ON_CLOSE,new Event(this,ON_CLOSE));
	}
	
}