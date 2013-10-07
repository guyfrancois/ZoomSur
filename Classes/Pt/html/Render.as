 /**
 *
 */
import Pt.Parsers.ArrayDonnees;
import org.aswing.EventDispatcher;
import org.aswing.Event;
import Pt.image.ImageLoader;
import org.aswing.geom.Point;
import Pt.Tools.Clips;
import org.aswing.util.Delegate;
//import GraphicTools.VignetteVideo;
import Pt.html.CssCollect;
import Pt.Tools.IncrementArray;

import Pt.Parsers.DataStk; // pour zoom : legende reduite +


class Pt.html.Render extends EventDispatcher {
	/**
	 * quand la structure est affichée
	 * onReady(source:)
	 */	
	public static var ON_ZOOM:String="onZoom";
	public static var ON_READY:String = "onReady";
	
	public var IMG_H:Number=55;
	public var IMG_W:Number=55;
	
	private var _maxWidth:Number=1000;
	
	
	//static var css:TextField.StyleSheet;
	private var stylefile:String;
	
	private var clip:MovieClip;
	
	
	
	private var _tagList:Array;
	
	public function setMaxWidth(val:Number){
		_maxWidth=val;
	
	}
	public function Render(clip:MovieClip,style:String) {
		super();
		stylefile=style;
		if (stylefile==undefined) {
			stylefile="style.css";
		}

		_tagList=new Array();
		this.clip=clip;
		
		loadCss();

	}
	
	private function loadCss(callBack:Function){
		CssCollect.load(stylefile,callBack)
		
	}
	
	public function getTagClip(name:String):MovieClip {
		return _tagList[name];
	}
	
	public function getTagScroll(name:String):Number {
		//trace("Pt.html.Render.getTagScroll("+name+")");
		var tclip:MovieClip=getTagClip(name);
		//trace("tclip:"+tclip);
		var coord:Point=new Point();
		tclip.localToGlobal(coord);
		//trace("coord.y"+coord.y);
		clip.globalToLocal(coord);
		//trace("coord.y"+coord.y);
		return coord.y;
	}
	
	public function initialise(html:Object){
			loadCss(Delegate.create(this, _disposeFromLoadCss,html))
	}
	private function _disposeFromLoadCss(css:String,html:Object) {
		dispose(html);
	}
	
	private var lastHTML:Object;
	public function clear(){
		for (var i : Number = 0; i < arr_imgLoaded.length; i++) {
			 var imageL:ImageLoader=arr_imgLoaded[i];
			 imageL.ml.unloadClip(imageL.cible);
		}
		clip.html_content.removeMovieClip();
		clip.html_content=undefined;
		lastHTML=undefined;
		
	}
	
	public function getHtmlClip():MovieClip {
		return clip.html_content;
	} 
	
	public function regen(callBack:Function) {
		arr_imgLoader=new Array();
		var html:Object=lastHTML;
		clip.html_content.removeMovieClip();
		var parent:MovieClip=clip.createEmptyMovieClip("html_content",1);
		if (html.firstChild!=undefined) {
          trace(html.firstChild.nodeName);
          innerDispose(html.firstChild.node,html.firstChild.nodeName,0,0,parent,_maxWidth);
        }
        arr_imgLoader.reverse();
        popImageLoader();
        callBack();
 
	}
	public function getHtmlData():Object{
		return lastHTML;
	}
	public function dispose(html:Object){
		arr_imgLoader=new Array();
		//trace("Pt.html.Render.dispose("+html+")");
		if (lastHTML==html && clip.html_content != undefined) {
			dispatchEvent(ON_READY,new Event(this,ON_READY));
			return;
		} else {
			lastHTML=html;
		clip.html_content.removeMovieClip();
		var parent:MovieClip=clip.createEmptyMovieClip("html_content",1);
		if (html.firstChild!=undefined) {
          trace(html.firstChild.nodeName);
          innerDispose(html.firstChild.node,html.firstChild.nodeName,0,0,parent,_maxWidth);
          arr_imgLoader.reverse();
          popImageLoader();
        } else {
        	//trace("undefined "+html.nodeName)
        	//trace(html.firstChild.nodeName)
        }
        updateAfterEvent();
		dispatchEvent(ON_READY,new Event(this,ON_READY));
		}
	}
	
	
	private function setlinkZoom(clipNode:MovieClip,html:Object) {
		if (html.zoom!=undefined && !(html.zoom instanceof Array)) {
			//trace("html.zoom :"+html.zoom)
			clipNode.onRelease=Delegate.create(this, this.setZoom,html.zoom,html.text)
		}
	}
	
