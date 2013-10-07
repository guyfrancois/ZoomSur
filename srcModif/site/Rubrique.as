/**
 *
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import org.aswing.util.Delegate;
import Pt.animate.ClipByFrame;

import Pt.Parsers.XmlTools;
import Pt.Parsers.SimpleXML;

import Pt.Tools.Clips;
import site.RubContent;
import GraphicTools.MenuPlat;

import Pt.animate.CBFReplaceClip;
import Pt.Temporise;

/**
 * definition de gestionnaire de rubriques (ecran rubrique)
 */
class site.Rubrique extends EventDispatcher {
	static var ON_LOADED:String="onLoaded"; // xml chargé
	
	private var cbfTrans:ClipByFrame;
	
	static var IMG_CLOSE:Number=1;
	static var IMG_CHRONIQUE_CLOSE:Number=11;
	static var IMG_CHRONIQUE:Number=16;
	static var IMG_CHRONIQUE_AUTRE:Number=17;
	static var IMG_AUTRE:Number=50;
	
	static var RUBRIQUESCROLL:String="ScrollerEtape";
	/**
	 * evenement selection d'un contenu à afficher	 */
	public static var ON_SELECT:String = "onSelect";
	private var clip:MovieClip;
	
	private var xmlData:Object;
	
	private var chronique:RubContent;
	private var journal:RubContent;
	private var portrait:RubContent;
	private var theme:RubContent;
	private var temoignage:RubContent;
	
	private var menuRub:MenuPlat;
	
	//private var chronique:RubContent;
	//private var chronique:RubContent;
	
	public function getXMLData(){
		return xmlData;
	}
	
	

	
	public function Rubrique(clip:MovieClip) {
		super();
		this.clip=clip;
		IMG_AUTRE=clip._totalframes;
		menuRub=new MenuPlat(clip.menuEtapes,undefined,{IMG_OUT:2,IMG_OVER:5,IMG_PRESS:7,IMG_ON:7,IMG_OFF:2,IMG_DEAD:1},undefined,false);
		menuRub.addEventListener(MenuPlat.ON_MENUPRESS,onMenuPressed,this);
		cbfTrans=new ClipByFrame(clip);
		
		cbfTrans.addEventListener(ClipByFrame.ON_STOP,onCBFStop,this);
		cbfTrans.addEventListener(ClipByFrame.ON_PREVFRAME,onCFBClosing,this)
		
		chronique=new RubContent(clip.chronique,RUBRIQUESCROLL,"content_");
		chronique.addEventListener(RubContent.ON_CLOSE,onCloseRubChronique,this);
		
		journal=new RubContent(clip.journal,RUBRIQUESCROLL,"content_");
		journal.addEventListener(RubContent.ON_CLOSE,onCloseRubContent,this);
		
		portrait=new RubContent(clip.portrait,RUBRIQUESCROLL,"content_");
		portrait.addEventListener(RubContent.ON_CLOSE,onCloseRubContent,this);
		
		theme=new RubContent(clip.theme,RUBRIQUESCROLL,"content_");
		theme.addEventListener(RubContent.ON_CLOSE,onCloseRubContent,this);
		
		temoignage=new RubContent(clip.temoignage,RUBRIQUESCROLL,"content_");
		temoignage.addEventListener(RubContent.ON_CLOSE,onCloseRubContent,this)
		
		trace("cine.Rubrique("+clip+")");
		
				
	}
	
		
	
	
	
	/**
	 * Ouverture de rubrique
	 * @param listeMenu  adresse complete (jusqu'a contenu final de la ressource à ouvrire)	 */
	public function transRubrique(){// file:String){
		//loadEtape(file);
		trace("site.Rubrique.transRubrique()");
		initialize();
	}
	
