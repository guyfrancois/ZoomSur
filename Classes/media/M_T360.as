/**
 * @author Administrator    , pense-tete
 * 3 avr. 08
 */

import Pt.image.SWFLoader;
import Pt.image.LoaderDefine;
import org.aswing.util.Delegate;

//import Pt.animate.ClipByFrame;
import Pt.Temporise;
import Pt.Tools.Chaines;
import Pt.scan.Souris;
import org.aswing.Event;
import org.aswing.EventDispatcher;
/**
 *
 *	360 dans zoom
 *	en fond, le 360 est manipulable
 *	forcement en fond pour les versions
 *	1 seul 360 pour le momen
 *	pas en popup
 *	
 *	le fond 360 mise en loupe
 *	
 *	  */
 
class media.M_T360 extends EventDispatcher {
	static var ON_READY:String="ON_READY";
	// TODO : Corriger le controleur de souris mal fichu 
	// voir zoom
	static var scan:Souris;
	
	
	// parametres de image
	private var src:String;
	private var nbImages:Number;
	private var width:Number;
	private var height:Number;
	private var swfWidth:Number;
	private var swfHeight:Number;
	private var close:Boolean;
	
	//private var stopAt:Number;
	private var startAt:Number; // image affiché au départ
	private var rotate:Number;  // nombre d'images  et sens de la rotation 
	private var rotateTime:Number; // temps total pour faire la rotation
	
	
	private var _ilArray:Array;// of SWFLoader;
	private var fond:String;
	private var hasBtn:Boolean;
	
	private var _contener:MovieClip;
	
	
	public function M_T360(contener:MovieClip,src:String,fond:String,nbImages:Number,width:Number,height:Number,hasBtn:Boolean,rotate:Number,startAt:Number,rotateTime:Number,swfWidth:Number,swfHeight:Number) {
		
		trace("media.MT360.MT360(contener, "+src+", "+fond+", "+nbImages+", width"+width+", height"+height+", hasBtn"+hasBtn+", rotate"+rotate+", startAt"+startAt+", rotateTime"+rotateTime+")");
		this._contener=contener;
		this.hasBtn=(hasBtn==true?true:false);
		this.src=src;
		this.fond=fond;
		this.nbImages=nbImages;
		
		this.width=width;
		this.height=height;
		
		this.swfWidth=contener.width=swfWidth;
		this.swfHeight=contener.height=swfHeight;
		
		this.rotate=rotate;
		this.startAt=startAt;
		this.rotateTime=rotateTime;
		trace("swfWidth"+swfWidth+" swfHeight"+swfHeight)
	}
	
	
	private var _countInitNbImages:Number=0;
	private var _vuesArray:Array ; // of MovieClip
	
	private var moveListener:Object;
	
	
	public function init(){
		_ilArray=new Array();
		_vuesArray=new Array();
		
		
		scan=new Souris(_contener);
		moveListener=scan.addEventListener(Souris.ON_MOUSEMOVE,onMoveMove,this);
if (fond!=undefined) {
		var fondL:SWFLoader=new SWFLoader( _contener.createEmptyMovieClip( "fond",0)
												,fond,width,height
												,LoaderDefine.ALIGNTOP,LoaderDefine.ALIGNLEFT,LoaderDefine.SCALLNONE);
}
		for (var i : Number = 0; i < nbImages; i++) {
				var id:Number= _vuesArray.push( _contener.createEmptyMovieClip( "V_"+i,i+1));
				 
				var il:SWFLoader=new SWFLoader( _vuesArray[id-1]
												,undefined,width,height
												,LoaderDefine.ALIGNTOP,LoaderDefine.ALIGNLEFT,LoaderDefine.SCALLNONE,
												swfWidth,swfHeight);
				_ilArray.push(il)
 				il.addEventListener(SWFLoader.ON_LOADINIT,onILInit,this);
 				var num:String=Chaines.untriml(String(i),3,"0");
 				var nomFichier:String=Chaines.scanf(src,num);
				il.load(Chaines.scanf(src,num),swfWidth,swfHeight);
				trace( _vuesArray[id-1]+" "+nomFichier)
				
		}
	}
	
	//private var _cible:MovieClip;
	public function onILInit(src:SWFLoader,cible:MovieClip){
		cible.stop();
		cible._visible=false;
		_countInitNbImages++;
		if (_countInitNbImages>=nbImages) {
			start()
			dispatchEvent(ON_READY,new Event(this,ON_READY));
		}
	}
	
