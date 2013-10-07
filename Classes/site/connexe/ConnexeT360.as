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
import media.M_T360;
import Pt.image.ImageLoader;
import GraphicTools.Loupe;

import Pt.html.Render;
import Pt.Tools.ClipScollerDerouleur;
import Pt.Tools.ClipScoller;


/**
 * Gere l'affichage d'une popup crédit
 */
class site.connexe.ConnexeT360  implements site.connexe.I_connexeContenu {

	private var xmlFile:String;
	private var cssFile:String;
	private var htmlZone:MovieClip;
	private var t360:M_T360;
	
	private var htmlContent:Render;
	private var asClipScollerb:Pt.Tools.ClipScoller;
	
	
	
	/**
	 * @param clip ecran qui contiendra le contenu	 */
	public function ConnexeT360(clip:MovieClip,xmlFile:String,cssFile:String) {
	
		this.xmlFile=xmlFile;
		this.cssFile=cssFile;
		
		htmlZone=clip.attachMovie("ecranT360","htmlZone",1);
       	htmlZone.btnZoom._visible=false;
       	
       	htmlContent=new Render(htmlZone.htmlContent.texte,cssFile);
        htmlContent.addEventListener(Render.ON_READY,_onUpdateContent,this);
       	asClipScollerb=new ClipScoller(htmlZone.htmlContent,true,"scroller_texte",0,-htmlZone.htmlContent.masque._y);
       	asClipScollerb.addEventListener(ClipScoller.ON_MOVEDONE,_onMoveDone,this);
       	htmlZone.btnZoom._visible=false;
		htmlContent.clear();
		asClipScollerb.onChanged();
		
	    loadContent(xmlFile);
	   
	
	}
	
	/**
	 * suppression du contenu obsoléte	 */
	public function remove(){
		t360.destroy();
		htmlContent.clear();
		htmlZone.removeMovieClip();
	}
	
	/**
	 * chargement du XML	 */
	private function loadContent(xmlFile:String) {
		var loaderXML:SimpleXML=new SimpleXML("mediahtml");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,_successData,this)
		//loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		loaderXML.load(xmlFile);
	}
	
	/**
	 * un fois le contenu chargé : initialise le html avec sont contenu
	 */
	private function _afficheContenu(data){
		//htmlZone.legende.
		htmlZone.legende.texte.autoSize=Clips.getAutoSize(htmlZone.legende.texte);
		Clips.setTexteHtmlCss(htmlZone.legende.texte,"style.css",data.legende[0].text);
		afficheMedia(data.T360[0]);
    	htmlContent.initialise(data.html[0]);
    }	
    
    private function afficheMedia(omedia:Object){
			htmlZone.img._visible=true;
			
//			contener:MovieClip,src:String,fond:String,nbImages:Number,width:Number,height:Number,hasBtn:Boolean,rotate:Number,startAt:Number,rotateTime:Number
			t360=new M_T360(
				htmlZone.img.createEmptyMovieClip("_img_",10),
				omedia.src,
				omedia.fond,
				Number(omedia.nbImages),
				omedia.width==undefined?htmlZone.img._width:Number(omedia.width),
				omedia.height==undefined?htmlZone.img._height:Number(omedia.height),
				omedia.hasBtn=="true",
				omedia.rotate==undefined?0:Number(omedia.rotate),
				omedia.startAt==undefined?0:Number(omedia.startAt),
				omedia.rotateTime==undefined?0:Number(omedia.rotateTime),
				omedia.swfWidth==undefined?htmlZone.img._width:Number(omedia.swfWidth),
				omedia.swfHeight==undefined?htmlZone.img._height:Number(omedia.swfHeight)
			
			 );
			
// TODO gerer le bouton loupe	
			if (omedia.hd) {
				htmlZone.btnZoom._visible=true;
				htmlZone.btnZoom.onRelease=Delegate.create(this,_onLoupe,omedia,htmlZone.img._img_)
			} else {
				htmlZone.btnZoom._visible=false;
			}		
			t360.init();
		
    }
    
    /**
     * lancement de la loupe     */
     private var lp:Loupe;
     private var loupeClip:MovieClip;
    
     private function _onLoupe(media:Object,cible:MovieClip) {
     trace("site.connexe.ConnexeT360._onLoupe(media)");
     trace(t360.currentSprite);
     
     	//var cible:MovieClip=t360.currentSprite;
     	loupeClip=cible._parent.attachMovie("loupe","loupeClip",100);
     	trace(cible._x+" "+cible.width+" "+loupeClip._width);
     	trace(cible._y+" "+cible.height+" "+loupeClip._height)
     	loupeClip.btns.btn_x.onRelease=Delegate.create(this,_onLoupeClose);
     	loupeClip._x=Math.floor(cible._x+(cible.width-loupeClip._width)/2);
    	loupeClip._y=Math.floor(cible._y+(cible.height-loupeClip._height)/2);
    	var num:String=Chaines.untriml(String(t360._currentImage),3,"0");
		var nomFichier:String=Chaines.scanf(media.hd,num);
    	trace("site.connexe.ConnexeT360._onLoupe(media, "+cible+")"+nomFichier);
    	var hdLoupe:Object= {
    		hd:nomFichier,
			defaultZoom:media.defaultZoom,
			minZoom:media.minZoom,
			maxZoom:media.maxZoom,
			pasZoom:media.pasZoom
    	}
		
     	lp=new Loupe(loupeClip,cible,hdLoupe);
     	lp.addEventListener(Loupe.ON_READY,openLoupe,this)
     	t360.stopInteraction();
     }
     
     private function openLoupe(){
     	_root.loader._visible=false;
     	 t360.tempo.destroy()
     	 lp.open();
     	 
     }
     
     private function _onLoupeClose(){
     	lp.close();
     	t360.initInteraction();
     }
    
  /**
     * mise à jour du scroll au changement de contenu
     */
 	private function _onUpdateContent(){
		asClipScollerb.onChanged();
	}
	
	/**
	 * sur commande de changement brutal de scroll :  correction du bug conservation du clic fantome des textfield
	 */
	private function _onMoveDone(src:ClipScoller,ypos:Number){
		src.toHidePlace();
		htmlContent.regen(Delegate.create(src, src.replaceTo,ypos));
	}   

	/**
	 * chargement réussi du xml	 */
	private function _successData(src:SimpleXML,conteneur:Object){
		_afficheContenu(conteneur);
	}
	
	
}