	private function setZoom(ref:String,legendeTexte:String) {
		//trace("Pt.html.Render.setZoom("+ref+", "+legendeTexte+" )");
	 	 DataStk.add("legendeAdPourZoom",legendeTexte);
	 	 
	 	 DataStk.event().dispatchEvent(ON_ZOOM,new Event(this,ON_ZOOM,[ref,legendeTexte]));
	 	 //	 	 SWFAddress.setZoom(ref);
	 }
	
	private function setTexte(textField:TextField,html:Object) {
		var type:String=html.type;
		var chaine:String=html.text;
		var width:Number=Number(html.txtwidth);
		if (!isNaN(width)) {
			textField._width=width;
		}
		//textField.autoSize="left";
		if (type=='html') {
			textField.styleSheet=CssCollect.cssArray[stylefile];
			
			
			textField.autoSize=Clips.getAutoSize(textField);
			textField.htmlText = chaine;
			var height=textField._height;
			textField.autoSize=false;
			textField._height=height+4;
			textField.htmlText = chaine;
			
 
		} else {
			textField.html=false;
			textField.autoSize=Clips.getAutoSize(textField);
			textField.text=chaine;
			var height=textField._height;
			textField.autoSize=false;
			textField._height=height+4;
			textField.text=chaine;
			
		}
		
		
		
		textField._parent.fond.forme._height=Math.floor(textField._height+textField._y);
		textField._parent.margeBas._y=Math.floor(textField._height+textField._y);
	}
	
	
	
