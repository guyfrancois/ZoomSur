/**
 *
 */
import site.connexe.TransContent;
import Pt.animate.Transition;
import Pt.image.ImageLoader;
import Pt.image.SWFLoader;
import  GraphicTools.Loupe;
import org.aswing.util.Delegate;
import Pt.draw.Primitive;
import Pt.Tools.Chaines;

/**
 *
 */
 /*
 var loupParam:Object= {
    src: "img/fonds/fond_1_01.jpg";
    hd : "img/fonds/fond_1_01.jpg",
    defaultZoom : "2.3",
    minZoom : "1.9",
    maxZoom : "3.1",
    pasZoom : "0.1"
}
*/

	/*
select vue
SELECT:[type Function]
nextNode:[object Object]
prevNode:[object Object]
text:Le Théâtre optique
pasZoom:0.1
maxZoom:4
minZoom:1
defaultZoom:2
hd:img/hd/diapo0/diapo0_%1.jpg
src:swf/diapo_0/diapo_0_%1.swf
img:img/ico/ico_3.jpg
seq:fond_0_3.xml
ref:_1
*/
	
	

class site.EcranLoupe extends TransContent {
	private var imageL:ImageLoader;
	private var _loupParam:Object;
	private var lp:Loupe;
	private var loupeClip:MovieClip;
	private var imageZoom:MovieClip;
	
	



	public function EcranLoupe(clip:MovieClip) {
		super(clip);
		imageZoom=clip.imageZoom;
		//clip.fond.onRelease=Delegate.create(this,transClose);
		//trace("site.EcranLoupe(clip)"+imageZoom);
	}
	
	
    private function onClosed(){
        super.onClosed();
        delete lp;
        loupeClip.removeMovieClip();
        imageL.abort();
        imageL.destroy();
        imageZoom.image.removeMovieClip();
        delete imageL;
        
    }
    
    private function onOpen(src:Transition) {
           super.onOpen(src);
    }
    
    
    public function transOpen(loupParam:Object){
        super.transOpen();
        Pt.sequence.T360.scan.stopScan();
        this._loupParam=loupParam;
        Primitive.rectangle(imageZoom.createEmptyMovieClip("fond",0),(900-589)/2,(585-430)/2,589,430,0x000000,100);
        imageZoom.createEmptyMovieClip("image",1);
       
        imageL=new ImageLoader(imageZoom.image,undefined,900,585,ImageLoader.ALIGNCENTER,ImageLoader.ALIGNCENTER,ImageLoader.SCALLNONE,589,430);
        imageL.addEventListener(ImageLoader.ON_LOADINIT,onLoadInitImage,this);
       
       	var num:String=Chaines.untriml(String(Pt.sequence.T360.getCurrentImage()),3,"0");
        imageL.load( Chaines.scanf(_loupParam.src,num));
            
    }
    
    public function transClose() {
    	
    	super.transClose();
    	lp.close();
    	 Pt.sequence.T360.scan.startScan();
    }
    
    private function onLoadInitImage(source:ImageLoader,cible:MovieClip) {
    	cible.btn_prev._visible=false;
		cible.btn_next._visible=false;
    	loupeClip=imageZoom.attachMovie("loupe","loupeClip",10);
    	loupeClip.btns.btn_x.onRelease=Delegate.create(this,transClose);
    	loupeClip._x=Math.floor(cible._x+(cible.width-loupeClip._width)/2);
    	loupeClip._y=Math.floor(cible._y+(cible.height-loupeClip._height)/2);
    	_root.loader._visible=true;
    	lp=new Loupe(loupeClip,cible,_loupParam);
    	
        lp.addEventListener(Loupe.ON_READY,openLoupe,this)
     }
     
     private function openLoupe(){
     	_root.loader._visible=false;
     	 lp.open();
     }
	
}