	/**
	 * affiche une image du 360 :	 */
	 
	 private function showImage(numImage:Number){
	 	trace("Pt.sequence.T360.showImage("+numImage+")");
	 	var i:Number=numImage%nbImages;
	 	
	 	if (i<0) {
	 		 i=nbImages+i;
	 	}
	 	//trace("Pt.sequence.T360.showImage("+numImage+")"+i);
	 	var currentImage:MovieClip;
	 	for (var j : Number = 0; j < _vuesArray.length; j++) {
	 		if (i==j) {
	 			currentImage=_vuesArray[j];
	 			_vuesArray[j]._visible=true;
	 			
	 			//trace("="+_vuesArray[j])
	 		} else {
	 			_vuesArray[j]._visible=false;
	 		}
	 	}
	 	if (hasBtn) {
			currentImage.btn_prev.onRelease=Delegate.create(this,__prevImage);
			currentImage.btn_next.onRelease=Delegate.create(this,__nextImage);
		} else {
			
		}
		
		// determiner le nom de fichier pour legende
			var num:String=Chaines.untriml(String(i),3,"0");
			var nomFichier:String=Chaines.scanf(src,num);
			dispatchEvent(ON_READY,new Event(this,ON_READY));
		
	 }
	 
	 private function __nextImage(){
	 	showImage(_currentImage+1);
	 }
	 private function __prevImage(){
	 	showImage(_currentImage-1);
	 }
	
	
	/**
	 * lance la lecture de l'element	 */
	public function start(){
			showImage(startAt);
			if (rotate==0) {  // rien a lire
				//trace("rien a lire");
			} else {
				//trace(rotateTime+" "+Math.abs(rotate)+" "+(rotateTime/Math.abs(rotate)));
				var delai:Number=(rotateTime/Math.abs(rotate));
				tempo.destroy();
				tempo=new Temporise(delai,Delegate.create(this, rotateTempo),false);
			}
			
			 
			
	}
	
	private function rotateTempo (tempo:Temporise,count:Number){
		//trace("Pt.sequence.T360.rotateTempo(tempo, "+count+")");
		if (rotate==0) {
			//trace("end tempo")
			initInteraction();
			tempo.remove();	
		} else {
			var inc:Number=rotate/Math.abs(rotate);
			startAt+=inc;
			rotate-=inc;
			//trace("startAt:"+startAt+" rotate:"+rotate);
			showImage(startAt);
		}
		
		
	}
	var tempo:Temporise;
	
	public function destroy(){
		stopInteraction();
		tempo.destroy();
		
		//scan.destroy()
		//scan.removeEventListener(moveListener);
		//delete scan;
		//scan=undefined;
		
		for (var i : Number = 0; i < _ilArray.length; i++) {
			_ilArray[i].destroy();
		}
	}
	
	public function initInteraction(){
		//trace("Pt.sequence.T360.initInteraction()"+scan);
		if (hasBtn) {
			
		} else {
			scan.startScan();
			scan.getClip().useHandCursor=true;
		}
	}
	
	public function stopInteraction(){
		//trace("Pt.sequence.T360.stopInteraction()"+scan);
		scan.stopScan();
	}
	
	
	private function _getCurrentImage():Number {
		for (var i : Number = 0; i < _vuesArray.length; i++) {
				if (_vuesArray[i]._visible) {
					trace("media.M_T360._getCurrentImage()"+i);
					return i;
				}
		}
	}
	
	function get _currentImage():Number{
		return _getCurrentImage();
	}	
	
	function get currentSprite():MovieClip {
		return _vuesArray[_currentImage];
	}
	
	
	
	var incdx:Number=0;
	private function onMoveMove(src:Souris,dx:Number,dy:Number){
		
		if (src.isDown && src.hasMouseOver() && _contener._visible ) {
			//trace("Pt.sequence.T360.onMoveMove(src, "+dx+", "+dy+")");
			incdx+=dx;
			if (Math.abs(incdx/10)>1) {
				
				if (src.hasMouseOver()) {
					//TODO gerer l
				} else {
			
				}
				showImage(_currentImage+Math.floor(incdx/10));
				incdx=0;
			}
		}
	}

}