/**
 * @author guyf
 */
 
import org.aswing.geom.Point;
import Pt.html.CssCollect;
import org.aswing.util.ArrayUtils; // setTextFront
import Pt.Parsers.DataStk; //convertURL
import Pt.bases.Bxml;
import Pt.Tools.Chaines;

class Pt.Tools.Clips {
	static var CLASSNAME:String="Tools.Clips";
	static function erreur(info:String){
		//trace("ERREUR "+CLASSNAME+" "+info);
	}
	/**
	 * Fourni une methode de redimensionnement adaptée à la mise en page
	 * tf.autoSize=Clips.getAutoSize(tf);
	 */

	static var getAutoSize:Function=Pt.Tools.Chaines.getAutoSize;
	
/*
	static function openFile (FILE:String){
		var MM:MacMax;
		MacMax.execute ("dir/"+FILE);
	}
	*/
	
	/**
	 * conversion automatiques des adresses
	 * exploite les parametres ?baseURL=chemin, _root._baseURL, _root._url
	 * remplace les sections de chaine @.../ par des chemins en memoire dans DataStk
	 * ne touche pas les adresses completes (contient :// ou :\\)
	 * 
	 * trace(Clips.convertURL("@zoom/@signes/image.jpg"));
	 * 	 */
	static function convertURL(url:String):String {
		Pt.Out.hx("convertURL"+url);
		var ati:Number=url.indexOf("@");
		while (ati!=-1) {
			var isep:Number=url.indexOf("/",ati);
			url=url.substring(0,ati)+DataStk.chemin(url.substring(ati+1,isep))+url.substring(isep+1)
			ati=url.indexOf("@");
		}
		if (url.indexOf("://")!=-1 || url.indexOf(":\\")!=-1) return url;
		return getLocalSite()+url;
	}
	
	static var _param:LoadVars;
	
	static function getParam(param:String):String{

		if (_root["_"+param]!=undefined) {
			return _root["_"+param];
		}
		if (_param==undefined) {
			var s:String = unescape(_root._url);
			var myParam:Array = s.split("?");
			_param = new LoadVars();
			_param.decode(myParam[1]);
			//trace("Pt.Tools.Clips.getParam("+param+")"+_param[param]);
		}
		return _param[param];
	//	__flashDirectory = myParam[1];
	//	__locale = myParam[2];
	}
	/**
	 * recherche le repertoire où est stocké le swf
	 * @return l'adresse vers le repertoire	 */
	static function getLocalSite():String {
		if (_root._baseURL!=undefined) {
			//trace("Pt.Tools.Clips.getLocalSite() _root._baseURL"+_root._baseURL);
			//trace("Pt.Tools.Clips.getLocalSite() _root._baseURL"+_root._baseURL);
			return _root._baseURL;
		}
		if (getParam("baseURL")!=undefined) {
			return getParam("baseURL");
		}
		var adAnim:String=_root._url.split("?")[0];
		//trace("Pt.Tools.Clips.getLocalSite()"+adAnim);
		//trace("->"+adAnim.substring(0,(adAnim.lastIndexOf("/")+1)));
		return adAnim.substring(0,(adAnim.lastIndexOf("/")+1));
	}
	static	function getClipFrom(reference:String,base:MovieClip):MovieClip{
		if (base==undefined) erreur("base indefinie");
		if (reference==undefined ||  reference.length==0 ) return  base;
		var tabRef:Array=reference.split(".");
		var clip:MovieClip=base;
		for (var i : Number = 0; i < tabRef.length; i++) {
			clip=clip[tabRef[i]];
		}
		if (clip==undefined) erreur(" reference introuvable :"+reference+"!");
		return clip;
	}
	
	static function getClipRef(clip:MovieClip):String {
		return String(eval(clip._target));
	}
	
