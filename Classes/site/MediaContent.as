/**
 * @author GuyF , pense-tete.com
 * @date 30 mai 07
 * 
 */

import GraphicTools.BOverOutSelect;
import Pt.image.ImageLoader;
import site.Navigator;

import org.aswing.util.Delegate;
import Pt.Tools.Clips;
import Pt.Tools.Chaines;
import media.*;

class site.MediaContent {
	private var clip:MovieClip;
	private var imageL:ImageLoader;
	private var btn_zoom:BOverOutSelect;
	private var btn_suiv:BOverOutSelect;
	private var btn_prec:BOverOutSelect;
	
	static var BTN_IMG:Object={IMG_OUT:1,IMG_OVER:4,IMG_PRESS:7,IMG_ON:7,IMG_OFF:1};

	
	
	public function MediaContent(clip:MovieClip) {
		//trace("site.MediaContent.MediaContent(clip)");
		this.clip=clip;
		btn_zoom=new BOverOutSelect(clip.icone_zoom,undefined,false,undefined,BTN_IMG);
		btn_zoom.addEventListener(BOverOutSelect.ON_RELEASE,this.onZoom,this);
		btn_suiv=new BOverOutSelect(clip.suiv,undefined,false,undefined,BTN_IMG);
		btn_suiv.addEventListener(BOverOutSelect.ON_RELEASE,this.onSuiv,this);
		btn_prec=new BOverOutSelect(clip.prec,undefined,false,undefined,BTN_IMG);
		btn_prec.addEventListener(BOverOutSelect.ON_RELEASE,this.onPrec,this);

	}
	

	
	
	/**
	 * @param img : structure de ressource image	 */
	private var _ressArray:Array;
	private var currentRess:Number;
	public function setContent(ress:Array) {
		_ressArray=ress;
		btn_zoom.getBtn()._visible=false;
		btn_suiv.getBtn()._visible=false;
		btn_prec.getBtn()._visible=false;
		initContent(0);

	}
	
	private var lastRess:I_media;
	
	private function initContent(ressId:Number){
		lastRess.transClose();
		currentRess=ressId;
		var mediaType:String;
		var mediaContent:MovieClip=clip.mediaContent;
		var ref:String=_ressArray[currentRess].ress;
		if (currentRess<(_ressArray.length-1)) {
			btn_suiv.getBtn()._visible=true;
		} else {
			btn_suiv.getBtn()._visible=false;
		}
		if (currentRess>0) {
			btn_prec.getBtn()._visible=true;
		} else {
			btn_prec.getBtn()._visible=false;
		}
		if (_ressArray[currentRess].zoom==undefined) {
			btn_zoom.getBtn()._visible=false;
		} else {
			btn_zoom.getBtn()._visible=true;
		}
		if (_ressArray[currentRess].text==undefined) {
			Clips.setTexteHtmlCss(clip.legende,"style.css","");
		} else {
			Clips.setTexteHtmlCss(clip.legende,"style.css",_ressArray[currentRess].text);
		}
				
		
		switch (ref.substr(ref.length-3,ref.length).toUpperCase()) {
			
			
			case "FLV" :
				//lastRess=new MVideo(mediaContent,_ressArray[currentRess]);
			break;
			case "MP3" :
				lastRess=new MMp3Image(mediaContent,_ressArray[currentRess]);
			break;
			case "SWF" :
				lastRess=new MSWF(mediaContent,_ressArray[currentRess]);
			break;
			case "JPG" :
			default :
				lastRess=new MImage(mediaContent,_ressArray[currentRess]);
			break;
			
			
		}
		clip._visible=true;		
		
	}
	
	/**
	 * affiche image	 */
	
	public function removeContent(){
		lastRess.transClose()
		btn_zoom.getBtn()._visible=false;
		btn_suiv.getBtn()._visible=false;
		btn_prec.getBtn()._visible=false;
		
		Clips.setTexteHtmlCss(clip.legende,"style.css","");
	}
	
	 
	 

	 private function onZoom(){
	 	setZoom(_ressArray[currentRess].zoom);
	 }

	 private function onSuiv(){
	 	initContent(currentRess+1);
	 }

	 private function onPrec(){
	 	initContent(currentRess-1);
	 }

	 private function setZoom(ref:String) {
	 	 SWFAddress.setZoom(ref);
	 }
	 

}