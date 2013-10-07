/**
 * @author Administrator    , pense-tete
 * 22 nov. 07
 */
/**
 * 
 */
class Pt.Parsers.XmlTools {
	private var dataXML:Object;
	
	
	public function XmlTools(dataXML:Object) {
		if (dataXML==undefined) trace("********** donnée XML non definie")
		this.dataXML=dataXML;
	}
	
	
	
	public function get xml():Object {
		return dataXML;
	}
	/**
	 * recheche dans un tableau de propriétés (type xml)
	 * @param nodeName : propriété concerné
	 * @param attr : nom de l'attibut servant de clé
	 * @param ref : valeur de la clé
	 * @return premiere correspondance exacte ;
	 */
	public function find(nodeName:String,attr:String,ref:String):Object {
		  
		//trace("Pt.Parsers.XmlTools.find("+nodeName+", "+attr+", "+ref+")");
		var nodArr:Array=dataXML[nodeName];
		var id:Number=Number(ref.substring(1));
		if (attr=="id" && !isNaN(id)) return nodArr[ref.substring(1)];
		for (var i:Number=0; i<nodArr.length;i++) {
				if (nodArr[i][attr]==ref) {
					return nodArr[i];
				}
		}
		//trace("Pt.Parsers.XmlTools.find erreur "+ref);
		return undefined
	}
	
	/**
	 * recheche dans un tableau de propriétés (type xml)
	 * @param nodeName : propriété concerné
	 * @param attr : nom de l'attibut servant de clé
	 * @param ref : valeur de la clé
	 * @return premiere correspondance exacte ;
	 */
	public function findIndex(nodeName:String,attr:String,ref:String):Number {
		var nodArr:Array=dataXML[nodeName];
		var id:Number=Number(ref.substring(1));
		if (attr=="id" && !isNaN(id)) return nodArr[ref.substring(1)];
        for (var i:Number=0; i<nodArr.length;i++) {
                if (nodArr[i][attr]==ref) {
                    return i;
                }
        }
        trace("Pt.Parsers.XmlTools.find erreur "+ref);
        return -1;
	}
	
	/**
	 * recherche dans un tableau (ressource XML) le premier  élément "article"
	 * dont l'attribut ref est la valeur de "type" + les mots succesif de la listemenu
	 * @param type : le type d'article (prefix)
	 * @param listMenu : la reference (generalement issu d'un menu)
	 * @return l'objet dont la reference correspond sinon undefined	 */
	public function findArticle (type:String,listMenu:Array):Object {
			//var listString:String=listMenu.join("/");
			var ref:String=type+listMenu.join("");
			return find("article","ref",ref);
	}
	/**
	 * recherche dans un tableau (ressource XML) tout les  éléments "article"
	 * dont l'attribut ref commence par le valeur de "type" puis par le nom succesif de la listemenu
	 * @param type : le type d'article (prefix)
	 * @param listMenu : la reference (generalement issu d'un menu)
	 * @return un tableau d'objet correspondant ,sinon (aucune correspondance) undefined
	 */
	public function findSubArticle (type:String,listMenu:Array):Array {
			//var listString:String=listMenu.join("/");
			var ref:String=type+listMenu.join("");
			var subArr:Array= findSub("article","ref",ref);
			if (subArr.length==0) {
				//trace("Pt.Parsers.XmlTools.findSubArticle erreur "+ref);
				return undefined;
			} else {
				return subArr;
			}
	}
	/**
	 * recheche dans un tableau de propriétés (type xml)
	 * @param nodeName : propriété concerné
	 * @param attr : nom de l'attibut servant de clé
	 * @param ref : valeur de la clé
	 * @return tableau des correspondances (commence par le clé)	 */
	public function findSub(nodeName:String,attr:String,ref:String):Array{
		//trace("Pt.Parsers.XmlTools.findSub("+nodeName+", "+attr+", "+ref+")");
		var subArr:Array=new Array();
		var nodArr:Array=dataXML[nodeName];
		
		for (var i:Number=0; i<nodArr.length;i++) {
			// la reference doit commencer par la reference en parametre
				if (nodArr[i][attr].indexOf(ref)==0 ) {
					subArr.push( nodArr[i]);
				}
		}
		
		return subArr;
	} 
	
	
	
	public function findAroundArticle(type:String,listMenu:Array) {
		
	}
	
	/**
	 * construire la structure pour generer un menu à partir de la liste des articles	 */
	public function buidMenuStruct(nodeName:String,attr:String,ref:String):Array {
		// TODO : implementation generer un menu
		var wordLengthAnd_:Number=ref.length+1;
		
		var menuArray:Array=new Array();
		var nodArr:Array=dataXML[nodeName];
		
		for (var i:Number=0; i<nodArr.length;i++) {
			// la reference doit commencer par la reference en parametre
				if (nodArr[i][attr].indexOf(ref)==0 ) {
					var subRef:String=nodArr[i][attr]
					.substring(wordLengthAnd_);
					var arrayIndex:Array=subRef.split("_");
					//trace("arrayIndex :"+arrayIndex);
					var lMenu:Array=menuArray;
					var lastlMenu:Object;
					for (var j : Number = 0; j < arrayIndex.length; j++) {
						var index:Number=Number(arrayIndex[j]);
						if (lMenu[index] == undefined) {
							lMenu[index]={article:new Object(),menuArray:new Array()};
						}
						lastlMenu=lMenu[index];
						lMenu=lMenu[index].menuArray;
					}
					lastlMenu.article=nodArr[i];
					//subArr.push( nodArr[i]);
				}
		}
		
		return menuArray;
	}
	
	
	
}