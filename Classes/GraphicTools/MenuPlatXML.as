/**
 * @author Administrator    , pense-tete
 * 29 janv. 08
 */
import GraphicTools.MenuPlat;
import Pt.Parsers.XmlTools;
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
import Pt.image.ImageLoader;
import Pt.html.Analyse;
import Pt.Tools.Chaines;
import Pt.Parsers.DataStk;
import GraphicTools.ToolTip;
import Pt.animate.ClipByFrame;
/**
 * 
 */
class GraphicTools.MenuPlatXML extends MenuPlat {
	
	
	private var textMargeWidth:Number=8;
	private var textMargeHeight:Number=4;
	public var ToolTipMenu:String="ToolTipMenu";
	
	
	/**
	 * @param dataXML : structure du menu
	 * 		.skin : element de bibliotheque
	 * 		.maxChar : maximum de caractere d'un element
	 * 		.maxW : largeur max du menu avant retour à la ligne
	 * 		.btnHM : marge horizontal entre les btn si btnh pas defini
	 * 		.btnh : largeur (horizontal) des boutons , 0 pour faire une colonne
	 * 		.btnVM : marge vertical des boutons si btnv pas defini
	 * 		.btnv : taille (vertival) des boutons, 0 pour faire dune ligne
	 * 		
	 * 		.btn [
	 * 			{ico:nom de bib , img : image à charger, width:[false], height : [false] text : texte}
	 * 		]
	 * 		
	 * 			.width= false : empeche la redimension fond.forme en largeur
	 * 			.height= false : empeche la redimension fond.forme en hauteur	 */
	public function MenuPlatXML(clip:MovieClip,resetEnable:Number,imagesBtn:Object,dataXML:Object,reclic:Boolean)  {
		super(clip,resetEnable,imagesBtn,dataXML,true,reclic);
		//arrayBtnData=new Array();
		//initialize();
		
	}

	
	

	

