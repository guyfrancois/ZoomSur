/**
 *
 */
import Pt.html.Render;
 import Pt.Parsers.DataStk;
import org.aswing.util.Delegate;
import site.connexe.TransContent;
import org.aswing.Event;
import Pt.Tools.ClipScollerDerouleur;
import Pt.Parsers.SimpleXML;
import Pt.Tools.ClipScoller;
import Pt.Tools.Clips;
import Pt.Tools.Chaines;
import media.FluxVideo;
import Pt.image.ImageLoader;
import  GraphicTools.Loupe;


/**
 * Gere l'affichage d'une popup crédit
 */
class site.connexe.DiapoMediaEtHtml  implements site.connexe.I_connexeContenu {

	private var htmlContent:Render;
	
	private var xmlFile:String;
	private var cssFile:String;
	private var htmlZone:MovieClip;
	private var fluxVideo:FluxVideo;
	
	
	private var asClipScollerb:Pt.Tools.ClipScoller;
	
	/**
	 * @param clip ecran qui contiendra le contenu	 */
	public function DiapoMediaEtHtml(clip:MovieClip,xmlFile:String,cssFile:String) {
	
		this.xmlFile=xmlFile;
		this.cssFile=cssFile;
		
		htmlZone=clip.attachMovie("ecranDiapoMediaHtml","htmlZone",1);
		fluxVideo=new FluxVideo(true,htmlZone.clipVideo,htmlZone.img._width,htmlZone.img._height,ImageLoader.ALIGNCENTER,ImageLoader.ALIGNBOTTOM,ImageLoader.SCALLIN);
		htmlContent=new Render(htmlZone.htmlContent.texte,cssFile);
        htmlContent.addEventListener(Render.ON_READY,_onUpdateContent,this);
       	asClipScollerb=new ClipScoller(htmlZone.htmlContent,true,"scroller_texte",0,-htmlZone.htmlContent.masque._y);
       	asClipScollerb.addEventListener(ClipScoller.ON_MOVEDONE,_onMoveDone,this);
       	htmlZone.btnZoom._visible=false;
       	htmlZone.btn_suiv._visible=false;
       	htmlZone.btn_prec._visible=false;
		htmlContent.clear();
		asClipScollerb.onChanged();
	    loadContent(xmlFile);
	   
	   fluxVideo.addEventListener(FluxVideo.ON_UPDATE,_onUpdateVideo,this)
	}
	
	/**
	 * suppression du contenu obsoléte	 */
	public function remove(){
		fluxVideo.stop();
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
		
		afficheMedias(data.media,data.legende);
    	htmlContent.initialise(data.html[0]);
    	
    	if (data.timecodes!=undefined) {
    		timecodes=data.timecodes[0].at;
    	}
    }	
    private var timecodes:Array;
    
    private var _mediaArr:Array;
    private var _legendArr:Array;
    private function afficheMedias(mediaArr:Array,legendArr:Array) {
    	_mediaArr=mediaArr;
    	_legendArr=legendArr;
    	if (_mediaArr.length>1) {
    		 	htmlZone.btn_suiv._visible=true;
       			htmlZone.btn_prec._visible=true;
       			htmlZone.btn_suiv.onRelease=Delegate.create(this,_onSuiv);
       			htmlZone.btn_prec.onRelease=Delegate.create(this,_onPrec);
    	}
    	afficheMedia(0);
    }
    
