/**
 * @author Administrator    , pense-tete
 * 26 mai 08
 */
 import org.aswing.Event;
import org.aswing.EventDispatcher;
import Pt.animate.ClipByFrame;
import org.aswing.util.Delegate;
import GraphicTools.BOverOutSelect;

/**
 * controle un tourne page
 * 
 */
class media.Pages extends EventDispatcher {
	static var imagesBtn:Object={IMG_OUT:1,IMG_OVER:2,IMG_PRESS:3,IMG_ON:3,IMG_OFF:1};
	
	/**
	 * losqu'un changement de page est demandé 
	 * id : page demandée
	 * function onPage(src:pages,id:Number);	 */
	static var ON_PAGE:String="onPage";
	
	
	private var clip:MovieClip
	private var  tf:TextField;
	private var nbPage:Number;
	
	private var btn_suivant:BOverOutSelect;
	private var btn_precedent:BOverOutSelect;
	private var _width:Number;
	/**
	 * contients les elements :
	 * 	compteur: TextField,
	 * 	_suiv : btn_page suivante    pivot horizontal de _prec ,point d' alignement à droite
	 *  _prec : btn_page precedente   	 */
	public function Pages(clip:MovieClip,nbPage:Number,width:Number) {
		super();
		this.clip=clip;
		tf=clip.compteur;
		this.nbPage=nbPage;
		_width=clip.compteur._width;
		setWidth(width);
		
		btn_suivant=initializeBtn(clip._suiv);
		btn_precedent=initializeBtn(clip._prec);
		btn_suivant.addEventListener(BOverOutSelect.ON_RELEASE,dispatchPage,this)
		btn_precedent.addEventListener(BOverOutSelect.ON_RELEASE,dispatchPage,this)
		
	}
	
	public function setWidth (val:Number) {
		if (val==undefined ) return;
		_width=val;
		//clip._prec._x=0;
		clip._suiv._x=val-clip._prec._x;
		//tf._x=0;
		tf._width=val;
	}
	
	/**
	 * id de la page, de 0 à nbPage -1	 */
	private var currentPage:Number ;
	
	public function setPage(id:Number) {
		currentPage=id;
		tf.text=(id+1)+"/"+nbPage;
		
		if (id<=0) {
			btn_precedent.enable=false;
			btn_suivant.enable=true;
		} else if(id>=nbPage-1){
			btn_precedent.enable=true;
			btn_suivant.enable=false;
		} else {
			btn_precedent.enable=true;
			btn_suivant.enable=true;
		}
	}
	
	private function dispatchPage(src:BOverOutSelect) {
		switch (src) {
			case btn_suivant :
				dispatchEvent(ON_PAGE,new Event(this,ON_PAGE,[currentPage+1]));
			break;
			case btn_precedent :
				dispatchEvent(ON_PAGE,new Event(this,ON_PAGE,[currentPage-1]));
			break;
		}
		
	} 
	
	
	private function initializeBtn(lClip): BOverOutSelect{
		var btnCBF:ClipByFrame=new ClipByFrame(lClip);
		return new BOverOutSelect(lClip,true,false,Delegate.create(btnCBF, btnCBF.goto),imagesBtn);
		

	}
	
	
	
}