	/**
	 * le parent est commun au deux	 */
	static function getTopMost(clip1:MovieClip,clip2:MovieClip):MovieClip {
		var ref1:String=getClipRef(clip1);
		var ref2:String=getClipRef(clip2);
		var ref1Ar:Array=ref1.split(".");
		var ref2Ar:Array=ref1.split(".");
		var i:Number=0;
		var minLength:Number=Math.min(ref1Ar.length,ref2Ar.length);
		while (ref1Ar[i]==ref2Ar[i] && i<minLength) {
			i++;
		}
		if (i+1==minLength) {
			// il y a inclusion
			if (ref1Ar.length==minLength) {
				ref2Ar=ref2Ar.slice(0,i+1);
				return eval(ref2Ar.join("."));
			} else {
				ref1Ar=ref1Ar.slice(0,i+1);
				return eval(ref1Ar.join("."));
			}
		}
		ref1Ar=ref1Ar.slice(0,i+1);
		ref2Ar=ref2Ar.slice(0,i+1);
		var bclip2:MovieClip=eval(ref2Ar.join("."));
		var bclip1:MovieClip=eval(ref1Ar.join("."));
		if (bclip2.getDepth()>bclip2.getDepth()) {
			return bclip2;
		} else {
			return bclip1;
		}
		
		
	}
	
	static function getClipRefIn(clip:MovieClip,baseRef:String):String {
		return getClipRef(clip).substring(baseRef.length);
		
	}
	
	static function ajouteTexte(clip:MovieClip,id:String,texte:String,format:TextFormat,dx:Number,dy:Number,width:Number):TextField {
		//trace("Tools.Clips.ajouteTexte("+clip+","+ id+","+ texte+","+ format+","+ dx+","+ dy+","+ width+")");
		if (width==undefined) {
			width=230;
		}
		if (texte!=undefined){
			var pos:Number=dy+clip._height;
			clip.createTextField(id,clip.getNextHighestDepth(),0+dx,clip._height+dy,width,14);
			var txtf:TextField=clip[id];
			if (txtf==undefined) {
				trace ("****************erreur clip.createTextField ");
			}

			//txtf.setNewTextFormat(format);
			
			txtf.embedFonts=true;
			//txtf.antiAliasType = "normal";
			//txtf.gridFitType = "subpixel";
			txtf.selectable=false;
			txtf.multiline = true;
  			txtf.wordWrap = true;
  			txtf.autoSize = "left";
			txtf.condenseWhite=true;
			txtf.html=true;
			if (_root.styles!=undefined) {
  				txtf.styleSheet=_root.styles;
  			}
			
			txtf.htmlText = texte;
  			//txtf.setTextFormat(format); 			

			return txtf;
		}
		return undefined;
	}
	
	static function setTextField(tfield:TextField,texte:String) {
		//trace("Pt.Tools.Clips.setTextField("+tfield+", "+texte+")");
			var tform:TextFormat=new TextFormat();
			tform.font="Futura Hv BT";
			tform.leading=-1;
			
			tfield.html=true;
  			tfield.condenseWhite=true;
  			tfield.selectable=false;
			tfield.multiline = true;
  			tfield.wordWrap = true;
  			tfield.autoSize = "left";
  			tfield.embedFonts=true;	
  			
			/*
			//tfield.styleSheet=new TextField.StyleSheet();
  			//tfield.antiAliasType = "advanced";
			//tfield.gridFitType = "subpixel";
			
			//tfield.sharpness = 100;
			//tfield.thickness = 150;
			*/
			tfield.htmlText=texte;
  			tfield.setTextFormat(tform);
			tfield.setNewTextFormat(tform);
			/*if (tfield._parent._name=="titre"){
				tfield._parent.setMask(tfield._parent._parent.masqueb);
			 
				if (tfield._parent._parent.legende!=undefined) {
					tfield._parent._parent.legende.setMask(tfield._parent._parent.masque);
				} 
			} */
			
			//txtf.antiAliasType = "normal";
			//txtf.gridFitType = "subpixel";
		
		
	}
	
