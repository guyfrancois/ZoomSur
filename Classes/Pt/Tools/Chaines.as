/**
 * @author guyf
 */
class Pt.Tools.Chaines {
	static var identifier:String="%";
	
	static function vScanf(format:String, args:Array):String
   {
	   //args.unshift(format); -> modifie de tableau entré
	   var targ:Array=new Array(format);
	   return Pt.Tools.Chaines.scanf.apply(null,  targ.concat(args));
   }
   
	
	/**
	 * 
	 * remplace dans une chaine, des elements identifiés par %1 %2 ... %9
	 * echapement en doublant % 
	 * exemples :
	 * {@code
	 *var resultat:String=Tools.Chaines.scanf("%1sototo%%1titi%1%dqdq"," un ")
	 *resultat : un sototo%1titi un %dqdq
	 *
	 *var resultat:String=Tools.Chaines.scanf("sototo%%1titi%1%dqdq"," un ");
	 *resultat :sototo%1titi un %dqdq
	 *
	 *var resultat:String=Tools.Chaines.scanf("%%1sototo%%1titi%1%dqdq"," un ");
	 *resultat :%1sototo%1titi un %dqdq
	 *
	 * }
	 * @param String chaine à scanner
	 * @param String les chaines de remplacement (de 1 Ã  9 possibles)
	 */
	static function scanf():String {

		//trace("Tools.Chaines.scanf()"+arguments);
		var chaine:String;
		if(arguments.length > 0){
    		//for(var i=0; i<arguments.length; i++){
      		//	//trace(arguments[i]);
    		//}
   			chaine=arguments[0];
   			
   			var tabString:Array=chaine.split(identifier);
   		//	//trace(tabString);
   			for (var j : Number = 1; j < tabString.length; j++) {
   				//TODO : rechercher des nombres + grand pour augmenter le nb de parametres possibles
   				var numP:Number=Number(tabString[j].charAt(0));
   				
   		//		//trace(numP+" "+j+" "+tabString[j].charAt(0)+" "+Number(tabString[j].charAt(0)));
   				if (!isNaN(numP) && arguments[numP]!= undefined  ) {
   		//			//trace("ajoute "+arguments[numP]+tabString[j].substring(1));
   					if (tabString[j-1]==identifier ) {
   						continue;
   					}
   					tabString[j]=arguments[numP]+tabString[j].substring(1);
   				} else {
   					
   					tabString[j]=identifier+tabString[j].substring(0);
   				}
   			}
   			chaine=tabString.join("");
  		} else {
    		//trace("pas d'argument");
  		} 
  		return chaine;
	}
	/**
	triml returns the given string less any leading blanks.
	 <code>
	 * LOCATION will have the value 'Toronto, Ontario  '.
	Location = triml('  Toronto, Ontario  ');
	</code>
	*/
	static function triml(texte:String):String{
		var i:Number=0;
		while (i<texte.length && texte.charAt(i)==" "){
			i++;
		}
		return texte.substring(i);
	}
	
	static function eatl(texte:String,eat:String):String{
		var i:Number=0;
		while (i<texte.length && texte.charAt(i)==eat){
			i++;
		}
		return texte.substring(i);
	}
	
	/**
	trimr returns the given string less any tailing blanks.
	 <code>
	 * LOCATION will have the value '  Toronto, Ontario'.
	Location = trimr('  Toronto, Ontario  ');
	</code>
	*/
	static function trimr(texte:String):String{
		var i:Number=texte.length-1;
		while (i>=0 && texte.charAt(i)==" "){
			i--;
		}
		texte.slice()
		return texte.substring(0,i+1);
	}
	
	static function eatr(texte:String,eat:String):String{
		var i:Number=texte.length-1;
		while (i>=0 && texte.charAt(i)==eat){
			i--;
		}
		texte.slice()
		return texte.substring(0,i+1);
	}
	
	
	
	static function trim(texte):String {
		return triml(trimr(texte));
	}
	static function findObject(reference:String,base:Object):Object {
		if (base==undefined) {
			base=_root;
		}
		if (reference==undefined ||  reference.length==0 ) return  base;
		var tabRef:Array=reference.split(".");
		var clip:Object=base;
		for (var i : Number = 0; i < tabRef.length; i++) {
			clip=clip[tabRef[i]];
		}
		if (clip==undefined) trace(" reference introuvable :"+base+"."+reference+"!");
		return clip;
	}
	/**
	 * Fourni une methode de redimensionnement adaptée à la mise en page
	 * tf.autoSize=Chaines.getAutoSize(tf);	 */
	static function getAutoSize(textField:TextField):String {
		var autoSize:String;
		var align:String=textField.getTextFormat().align;
        if (align=="center" || align=="justify" ) {
            autoSize="center";
        } else {
            autoSize=align;
        }
		return autoSize;
	}
	
	static function autosizeTF(textField:TextField):Object {
		textField.autoSize=getAutoSize(textField);
        
	return textField.autoSize;
	}
	
	
	static function urlEncode(chaine:String):String {
		var lv:LoadVars = new LoadVars();
		lv.chaine = chaine;
		var encodeFull:String=lv.toString();
		return encodeFull.split("=")[1];
	}
	/**
	 * 
	 * 
	 * 
	 * import Pt.Tools.Chaines;
trace("createString");
trace(Chaines.createString(5,"0"));
trace("untriml");
trace(Chaines.untriml("2",5,"0"));
trace(Chaines.untriml("12345",5,"0"));
trace(Chaines.untriml("123456789",5,"0"));
trace("untrimr");
trace(Chaines.untrimr("2",5,"0"));
trace(Chaines.untrimr("12345",5,"0"));
trace(Chaines.untrimr(undefined,5,"0"));
trace(Chaines.untrimr("123456789",5,"0"));
 * 
 * 
 * createString
00000
untriml
00002
12345
56789
untrimr
20000
12345
00000
12345
 *  */	 
	static function createString(totalSize:Number,char:String) :String {
		if (char==undefined) char=" ";
		if (totalSize==undefined) totalSize=0;
		var chaine:String="";
		for (var i : Number = 0; i < totalSize; i++) {
			chaine+=char;
		}
		return chaine
	}
	