	/** creer un lot de texte sur coupure de mots */
	private function createBtn(i:Number):GraphicTools.BOverOutSelect {
		var noeud:Object=xmlTools.find(_btnTag,_attRef,"_"+i);
	
		arrayBtnData[i]=noeud;
		
		var skin:String=xmlTools.xml.skin;
		if (noeud.skin!=undefined) {
			skin=skin+noeud.skin;
		}
		var maxChar:Number=Number(xmlTools.xml.maxChar);
		var menuParam:Object=xmlTools.xml;

        if (isNaN(maxChar)) maxChar=-1;
		var lClip:MovieClip=clip.attachMovie(skin,_btnPrefix+i,clip.getNextHighestDepth());
		var btn:GraphicTools.BOverOutSelect=initializeBtn(lClip);
	
		var tf:TextField=lClip.texte.texte;
		
		var texte:String=noeud.text;
		if (tf!=undefined) {
			tf.autoSize=Clips.getAutoSize(tf);
		
			if (maxChar >=0) {
				var htmlAna:Analyse=new Analyse(texte);
				var iHtml:Number=htmlAna.HtmlIToString(maxChar);
				if (iHtml<noeud.text.length ) {
					//trace("couper à "+iHtml)
					trace (htmlAna.getLastTagList());
					texte=Chaines.cutLastWord(noeud.text,iHtml,">< ",DataStk.dico("caractereETC"));
					texte+=htmlAna.genLastTagClosure();
					texte+=DataStk.dico("caractereETC");
				}
			}
	
			//trace("GraphicTools.MenuPlatXML.createBtn(i) texte:"+texte);	
			Clips.setTexteHtmlCss(lClip.texte.texte,"style.css",texte,Delegate.create(this, disposeBtn,i,menuParam,noeud));
		} else {
			texte=undefined;
			disposeBtn(i,menuParam,noeud);
		}
	
		
		if (texte!=noeud.text ) {
				if (noeud.img!=undefined && lClip.img!=undefined) {
					ToolTip.associer(btn,noeud.text,xmlTools.xml.tooltip==undefined?ToolTipMenu:xmlTools.xml.tooltip,xmlTools.xml.tooltipx==undefined?-1:parseInt(xmlTools.xml.tooltipx),xmlTools.xml.tooltipy==undefined?-30:parseInt(xmlTools.xml.tooltipy),lClip.fond==undefined?lClip:lClip.fond);
				} else {
					ToolTip.associer(btn,noeud.text,xmlTools.xml.tooltip==undefined?ToolTipMenu:xmlTools.xml.tooltip,xmlTools.xml.tooltipx==undefined?-1:parseInt(xmlTools.xml.tooltipx),xmlTools.xml.tooltipy==undefined?-2:parseInt(xmlTools.xml.tooltipy),lClip.fond==undefined?lClip:lClip.fond);
				}
		}
		return btn;
	}
	
	
	private function disposeBtn(id:Number,menuParam:Object,noeud:Object) {
		var maxW:Number=Number(menuParam.maxW);
		var btnHM:Number=Number(menuParam.btnHM);
		var btnVM:Number=Number(menuParam.btnVM);
		var btnh:Number=Number(menuParam.btnH);
        var btnv:Number=Number(menuParam.btnV);
        var ico:String=noeud.ico;
        var img:String=noeud.img;


        
        if (isNaN(btnh)) {
        	btnh=0;
        	//if (isNaN(btnHM)) btnHM=0;
        } 
        if (isNaN(btnv))  {
        	btnv=0;
        	//if (isNaN(btnVM)) btnVM=0;
        } 
		//trace("GraphicTools.MenuPlatXML.disposeBtn("+id+", "+btnh+", "+btnv+", "+ico+", "+img+")btnHM"+btnHM+" btnVM"+btnVM);
		var courant:MovieClip=clip[_btnPrefix+id];
		
		if (noeud.width!="false") {
			courant.fond.forme._width=courant.texte.texte.textWidth+2*(courant.texte._x-courant.fond._x)+textMargeWidth;
		}
		if (noeud.height!="false") {
			courant.fond.forme._height=courant.texte.texte.textHeight+2*(courant.texte._y-courant.fond._y)+textMargeHeight;
		}

		
		if (id!=0) {
		  var precedent:MovieClip=clip[_btnPrefix+(id-1) ];
		  if (isNaN(btnHM)) {
		    courant._x=precedent._x+btnh;
		  } else  {
            courant._x=Math.max(precedent.getBounds(precedent._parent).xMax+btnHM,precedent._x+btnh);
          }
          if (isNaN(btnVM)) {
          	courant._y=precedent._y+btnv;
          } else  {
          	courant._y=Math.max(precedent.getBounds(precedent._parent).yMax+btnVM,precedent._y+btnv);
          }
          if (!isNaN(maxW) &&   courant._x>maxW ) {
             courant._x=0;
             courant._y=precedent.getBounds(precedent._parent).yMax;
          }
          
		}
		if (courant.ico._x>0) {
			courant.ico._x=courant.fond._width+courant.fond._x-courant.ico._width;
		}
		if (ico!=undefined && courant.ico!=undefined) {
			var icoTarget:MovieClip=courant.ico;
			while (icoTarget["ico"]!=undefined) {
				icoTarget=icoTarget["ico"];
			}
			icoTarget.attachMovie(ico,"ico",1);
			
		}
		if (img!=undefined && courant.img!=undefined) {
			var imgTarget:MovieClip=courant.img;
			while (imgTarget["img"]!=undefined) {
				imgTarget=imgTarget["img"];
			}
			var il:ImageLoader=new ImageLoader(imgTarget,img);
			
		}
		courant._x=Math.floor(courant._x)
		courant._y=Math.floor(courant._y)
		super.disposeBtn(id);

	}
	

	
}