/**
 * @author Administrator    , pense-tete
 * 7 avr. 08
 */
import Pt.Zone.IContent;
import org.aswing.EventDispatcher;
import org.aswing.util.Delegate;
import Pt.Temporise;
import Pt.animate.CBFReplaceClip ;
import Pt.Tools.Clips;
import org.aswing.util.ArrayUtils;
import Pt.Parsers.DataStk;
import site.DefTYPES;
import site.Versions;

/**
 * ABSTRACT, gestionnaire de contenu 
 * voir site.targets.Fond,Popup,Scene */

class Pt.Zone.ContentGest extends EventDispatcher implements IContent {
	private var clip:MovieClip;
	
	private var DEFAULTHIDE:Number=500;
	static var scrollType:String="scroller_popup";
	  
    private var _decoup:Number=10;
    
    private var _tmpTransArr:Array; //{trans:tmpTrans,cbf:cbfreplace}
	
	private var convertCheminToRef:Function= Pt.Tools.Clips.convertCheminToRef;
	private var convertRefToChemin:Function= Pt.Tools.Clips.convertRefToChemin;
	private var legendeArray:Array;
	
	private var textLegende:String;
	
	
	
	
	public function ContentGest(clip:MovieClip) {
		this.clip=clip;
		DEFAULTHIDE=Number(DataStk.val("config").defaut_fade[0].alpha);
		_tmpTransArr=new Array();
		legendeArray=DataStk.val(DataStk.DICO).legendeFond;
	}
	
	
	public function create(contentType:String, chem:String):MovieClip{
		//trace("Pt.Zone.ContentGest.create("+contentType+", "+chem+") NON IMPLEMENTé");
		return null;
	}
	
	public function setTexte(dataXML:Object):MovieClip {
		return undefined;
	}

	public function remove(chem:String) {
		//trace("Pt.Zone.ContentGest.remove("+chem+")");
		var ref:String=convertCheminToRef(chem);
		//trace(clip[ref])

		removeClip(clip[ref]);
		
	}
	
	private function removeClip(cible:MovieClip,users:Number) {
	
		//trace("Pt.Zone.ContentGest.removeClip("+cible+","+cible._users+" )");
		
		if (cible._name=="texte") return;
		if (cible._users>0) return;
		cible.controler.destroy();
		cible.removeMovieClip();
		delete cible;
		
	}
	
	public function removeAll() {
		for (var i : String in clip) {
			clip[i].controler.destroy();
			clip[i].removeMovieClip();
			clip[i]=undefined;
			delete clip[i];
		}
	}
	
	// TODO : teste close
	public function close() {
			hideAll();
	}

	public function open() {

	}

	public function hideAll() {
		
		for (var i : String in clip) {
			hideClip(clip[i],DEFAULTHIDE,Delegate.create(this, removeClip,clip[i],clip[i]._users));
		}
	}
	
	public function hideAllForEnd() {
		
		for (var i : String in clip) {
			clip[i]._users=0;
			hideClip(clip[i],DEFAULTHIDE,Delegate.create(this, removeClip,clip[i],clip[i]._users));
		}
	}
	
	
	
	

	
	private function hideClip(cible:MovieClip,duree:Number,CALLBACK:Function) {
		stopCurrentCBFFor(cible);
		if (cible == undefined) return; 
		if (duree==0 || cible._alpha==0 || cible._visible==false ) {
			cible._alpha=100;
			cible._visible=false;
			CALLBACK();
			return;
		}
		var cbfreplace:CBFReplaceClip =new CBFReplaceClip(cible,{_alpha:0},cible);
		var tmpTrans:Temporise=new Temporise(duree/_decoup,Delegate.create(this, _render,cbfreplace,_decoup,CALLBACK),false)
		_tmpTransArr.push({trans:tmpTrans,cbf:cbfreplace});
	}

	public function hide(chem:String,duree:Number,CALLBACK:Function) {
		
		var ref:String=convertCheminToRef(chem);
		
		hideClip(clip[ref],duree,CALLBACK);
		
	}


    private function stopCurrentCBFFor(clipInTrans:MovieClip) {
    	for (var i : Number = 0; i < _tmpTransArr.length; i++) {
            var inTrans:Temporise=_tmpTransArr[i].trans;
            var inCBF:CBFReplaceClip=_tmpTransArr[i].cbf;
            if (inCBF.getClip()==clipInTrans) {
            	inTrans.destroy();
            	 _tmpTransArr.splice(i, 1);
            	 return;
            }
        }
    }
	private function showClip(cible:MovieClip,duree:Number,CALLBACK:Function) {
        stopCurrentCBFFor(cible);
		if (cible._visible==false) {
			cible._alpha=0;
		}
		cible._visible=true;
		var top=clip.getNextHighestDepth()-1;
		
		if (duree==0) {
			cible._alpha=100;
			CALLBACK();
			return;
		}
		//cible._alpha=0;
		
		var cbfreplace:CBFReplaceClip =new CBFReplaceClip(cible,{_alpha:100},cible);
		
		var tmpTrans:Temporise=new Temporise(duree/_decoup,Delegate.create(this, _render,cbfreplace,_decoup,CALLBACK),false)
		_tmpTransArr.push({trans:tmpTrans,cbf:cbfreplace});
		
	}

	public function show(chem:String,duree:Number,CALLBACK:Function) {
		open();
		var ref:String=convertCheminToRef(chem);
		var cible=clip[ref];
		showClip(clip[ref],duree,CALLBACK);
		
	}
	
	
	private function _render(src:Temporise,count:Number,cbfreplace:CBFReplaceClip,ecart:Number,CALLBACK:Function){
		cbfreplace._render(count/_decoup);
		if (count==_decoup) {
			if (cbfreplace.getClip()._alpha==0) {
				cbfreplace.getClip()._visible=false;
			}
			CALLBACK();
			src.destroy()
			ArrayUtils.removeFromArray(_tmpTransArr,src);
		}
	}
	
	
	
	public function pause(){
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr[i].trans.pause();
		}
		
	}
	
	public function reprise(){
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr[i].trans.reprise();
		}
	}
	
	public function removeForEnd(){
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr[i].trans.destroy();
		}
		_tmpTransArr=new Array();
		close();
		hideAllForEnd();
		
	}
	public function clear(){
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr[i].trans.destroy();
		}
		_tmpTransArr=new Array();
		close();
		hideAll();
	}
	
	public function setLegende(texte:String){
		
	}
	public function setInLoad(){
			
	}
	public function setInPlay(){
		
	}
	
	public function destroy() {
		//trace("Pt.Zone.ContentGest.destroy()");
		for (var i : Number = 0; i < _tmpTransArr.length; i++) {
			_tmpTransArr[i].trans.destroy();
		}
		removeAll();
		_tmpTransArr=new Array();
	}
	
	public function transfert(o:Object) {
		
	}
	
	

}