	private function innerDispose(phtml:Object,pnodeName:String,px:Number,py:Number,pparent:MovieClip,maxWidth:Number){
       trace("Pt.html.Render.innerDispose(html, "+pnodeName+", "+px+", "+py+", "+pparent+")");
      
      var html:Object=phtml;
      var nodeName:String=pnodeName;
      var x:Number=Math.floor(px);
      var y:Number=Math.floor(py);
      var parent:MovieClip=pparent;
      var tagCmpt:IncrementArray=new IncrementArray();
      while (html!=undefined ) {
     	var heightBeforeNode=Math.floor(parent._height);
        var depth:Number=parent.getNextHighestDepth();
        var clipNode:MovieClip;
        var dx:Number=0;
        var dy:Number=0;
        
       
        switch (nodeName){
        	case "div":
        	
        	 clipNode=parent.createEmptyMovieClip("div_"+tagCmpt.inc(nodeName),depth);
        	 clipNode._x=x;
        	 clipNode._y=y;
        	 
        	break;
        	
        	case "span":
        	 var skin:String=(html.skin==undefined?nodeName:html.skin);
        	 clipNode=parent.attachMovie(skin,nodeName+"_"+tagCmpt.inc(nodeName),depth,{_x:x,_y:y});
             if (clipNode==undefined) {
        	 	clipNode=parent.createEmptyMovieClip("span_"+tagCmpt.inc(nodeName),depth);
             }
        	 clipNode._x=x;
        	 clipNode._y=y;
        	 
        	break;
        	case "blockquote" :
        	 clipNode=parent.createEmptyMovieClip("blockquote_"+tagCmpt.inc(nodeName),depth);
        	 clipNode._x=x;
        	 clipNode._y=y;
        	 var width:Number=(isNaN(Number(html.width))?10:Number(html.width));
        	 dx+=width;
        	break;
        	
 
        	case "ul" :
        	 clipNode=parent.createEmptyMovieClip("ul_"+tagCmpt.inc(nodeName),depth);
        	 clipNode._x=x;
             clipNode._y=y;
        	 dx+=10;
        	break;
 
        	case "li" :
        	 clipNode=parent.attachMovie(nodeName,nodeName+"_"+tagCmpt.inc(nodeName),depth,{_x:x,_y:y});
             dx+=Math.floor(clipNode._width);
         	break;
         	
         	case "img" :
         	 var skin:String=(html.skin==undefined?nodeName:html.skin);
         	 var width:Number=(isNaN(Number(html.width))?IMG_W:Number(html.width));
         	 var height:Number=(isNaN(Number(html.height))?IMG_H:Number(html.height));
         	 var cptSkin=tagCmpt.inc(skin)
         	 clipNode=parent.attachMovie(skin,skin+"_"+cptSkin,depth,{_x:x,_y:y});
         	 if (clipNode==undefined) {
         	 	clipNode=parent.createEmptyMovieClip(skin+"_"+cptSkin,depth);
         	 	clipNode._x=x;
         	 	clipNode._y=y;
         	 	
         	 }
         	 if (clipNode.fond==undefined) {
         	 	clipNode.createEmptyMovieClip("fond",0);
         	 	Clips.rectangle(clipNode,0,0,width,height);
         	 }
         	 if (clipNode.img==undefined) {
         	 	clipNode.createEmptyMovieClip("img",1);
         	 }
         	// var imageL:ImageLoader=new ImageLoader(clipNode.img.createEmptyMovieClip("img",1),html.src,width,height,ImageLoader.ALIGNCENTER,ImageLoader.ALIGNCENTER,ImageLoader.SCALLIN);
         	pushImageLoader(clipNode.img.createEmptyMovieClip("img",1),html.src,width,height)
         	 dx+=Math.floor(clipNode._width);
         	break;
         	
         	case "video" :
         		var skin:String=(html.skin==undefined?nodeName:html.skin);
         		var cptSkin=tagCmpt.inc(skin)
         		clipNode=parent.attachMovie(skin,skin+"_"+cptSkin,depth,{_x:x,_y:y});
         		//trace("Pt.html.Render.innerDispose(phtml, pnodeName, px, py, pparent) video: a reimplementer");
         		//var videoBlock:VignetteVideo=new VignetteVideo(clipNode,html);
         		dx+=Math.floor(clipNode._width);
         	break;
 
        	default :
        	  clipNode=parent.attachMovie(nodeName,nodeName+"_"+tagCmpt.inc(nodeName),depth,{_x:x,_y:y});
        	  dy+=Math.floor(clipNode._height);
        	 	
        	break;
        }
       
       
        if (clipNode==undefined) {
                trace("ERREUR Pt.html.Render.innerDispose : "+nodeName+" n'est pas lié dans la bibliothéque ");
                clipNode=parent.createEmptyMovieClip(nodeName+"_"+tagCmpt[nodeName],depth);
                clipNode._x=x;
                clipNode._y=y;
                dy+=Math.floor(clipNode._height);
        }
        createLink(clipNode,html.href);
        
       if (clipNode.texte instanceof TextField ) {
       		setTexte(clipNode.texte,html); 	
       } else if (clipNode.texte instanceof MovieClip ) {
       		setTexte(clipNode.texte.texte,html); 
       }
        
      	
      setlinkZoom(clipNode,html);
      	
        if (html.name!=undefined) {
        	  trace("Pt.html.Render.innerDispose(html, nodeName, x, y, parent)");
        	_tagList[html.name]=clipNode;
        }
        // gere la suite au noeud
        if (html.firstChild!=undefined) {
          innerDispose(html.firstChild.node,html.firstChild.nodeName,dx,dy,clipNode,maxWidth-dx);
        }
        if (maxWidth>clipNode._width && maxWidth<clipNode._x+clipNode._width ) {
      		 	clipNode._x=Math.floor(px);
         	 	clipNode._y=Math.floor(heightBeforeNode);
        }
        if (!isNaN(html.x))  clipNode.x+=Number(html.x);
        if (!isNaN(html.y))  clipNode.y+=Number(html.y);
      
      	
      	if (nodeName=="img" || nodeName=="div" || nodeName=="span")  {
      			x=Math.floor(clipNode._x+clipNode._width);
				y=Math.floor(clipNode._y);
      	} else {
				x=x;
				y=Math.floor(parent._height);
      	}
      nodeName=html.nextNode.nodeName;    
	  html=html.nextNode.node;
	     	
      } // end while
        
	}
	
	
	function createLink (lclip:MovieClip,href:String){
		if (href==undefined)  {
			return ;
		}
        var url:Array=href.split(':');
        if (url[0]=="asfunction") {
        	var mycall:Array=url[1].split(",");
        	var appel:Function=eval(mycall[0]);
        	
        	lclip.onPress=function (){
       			appel.apply(null,mycall.slice(1));
         	 	
        	}
        	
        	
       	} else {	
       		if (Clips.getParam("swhx")!="true") {
       		lclip.onPress=function (){
       			SWFAddress.openLink(href,"_blank");
         	 	
        	}
       		}
		}
        
        
		
	}
	
	private var arr_imgLoader:Array;
	private function pushImageLoader(clipImg:MovieClip,src:String,width:Number,height:Number){
		arr_imgLoader.push({clipImg:clipImg,src:src,width:width,height:height})
	}
	
	private var arr_imgLoaded:Array=new Array();
	private function popImageLoader(){
		var oImage:Object=arr_imgLoader.pop();
		if (oImage==undefined) return;
		
		 var imageL:ImageLoader=new ImageLoader(oImage.clipImg,undefined,oImage.width,oImage.height,ImageLoader.ALIGNCENTER,ImageLoader.ALIGNCENTER,ImageLoader.SCALLIN);
		 imageL.addEventListener(ImageLoader.ON_LOADCOMPLETE,this.popImageLoader,this);
		 imageL.load(oImage.src)
		 arr_imgLoaded.push(imageL);
         	
	}
	
}