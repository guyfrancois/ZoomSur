/**
 * @author Administrator    , pense-tete
 * 5 mai 08
 */
/**
 * 
 */
class Pt.Parsers.XmlNodeTools {
	private var _xmlNode:XMLNode;
	public function XmlNodeTools(xmlNode:XMLNode) {
		if (xmlNode==undefined) trace("********** donnée XML non definie")
		_xmlNode=xmlNode;
	}
	
	public function get xml():XMLNode {
		return _xmlNode;
	}
	public function findNodes(nodeName:String):Array {
		//trace("Pt.Parsers.XmlNodeTools.findNode("+nodeName+")");
		var arr_nodes:Array=new Array();
		if (_xmlNode.hasChildNodes()) {
		    for (var aNode:XMLNode = _xmlNode.firstChild; aNode != null; aNode=aNode.nextSibling) {
		    	if (aNode.nodeType == 1 && aNode.nodeName==nodeName ) {
		    				arr_nodes.push(aNode);            	
        		}
		    }
    	} else {
    		return arr_nodes;	
    	}

	}
	
	public function findNodeInSub(nodeName:String,attr:String,ref:String) :XMLNode {
		if (_xmlNode.hasChildNodes()) {
            for (var aNode:XMLNode = _xmlNode.firstChild; aNode != null; aNode=aNode.nextSibling) {
                if (aNode.nodeType == 1 && aNode.nodeName==nodeName && aNode.attributes[attr]==ref) {
                            return aNode;               
                } else {
                	 var xnt: XmlNodeTools = new XmlNodeTools(aNode);
                	var rNode:XMLNode=xnt.findNodeInSub(nodeName,attr,ref);
                	if (rNode!=undefined) return rNode;
                	
                }
            }
        } else {
            return undefined;   
        }
	}
	
	public function findNode(nodeName:String,attr:String,ref:String):XMLNode {
		//trace("Pt.Parsers.XmlNodeTools.findNode("+nodeName+", "+attr+", "+ref+")");
		if (_xmlNode.hasChildNodes()) {
		    for (var aNode:XMLNode = _xmlNode.firstChild; aNode != null; aNode=aNode.nextSibling) {
		    	if (aNode.nodeType == 1 && aNode.nodeName==nodeName && aNode.attributes[attr]==ref) {
		    				return aNode;            	
        		}
		    }
    	} else {
    		return undefined;	
    	}

	}
	
	public static function troncHtmlNode (dataHTML:String,type:String,_class:String):String {
		var htmlNode:XMLNode=genHtmlNode(dataHTML, "html", _class);
		var chaineCode:String="";
		if (htmlNode.hasChildNodes()) {
		    for (var i = 0; i<htmlNode.childNodes.length; i++) {
		    	chaineCode+=htmlNode.childNodes[i];
		    }
    	} 
		return chaineCode;
	}
	
	/**
	 * 
	 * @param dataHTML : chaine de texte au format html
	 * @type : nom du noeud de chaine html
	 * @_class : classe de style de la chaine
	 * @par	 */
	public static function genHtmlNode(dataHTML:String,type:String,_class:String,parentNode:XMLNode):XMLNode {
		//trace("Pt.Parsers.XmlNodeTools.genHtmlNode");
		//trace("->   type :"+type+", _class :"+_class);
		//trace("->dataHTML: "+dataHTML);
		var htmlNode:XMLNode=new XML(dataHTML);
		//trace("->htmlNode: "+htmlNode);
		//trace("->htmlNode.firstChild: "+htmlNode.firstChild);
		
		if (type=="html" || _class!=undefined)  {
			//if (htmlNode.firstChild.nodeName==type) {
				htmlNode=htmlNode.firstChild;
			//}
			if (_class!=undefined) {
				if (htmlNode.firstChild.nodeName=="span" && htmlNode.firstChild.attributes["class"]==_class) {
					htmlNode=htmlNode.firstChild;
				}
			}
		}
		//trace("-->"+htmlNode.nodeName);
		if (htmlNode.hasChildNodes() && parentNode!=undefined) {
		   for (var i = 0; i<htmlNode.childNodes.length; i++) {
		    	//trace(htmlNode.childNodes[i]);
		    	parentNode.appendChild(htmlNode.childNodes[i].cloneNode(true));
		    }
    	} 
		
		return htmlNode;
	}
	
	/**
	 * genere le noeud d'une partie
	 */
	 public static function genElement(dataPartie:Object,parentNode:XMLNode) {
	 	for (var i : String in dataPartie) {
	 		if (dataPartie[i] instanceof Array) {
	 			genArray(dataPartie[i],i,parentNode)
	 		} else {
	 			
	 			if (i=="text") {
	 				if (dataPartie["type"]=="html" || dataPartie["class"] !=undefined) {
	 					// insertion en mode html <-> XML
	 					
	 					
	 					genHtmlNode(dataPartie[i],dataPartie["type"],dataPartie["class"],parentNode);
	 				} else {
	 					// texte brute
	 					parentNode.appendChild(new XMLNode(3,dataPartie[i]));
	 				}
	 			} else if (i!="firstChild" && i!="prevNode" && i!="nextNode" && i!="RACINE" ) {
	 				parentNode.attributes[i]=dataPartie[i];
	 			}
	 		}
	 	}
	 }

