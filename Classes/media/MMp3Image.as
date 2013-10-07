/**
 *
 */

import GraphicTools.LecteurAudio;
import Pt.image.ImageLoader;
import org.aswing.util.Delegate;
import org.aswing.util.SuspendedCall;

/**
 *
 */
class media.MMp3Image implements media.I_media   {
	private var imageL:ImageLoader;
	private var lmVideo:LecteurAudio;
	private var clip:MovieClip;
	private var mediaClip:MovieClip;
	
	private var dataXML:Object;
	public function MMp3Image(clip:MovieClip,dataXML:Object,format:String) {
		this.clip=clip;
		var lFormat:String=format;
		if (lFormat==undefined) {
			lFormat="";
		}
		mediaClip=clip.attachMovie("mediaContentMp3"+lFormat,"media",0);
		this.dataXML=dataXML;
		var video:MovieClip=mediaClip.video;
        lmVideo= new LecteurAudio(video.barre.btn_pause, video.barre.btn_play,video.barre.btn_stop, undefined, video.barre.progression,video.barre.streaming,true);
	    //fond
	   initBtn();
	   initEcran();
    	
	 	imageL=new ImageLoader(mediaClip.img.imgCible,undefined,250,200,ImageLoader.ALIGNCENTER,ImageLoader.ALIGNBOTTOM,ImageLoader.SCALLNONE);
 		imageL.addEventListener(ImageLoader.ON_LOADINIT,Delegate.create(this, onLoadInitImage));
 		imageL.load(dataXML.img);
    	
	}
	
	private function onLoadInitImage(){
		if (dataXML.zoom!=undefined) {
			mediaClip.img.onPress =  Delegate.create(this, setZoom,dataXML.zoom)  ;
		}
	}

	
	private function initBtn(){
   		if (dataXML.zoom!=undefined) {
			mediaClip.video.fond.onPress =  Delegate.create(this, setZoom,dataXML.zoom)  ;
   		}
	}
	
	
    private function lanceVideo() {
    	lmVideo.start(dataXML.ress);    	
    }
    
    private function initEcran(){
  
              	SuspendedCall.createCall(lanceVideo, this, 3);
            
    }
	
    public function transClose(){
    	
    	lmVideo.destroy();
		mediaClip.removeMovieClip();
        
    }
    
     private function setZoom(ref:String) {
	 	 SWFAddress.setZoom(ref);
	 }
	 

   

    
}