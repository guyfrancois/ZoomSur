/**
 * @author Administrator    , pense-tete
 * 1 avr. 08
 */
import site.ITextType;
import org.aswing.util.Delegate;
import org.aswing.EventDispatcher;
import Pt.html.CssCollect;
import Pt.Parsers.DataStk;
import Pt.Tools.Clips
import GraphicTools.ToolTip;

import Pt.conteneur.accordeon.HeaderAccordeon;
import Pt.conteneur.accordeon.AccordeonContent;
import Pt.conteneur.accordeon.AccordeonItem;
import Pt.conteneur.AccordeonV;
import GraphicTools.BOverOutPress;


/**
 *  utilise textScroller pour afficher les textes en continue, tout en html
 */
class site.TexteAccordeon extends EventDispatcher implements site.ITextType {
	public static var HIDEBTNSEQ:String="hideBtnSequence";
	public static var SHOWBTNSEQ:String="showBtnSequence";
	
	private var clip:MovieClip;
	public static var CONTENTTYPE:String="accordeonContener";
	public static var CONTENTITEMTYPE:String="accordeonItem";
	public static var BLOCCHAPITRETEXTE:String="accordeonChapitreTexte"; // bloc de texte
	public static var ICOANIMATION:String="icoAnimation";
	
	private var accordeonVertical:AccordeonV;
	private var selTextListenner:Object;
	private var selAnimListenner:Object;
	
	private var _btnAnimVisibility:Boolean=false;
	
	
	public function TexteAccordeon(clip:MovieClip) {
		this.clip=clip;
		selTextListenner=DataStk.event().addEventListener("SEL_TEXT",onSelText,this);
		selAnimListenner=DataStk.event().addEventListener("SEL_ANIM",onSelAnim,this);
		var globalListenner:Object=new Object();
		globalListenner[HIDEBTNSEQ]=Delegate.create(this,function (){this.setBtnAnimVisibility(false)});
		globalListenner[SHOWBTNSEQ]=Delegate.create(this,function (){this.setBtnAnimVisibility(true)});
		
		DataStk.event().addEventListener(globalListenner);
		
	}
	
	/** METHODES D'INTERFACES */
	public function setTextes(dataXML:Object) {
		CssCollect.load("style.css",Delegate.create(this, _setTextes,dataXML));
	}
	
	private var arrayChapitrePara:Array;
	private var arrayChapitreAnim:Array;
	private function _setTextes(css:TextField.StyleSheet,dataXML:Object) {
		var content:MovieClip=clip.attachMovie(CONTENTTYPE,"content",1);
		var chapitres:Array=dataXML.chapitre;
		arrayChapitrePara=new Array();
		arrayChapitreAnim=new Array();
		
		accordeonVertical= new AccordeonV(content.texte);
		for (var i : Number = 0; i < chapitres.length; i++) {
			var item:MovieClip=content.texte.attachMovie(CONTENTITEMTYPE,"item_"+i,i);
			setTitre(chapitres[i],item);
			var ha:HeaderAccordeon=new HeaderAccordeon(item.titre);
			//trace("chapitres["+i+"].titre[0].seq"+chapitres[i].titre[0].seq)
			ha.addEventListener(HeaderAccordeon.ON_CHANGE,Delegate.create(this, onHeaderSelect,i),this);
			// TODO : affecter le contenu
			setContenu(chapitres[i],item.contenu,i);
			item.contenu.texte._visible=false;
			var ac:AccordeonContent=new AccordeonContent(item.contenu);
			accordeonVertical.addItem(item,ha,ac);
		}
		accordeonVertical.resize(0,content.masque._height)
		accordeonVertical.open(0,true);
		setBtnAnimVisibility(_btnAnimVisibility);
	}
	
