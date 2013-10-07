/**
 * SWFAddress v1.2: Deep linking for Flash - http://www.asual.com/swfaddress/
 * 
 * SWFAddress is (c) 2006-2007 Rostislav Hristov and is released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 * classes : C:\Documents and Settings\Administrator\Local Settings\Application Data\Macromedia\Flash 8\fr\Configuration\Classes
 */


import flash.external.ExternalInterface;
import mx.events.EventDispatcher;

class SWFAddress {
	static var hnote:Function=GraphicTools.InfoBulle.hnote;
	static var note : Function=GraphicTools.InfoBulle.note;
    private static var _value:String = '';
    private static var _interval:Number;
    private static var _dispatcher:EventDispatcher;
    //private static var _availability:Boolean = ExternalInterface.available;
    private static var _availability:Boolean=false;
    private static var _init:Boolean = SWFAddress._initialize();

    public static var onChange:Function;
    
    private static function _check():Void {
        if (SWFAddress.onChange || typeof _dispatcher['__q_change'] != 'undefined') {
            clearInterval(SWFAddress._interval);
            SWFAddress.setValue(SWFAddress.getValue());
            
        }
    }

    private static function _initialize():Boolean {
        if (typeof _dispatcher == 'undefined') {
            _dispatcher = new EventDispatcher();
        }        
        if (_availability) {
            ExternalInterface.addCallback('getSWFAddressValue', SWFAddress, 
                function():String {return this._value});
            ExternalInterface.addCallback('setSWFAddressValue', SWFAddress, 
                SWFAddress.setValue);
        }
        SWFAddress._interval = setInterval(SWFAddress._check, 10);        
        return true;
    }
    
    public static function openLink(url:String, target:String):Void {
    	if (Pt.Tools.Clips.getParam("swhx")!="true") {
        if ( ExternalInterface.available) {
            ExternalInterface.call('SWFAddress.openLink', url, target);
        } else {
            getURL(url, target);
        }
    	}
    }

    public static function openPopup(url:String, name:String, options:String):Void {
    	if (Pt.Tools.Clips.getParam("swhx")!="true") {
        if ( ExternalInterface.available) {
            ExternalInterface.call('SWFAddress.openPopup', url, name, options);
        } else {
            getURL('javascript:window.open("' + url + '","' + name + '","' + options + '");',"_blank");
        }
    	}
    }
        
    public static function getTitle():String {
        var title:String = (_availability) ? 
            String(ExternalInterface.call('SWFAddress.getTitle')) : '';
        if (title == 'undefined' || title == 'null') title = '';
        return title;
    }

    public static function setTitle(title:String):Void {
        if (_availability) ExternalInterface.call('SWFAddress.setTitle', title);
    }
    
    public static function setTag(tag:String):Void {
        if (_availability) ExternalInterface.call('SWFAddress.setTag', tag);
    }
    
    public static function getStatus():String {
        var status:String = (_availability) ? 
            String(ExternalInterface.call('SWFAddress.getStatus')) : '';
        if (status == 'undefined' || status == 'null') status = '';
        return status;
    }

    public static function setStatus(status:String):Void {
        if (_availability) ExternalInterface.call('SWFAddress.setStatus', status);
    }
    
    public static function resetStatus():Void {
        if (_availability) ExternalInterface.call('SWFAddress.resetStatus');
    }
    
    public static function getPath():String {
        var value:String = SWFAddress.getValue();
        if (value.indexOf('?') != 1) {
            return value.split('?')[0];
        } else {
            return value;   
        }
    }

    public static function getQueryString():String {
        var value:String = SWFAddress.getValue();
        var index:Number = value.indexOf('?');
        if (index != -1 && index < value.length) {
            return value.substr(index + 1);
        }
        return '';
    }

    public static function getParameter(param:String):String {
        var value:String = SWFAddress.getValue();
        var index:Number = value.indexOf('?');
        if (index != -1) {
            value = value.substr(index + 1);
            var params:Array = value.split('&');
            var p:Array;
            var i:Number = params.length;
            while(i--) {
                p = params[i].split('=');
                if (p[0] == param) {
                    return p[1];
                }
            }
        }
        return '';
    }

