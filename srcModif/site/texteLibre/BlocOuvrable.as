/**
 * @author Administrator    , pense-tete
 * 2 avr. 08
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
import Pt.animate.Transition;
import GraphicTools.BOverOutPress;
import Pt.html.CssCollect;
import org.aswing.geom.Point;

/**
 * 
 */
class site.texteLibre.BlocOuvrable extends EventDispatcher implements site.ITextType {
	/**
	 * envement lancé losque le bloc change de taille 
	 * function onChange(src:ITextType,isOpen:Boolean)	 */
	static var ON_CHANGE:String="onChange";
	
	
	/** images du boutons sequence */
	

	static var BLOCTEXTEOUVRE:String="BlocTexteOuvre"; // bloc ouvrable, animation
	static var BLOCTEXTE:String="BlocTexteSansTitre"; // bloc sans titre 
	
	// sur 2 images
	static var BLOCCHAPITRETEXTE:String="blocChapitreTexte"; // bloc de texte
	static var BLOCCHAPITRETEXTESANSTITRE:String="blocChapitreTexteSansTitre"; // bloc de texte
	
	
	
	static var ICOANIMATION:String="icoAnimation"; // bloc de texte
	
	

	private var clip:MovieClip;
	private var content:MovieClip;
	private var inContent:MovieClip;
	private var dataXML:Object;
	private var btnTitre:BOverOutPress;
	private var trans:Transition;
	
	public function BlocOuvrable(clip:MovieClip) {
		super();
		this.clip=clip;
	}
	
	public function getClip(){
		return content;
	}
	
	private var listePara:Array;
	
	
	/*
	public function selectParaYPos(id:Number):Number {
		for (var i : Number = 0; i < listePara.length; i++) {
			if (id==i) {
				listePara[i].gotoAndStop(2);
			} else {
				listePara[i].gotoAndStop(1);
			}
		}
		if (id==undefined) return 0;
		
		return content._y+content.inContent._y+listePara[id]._y;
	}
	*/
	private var _id:Number;
	public function closePara() {
		_id=undefined;
		for (var i : Number = 0; i < listePara.length; i++) {
			listePara[i].gotoAndStop(1);
		}
		
	}
	
	public function getOpenPara():Number {
		return _id;
	}
	public function openPara(id:Number) {
		_id=id;
		for (var i : Number = 0; i < listePara.length; i++) {
			if (id==i) {
				listePara[i].gotoAndStop(2);
			} else {
				listePara[i].gotoAndStop(1);
			}
		}
	}
	
	public function getYPos(clipRef:MovieClip){
		trace("site.texteLibre.BlocOuvrable.getYPos("+clipRef+")"+content+" "+listePara[_id]);
		var pt:Point=new Point();
		for (var i : Number = 0; i < listePara.length; i++) {
			if (_id==i) {
				listePara[i].gotoAndStop(2);
			} else {
				listePara[i].gotoAndStop(1);
			}
		}
		if (listePara[_id]==undefined ) {
			
			content.localToGlobal(pt);
			clipRef.globalToLocal(pt);
			return pt.y;	
		} else {
			//var addTitre:Number=0;
			if (content.titre!=undefined && _id==0) {
				// TODO : decalage de quelques pixels, pourquoi ?
				content.localToGlobal(pt);
				//pt.y+=content.titre.texte.y;
				//addTitre=content.titre._height;
				trace("ADDTITRE")
			} else {
				
				listePara[_id].localToGlobal(pt);
				
			}
			clipRef.globalToLocal(pt);
			return pt.y;	
		}
	}
	
	
	/**
	 * recois les donnée d'1 chapitre	 */
	private var hasTitre:Boolean;
	public function setTextes(dataXML:Object) {
		
		hasTitre=dataXML.titre[0].text!=undefined;
		this.dataXML=dataXML;
		var depth:Number=clip.getNextHighestDepth();
		
		if (hasTitre) {
			content=clip.attachMovie(BLOCTEXTEOUVRE,"chapitre_"+depth,depth,{_y:clip._height});
			initTrans(content);
			initializeBtnTitre(content.titre);
			content.titre.texte.autoSize=Clips.getAutoSize(content.titre.texte);
			Clips.setTexteHtmlCss(content.titre.texte,"style.css",dataXML.titre[0].text);
			content.titre.fond._height=content.titre.texte._height-content.titre.fond._y*2
			closeFond();
		} else {
			content=clip.attachMovie(BLOCTEXTE,"chapitre_"+depth,depth,{_y:clip._height});
			addInContentSansTitre();
		}
		
		//Clips.setTexteHtmlCss(content.texte,"style.css",texte,Delegate.create(ltextScoller, ltextScoller.onChanged));		
		
	}
	private function addInContentSansTitre(){
		inContent=content.createEmptyMovieClip("inContent",1);
		inContent._y=0;

		innerDispose(dataXML.texte[0],"texte",0,0,inContent);
	}
	