	static function setText(tfield:TextField,texte:Object,etend:String,selectable:Boolean){
		tfield._highquality=2;
		if (selectable || texte.selectable=="true") {
			tfield.selectable=true;
		} else {
			tfield.selectable=false;
		}
		tfield.multiline = true;
  		tfield.wordWrap = true;
  		if (etend!=undefined) {
  			tfield.autoSize = etend;
  		} 
  		if (texte.type=="html") {
			//tfield.embedFonts=true;	
		
  			tfield.html=true;
  			tfield.condenseWhite=true;

  			tfield.htmlText=texte.html;
  			if (_root.styles!=undefined) {
  				tfield.styleSheet=_root.styles;
  			}
  		} else if  (texte.text!=undefined){
  			tfield.html=false;
  			tfield.text=texte.text;
  		} else {
  			tfield.text="";
  			//trace("EcranBase.setText "+tfield+" "+texte+" champs texte indefini !");
  		}
	}
	static	public function rectangle(target_mc:MovieClip,x:Number,y:Number,width:Number,height:Number,alpha:Number):Void{
		var lalpha:Number=0;
		if (alpha!=undefined) {
			lalpha=alpha;
		}
		target_mc.beginFill(0x000000, lalpha);
		target_mc.lineStyle(1, 0x000000, lalpha);
		target_mc.moveTo(x, y);
		target_mc.lineTo(x+width,y);
		target_mc.lineTo(x+width,y+height);
		target_mc.lineTo(x,y+height);
		target_mc.lineTo(x,y);
		target_mc.endFill();
	}
	/*
	static public function applyASColor(clip:MovieClip,asColor: org.aswing.ASColor):org.aswing.ASColor {
		//trace("Pt.Tools.Clips.applyASColor("+clip+","+ asColor+")");
		var oldAsColor:org.aswing.ASColor;
		var couleur:Color = new Color(clip);
		oldAsColor=new org.aswing.ASColor(couleur.getRGB(),clip._alpha);
		couleur.setRGB(asColor.getRGB());
		clip._alpha=asColor.getAlpha();
		return oldAsColor;
	}
	*/
	
	/**
	 * recherche en profondeur de clip l'implementation d'une fonction
	 * @param fonctionName le nom de la fonction
	 * @param le clip par lequel on commence la recherche
	 * @return la fonction si elle est trouvée
	 * 	 */
	static public function findFirstImplementationOf(fonctionName:String,clip:MovieClip):MovieClip {
		if (clip[fonctionName] instanceof Function ) {
			return clip ;
		} else {
			if (clip==_root || clip==undefined) {
				//Log.addMessage("findFirstImplementationOf("+fonctionName+", _root!!)", Log.WARNING,"Pt.Tools.Clips");
				return undefined;
			} else {
				return findFirstImplementationOf(fonctionName,clip._parent);
			}
		}	
	}
	static public function initAntiClic(clip:MovieClip) {
		clip.useHandCursor=false;
		clip.onRollOver=function(){
		}
		clip._alpha=0;
	}
	
	static var SCALLIN:Number=0; // à l'interieur
	static var SCALLOUT:Number=1; // à l'exterieur
	static var SCALLNONE:Number=-1; // pas de re-scall
	/**
	 * calcul le scale à appliquer pour passer d'une dimension à une autre
	 * avec choix de taille interne ou autour	 */
	static function getScaleFromTo(width:Number,height:Number,maxWidth:Number,maxHeight:Number,scaleMode:Number):Number {
		//trace("Pt.image.ImageLoader.getScaleFromTo("+width+","+height+" ,"+maxWidth+" ,"+maxHeight+", "+scaleMode+" )");
		var scale:Number=100;
		var scW=maxWidth*100/width;
		var scH=maxHeight*100/height;
		//trace(scW+" "+scH);
		if (scaleMode==SCALLIN) {
			return Math.min(scW,scH);
		} else if (scaleMode==SCALLOUT) {
			return Math.max(scW,scH);
		}
		return scale;
	}
	