    private function _onSuiv() {
    	afficheMedia(_currentId++>=_mediaArr.length?0:_currentId++);
    }
    private function _onPrec() {
    	afficheMedia(_currentId--<0?_mediaArr.length-1:_currentId--);
    }
    private var _currentId:Number;
    private function afficheMedia(mediaId:Number){
    	_currentId=mediaId;
    	var media:Object=_mediaArr[mediaId];
    	if (htmlZone.img._img_!=undefined) {
    		htmlZone.img._img_.removeMovieClip();	
    	}
    	
    	Clips.setTexteHtmlCss(htmlZone.legende.texte,"style.css",_legendArr[mediaId].text);
    	if (Chaines.fileIsPhoto(media.src) || Chaines.fileIsAnim(media.src)) {
			fluxVideo.stop();
			htmlZone.img._visible=true;
			htmlZone.clipVideo._visible=false;
			
			//cible:MovieClip,path:String,maxWidth:Number,maxHeight:Number,hAlign:Number,vAlign:Number,scaleMode:Number,swfWidth:Number,swfHeight:Number
			var il:ImageLoader=new ImageLoader(htmlZone.img.createEmptyMovieClip("_img_",10),media.src,htmlZone.img._width,htmlZone.img._height,ImageLoader.ALIGNCENTER,ImageLoader.ALIGNBOTTOM,ImageLoader.SCALLIN);
// TODO gerer le bouton loupe	
			if (media.hd) {
				htmlZone.btnZoom._visible=true;
				htmlZone.btnZoom.onRelease=Delegate.create(this,_onLoupe,media,htmlZone.img._img_)
			} else {
				htmlZone.btnZoom._visible=false;
			}		
		} else {
			
			htmlZone.img._visible=false;
			htmlZone.clipVideo._visible=true;
			fluxVideo.start(media.src,true);
			
		}
		
		
    }
    
    /**
     * lancement de la loupe     */
     private var lp:Loupe;
     private var loupeClip:MovieClip;
    
     private function _onLoupe(media:Object,cible:MovieClip) {
     	loupeClip=cible._parent.attachMovie("loupe","loupeClip",100);
     	loupeClip.btns.btn_x.onRelease=Delegate.create(this,_onLoupeClose);
     	loupeClip._x=Math.floor(cible._x+(cible.width-loupeClip._width)/2);
    	loupeClip._y=Math.floor(cible._y+(cible.height-loupeClip._height)/2);
    	
     	lp=new Loupe(loupeClip,cible,media);
     	lp.addEventListener(Loupe.ON_READY,openLoupe,this)
     }
     
     private function openLoupe(){
     	_root.loader._visible=false;
     	 lp.open();
     }
     
     private function _onLoupeClose(){
     	lp.close();
     }
     /**
      * Gestion du texte Associé à une video en timecode
      *       */
      var lastTimeCodeRef:Number;
      private function findCurrentText(time:Number):Number {
      //	trace("site.connexe.MediaEtHtml.findCurrentText("+time+")");
      	var _timecodeRef:Number=0;
      	if (timecodes) {
      		while (_timecodeRef<timecodes.length && timecodes[_timecodeRef].time<=time) {
      			_timecodeRef++;
      		}
      		
      		return _timecodeRef-1;
      	} else {
      		return null
      	}
      } 
      
      
     /**
      * 
      *       */
      private function _onUpdateVideo() {
      	fluxVideo.position();
      	var newTimeCodeRef:Number=findCurrentText(fluxVideo.position());
      	if (lastTimeCodeRef!=newTimeCodeRef) {
      		// update TexteHtml avec timecode
      		trace("site.connexe.MediaEtHtml._onUpdateVideo()"+lastTimeCodeRef+" "+newTimeCodeRef+" at"+fluxVideo.position());
      		lastTimeCodeRef=newTimeCodeRef;
      		updateHtmlTextTimeCode();
      	}
      }
      
      private function updateHtmlTextTimeCode() {
      	var data:Object=timecodes[lastTimeCodeRef].time
      	htmlContent.clear();
		asClipScollerb.onChanged();
		htmlContent.initialise(timecodes[lastTimeCodeRef]);
		
      }
    
    /**
     * mise à jour du scroll au changement de contenu     */
 	private function _onUpdateContent(){
		asClipScollerb.onChanged();
	}
	
	/**
	 * sur commande de changement brutal de scroll :  correction du bug conservation du clic fantome des textfield	 */
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