	/**
	 * fige la taille de la chaine de charactere par la droite	 */
	static function untriml(texte:String,totalSize:Number,char:String):String{
		if (char==undefined) char=" ";
		if (totalSize==undefined) totalSize=0; 
		if (texte==undefined) texte="";
		if (texte.length>=totalSize) return texte.substr(-totalSize,totalSize);
		var comp:Number=totalSize-texte.length;
		return createString(comp,char)+texte;
	}
	
	/**
	 * fige la taille de la chaine de charactere par la gauche
	 */
	static function untrimr(texte:String,totalSize:Number,char:String):String{
		if (char==undefined) char=" ";
		if (totalSize==undefined) totalSize=0; 
		if (texte==undefined) texte="";
		if (texte.length>=totalSize) return texte.substr(0,totalSize);
		var comp:Number=totalSize-texte.length;
		return texte+createString(comp,char);
	}
	
	 public static function mailto(fromEmail:String,fromNom:String,objet:String,corps:String,destinataire:String):String{
     
     	var mail:LoadVars = new LoadVars();
		mail.subject = objet;
		mail.body = corps+"\n"+"\n"+"-----------------\n"+fromNom+"\n"+fromEmail+"\n"+"-----------------\n"+SWFAddress.getHref();

		trace (mail.toString());
     	
     	return "mailto:"+destinataire+"?"+mail.toString();
     	
     	//getURL("mailto:"+_root.textes.maill+"?subject=contact:");
     }
	
	
	static function isEmail(texte:String) {
	//email address has to have at least 5 chars
	if (texte.length < 5)
	{
		return false;
	}
	var iChars = "*|,\":<>[]{}`';()&$#%";
	var eLength = texte.length;
	for (var i=0; i < eLength; i++)	{
		if (iChars.indexOf(texte.charAt(i)) != -1) {
			//trace("Invalid Email Address : Illegal Character in Email Address : -->" + texte.charAt(i) + "<--.");
			return false;
		}
	}
	var atIndex = texte.lastIndexOf("@");
	if(atIndex < 1 || (atIndex == eLength - 1))
	{
		//trace("Invalid Email Address : Email Address must contain @ as at least the second chararcter.");
		return false;
	}
	var pIndex = texte.lastIndexOf(".");
	if(pIndex < 4 || (pIndex == eLength - 1))
	{
		//trace("Invalid Email Address : Email Address must contain at least one . (period) in a valid position");
		return false;
	}
	for (var i = 0; i<eLength; i++) {
		if ((texte.charAt(i) == "." || texte.charAt(i) == "@") && texte.charAt(i) == texte.charAt(i-1)) {
			//trace("Invalid Email Address : Cannot contain two \".\" or \"@\" in a row : -->"+texte.charAt(i)+"<--.");
		return false;
		}
	}

	if(atIndex > pIndex)
	{
		//trace("Invalid Email Address : Email Address must be in the form of name@domain.domaintype");
		return false;
	}
	return true;
  }
  
  static function cutLastWord(chaine:String,at:Number,sepListe:String,complete:String):String{
  		
  		if (chaine.length<=at) return chaine;
  		if (sepListe==undefined) sepListe=" ";
  		if (complete==undefined) complete="";
  		var ret:String;
  		var cutIndex:Number=at-complete.length;
  		if (chaine.length>at) {
			ret=Chaines.trimr(chaine.substring(0,cutIndex));
			if (ret.length<cutIndex|| sepListe.indexOf(chaine.charAt(cutIndex))>-1 ) {
				return ret;
			} else {
				for (var i:Number=cutIndex-1;i>0;i--) {
					if ( sepListe.indexOf(ret.charAt(i))>-1 ) {
						return Chaines.trimr(ret.substring(0,i+1));
					}
				}
				
			}
		}
		return ret;
  }
  
  static var dayOfWeek_array:Array = new Array("dimanche","lundi", "mardi", "mercredi", "jeudi", "vendreid", "samedi");
  static var mounth_array:Array = new Array ("janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre");
  
  static function dateEnChaine(date:Date):String {
  	//lundi 12 août 1974 à 18:15:00, GMT - 7h00. 
    	
  	return dayOfWeek_array[date.getDay()]+" "+date.getDate()+" "+mounth_array[date.getMonth()]+" "+date.getFullYear();
  	
  }
  
  static function getExt(file:String):String {
   	var  ext:String=file.substring(file.lastIndexOf(".")+1);
  	return ext.toLowerCase();
  }
  
  static function fileIsVideo(file:String):Boolean {
  	var ext:String=getExt(file);
  	if (ext=="flv" || ext=="f4v") return true
  	else return false;
  }
  
  static function fileIsSon(file:String):Boolean {
  	var ext:String=getExt(file);
  	if (ext=="mp3" ) return true
  	else return false;
  }
  
  static function fileIsAnim (file:String):Boolean {
  	var ext:String=getExt(file);
  	if (ext=="swf" ) return true
  	else return false;
  }
  
  static function fileIsPhoto (file:String):Boolean {
  	var ext:String=getExt(file);
  	if (ext=="jpg" || ext=="png" ) return true
  	else return false;
  }
}