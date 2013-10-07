/**
 *
 */

import GraphicTools.LecteurSWF;
import Pt.image.ImageLoader;
import org.aswing.util.Delegate;
import org.aswing.util.SuspendedCall;

/**
 *
 */
class media.MSWF  implements media.I_media   {

	private var lmVideo:LecteurSWF;
	private var clip:MovieClip;
	private var mediaClip:MovieClip;
	
	private var dataXML:Object;
	public function MSWF(clip:MovieClip,dataXML:Object,format:String) {
		this.clip=clip;
				var lFormat:String=format;
		if (lFormat==undefined) {
			lFormat="";
		}
		mediaClip=clip.attachMovie("mediaContentSWF"+lFormat,"media",0);
		this.dataXML=dataXML;
		var video:MovieClip=mediaClip.video;
        lmVideo= new LecteurSWF(video.barre.btn_pause, video.barre.btn_play,video.barre.btn_stop, undefined,mediaClip.img.imgCible, video.barre.progression,video.barre.streaming,true);
	    //fond
	   initBtn();
	   initEcran();
    	
    	
	}
	

	
	private function initBtn(){
   		if (dataXML.zoom!=undefined) {
			mediaClip.video.fond.onPress =  Delegate.create(this, setZoom,dataXML.zoom)  ;
   		}
	}
	
	
    private function lanceVideo() {
    	lmVideo.start(dataXML.ress,dataXML.width,dataXML.height);    	
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