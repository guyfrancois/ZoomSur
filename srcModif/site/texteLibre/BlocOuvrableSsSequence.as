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
import site.texteLibre.BlocOuvrable;

/**
 * 
 */
class site.texteLibre.BlocOuvrableSsSequence extends BlocOuvrable implements site.ITextType {

	public function BlocOuvrableSsSequence(clip:MovieClip) {
		super(clip);
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
         	listePara.push(clipNode);
         break;
         case "sequence" :
         //	clipNode=parent.attachMovie(ICOANIMATION,nodeName+"_"+depth,depth,{_x:x,_y:y});
         //	clipNode._x=parent._width-clipNode._width;
         //	addBtnSeq(clipNode,html.src);
         break;
        }
        
		y=parent._height;
		nodeName=html.nextNode.nodeName;    
	  	html=html.nextNode.node;
      
      }
      content.fond._height=parent._y+parent._height-(content.fond._y*2);
	}
	

}