	private function onHeaderSelect(src:HeaderAccordeon,eventParam,idChapitre:Number) {
		//trace("site.TexteAccordeon.onHeaderSelect("+src+", "+idChapitre+")");
		SWFAddress.setSequence(site.Appli.CMDPAUSE)
		//Send.event("FINDCMD,SEL_TEXT,"+idChapitre+","+0);
	}
	/**
	 * affecter le titre de chapitres[i]	 */
	private function setTitre(dataXML:Object,item:MovieClip) {
		var tf:TextField=item.titre.texte.texte;
		tf.autoSize=Clips.getAutoSize(tf);
		Clips.setTexteHtmlCss(tf,"style.css",dataXML.titre[0].text);
		item.titre.fond._height=item.titre._height;
		
	}
	/**
	 * ajouter le contenu de chapitres[i]	 */
	private function setContenu(dataXML:Object,itemContent:MovieClip,idChapitre:Number){
		
		innerDispose(dataXML.texte[0],"texte",0,0,itemContent.texte,idChapitre);
		
	}
	
	
	private function innerDispose(phtml:Object,pnodeName:String,px:Number,py:Number,pparent:MovieClip,idChapitre:Number){
       trace("innerDispose(html, "+pnodeName+", "+px+", "+py+", "+pparent+")");
      var listePara:Array=new Array();
      var listeAnim:Array=new Array();
     
      var html:Object=phtml;
      var nodeName:String=pnodeName;
      var x:Number=px;
      var y:Number=py;
      var parent:MovieClip=pparent;
      var idText:Number=0;
      var textCMD:String;
      
      while (html!=undefined ) {
     
        var depth:Number=parent.getNextHighestDepth();
        var clipNode:MovieClip;
        var dx:Number=0;
        var dy:Number=0;
        switch (nodeName){
         case "texte" :
           	clipNode=parent.attachMovie(BLOCCHAPITRETEXTE,nodeName+"_"+depth,depth,{_x:Math.floor(x),_y:Math.floor(y)});
         	clipNode.texte.autoSize=Clips.getAutoSize(clipNode.texte);
         	Clips.setTexteHtmlCss(clipNode.texte,"style.css",html.text); // immediat, la css est déjà chargé
         	clipNode.fond._height=clipNode._height;
         	 listePara.push(clipNode)
         	 if (html.seq!="false") {
         	 	addTextSeq(clipNode.fond,idChapitre,idText);
         	 	textCMD="SEL_TEXT,"+idChapitre+","+idText;
         	 }
         	 idText++;
         break;
         case "sequence" :
         	clipNode=parent.attachMovie(ICOANIMATION,nodeName+"_"+depth,depth,{_x:x,_y:Math.floor(y)});
         	clipNode._x=Math.floor(parent._width-clipNode._width);
         	listeAnim.push(clipNode);
         	addBtnSeq(clipNode,html.src,html.ref,textCMD);
         	
         break;
        }
       
		y=parent._height;
		nodeName=html.nextNode.nodeName;    
	  	html=html.nextNode.node;
      
      }
      arrayChapitrePara.push(listePara);
      arrayChapitreAnim.push(listeAnim);
     
      //content.fond._height=parent._y+parent._height-(content.fond._y*2);
	}
	
	

	
	public function destroy() {
		DataStk.event().removeEventListener(selTextListenner);
		DataStk.event().removeEventListener(selAnimListenner);
		
		clip.content.removeMovieClip();
	}
	
	//private var _tmpParagraph:Number;
	public function openBloc(id:Number,idPara:Number){
		//trace("site.TexteAccordeon.openBloc("+id+", "+idPara+")");
		
		closePara();
		if (id!=undefined) {
			_currentSeq.gotoAndStop(1);
			accordeonVertical.open(id);
		}
		if (idPara!=undefined) {
			openPara(idPara);
		}
		
		
	}
	
	
	
	private function findLegende(ref:String):String {
		var legendeArray:Array=DataStk.val(DataStk.DICO).legendeIco;
		for (var i:Number=0;i<legendeArray.length;i++) {
			if (legendeArray[i].src==ref) {
				return legendeArray[i].text
			}
		}
		return undefined
	}
	
	/* Gestion bouton sequence */
	private var _currentSeq:MovieClip;
	private function addBtnSeq(lClip:MovieClip,seq:String,ref:String,textCMD:String){
		
		var btnSeq:BOverOutPress=new BOverOutPress(lClip,true,false,null,false);
		btnSeq.addEventListener(BOverOutPress.ON_RELEASE,Delegate.create(this, onBtnSeqReleased,seq,textCMD),this);
		btnSeq.addEventListener(BOverOutPress.ON_OVER,onBtnSeqOver,this);
		btnSeq.addEventListener(BOverOutPress.ON_OUT,onBtnSeqOut,this);
		
		ToolTip.associer(btnSeq,findLegende(ref),'infoBulleIco',-30,-30,lClip.fond==undefined?lClip:lClip.fond);

	}
	
