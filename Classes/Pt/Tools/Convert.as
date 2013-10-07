/**
 * @author GuyF , pense-tete.com
 * @date 13 févr. 07
 * 
 */
 
class Pt.Tools.Convert {
	/**
	 * applati un objet tableau
	 * 
	 * traitement des textes alternatifs inclus
	 * 
	 *           texte:[objet #565, class 'Array'] [
                  0:[objet #566, class 'Object'] {
                    survol_carte:"1", survol_elt:"1",
                    text:"\r\n\t\t\t\t\tPrincipauté d'Andorre\r\n\t\t\t\t"
                  },
                  1:[objet #567, class 'Object'] {
                    fixe_elt:"1",
                    text:"\r\n\t\t\t\t\tAndorre\r\n\t\t\t\t"
                  },
                  2:[objet #568, class 'Object'] {
                    clic_carte:"1",
                    text:"\r\n\t\t\t\t\tdetail\r\n\t\t\t\t"
                  }
                ]	 
	  * en
	  * survol_elt {
	  *  text:"\r\n\t\t\t\t\tPrincipauté d'Andorre\r\n\t\t\t\t"
	  * }
	  * survol_carte {
	  *  text:"\r\n\t\t\t\t\tPrincipauté d'Andorre\r\n\t\t\t\t"
	  * }
	  * fixe_elt {
	  *  text:"\r\n\t\t\t\t\tAndorre\r\n\t\t\t\t"
	  * }
	  * clic_carte {
	  *   text:"\r\n\t\t\t\t\tdetail\r\n\t\t\t\t"
	  * }	  */
	static function ArrayToObj(datas:Object):Object {
		var obj:Object=new Object();
		for (var i : String in datas) {
			if (i=="texte") {
				for (var j:Number=0;j<datas["texte"].length;j++) {
					var bloc:Object=datas["texte"][j];
					for (var k : String in bloc) {
						if (k!="text" && bloc[k]=="1") {
							obj["texte_"+k]=bloc["text"];
						}
						
					}
				}
			} else	if (datas[i][0]!=undefined) {
				obj[i]=datas[i][0];
			} else {
				obj[i]=datas[i];
			}
			
		}
		return obj;
	}
	/**
	 * complete au objet de Data avec les valeurs d'un Objet par default
	 * @param datas l'objet à completer
	 * @param l'objet contenant des valeurs par default
	 * @return un nouvel objet completé	 */
	static function completObjWDef(datas:Object,_default:Object):Object {
		var obj:Object=new Object();
		for (var i : String in datas) {
			obj[i]=datas[i];
		}
		for (var j : String in _default) {
			if (obj[j]==undefined) {
				obj[j]=_default[j];
			}
		}
		return obj;
	}
	static function Trace_completObjWDef(datas:Object,_default:Object):Object {
		//trace("Pt.Tools.Convert.Trace_completObjWDef(datas, _default)");
		var obj:Object=new Object();
		for (var i : String in datas) {
			//trace("datas : "+i+" "+datas[i]);
			obj[i]=datas[i];
		}
		for (var j : String in _default) {
			//trace("_default : "+j+" "+_default[j]);
			if (obj[j]==undefined) {
				//trace("affect "+j);
				obj[j]=_default[j];
			}
		}
		for (var h : String in obj) {
			//trace("obj : "+h+" "+obj[h]);
		}
		return obj;
	}
}