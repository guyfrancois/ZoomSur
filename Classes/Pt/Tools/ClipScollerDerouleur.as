/**
 * @author GuyF , pense-tete.com
 * @date 8 mars 07
 * 
 */
import Pt.Tools.ClipEvent; 
class Pt.Tools.ClipScollerDerouleur {
	
	private var clipTexte:MovieClip;
	private var _baseXText:Number;
	private var _baseYText:Number;
	private var _maxWidthText:Number;
	private var _maxHeightText:Number;
	
	private var texte:MovieClip;
	private var masque:MovieClip;
	private var pas:Number=1;
	private var MaxPas:Number=7;
	private var tempo:Number=20;
	private var scrollerMC:MovieClip;
	/**
	 * ClipTexte contient
	 * 	texte:TextField;
	 * 	@param clipTexte : clip contenant
	 * 			le clip à scroller : texte
	 * 			le masque : masque
	 */
	public function ClipScollerDerouleur(clipTexte:MovieClip) {
		this.clipTexte=clipTexte;
		texte=clipTexte.texte;
		masque=clipTexte.masque;
		texte.setMask(masque);
		_baseXText=texte._x;
		_baseYText=texte._y;
		_maxWidthText=texte._width;
		texte._y=texte._y+masque._height/2;
		_maxHeightText=masque._height;
		if (texte._height>masque._height) {
				addScroller();
				startDeroule();
		}
		var locRef:ClipScollerDerouleur=this;
		clipTexte.onUnload=function() {
			locRef.removeScroller();
		}
	}
	
	
	
	
	
	private function addScroller(){
		initScrollerMover();
	}
	public function removeScroller(){
		//trace("Pt.Tools.TextScoller.removeScroller()");
		clearInterval(DerouleInterval);
		texte._x=_baseXText;
		masque._x=_baseXText;
		//texte._width=_maxWidthText;
	}

	
	private function  initScrollerMover(){
		
		scrollerMC.masque.useHandCursor=false;
		
		ClipEvent.setEventsTrigger(masque,"onMouseMove");
		masque.addEventListener("onMouseMove",_onMouseMove,this);
		
	}
	
	private var manetteYMouse:Number;

	function _onMouseMove(){
		
		pas=(((masque._height/2)-masque._ymouse)/masque._height)*10;
		//trace("Pt.Tools.ClipScollerDerouleur._onMouseMove()"+pas);
		if (pas>2) {
			pas=2;
		} else	if (pas<-2) {
			pas=-2;
		} else if (pas<1 && pas>-1) {
			pas=0;
		} 
		
	
	}
	
	private function updateTextScoller(pas:Number){
		if (pas>0) {
			if (((texte._y-pas)+texte._height)<(masque._y+masque._height) ) {
				texte._y=_baseYText;
			} else {
				texte._y=Math.floor(texte._y-pas);
			}
		} else if (pas<0) {
			if ((texte._y-pas)>masque._y) {
				texte._y=masque._y+masque._height-texte._height
			} else {
				texte._y=Math.floor(texte._y-pas);
			}
		
		}
		updateAfterEvent();
		
	}


	
	var DerouleInterval:Number;
	
	function startDeroule(){
		//trace("GraphicTools.Simples.GestDerouleur.startDeroule()"+auto);
		if ( DerouleInterval==undefined) {
			DerouleInterval=setInterval(this,"derouleSolo",tempo);
		}
		
	}
	function stopDeroule(){
		clearInterval(DerouleInterval);
		DerouleInterval=undefined;
	}
	function derouleSolo(){
		updateTextScoller(pas);
	}
	
}