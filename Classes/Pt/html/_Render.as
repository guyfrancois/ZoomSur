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
import GraphicTools.VignetteVideo;

class Pt.html.Render extends EventDispatcher {
	/**
	 * quand la structure est affichée
	 * onReady(source:)
	 */	
	public static var ON_READY:String = "onReady";
	
	static var cssArray:Array;
	//static var css:TextField.StyleSheet;
	private var stylefile:String;
	
	private var clip:MovieClip;
	
	
	
	private var _tagList:Array;
	public function Render(clip:MovieClip,style:String) {
		super();
		stylefile=style;
		if (stylefile==undefined) {
			stylefile="style.css";
		}
		if (cssArray==undefined) {
			cssArray=new Array();
		}
		_tagList=new Array();
		this.clip=clip;
		
		loadCss();

	}
	
	private function loadCss(callBack:Function){
		var locRef:Render=this;
		var file:String=stylefile;
		var css:TextField.StyleSheet = new TextField.StyleSheet();
	    if (Render.cssArray[file]==undefined) {
        css = new TextField.StyleSheet();
		css.onLoad  = function(success:Boolean) {
		 	if (success) {
		 		Render.cssArray[file]= css;
          		callBack();
     		}
		}
		css.load(file);
	    } else {
	    	callBack();
	    }
		
		
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
		var locRef:Render=this;
		if (Render.cssArray[stylefile]!=undefined) {
			dispose(html);
		} else {
			loadCss(Delegate.create(this, dispose,html))
		}
	}
	
	private var lastHTML:Object;
	public function clear(){
		clip.html_content.removeMovieClip();
		clip.html_content=undefined;
		lastHTML=undefined;
	}
	
	public function regen(callBack:Function) {
		var html:Object=lastHTML;
		clip.html_content.removeMovieClip();
		var parent:MovieClip=clip.createEmptyMovieClip("html_content",1);
		if (html.firstChild!=undefined) {
          trace(html.firstChild.nodeName);
          innerDispose(html.firstChild.node,html.firstChild.nodeName,0,0,parent);
        }
        callBack();
 
	}
	public function dispose(html:Object){
		//trace("Pt.html.Render.dispose(html)");
		if (lastHTML==html && clip.html_content != undefined) {
			dispatchEvent(ON_READY,new Event(this,ON_READY));
			return;
		} else {
			lastHTML=html;
		clip.html_content.removeMovieClip();
		var parent:MovieClip=clip.createEmptyMovieClip("html_content",1);
		if (html.firstChild!=undefined) {
          trace(html.firstChild.nodeName);
          innerDispose(html.firstChild.node,html.firstChild.nodeName,0,0,parent);
        }
        updateAfterEvent();
		dispatchEvent(ON_READY,new Event(this,ON_READY));
		}
	}
	
	private function setTexte(textField:TextField,html:Object) {
		var type:String=html.type;
		var chaine:String=html.text;
		var width:Number=Number(html.width);
		if (!isNaN(width)) {
			textField._width=width;
		}
		//textField.autoSize="left";
		if (type=='html') {
			

            trace("Render.css"+Render.cssArray[stylefile]);

			textField.styleSheet=Render.cssArray[stylefile];
			textField.htmlText = chaine;
			textField.autoSize="left";
			var height=textField._height;
			textField.autoSize=false;
			textField.htmlText = chaine;
			textField._height=height;
 
		} else {
			textField.html=false;
			textField.text=chaine;
		}
	}
	
	private function innerDispose(phtml:Object,pnodeName:String,px:Number,py:Number,pparent:MovieClip){
       trace("Pt.html.Render.innerDispose(html, "+pnodeName+", "+px+", "+py+", "+pparent+")");
      
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
        	case "div":
        	 clipNode=parent.createEmptyMovieClip("div_"+depth,depth);
        	 clipNode._x=x;
        	 clipNode._y=y;
        	 
        	break;
        	case "blockquote" :
        	 clipNode=parent.createEmptyMovieClip("blockquote_"+depth,depth);
        	 clipNode._x=x;
        	 clipNode._y=y;
        	 var width:Number=(isNaN(Number(html.width))?10:Number(html.width));
        	 dx+=width;
        	break;
        	
 
        	case "ul" :
        	 clipNode=parent.createEmptyMovieClip("ul_"+depth,depth);
        	 clipNode._x=x;
             clipNode._y=y;
        	 dx+=10;
        	break;
 
        	case "li" :
        	 clipNode=parent.attachMovie(nodeName,nodeName+"_"+depth,depth,{_x:x,_y:y});
             dx+=clipNode._width;
         	break;
         	
         	case "img" :
         	 var skin:String=(html.skin==undefined?nodeName:html.skin);
         	 var width:Number=(isNaN(Number(html.width))?55:Number(html.width));
         	 var height:Number=(isNaN(Number(html.height))?55:Number(html.height));
         	 clipNode=parent.attachMovie(skin,skin+"_"+depth,depth,{_x:x,_y:y});
         	 if (clipNode==undefined) {
         	 	clipNode=parent.createEmptyMovieClip(skin+"_"+depth,depth);
         	 	clipNode._x=x;
         	 	clipNode._y=y;
         	 	clipNode.createEmptyMovieClip("fond",0);
         	 	Clips.rectangle(clipNode,0,0,width,height);
         	 }
         	 if (clipNode.img==undefined) {
         	 	clipNode.createEmptyMovieClip("img",1);
         	 }
         	 var imageL:ImageLoader=new ImageLoader(clipNode.img,html.src,width,height,ImageLoader.ALIGNCENTER,ImageLoader.ALIGNCENTER);
         	
         	 dx+=clipNode._width;
         	break;
         	
         	case "video" :
         		var skin:String=(html.skin==undefined?nodeName:html.skin);
         		clipNode=parent.attachMovie(skin,skin+"_"+depth,depth,{_x:x,_y:y});
         		var videoBlock:VignetteVideo=new VignetteVideo(clipNode,html);
         		dx+=clipNode._width;
         	break;
 
        	default :
        	  clipNode=parent.attachMovie(nodeName,nodeName+"_"+depth,depth,{_x:x,_y:y});
        	  dy+=clipNode._height;
        	break;
        }
       
       
        if (clipNode==undefined) {
                trace("ERREUR Pt.html.Render.innerDispose : "+nodeName+" n'est pas lié dans la bibliothéque ");
                clipNode=parent.createEmptyMovieClip("ERREUR_"+depth,depth);
                clipNode._x=x;
                clipNode._y=y;
                dy+=clipNode._height;
        }
        createLink(clipNode,html.href);
        
        setTexte(clipNode.texte,html);
      
        if (html.name!=undefined) {
        	  trace("Pt.html.Render.innerDispose(html, nodeName, x, y, parent)");
        	_tagList[html.name]=clipNode;
        }
        // gere la suite au noeud
        if (html.firstChild!=undefined) {
          innerDispose(html.firstChild.node,html.firstChild.nodeName,dx,dy,clipNode);
        }
        
      
      	if (nodeName=="img" || nodeName=="div")  {
				x=clipNode._x+clipNode._width;
				y=clipNode._y;

      	} else {
				x=x;
				y=parent._height;
      	}
      nodeName=html.nextNode.nodeName;    
	  html=html.nextNode.node;
	     	
      } 
        
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
       			appel.apply(null,[mycall[1]]);
         	 	
        	}
        	
        	
       	} else {	
       		lclip.onPress=function (){
       			SWFAddress.openLink(href,"_blank");
         	 	
        	}
		}
        
        
		
	}
	
}