    public static function getParameterNames():Array {
        var value:String = SWFAddress.getValue();
        var index:Number = value.indexOf('?');
        var names:Array = new Array();
        if (index != -1) {
            value = value.substr(index + 1);
            if (value != '' && value.indexOf('=') != -1) {            
                var params:Array = value.split('&');
                var i:Number = 0;
                while(i < params.length) {
                    names.push(params[i].split('=')[0]);
                    i++;
                }
            }
        }
        return names;
    }

    public static function getDispatcher():EventDispatcher {
        if (typeof _dispatcher == 'undefined') {
            _dispatcher = new EventDispatcher();
        }
        return _dispatcher;
    }
    
    public static function getHref():String {
    	var addr:String;
        if (_availability) {
            addr = String(ExternalInterface.call('SWFAddress.getHref'));
        }
        trace("SWFAddress.getHref()"+addr);
        if (addr == 'undefined' ||!_availability) addr = '';   
        trace("SWFAddress.getHref()"+addr);     
        return addr;
    }
    
    public static function getBaseHref():String {
    	var addr:String= getHref();
    	return addr.split("#")[0];
    }
    
    public static function getValue():String {
        var addr:String, id:String = 'null';
        if (_availability) {
            addr = String(ExternalInterface.call('SWFAddress.getValue'));
            id = String(ExternalInterface.call('SWFAddress.getId'));
        }
        if (id == 'null' || !_availability) {
            addr = SWFAddress._value;
        } else {
            if (addr == 'undefined' || addr == 'null') addr = '';        
        }
        return addr;
    }
    

    public static function setValue(addr:String):Void {
        if (addr == 'undefined' || addr == 'null') addr = '';
        SWFAddress._value = addr;
        if (_availability) ExternalInterface.call('SWFAddress.setValue', addr);
        if (SWFAddress.onChange) 
            SWFAddress.onChange();
        if (typeof _dispatcher['__q_change'] != 'undefined')
            SWFAddress.getDispatcher().dispatchEvent({type: 'change', target: SWFAddress.getDispatcher()});        
    }
    
    
    
    /**
     * Ajout pour faciliter l'usage de liens repere
     */

     
     public static function setZoom(addr:String) {
     	site.Navigator.getInstance().setZoom(addr);
     	site.Navigator.getInstance().updateValue();
     }
     
     public static function setSequence(file:String) {
     	trace("SWFAddress.setSequence("+file+")");
     	site.Navigator.getInstance().setSequence(file);
     }
     
     public static function setRepere(addr:String) {
     	site.Navigator.getInstance().setRepere(addr);
     	site.Navigator.getInstance().updateValue();
     }
     
       public static function setLoupe(file:String) {
        trace("SWFAddress.setLoupe("+file+")");
        site.Navigator.getInstance().setLoupe(file);
     }
     
     public static var isModeGuide:Function;
     /*
     public static function  setMode(mode:String) {
     	site.Navigator.getInstance().setMode(mode);
     }
     
     
     public static function  getMode():String {
     	return site.Navigator.getInstance().getMode();
     }
     */
     
     public static function setVideo(addr:String) {
     	site.Navigator.getInstance().setVideo(addr);
     	site.Navigator.getInstance().updateValue();
     }
     
     public static function cineSource(addr:String) {
     	var lien:String=_root.xmlData.cineSource[0].prefixe+addr+_root.xmlData.cineSource[0].suffixe;
     	SWFAddress.openPopup(lien,"popupNeorealisme","toolbar=no,location=no,noborder,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=565,height=450,top=20,left=20");
     }
     public static function fichePerso(addr:String) {
     	var lien:String=_root.xmlData.fichePerso[0].prefixe+addr+_root.xmlData.fichePerso[0].suffixe;
     	SWFAddress.openPopup(lien,"popupNeorealisme","toolbar=no,location=no,noborder,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=565,height=450,top=20,left=20");
     }
     
     public static function mailto(fromEmail:String,fromNom:String,objet:String,corps:String,destinataire:String){
     
     	var mail:LoadVars = new LoadVars();
		mail.subject = objet;
		mail.body = corps+"\n"+"\n"+"-----------------\n"+fromNom+"\n"+fromEmail+"\n"+"-----------------\n"+SWFAddress.getHref();

		trace (mail.toString());
     	
     	SWFAddress.openLink("mailto:"+destinataire+"?"+mail.toString());
     	//getURL("mailto:"+_root.textes.maill+"?subject=contact:");
     }

}