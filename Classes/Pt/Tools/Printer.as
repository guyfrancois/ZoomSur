/**
 * @author GuyF , pense-tete.com
 * @date 4 juin 07
 * 
 */
import org.aswing.util.SuspendedCall;
class Pt.Tools.Printer {
	
	static function print(BoutonPrint_mc:MovieClip,clip_mc:MovieClip){
		var ma_pj:PrintJob = new PrintJob();
		var margeur:MovieClip;
	// instancier l'objet
	// afficher la bo�te de dialogue d'impression
	if (ma_pj.start()) {
		// initialiser la t�che d'impression
		// ajouter la zone sp�cifi�e � la t�che d'impression
		// r�p�ter une fois pour chaque page � imprimer
		BoutonPrint_mc._visible=false;

		if ((margeur=clip_mc.attachMovie("margeur","margeur",0,{_alpha:0}))==undefined) throw new Error("Clip margeur");
		//trace("impression addPage "+clip_mc+" "+clip_mc._currentframe);
		ma_pj.addPage(clip_mc, margeur.getBounds(clip_mc), {printAsBitmap:true});
		BoutonPrint_mc._visible=true;
		clip_mc.margeur.removeMovieClip();
		// envoyer la(les) page(s) au spouleur
		// envoyer des pages du spouleur vers l'imprimante
		ma_pj.send();
		// imprimer page(s)
	} else {
		throw new Error("L'impression n'est pas disponnible !");
		
	}
	// nettoyer
	delete ma_pj;
		
	}
	
	static function printClip(clip_mc:MovieClip,top:String,bottom:String){
	
		var printMC:MovieClip=clip_mc.duplicateMovieClip("printMC",1000);
		
		
		printMC._visible=false;
		var vp:Printer=new Printer(printMC,top,bottom);
		SuspendedCall.createCall(vp.doPrint,vp,3);
		
	}
	
	private var _printMC:MovieClip;
	private var top:String;
	private var bottom:String;
    private var masque:MovieClip;
    private var topTexte:String;
	
	public function Printer(printMC:MovieClip,top:String,bottom:String,masque:MovieClip) {
		this._printMC=printMC;
		this.top=top;
		this.bottom=bottom;
		this.masque=masque;
	}
	
	function doPrint() {
		
		var ma_pj:PrintJob = new PrintJob();
	
		if (ma_pj.start()) {
			_printMC._visible=true;
			_printMC.setMask(null);
			
		//printTopBottom
		var tfTOP:MovieClip=_printMC.attachMovie("printTop","top",2);
		tfTOP.texte.text=top;
		tfTOP._y=-30;
		tfTOP._x=-30;
		/*
		this["bloc"+i].texte.styleSheet = css;
		this["bloc"+i].texte.htmlText=this["texte"+i];
		*/
		var tfBOTTOM:MovieClip=_printMC.attachMovie("printBottom","BOTTOM",3);
		tfBOTTOM.texte.text=bottom;
		tfBOTTOM._y=_printMC._height+10;
		tfBOTTOM._x=-30;
		//trace(_printMC._height);
		_printMC._xscale=80;
		_printMC._yscale=80;
		var width:Number=_printMC._width;
		if (masque!=undefined) {
			width=masque._width;
		}
		//trace(_printMC._height);
		
			//trace("Pt.Tools.Printer.doPrint(ma_pj,"+ _printMC+")");
			var height:Number=800;
			var curr=-60;
			while (curr<=_printMC._height) {
				ma_pj.addPage(_printMC, {xMin:-30,xMax:width,yMin:curr,yMax:curr+height}, {printAsBitmap:false});
				curr+=height-60;
			}
			//trace("Pt.Tools.Printer.doPrint()"+(curr-60)+" "+_printMC._height);
			//_printMC.removeMovieClip();
			_printMC.setMask(masque);
			_printMC._xscale=100;
			_printMC._yscale=100;
			// envoyer la(les) page(s) au spouleur
			// envoyer des pages du spouleur vers l'imprimante
			ma_pj.send();
			// imprmer page(s)
			delete ma_pj;
		
		} else {
			throw new Error("L'impression n'est pas disponnible !");
			delete ma_pj;
		}
	}

}