	static function getScalesFromTo(width:Number,height:Number,maxWidth:Number,maxHeight:Number,scaleMode:Number):Object {
		//trace("Pt.image.ImageLoader.getScaleFromTo("+width+","+height+" ,"+maxWidth+" ,"+maxHeight+", "+scaleMode+" )");
		var scale:Number=100;
		var scW=maxWidth*100/width;
		var scH=maxHeight*100/height;
		//trace(scW+" "+scH);
		/*
		if (scaleMode==SCALLIN) {
			return Math.min(scW,scH);
		} else if (scaleMode==SCALLOUT) {
			return Math.max(scW,scH);
		}
		*/
		return {_xscale:scW,_yscale:scH};
	}
	
	/**
	 * calcul la transfomation à appliquer à un clip pour qu'il se superpose à un autre
	 * @param clip : le clip à déplacer
	 * @param cible : le clip à superposer
	 * @param clipPoint : le point de reference dans clip  
	 * @param ciblePoint : le point de reference dans la cible
	 * @param clipRef : le sous-clip de clip de reference 
	 * @param clibleRef : le sous-clip de cible de reference	 */
	static function getDeplaceTo(clip:MovieClip,cible:MovieClip,
								 clipPoint:org.aswing.geom.Point,ciblePoint:org.aswing.geom.Point,
								 clipRef:MovieClip,cibleRef:MovieClip
								 ):Object {
								
		//trace("Pt.Tools.Clips.getDeplaceTo(clip "+clip+", cible "+cible+", clipPoint "+clipPoint+", ciblePoint "+ciblePoint+", clipRef "+clipRef+", cibleRef "+cibleRef+")");						 	
		if (clipPoint==undefined) clipPoint=new Point();
		if (ciblePoint==undefined) ciblePoint=new Point();								 	
		if (clipRef==undefined) clipRef=clip;
		if (cibleRef==undefined) cibleRef=cible;
		if (cibleRef.width==undefined) cibleRef.width=cibleRef._width;
		if (cibleRef.height==undefined) cibleRef.height=cibleRef._height;
		//var scale:Number;

		//scale=getScaleFromTo(clipRef._width,clipRef._height,cibleRef._width,cibleRef._height,SCALLIN);
		//trace("cibleRef wXh:"+cibleRef.width+" x "+cibleRef.height);
		var scalePointRef:Point= new Point();
		cibleRef._parent.localToGlobal(scalePointRef);
		clip._parent.globalToLocal(scalePointRef);
		
		//trace("global scalePointRef xXy:"+scalePointRef.x+" x "+scalePointRef.y);
		
		var scalePoint:Point= new Point(cibleRef.width,cibleRef.height);
		cibleRef._parent.localToGlobal(scalePoint);
		
		clip._parent.globalToLocal(scalePoint);
		//trace("local scalePoint wXh:"+(scalePoint.x-scalePointRef.x)+" x "+(scalePoint.y-scalePointRef.y) );
		
		
		var scalePointClipRef:Point= new Point();
		clipRef._parent.localToGlobal(scalePointClipRef);
		clip._parent.globalToLocal(scalePointClipRef);
		
		var scalePointClip:Point= new Point(clipRef.width,clipRef.height);
		clipRef._parent.localToGlobal(scalePointClip);
		clip._parent.globalToLocal(scalePointClip);
		
			
		var scales:Object=getScalesFromTo(scalePointClip.x-scalePointClipRef.x,scalePointClip.y-scalePointClipRef.y,scalePoint.x-scalePointRef.x,scalePoint.y-scalePointRef.y,SCALLIN);
		var pointOrigine : org.aswing.geom.Point = new Point(ciblePoint);
		
		cibleRef.localToGlobal(pointOrigine);
		clip.globalToLocal(pointOrigine);
		
		var vectDecalage:org.aswing.geom.Point=new Point(clipPoint);
		clipRef.localToGlobal(vectDecalage);
		clip.globalToLocal(vectDecalage);
		
		vectDecalage.x=vectDecalage.x*scales._xscale/100;
		vectDecalage.y=vectDecalage.y*scales._yscale/100;
		pointOrigine.substract(vectDecalage);
		return {point:pointOrigine.substract(vectDecalage),scale:scales._xscale,_xscale:scales._xscale,_yscale:scales._yscale};
	}
	