	private function addInContentTitre(){
		content.titre.gotoAndStop(2);
		inContent=content.createEmptyMovieClip("inContent",1);
		inContent._y=content.titre._height+content.titre._y;
		innerDispose(dataXML.texte[0],"texte",0,0,inContent);

	}
	private function innerDispose(phtml:Object,pnodeName:String,px:Number,py:Number,pparent:MovieClip){
       trace("innerDispose(html, "+pnodeName+", "+px+", "+py+", "+pparent+")");
      listePara=new Array();
      var html:Object=phtml;
      var nodeName:String=pnodeName;
      var x:Number=px;
      var y:Number=py;
      var parent:MovieClip=pparent;
      
      while (html!=undefined ) {
     
        var depth:Number=parent.getNextHighestDepth();
        var clipNode:MovieClip;
        var dx:Number=0;
        var dy:Number=0;
        switch (nodeName){
         case "texte" :
         	var el_biblio:String;
         	if (hasTitre) {
         		el_biblio=BLOCCHAPITRETEXTE;
         	} else {
         		el_biblio=BLOCCHAPITRETEXTESANSTITRE;
         	}
         	clipNode=parent.attachMovie(el_biblio,nodeName+"_"+depth,depth,{_x:x+(hasTitre?10:0),_y:y});
         	clipNode.texte.autoSize=Clips.getAutoSize(clipNode.texte);
         	Clips.setTexteHtmlCss(clipNode.texte,"style.css",html.text); // immediat, la css est déjà chargé
         	clipNode.fond.forme._height=clipNode.texte._height;
         break;
         case "sequence" :
         	clipNode=parent.attachMovie(ICOANIMATION,nodeName+"_"+depth,depth,{_x:x,_y:y});
         	clipNode._x=parent._width-clipNode._width;
         	addBtnSeq(clipNode,html.src);
         break;
        }
        listePara.push(clipNode)
		y=parent._height;
		nodeName=html.nextNode.nodeName;    
	  	html=html.nextNode.node;
      
      }
      content.fond._height=parent._y+parent._height-(content.fond._y*2);
	}
	
	
	/** initialisation des elemets inclus */
	private function initTrans(lclip:MovieClip){
		if (trans!=undefined) return;
		trans=new Transition(content);
		trans.addEventListener(Transition.ON_CLOSE,onTransClosed,this);
		trans.addEventListener(Transition.ON_OPEN,onTransOpened,this);
	}
	
	private function initializeBtnTitre(lClip:MovieClip){
		if (btnTitre!=undefined) return;
		btnTitre=new BOverOutPress(lClip,true,false,null,false);
		btnTitre.addEventListener(BOverOutPress.ON_RELEASE,onTitreReleased,this);
		

	}
	
	private function addBtnSeq(lClip:MovieClip,seq:String){
		var btnSeq:BOverOutPress=new BOverOutPress(lClip,true,false,null,false);
		
		btnSeq.addEventListener(BOverOutPress.ON_RELEASE,Delegate.create(this, onBtnSeqReleased,seq),this);
		

	}
	
	/** interface */
	public function open(){
		if (trans.isClose()) {
			trans.open();
		}
		
	}
	
	public function isOpen():Boolean{
		return !trans.isClose();
	}
	
	public function close():Boolean{
		if (trans.isOpen()){
			trans.close();
			return true;
		} else {
			return false;
		}
	}
	
	
	function destroy(){
		content.removeMovieClip();
		delete trans;
		delete btnTitre;
		
	}
	
	
	
	/** gestions des evenements */
	private function onTitreReleased(){
		if (trans.isOpen()) {
			close();
		} else {
			open();
		}
	}
	
	private function onBtnSeqReleased(src:BOverOutPress,clip:MovieClip,seq:String) {
		trace("site.texteLibre.BlocOuvrable.onBtnSeqReleased("+src+","+clip+","+seq+")");
		SWFAddress.setSequence(seq);
	}
	
	
	private function closeFond(){
		content.fond._height=content.titre._y+content.titre._height-(content.fond._y*2);
	}
	private function onTransClosed(){
		content.titre.gotoAndStop(1);
		inContent.removeMovieClip();
		closeFond();
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE,[false]));
	}
	private function onTransOpened(){
		addInContentTitre();
		openPara(_id);
		dispatchEvent(ON_CHANGE,new Event(this,ON_CHANGE,[true]));
	}
}