	/**
	 * generer les noeud d'une rubriques d'étape (+ieur parties)
	 */
	 public static function genArray(rubArray:Array,type:String,parentNode:XMLNode) {
	 	for (var index:Number=0;index<rubArray.length;index++) {
	 		var _tmpNode:XMLNode;
	 		_tmpNode=new XMLNode(1,type);
	 		genElement(rubArray[index],_tmpNode);
	 		parentNode.appendChild(_tmpNode);
	 	}
	 	
	 }
	 
	 public static function getBaseObject(dataXML:Object):Object {
	 	//trace("Pt.Parsers.XmlNodeTools.getBaseObject("+dataXML+")");
	 	var ldataXML:Object=dataXML;
	 	for (var i : String in ldataXML) {
	 		Pt.Out.hx(i+" "+ldataXML[i]);
	 	}
	 	
	 		while (ldataXML.prevNode!=undefined) {
	 			
	 			for (var i : String in ldataXML) {
	 				if (i!="firstChild" && i!="prevNode" && i!="nextNode" ) {
	 					Pt.Out.hx(i+" "+ldataXML[i]);
	 				} else {
	 					Pt.Out.hx(i+" "+ldataXML[i].nodeName+" "+ldataXML[i].node);
	 				}
	 				
	 				
	 			}
	 			ldataXML=ldataXML.prevNode.node;
	 		}

		return ldataXML;
	 	
	 }
	 
	 /**
	  * Object de structure dataXML	  */
	 public static function cloneDataXML(existObject:Object):Object {
	 	if (isArray(existObject)) {
	 		Pt.Out.hx("cloneData erreur : ne drevais pas etre un tableau");
	 		//return null;	
	 	}
	 	if(existObject instanceof Object){
			var newObject:Object = new Object();
			if (existObject.firstChild!=undefined) 	newObject.firstChild={nodeName:existObject.firstChild.nodeName,node:existObject.firstChild.node};
			if (existObject.prevNode!=undefined) 	newObject.prevNode={nodeName:existObject.prevNode.nodeName,node:existObject.prevNode.node};
			if (existObject.nextNode!=undefined) 	newObject.nextNode={nodeName:existObject.nextNode.nodeName,node:existObject.nextNode.node};
			
			var lastExistNode:Object;
			var lastNewNode:Object;
			for(var i:String in existObject){
				if (i!="firstChild" && i!="prevNode" && i!="nextNode" ) {
					if (isArray(existObject[i])) {  // un tableau -> famille de noeud
						newObject[i]=existObject[i].concat();
						for (var j : Number = 0; j < existObject[i].length; j++) {
							newObject[i][j] = cloneDataXML(existObject[i][j])
							
							if (existObject.firstChild.node==existObject[i][j]) existObject.firstChild.node=newObject[i][j];
							if (newObject[i][j].prevNode.node==lastExistNode) newObject[i][j].prevNode.node=lastNewNode;
							if (newObject[i][j].prevNode.node==existObject) newObject[i][j].prevNode.node=newObject;
							if (lastNewNode.nextNode.node=existObject[i][j]) lastNewNode.nextNode.node=newObject[i][j];
							lastExistNode=existObject[i][j];
							lastNewNode=newObject[i][j];
						}
						
						
						
					} else 	if(existObject[i] instanceof Object){ // des attributs 
						newObject[i] = new Object();
						newObject[i] = cloneDataXML(existObject[i]);
					}else{
						newObject[i] = existObject[i];
					}
					
					
				} 
			}
			return newObject;
		}else{
			return existObject;
		}
	 }
	 
	
	public static function isArray(value):Boolean {
		return (value instanceof Array);
	}
	
	/**
	 * Checks wherever passed-in value is <code>String</code>.
	 */
	public static function isString(value):Boolean {
		return ( typeof(value) == "string" || value instanceof String );
	}
	
	/**
	 * Checks wherever passed-in value is <code>Number</code>.
	 */
	public static function isNumber(value):Boolean {
		return ( typeof(value) == "number" || value instanceof Number );
	}

	/**
	 * Checks wherever passed-in value is <code>Boolean</code>.
	 */
	public static function isBoolean(value):Boolean {
		return ( typeof(value) == "boolean" || value instanceof Boolean );
	}

	/**
	 * Checks wherever passed-in value is <code>Function</code>.
	 */
	public static function isFunction(value):Boolean {
		return ( typeof(value) == "function" || value instanceof Function );
	}

	/**
	 * Checks wherever passed-in value is <code>MovieClip</code>.
	 */
	public static function isMovieClip(value):Boolean {
		return ( typeof(value) == "movieclip" || value instanceof MovieClip );
	}
	
}