	static var setTextXML:Function=setTextXMLFront;
	
	static function setTextXMLBack(field:TextField,cssfile:String,texteXML:Object,callBack:Function,maxWidth:Number,maxHeight:Number,menuHandler:Function,menuInfo:String){
		addMenu(field._parent,menuInfo==undefined?field._parent._name:menuInfo,menuHandler);
		setTexteHtmlCss(field,cssfile,texteXML.text,callBack,maxWidth,maxHeight);
	}
	
	
	static function  addMenu(clip:MovieClip,info:String,handler:Function){
		
		var my_cm:ContextMenu = new ContextMenu();
		for(var propName:String in my_cm.builtInItems) {
    		my_cm.builtInItems[propName]=false;
		}
		
		my_cm.customItems.push(new ContextMenuItem(info,handler));
		
		clip.menu=my_cm;
		
	}
	
	
	/**
	 * la chaine est traitée en fonction des donnée de "base" :
	 * texteXML : 
	 * 		base : optionnel , contient les references dans une base de donnée Bxml
	 * 		text : contien le texte initial sujet à transformation  avec des %n pour les parametres
	 * 			 */
	static function setTextXMLFront(field:TextField,cssfile:String,texteXML:Object,callBack:Function,maxWidth:Number,maxHeight:Number){
		//field.autoSize=true;
		
		//trace("Pt.Tools.Clips.setTextXMLFront(field, cssfile, texteXML, callBack, maxWidth, maxHeight)  base :"+texteXML.base);
		var arrBase:Array=texteXML.base.split(',');
		for(var i:Number=0; i<arrBase.length; i++){
			// tranforme la chaine de recherche en donnée exploitable
			
			arrBase[i]=Bxml.getData(arrBase[i]+"/text")
		}
		//trace("base :"+arrBase)
		// TODO transformer la chaine
		
		setTexteHtmlCss(field,cssfile,Chaines.vScanf(texteXML.text,arrBase),callBack,maxWidth,maxHeight);
	}
	/**
	 * Affect au champs texte 
	 * @param field : le champs texte
	 * @param cssfile: chemin vers un fichier css
	 * @param texte : texte à affecter (au format html)
	 * @param callBack : function de rappel , lorsque le texte est ajouté (potentielement dépendant du chargement de lu fichier css
	
	 */
	static function  setTexteHtmlCss(field:TextField,cssfile:String,texte:String,callBack:Function,maxWidth:Number,maxHeight:Number){
		//trace("Pt.Tools.Clips.setTexteHtmlCss("+field+", "+cssfile+", "+texte+" , callBack)");
		field._OVERSIZE=false;
		
		if (field.htmlText == texte || field==undefined || texte==undefined ) {
			//trace("filtre");
			
			if (field.autoSize!=false) {
				field.autoSize=false;
				/*
				var height=field._height;
          		var width=field._width;
          		texte=field.htmlText;
				
				field.htmlText = texte;
				field._width=Math.min(width,maxWidth==undefined?width:maxWidth);
				field._height=Math.min(height,maxHeight==undefined?height:maxHeight);
				*/
			}
			callBack();
			return;
		}
		field.text="";
		var xfield:Number=field._x;
		var cb:Function =function (css:TextField.StyleSheet){
			if (css!=undefined) {
				//trace("->cb");
				var prevWidth:Number=field._width;
				field.styleSheet = css;
				field.htmlText = texte;
          		if (field.autoSize!=false) {
          				//trace("field.autoSize :"+field.autoSize);
          			//	//trace("_height :"+field._height+"_width :"+field._width);
          				var height:Number=field._height;
          				var width:Number=field._width;
						field.autoSize=false;
						
						if (field.multiline && field.wordWrap) {
          					width=prevWidth;
          				} else {
          					width+=4;
          				}
						
						
						field._width=Math.min(width,maxWidth==undefined?width:maxWidth);
						field._height=Math.min(height,maxHeight==undefined?height:maxHeight);
						field.htmlText = texte;
					//	//trace("_height :"+field._height+"_width :"+field._width);
					//	//trace("m_width :"+Math.min(width,maxWidth==undefined?width:maxWidth)+"m_height :"+Math.min(height,maxHeight==undefined?height:maxHeight));
						if (field._width<(width-0.2) || field._height < (height-0.2) ) {
							field._OVERSIZE=true;
						}
						
						
          		} else {
          			field._width=prevWidth;	
          			field._x=xfield;
          		}
          		
			} else {
				if (field.autoSize!=false) {
					field.autoSize=false;
				}
			}
			callBack();
		}
		CssCollect.load(cssfile,cb)
	}
	
