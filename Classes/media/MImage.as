/**
 *
 */

import Pt.image.ImageLoader;
import media.I_media;
import org.aswing.util.Delegate;
import Pt.image.LoaderDefine;

/**
 *
 *
 */
class media.MImage implements media.I_media  {
	private var imageL:ImageLoader;
	private var clip:MovieClip;
	private var dataXML:Object;
	private var mediaClip:MovieClip;
	public function MImage(clip:MovieClip,dataXML:Object,format:String) {
		this.clip=clip;
		this.dataXML=dataXML;
		var lFormat:String=format;
		if (lFormat==undefined) {
			lFormat="";
		}
		mediaClip=clip.attachMovie("mediaContentImage"+lFormat,"media",0);

 		imageL=new ImageLoader(mediaClip.img.imgCible,undefined,250,200,LoaderDefine.ALIGNCENTER,LoaderDefine.ALIGNBOTTOM,LoaderDefine.SCALLNONE);
 		imageL.addEventListener(ImageLoader.ON_LOADINIT,Delegate.create(this, onLoadInitImage));
 		
 		imageL.load(dataXML.ress);
    	
	}
	
	private function onLoadInitImage(){
		if (dataXML.zoom!=undefined) {
			mediaClip.img.onPress =  Delegate.create(this, setZoom,dataXML.zoom)  ;
		}
	}
	
	
    public function transClose(){
		mediaClip.removeMovieClip();
        
    }
    
     private function setZoom(ref:String) {
	 	 SWFAddress.setZoom(ref);
	 }
	 
    
}