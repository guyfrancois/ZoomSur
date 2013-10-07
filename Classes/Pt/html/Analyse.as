/**
 * @author Administrator    , pense-tete
 * 25 mars 08
 */
import Pt.Parsers.XmlNodeTools;
/**
 * 
 */
class Pt.html.Analyse {
	private var text:String;
	
	public function Analyse(texte:String) {
		this.text=texte;
	}
	
	/**
	 * recycle l'objet	 */
	public function setText(texte:String) {
		this.text=texte;
	}
	
	/**
	 * convertie une position visible dans le html
	 * en position dans le code
	 */
	private var tagPile:Array;
	public function HtmlIToString(index:Number):Number {
		tagPile=new Array();
		//trace("HtmlIToString"+index+" "+text.length);
		//trace(getTextField().text);
		var htmli:Number=0;
		var stri:Number=0;
		var inTaG:Boolean=false;
		while (htmli<index+1 && htmli<=text.length) { //recallé pour regarder le caractere expressif de 0 a text.length
			
			
			if (text.charAt(stri)=="<") {
				inTaG=true;	
				tagPile.push("")
			}
			if (text.charAt(stri)==">") {
				
				inTaG=false;
				var lastTag:String=String(tagPile[tagPile.length-1]);
				if (lastTag.charAt(1)=="/") { // tag de fermeture
					 // vir le tag de fermeture
					
					var poped:String=String(tagPile.pop()); // vire le tag d'ouverture
					tagPile.pop();
					Pt.Out.hx("Pt.html.Analyse.HtmlIToString(index)"+poped.split(" ")[0]);
					switch (poped.split(" ")[0]){
						case "</li" :
							htmli++;
						break;
					}
				} else if (lastTag.charAt(lastTag.length-1)=="/") {// tag singleton <br/>
					var poped:String=String(tagPile.pop());
					Pt.Out.hx("Pt.html.Analyse.HtmlIToString(index)"+poped);
					switch (poped.split(" ")[0]){
						case "<br" :
							htmli++;
						break;
					}
					
				}
			} else if (inTaG==false){
				//trace(" cstri+"+text.charAt(stri))

				htmli++;
			} else {
					tagPile[tagPile.length-1]+=text.charAt(stri);
				
			} 
			
			
			stri++;
		//	//trace(inTaG+" htmli"+htmli+" stri"+stri+" ")
			
		}
		return stri-1;//recallé pour regarder le caractere expressif de 0 a text.length
	}
	public function genLastTagClosure(){
		var ret:String="";
		for (var i : Number = tagPile.length-1; i >= 0; i--) {
			
			ret+="</"+tagPile[i].substring(1).split(" ")[0]+">";
		}
		return ret;
		
	}
	public function getLastTagList():Array{
		return tagPile;
	}
	
	public function StringIToHtml(index:Number):Number {
		return index;
	}
	
	public function getXMLObjectAroundStringIndex(index:String):Object {
		return index;
	}
	
	public static function validate(text:String):Object{
    	var bXML:XML=new XML(text);
    	//trace("Pt.html.Analyse.validate()");
    	//trace(bXML.status);
    	var message:String;
    	switch (bXML.status) {
    		    case  0  : message="Pas d'erreur HTML'."; break;
    		   
                case  -2 : message="Une section CDATA n'est pas fermée."; break;
                case  -3 : message="La déclaration XML n'est pas fermée."; break;
                case  -4 : message="La déclaration DOCTYPE n'est pas fermée."; break;
                case  -5 : message="un commentaire n'est pas fermé."; break;
                case  -6 : message="Un élément XML est mal formé."; break;
                case  -7 : message="Out of memory."; break;
                case  -8 : message="Une valeur d'attribut n'est pas fermée."; break;
                case  -9 : message="Une balise ouvrante ne correspond à aucune balise de fermeture."; break;
                case  -10 : message="Une balise fermante ne correspond à aucune balise d'ouverture."; break;
    		
    	}
    	return {status:bXML.status,message:message,retour:bXML.toString()};
    }
    
    static var eTag:String="<end />";
    static var bTag:String="<begin />";
        
    static function currentTag(text:String,beginIndex:Number,endIndex:Number):XMLNode {
    	var htmlText:String=text;
    	htmlText=htmlText.substring(0,endIndex)+eTag+htmlText.substring(endIndex);
        htmlText=htmlText.substring(0,beginIndex)+bTag+htmlText.substring(beginIndex);
    	var bXML:XML=new XML(htmlText);
        
        var xmlTool:XmlNodeTools=new XmlNodeTools(bXML);

        var endNode:XMLNode=xmlTool.findNodeInSub("end").parentNode;
        if (xmlTool.findNodeInSub("begin").parentNode==endNode) {
            	return endNode;
        } else {
        	return undefined;
        }
    }
    
    public function isInTagClassAt(tag:String,_class:String,beginIndex:Number):Boolean {
    	var traceIndexStart:Number=HtmlIToString(beginIndex);
    	var listeTagStart:Array=getLastTagList();
        trace("traceIndexStart"+traceIndexStart);


        for (var i : Number = 0; i < listeTagStart.length; i++) {
            var node:XML=listeTagStart[i];
            trace("listeTagStart "+i+" "+listeTagStart[i]);
            if (tag==node.firstChild.nodeName && _class==node.firstChild.attributes["class"])  return true;
            
        }
        return false;
    }
}