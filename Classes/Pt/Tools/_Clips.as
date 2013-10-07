/**
 * @author guyf
 */
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
	 * recherche le repertoire où est stocké le swf
	 * @return l'adresse vers le repertoire	 */
	static function getLocalSite():String {
		var adAnim:String=_root._url;
		return adAnim.substring(0,(adAnim.lastIndexOf("/")));
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
		if (clipPoint==undefined) clipPoint=new org.aswing.geom.Point();
		if (ciblePoint==undefined) ciblePoint=new org.aswing.geom.Point();								 	
		if (clipRef==undefined) clipRef=clip;
		if (cibleRef==undefined) cibleRef=cible;
		//var scale:Number;

		//scale=getScaleFromTo(clipRef._width,clipRef._height,cibleRef._width,cibleRef._height,SCALLIN);
		var scales:Object=getScalesFromTo(clipRef._width,clipRef._height,cibleRef._width,cibleRef._height,SCALLIN);
		var pointOrigine : org.aswing.geom.Point = new org.aswing.geom.Point(ciblePoint);
		
		cibleRef.localToGlobal(pointOrigine);
		clip.globalToLocal(pointOrigine);
		
		var vectDecalage:org.aswing.geom.Point=new org.aswing.geom.Point(clipPoint);
		clipRef.localToGlobal(vectDecalage);
		clip.globalToLocal(vectDecalage);
		
		vectDecalage.x=vectDecalage.x*scales._xscale/100;
		vectDecalage.y=vectDecalage.y*scales._yscale/100;
		pointOrigine.substract(vectDecalage);
		return {point:pointOrigine.substract(vectDecalage),scale:scales._xscale,_xscale:scales._xscale,_yscale:scales._yscale};
	}
	/**
	 * Affect au champs texte 
	 * @param field : le champs texte
	 * @param cssfile: chemin vers un fichier css
	 * @param texte : texte à affecter (au format html)
	 * @param callBack : function de rappel , lorsque le texte est ajouté (potentielement dépendant du chargement de lu fichier css	 */
	static function  setTexteHtmlCss(field:TextField,cssfile:String,texte:String,callBack:Function){
		if (field.htmlText == texte) {
			callBack();
			return;
		}
		//var format:TextFormat = field.getTextFormat();
		field.text="";
		var css:TextField.StyleSheet = new TextField.StyleSheet();
		css.onLoad  = function(success:Boolean) {
		 	if (success) {
		  		field.styleSheet = css;
		  		if (texte==undefined) {
		  			field.htmlText="";
		  		} else {

          			field.htmlText = texte;
          			if (field.autoSize!=false) {
          				var height=field._height;
          				var width=field._width;
						field.autoSize=false;
						field.htmlText = texte;
						field._width=width;
						field._height=height;
          			}
		  		}
		/*  		var cssformat:TextFormat = field.getTextFormat();
		  		cssformat.letterSpacing=format.letterSpacing;
		  		field.setTextFormat( cssformat);
*/
          		callBack();
          		
     		}
		}
		
		css.load(cssfile);
	}
}