	private var _callback:Function;
	public function transClose(_callback:Function){
		this._callback=_callback;
		dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[IMG_CLOSE]));
		//Pt.animate.QualitySwap.low();
		_currentContent.transClose();
	}
	
	
	private function closeRubrique(){
		menuRub.enable(true);
		
		cbfTrans.goto(IMG_CLOSE,IMG_CHRONIQUE);
		
	}
	
	
	private function initialize (){
		trace("site.Rubrique.initialize()");
		
		menuRub.setNoAction(0);
		_currentContent=chronique;
		_currentContentData={xmlData:xmlData.chronique,defaultTitre:_root.xmlData.chronique[0].text};
		if (cbfTrans.goto(IMG_CHRONIQUE)) {
				Pt.animate.QualitySwap.low();
				dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[IMG_CHRONIQUE]));
				
		}
	}
	
	
	private var fileName:String;
	private var idEtape:Number;
	public function loadEtape(id:Number){
		idEtape=id;
		this.fileName=_root.xmlData.etape[Number(id) ].src;
    	var loaderXML:SimpleXML=new SimpleXML("ressources");
		loaderXML.addEventListener(SimpleXML.ON_SUCCESS,successData,this)
		loaderXML.addEventListener(SimpleXML.ON_FAILED,failedData,this)
		loaderXML.load(fileName);
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
	

	 	pour desactiver une rubrique :
	 		ne pas mettre le bloc correspondant,
	 		le titre du bouton (alors grisé) sera celui de ressources
	 
	 
	 */
    
    private function initBtnTexteEtat(btn:GraphicTools.BOverOutPress,data:Object,defaut:String) {
    	var lClip:MovieClip;
		var texte:String;
		var texteOver:String;
		
		texteOver=data.titreOver[0].text;
    	texte=data.titre[0].text;
    	 
    	 lClip=btn.getBtn();
		
		 
		 if (texte==undefined) {
		 	 texte=defaut;
		 }
		
		 if (data==undefined) {
		 	 btn.dead=true
		 } else {
		 	 btn.dead=false;
		 }
		
		 if (texteOver==undefined) {
		 	lClip.over.enabled=false;
		 } else {
		 	lClip.over.enabled=true;
		 	lClip.over.texte.autoSize=Clips.getAutoSize(lClip.over.texte);
		 	Clips.setTexteHtmlCss(lClip.over.texte,"style.css",texteOver,Delegate.create(this, onTitreAdded,lClip.over));
		 }
		 
		 lClip.texte.texte.autoSize=Clips.getAutoSize(lClip.texte.texte);
		 Clips.setTexteHtmlCss(lClip.texte.texte,"style.css",texte,Delegate.create(this, onTitreAdded,lClip.texte));
    	
    }
    
    private function successData(src:SimpleXML,conteneur:Object){
		trace("site.Rubrique.successData(src, conteneur)");
		_root.currentXmlData=this.xmlData=conteneur;
		/**
		 * initier les boutons optionnels		 */

 		
 		initBtnTexteEtat(menuRub.getBtn(0),xmlData.chronique[0],_root.xmlData.chronique[0].text);
 		initBtnTexteEtat(menuRub.getBtn(1),xmlData.journal[0],_root.xmlData.journal[0].text);
 		initBtnTexteEtat(menuRub.getBtn(2),xmlData.portrait[0],_root.xmlData.portrait[0].text);
		initBtnTexteEtat(menuRub.getBtn(3),xmlData.theme[0],_root.xmlData.theme[0].text);
		initBtnTexteEtat(menuRub.getBtn(4),xmlData.temoignage[0],_root.xmlData.temoignage[0].text);
					 
		dispatchEvent(ON_LOADED,new Event(this,ON_LOADED,[idEtape]));
		//initialize();
	}
	private function failedData(conteneur:Object){
		trace("site.Rubrique.failedData(conteneur)");
	}
	
	
	private function onTitreAdded (clipTexte:MovieClip){
		//var height=clipBtn.texte._height
		var tf:TextField=clipTexte.texte;
		
		tf._y=-tf.textHeight-4;
		clipTexte.fond._y=tf._y-2;
		clipTexte.fond._height=tf.textHeight+4+2;
		clipTexte.fond._width=tf.textWidth+4;
		
	}
	
	
	
	private var _currentContent:RubContent;
	private var _currentContentData:Object;
	
	
	private function onCloseRubChronique(src:RubContent){
		if (_currentContent==src) {
			_currentContent=undefined;
			_currentContentData=undefined;
		} 
		if (_currentContent!=undefined) {
			// c'est un autre contenu de rubrique, transiter vers autre
			if (cbfTrans.goto(IMG_AUTRE,IMG_CHRONIQUE_AUTRE)) {
				dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[IMG_AUTRE]));
			//	Pt.animate.QualitySwap.low();
			} else {
				_currentContent.setContent(_currentContentData);
			}
			
		} else {
			// fermeture de rubrique
			closeRubrique();
		}
	}
	
	
	private function onCloseRubContent(src:RubContent){
		if (_currentContent==src) {
			_currentContent=undefined;
			_currentContentData=undefined;
		} 
		if (_currentContent==chronique) {
			// c'est un contenu de chronique , transiter vers chronique
				if (cbfTrans.goto(IMG_CHRONIQUE)) {
					dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[IMG_CHRONIQUE]));
			//		Pt.animate.QualitySwap.low();
				} else {
					_currentContent.setContent(_currentContentData);
				}
		} else	if ( _currentContent != undefined){
			// c'est une autre rubrique
			if (cbfTrans.goto(IMG_AUTRE,IMG_CHRONIQUE_AUTRE)) {
				dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[IMG_AUTRE]));
			//	Pt.animate.QualitySwap.low();
			} else {
				_currentContent.setContent(_currentContentData);
			}
			
		} else {
			// fermeture de rubrique
			closeRubrique();
		}
	}
	
	
	private function _selectContent(content:RubContent,contentData:Object) {
		var prevContent:RubContent=_currentContent
		var prevContentData:Object=_currentContentData;
		
		_currentContent=content;
		_currentContentData=contentData;
		
		if (prevContent==undefined) {
			_currentContent.setContent(_currentContentData);
		} else {
			prevContent.transClose()
		}

		
	}
	
	private function _onSelectionneChronique() {
		
		_selectContent(chronique,{xmlData:xmlData.chronique,defaultTitre:_root.xmlData.chronique[0].text});
	}
	
	private function _onSelectionneJournal() {
		
		_selectContent(journal,{xmlData:xmlData.journal,defaultTitre:_root.xmlData.journal[0].text});
	}
		
	
	
	private function _onSelectionnePortait() {
		
		_selectContent(portrait,{xmlData:xmlData.portrait,defaultTitre:_root.xmlData.portrait[0].text});
		
	}
	
	private function _onSelectionneTheme() {
		
		_selectContent(theme,{xmlData:xmlData.theme,defaultTitre:_root.xmlData.theme[0].text});

	}
	
	private function _onSelectionneTemoignage() {
		
		_selectContent(temoignage,{xmlData:xmlData.temoignage,defaultTitre:_root.xmlData.temoignage[0].text});

	}
	

	
	private function onMenuPressed (src:MenuPlat,id:Number){
		switch (id) {
			case 0 :
				
				_onSelectionneChronique();
			break;
			case 1 :
				_onSelectionneJournal();
				prepareGravure(id);
			break;
			case 2 :
				_onSelectionnePortait();
				prepareGravure(id);
			break;
			case 3 :
				_onSelectionneTheme();
				prepareGravure(id);
			break;
			case 4 :
				_onSelectionneTemoignage();
				prepareGravure(id);
			break;
		}
		
	}
	
	private function onCFBClosing(src:ClipByFrame,imageFin,currentframe) {
		if (imageFin==IMG_CLOSE ) {
			if (currentframe==IMG_CHRONIQUE_CLOSE) {
				_callback();
			}
		}
		
	}
	
	private function onCBFStop(src:ClipByFrame,imageStop:Number){
		Pt.animate.QualitySwap.hight();
		switch (imageStop) {
			case IMG_AUTRE :
				_currentContent.setContent(_currentContentData);
			break;
			case IMG_CHRONIQUE :
				effaceGravures();
			// normalement c'est déjà ça mais j'ai pas le temps de contrôler
				_currentContent=chronique;
				_currentContentData={xmlData:xmlData.chronique,defaultTitre:_root.xmlData.chronique[0].text}
				_currentContent.setContent(_currentContentData);
				//chronique.setContent(xmlData.chronique);
			break;
			case IMG_CLOSE :
				effaceGravures();
				_currentContent=undefined;
				_currentContentData=undefined;

				
			break;
			default :
			break; 
		}
	
	}
	
	
	/** gestion gravures
	 * 	 */
	private function effaceGravures(){
		var imagesClip:MovieClip=clip._parent.transGravure.image;
		for (var i : String in imagesClip) {
			imagesClip[i]._visible=false;
			imagesClip[i]._alpha=0;
		}
	}
   	private function prepareGravure(id:Number) {
		var imagesClip:MovieClip=clip._parent.transGravure.image;
		imagesClip['img_'+id].swapDepths(imagesClip.getNextHighestDepth()-1);
		afficheImgGravure(imagesClip['img_'+id]);
		
		for (var i : String in imagesClip) {
			if (i!==('img_'+id) ) {
				if (imagesClip[i]._visible) {
					effaceImgGravure(imagesClip[i]);
				}
			} 
		}
	}
	
	private function effaceImgGravure(clipImage:MovieClip){
		var cbfReplace:CBFReplaceClip=new CBFReplaceClip(clipImage,{_alpha:0},{_alpha:100});

		var tempo:Temporise=new Temporise(5,Delegate.create(this, this.renderEffaceImgGravure,cbfReplace))
	}

	private function afficheImgGravure(clipImage:MovieClip){
		clipImage._visible=true;
		clipImage._alpha=0;
		var cbfReplace:CBFReplaceClip=new CBFReplaceClip(clipImage,{_alpha:100},{_alpha:0});

		var tempo:Temporise=new Temporise(5,Delegate.create(this, this.renderEffaceImgGravure,cbfReplace))
	}
	private function renderEffaceImgGravure(tempo:Temporise,count:Number,cbfReplace:CBFReplaceClip){
		trace("site.Rubrique.renderEffaceImgGravure(tempo, "+count+", cbfReplace)");
		cbfReplace._render(count/10);
		trace("cbfReplace.getClip()._alpha "+cbfReplace.getClip()._alpha);
		if (count==10) {
			tempo.destroy();
			if (cbfReplace.getClip()._alpha==0) {
				cbfReplace.getClip()._visible=false;
			}
			
		}
		
	}
   
}