	private function onBtnSeqReleased(src:BOverOutPress,clip:MovieClip,seq:String,textCMD:String) {
		//trace("site.onBtnSeqReleased.onBtnSeqReleased("+src+","+clip+","+seq+")");
		Send.event(textCMD);
		_currentSeq.gotoAndStop(1);
		_currentSeq=src.getBtn();
		src.getBtn().gotoAndStop(3);
		
		SWFAddress.setSequence(seq);
	}
	private function onBtnSeqOver(src:BOverOutPress,clip:MovieClip) {
		//trace("site.onBtnSeqReleased.onTextSeqOver("+src+","+clip+")"+clip._parent._currentframe);
		if (src.getBtn()._currentframe!=3) {
			src.getBtn().gotoAndStop(2)
		}
	}
	private function onBtnSeqOut(src:BOverOutPress,clip:MovieClip) {
		//trace("site.onBtnSeqReleased.onTextOut("+src+","+clip+")"+clip._parent._currentframe);
		if (src.getBtn()._currentframe==2) {
			src.getBtn().gotoAndStop(1)
		}
	}
	
	/* Gestion texte sequence */
	
	
	private function addTextSeq(lClip:MovieClip,idChapitre:Number,idText:Number){
		//trace("site.TexteAccordeon.addTextSeq("+lClip+", seq)");
		//lClip.hitArea;
		var btnSeq:BOverOutPress=new BOverOutPress(lClip,true,false,null,false);
		
		btnSeq.addEventListener(BOverOutPress.ON_RELEASE,Delegate.create(this, onTextSeqReleased,idChapitre,idText),this);
		btnSeq.addEventListener(BOverOutPress.ON_OVER,onTextSeqOver,this);
		btnSeq.addEventListener(BOverOutPress.ON_OUT,onTextOut,this)
	}
	
	private function onTextSeqOver(src:BOverOutPress,clip:MovieClip) {
		//trace("site.onBtnSeqReleased.onTextSeqOver("+src+","+clip+")"+clip._parent._currentframe);
		if (src.getBtn()._currentframe!=3) {
			src.getBtn().gotoAndStop(2)
		}
	}
	private function onTextOut(src:BOverOutPress,clip:MovieClip) {
		//trace("site.onBtnSeqReleased.onTextOut("+src+","+clip+")"+clip._parent._currentframe);
		if (src.getBtn()._currentframe==2) {
			src.getBtn().gotoAndStop(1)
		}
	}

	private function onTextSeqReleased(src:BOverOutPress,clip:MovieClip,idChapitre:Number,idText:Number) {
		//trace("site.onBtnSeqReleased.onBtnSeqReleased("+src+","+clip+","+idChapitre+","+idText+")");
		
		Send.event("FINDCMD,SEL_TEXT,"+idChapitre+","+idText);
	}
	
	
	private function onSelText(src:DataStk,ibBloc:Number,idPara:Number){
		//trace("site.TexteAccordeon.onSelText(src, "+ibBloc+","+ idPara+")");
		openBloc(ibBloc,idPara);
	}
	
	private function setBtnAnimVisibility(visible:Boolean) {
		//trace("site.TexteAccordeon.setBtnAnimVisibility("+visible+")");
		_btnAnimVisibility=visible;
		for (var i : Number = 0; i < arrayChapitrePara.length; i++) {
			for (var j : Number = 0; j < arrayChapitreAnim[i].length; j++) {
				arrayChapitreAnim[i][j]._visible=visible;
			}
		}
		
		
	}
	
	private function onSelAnim(src:DataStk,ibBloc:Number,idAnim:Number){
		//trace("site.TexteAccordeon.onSelAnim(src, "+ibBloc+", "+idAnim+")"+_currentSeq+" "+accordeonVertical.current);
		if (accordeonVertical.current==ibBloc) {
			_currentSeq.gotoAndStop(1);
			_currentSeq=arrayChapitreAnim[accordeonVertical.current][idAnim];
			_currentSeq.gotoAndStop(3);
			//trace(_currentSeq)
		} else {
			//trace("SELECTION d'une Anim hors contexte : volet courant:"+accordeonVertical.current+" volet demandé :"+ibBloc)
		}
	}
	
	
	/* gestion des paragraphes */
	private var _currentParagraph:Number=0;
	public function closePara(){
		arrayChapitrePara[accordeonVertical.current][_currentParagraph].fond.gotoAndStop(1);
		
		
	}
	private function openPara(idPara:Number) {
		_currentSeq.gotoAndStop(1);
		_currentParagraph=idPara;
		var para:MovieClip=arrayChapitrePara[accordeonVertical.current][idPara];
		para.fond.gotoAndStop(3);
		accordeonVertical.getItem(accordeonVertical.current).content.scrollTo(para._y);
	}
	
	
	
	
	
}