	static var ALIGNTOP:Number=0;
	static var ALIGNLEFT:Number=0;
	static var ALIGNCENTER:Number=1;
	static var ALIGNBOTTOM:Number=2;
	static var ALIGNRIGHT:Number=2;
	static public function doAlignV(target_mc:MovieClip,y:Number,maxHeight:Number,vAlign:Number){
		if (target_mc.height==undefined) target_mc.height=target_mc._height;
		     
		switch (vAlign) {
			case ALIGNCENTER :
				target_mc._y=y+(maxHeight-target_mc.height*target_mc._yscale/100)/2;
			break;
			case ALIGNTOP :
				//trace("Pt.image.ImageLoader.redim(target_mc)+ALIGNTOP");
				target_mc._y=y;
			break;
			case ALIGNBOTTOM :
				target_mc._y=y+(maxHeight-target_mc.height*target_mc._yscale/100);
			break;
		}
	}
	
	static public function doAlignH(target_mc:MovieClip,x:Number,maxWidth:Number,hAlign:Number){
		 if (target_mc.width==undefined) target_mc.width=target_mc._width;
		 switch (hAlign) {
			case ALIGNCENTER :
				target_mc._x=x+(maxWidth-target_mc.width*target_mc._xscale/100)/2;
			break;
			case ALIGNLEFT :
				target_mc._x=x;
			break;
			case ALIGNRIGHT :
				//trace("Pt.image.ImageLoader.redim(target_mc)+ALIGNRIGHT");
				target_mc._x=x+(maxWidth-target_mc.width*target_mc._xscale/100);
			break;
			
		}
		 
	}
	
	static public function doAlign (target_mc:MovieClip,reference:Point,maxWidth:Number,maxHeight:Number,hAlign:Number,vAlign:Number){
		doAlignV(target_mc,reference.y,maxHeight,vAlign);
		doAlignH(target_mc,reference.x,maxWidth,hAlign)
		
		/*
        if (target_mc.width==undefined) target_mc.width=target_mc._width;
        if (target_mc.height==undefined) target_mc.height=target_mc._height;
       
       
     
		switch (vAlign) {
			case ALIGNCENTER :
				target_mc._y=reference.y+(maxHeight-target_mc.height*target_mc._yscale/100)/2;
			break;
			case ALIGNTOP :
				//trace("Pt.image.ImageLoader.redim(target_mc)+ALIGNTOP");
				target_mc._y=reference.y;
			break;
			case ALIGNBOTTOM :
				target_mc._y=reference.y+(maxHeight-target_mc.height*target_mc._yscale/100);
			break;
		}
		switch (hAlign) {
			case ALIGNCENTER :
				target_mc._x=reference.x+(maxWidth-target_mc.width*target_mc._xscale/100)/2;
			break;
			case ALIGNLEFT :
				target_mc._x=reference.x;
			break;
			case ALIGNRIGHT :
				//trace("Pt.image.ImageLoader.redim(target_mc)+ALIGNRIGHT");
				target_mc._x=reference.x+(maxWidth-target_mc.width*target_mc._xscale/100);
			break;
			
		}
		*/
	}
	
	
	public static function convertCheminToRef(val:String):String{
		return val.split("/").join("@").split(".").join("$");
		
	}
	
	public static  function convertRefToChemin(val:String):String {
		return val.split("@").join("/").split("$").join(".");
	}
}
