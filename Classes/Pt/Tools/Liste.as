/**
* @class Pt.Tools.Liste
* @author <a href="mailto:guy@guyf.fr.st">guy-françois DELATTRE</a>
* @version 0.1
* @description extends Array
* gestion d'une liste
*
* @usage   <pre>monObjet = new Pt.Tools.Liste();
*               monObjet.setCle("nomDeChampsCle");</pre>
* @usage   <pre>bibliotheque -> definition de composant -> class AS2 : MaClasse </pre>
*/
dynamic class Pt.Tools.Liste  extends Array {
	var _cle:String;
	private var _index:Number = 0;
	var sorted:Boolean = false;
	/**
	 	* @method setCle
	 	* @description  definit le champs clé unique
	 	* @param NomCle String : nom du champs clé unique
	 	*/
	function setCle(NomCle:String) {
		this._cle = NomCle;
	}
	function setSorted() {
		sorted = true;
	}
	/**
		* @method getCle
		* @description  valeur dans le champs "cle" de l'element
		* @param element:Object element dont on veut recuperer la valeur contenu dans le champs clé
		* @returns String la valeur de la clé
		*/
	function getCle(element:Object):Object {
		if (element == undefined || _cle == undefined) {
			return undefined;
		} else {
			return eval("element."+_cle);
		}
	}
	/**
		* @method trouve
		* @description  recherche un element à partire d'une clé
		* @param cle:String
		* @returns  Object l'element ou undefine si l'element d'existe pas
		*/
	function vider() {
		this.splice(0);
		_index = 0;
	}
	function dicotom(cle:Object,min:Number,max:Number):Object {
		//trace("dicotom "+cle+" "+min+" "+getCle(this[min])+" "+max+" "+getCle(this[max]));
		var cleMax:Object=getCle(this[max]);
		var cleMin:Object=getCle(this[min]);
		 if (cleMax<= cle) {
		 	if (cleMax== cle) {
				_index=max;
				return this[_index];
			} else {
				_index=max+1;
				return undefined;
		 	}
		} else if (cleMin>= cle) {
			if (cleMin== cle) {
				_index=min;
				return this[_index];
			} else {
				_index=min;
				return undefined;
			}
		} else	 {
			_index = min+Math.floor((max-min)/2);
			if (getCle(this[_index]) < cle) {
						return dicotom(cle,_index+1,max);
			} else {
				return dicotom(cle,min,_index-1);
			}
		}
	
	}
	function linea(cle:Object):Object {
		for (_index=0; _index<this.length; _index++) {
					var locObj:Object = this[_index];
					var locCle:Object = getCle(this[_index]);
//					if (locCle.valueOf() == cle.valueOf()) {
					if (locCle== cle) {
						return this[_index];
//					} else if (locCle.valueOf() > cle.valueOf()) {
					} else if (locCle > cle) {
						return undefined
					}
				}
		return undefined;				
	}
	function trouve(cle:Object):Object {
		if (this.length==0) return undefined
		var val:Object=dicotom(cle,0,this.length-1);
		if (getCle(val)==cle) {
				return val;
		}else {
				return undefined;
			
		}
		
	}
	/**
		* @method ajoute
		* @description  ajoute un element si il n'existe pas, l'indexation pointe sur l'element (ajouté ou ancien)
		* @param element:Object l'element à ajouter
		* @returns  Boolean  true si ajouté, false si existe déjà
		*/
	function ajoute(element:Object):Boolean {
		var locCle:Object = getCle(element);
		var locObj:Object = trouve(locCle);
		if (locObj != undefined) {
			return false;
		} else {
			if (sorted) {
				this.splice(_index, 0, element);
			} else {
				this.push(element);
			}
			return true;
		}
	}
	function ajouteTjrs(element:Object):Boolean {
		if (sorted) {
			trouve(getCle(element));
			this.splice(_index, 0, element);
		} else {
			this.push(element);
		}
		return true;
	}
	/**
		* @method supprime
		* @description    supprime un élément de la liste à partire d'une valeur de clé
		* l'indexation pointe sur l'element precedant celui qui vient d'être supprimé
		* @param cle:String
		* @returns Object
		*/
	function supprime(cle:String):Object {
		var locObj:Object = trouve(cle);
		if (locObj != undefined) {
			var debut_arr:Array = this.slice(0, _index);
			this.splice(0, _index+1);
			for (var i:Number = 0; i<debut_arr.length; i++) {
				this.unshift(debut_arr[i]);
			}
			_index--;
		}
		return locObj;
	}
	/**
		* @method suivant
		* @description   retourne l'élément suivant l'indexation dans la liste
		* @param none
		* @returns  Object, l'element , undefined si pas de suivant.
		*/
	function suivant():Object {
		if (_index<length) {
			_index++;
		}
		return courant();
	}
	/**
		* @method debut
		* @description retourne le premier élément de la liste, met l'indexation au debut
		* @param none
		* @returns  Object, l'element , undefined si pas de debut (vide).
		*/
	function debut():Object {
		_index = 0;
		return courant();
	}
	/**
		* @method courant
		* @description   retourne l'element pointé par l'indexation
		* @param none
		* @returns  Object, l'element , undefined si il n'y a pas d'element courant (la fin)
		*/
	function courant():Object {
		return this[_index];
	}
	function dernier():Object {
		_index = length-1;
		return courant();
	}
}
