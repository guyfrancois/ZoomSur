/**
 *
 */
import org.aswing.util.SuspendedCall;

import Pt.image.ImageLoader;

/**
 *
 */
class GraphicTools.VignetteVideo  {
	private var imageL:ImageLoader;
	
	private var clip:MovieClip;
	
	private var dataXML:Object;
	public function VignetteVideo(clip:MovieClip,dataXML:Object) {
		this.clip=clip;
		this.dataXML=dataXML;
		var imageAddr:String=dataXML.src.substring(0,(dataXML.src.length-3))+"jpg";
		var video:MovieClip=clip.video;
    //    lmVideo= new LecteurMedia(video.barre.btn_pause, video.barre.btn_play,video.barre.btn_stop, video.flvplayBack, undefined, video.barre.progression,video.barre.streaming,true);
 		imageL=new ImageLoader(clip.image.cible,undefined,320,240,ImageLoader.ALIGNCENTER,ImageLoader.ALIGNCENTER,ImageLoader.SCALLNONE);
 		imageL.load(imageAddr)
	//	lmVideo.addEventListener(LecteurMedia.ON_STOP,this.transClose,this);
	    
	   initBtn();
    	
	}
	
	private function initBtn(){
		var locRef:VignetteVideo=this;
		clip.onPress=function (){
    		locRef.transOpen();
    	}
	}
	
	private function removeBtn(){
		delete clip.onPress; 
	}
	
	public function transOpen(){
		removeBtn();
		initEcran();
	}
	
	
    private function initEcran(){
  
              	SuspendedCall.createCall(lanceVideo, this, 3);
            
    }
    
    
    private function lanceVideo() {
    	
    	clip.image._visible=false;
    //	lmVideo.startVideo(dataXML.src,true);    	
    }
    
    
   

   
    public function transClose(){
    	initBtn();
    	clip.image._visible=true;
    //	lmVideo.destroy();
        
    }
    
}