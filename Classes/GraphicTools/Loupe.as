/**
 * @author Administrator    , pense-tete
 * 27 nov. 07
 */
 import org.aswing.EventDispatcher;
import org.aswing.Event;
 import Pt.animate.Transition;
 import Pt.Tools.ClipEvent; 
 import org.aswing.geom.Point;
 import GraphicTools.BOverOutPress;
 import Pt.image.ImageLoader;
 import Pt.Tools.Clips;
 import Pt.Tools.Slider;
 import Pt.Tools.Chaines;
/**
 * 
 */
class GraphicTools.Loupe extends EventDispatcher {
	static var ON_READY:String="onReady";

	private var clip:MovieClip
	private var trans:Transition;
	
	private var clipRef:MovieClip;
	
	
	private var echelle:Number;
	
	private var refImgPos:Point;
	// parametres XML
	// .hd
	// .defaultZoom
	// .minZoom
	// .maxZoom
	// .pasZoom
	private var zoomParam:Object;
	private var hd:String;
	private var defaultZoom:Number;
	private var minZoom:Number;
	private var maxZoom:Number;
	private var pasZoom:Number;
	private var infoZoom:TextField;
	private var monSlide:Slider;
	
	
	public function Loupe(clip:MovieClip,clipRef:MovieClip,zoomParam:Object) {
		super();
		this.zoomParam=zoomParam;
		hd=zoomParam.hd;
		defaultZoom=Number(zoomParam.defaultZoom);
		minZoom=Number(zoomParam.minZoom);
		maxZoom=Number(zoomParam.maxZoom);
		pasZoom=Number(zoomParam.pasZoom);
	
		this.clip=clip;
		this.clipRef=clipRef;
		//trace("zoomParam.defaultZoom"+zoomParam.defaultZoom+" "+clip.btns.grip)
		this.echelle=defaultZoom;
		clip._visible=false;
		trans=new Transition(clip);
	
		//clip.gotoAndStop(clip._totalframes);
		
		
		trans.addEventListener(Transition.ON_CLOSE,_onTransClose,this);
		trans.addEventListener(Transition.ON_OPEN,_onTransOpen,this);
		trans.addEventListener(Transition.ON_UPDATE,onUpdate,this);// synchro avec masque
		
		var nbtnp:BOverOutPress=new BOverOutPress(clip.btns.btn_p,true,false);
		nbtnp.addEventListener(BOverOutPress.ON_RELEASE,_zoomp,this);
		
		var nbtnm:BOverOutPress=new BOverOutPress(clip.btns.btn_m,true,false);
		nbtnm.addEventListener(BOverOutPress.ON_RELEASE,_zoomm,this);
		
		monSlide=new Slider(clip.btns.scroll,pasZoom*10,minZoom*10,maxZoom*10,defaultZoom*10) ;
		monSlide.addEventListener(Slider.ON_MOVEDONE,this.onMoveScroll,this);
       
		infoZoom=clip.btns.zoom;
		initialise();
		
		refImgPos=new Point();
		clipRef.localToGlobal(refImgPos);
		var num:String=Chaines.untriml(String(Pt.sequence.T360.getCurrentImage()),3,"0");
       
		var loader:ImageLoader=new ImageLoader(clip.img.createEmptyMovieClip("_z",10),Chaines.scanf(hd,num),null,null,ImageLoader.ALIGNLEFT,ImageLoader.ALIGNTOP,ImageLoader.SCALLNONE);
		loader.addEventListener(ImageLoader.ON_LOADINIT,_onZoomInit,this);
	}
	
	private function onMoveScroll(src:Slider,val:Number){
		echelle=val/10;
		miseAEchelle();
	}
	
	private var scallAt1:Number;
	private var __echelle1 :Number;
	private var __ratio :Number;
	private function _zoomp() {
		var next:Number=Math.round((echelle+pasZoom)*10)/10;
		//trace((echelle+pasZoom)+" "+maxZoom+((echelle+pasZoom)<=maxZoom))
		if ((next)<=maxZoom) {
			echelle=next;
			monSlide.moveTo(echelle*10);
			miseAEchelle();
		}
		
	}
	private function _zoomm() {
		//trace((echelle-pasZoom)+" "+minZoom+((echelle-pasZoom)>=minZoom))
		var next:Number=Math.round((echelle-pasZoom)*10)/10;
		if (next>=minZoom) {
			echelle=next;
			monSlide.moveTo(echelle*10);
			miseAEchelle();
		}
		
	}
	private var cible:MovieClip;
	private var posAt1Initial:Point;
	private var pointsAlign:Object;
	private function _onZoomInit(il:ImageLoader,cible:MovieClip) {
		
		
		var mod:Object=Clips.getDeplaceTo(cible,clipRef);
		cible.btn_prev._visible=false;
		cible.btn_next._visible=false;
		scallAt1=mod.scale;
		//trace("scallAt1 : "+scallAt1);
		//trace(100/scallAt1);
		if (isNaN(maxZoom) ) {
			maxZoom=100/scallAt1;
		}
		if (isNaN(echelle)) {
			echelle=100/scallAt1;
		}
		cible._xscale=mod.scale;
		cible._yscale=mod.scale;
		cible._x=mod.point.x;
		cible._y=mod.point.y;
		posAt1Initial=new Point(clip._x,clip._y);
		clip._parent.localToGlobal(posAt1Initial);
		clip.img._x=0;
		clip.img._y=0;
		clip.img.cacheAsBitmap=true
		
		miseAEchelle();
		dispatchEvent(ON_READY,new Event(this,ON_READY));
		
	}
	
	/**
	 * @param lwidth : largeur loupe
	 */
	 /*
	private function test(lwidth:Number,__zoomRange:Number){
		 var x:Number=-lwidth/2*(__zoomRange*__ratio-1)
					-__content._width-(winx-__zoomTarget._width)*__zoomRange*__ratio
	}
	*/
	/** deplacement de la cible du à l'alignement du point focal à echelle*/
	private function miseAEchelle(){
		//trace("bro.Loupe.miseAEchelle("+echelle+")");
		clip.img._xscale=echelle*100;
		
		clip.img._yscale=echelle*100;
		infoZoom.text=String(echelle);
		placeZoom();
	}
	private function placeZoom(){
		var points:Object=getPointsRef();
		var pointi:Point=points.ipoint;
		//trace("pointi"+pointi.toString());
		clip.img._x=(-refImgPos.x-pointi.x+posAt1Initial.x)*clip.img._xscale/100+clip.masque._width/2;
		clip.img._y=(-refImgPos.y-pointi.y+posAt1Initial.y)*clip.img._yscale/100+clip.masque._height/2;
		
	}
	
	private function onUpdate(src:Transition,currentImg:Number){
		clip.masque.gotoAndStop(src.getClip()._totalframes-currentImg+1);
		clip.masque2.gotoAndStop(src.getClip()._totalframes-currentImg+1);
		
	}
	public function isOpen():Boolean{
		return trans.isOpen()
	}
	public function isClose():Boolean{
		return trans.isClose()
	}
	
	
	public function open(){
		//trace("bro.Loupe.open()");
		clip._visible=true;
		trans.open();
	}
	public function close(){
		ClipEvent.unsetEventsTrigger(clip.masque,"onPress");
		ClipEvent.unsetEventsTrigger(clip.btns.grip,"onPress");
		//trace("bro.Loupe.close()");
		trans.close();
	}
	
	private function _onTransClose(){
		clip._visible=false;
	}
	private function _onTransOpen(){
		var P:Point=refImgPos.clone();
		clip._parent.globalToLocal(P);
		minx=P.x-clip.masque._width/2;
		maxx=P.x+clipRef.width-clip.masque._width/2
		miny=P.y-clip.masque._height/2
		maxy=P.y+clipRef.height-clip.masque._height/2
		miseAEchelle();
	//	ClipEvent.setEventsTrigger(clip.masque,"onPress");
		ClipEvent.setEventsTrigger(clip.btns.grip,"onPress");
	}
	
	private function initialise(){
        ClipEvent.initialize(clip.masque);
        ClipEvent.initialize(clip.btns.grip);
        clip.btns.grip.addEventListener("onPress",startScan,this);
		clip.btns.grip.addEventListener("onMouseMove",_onMouseMove,this);
		clip.btns.grip.addEventListener("onRelease",stopScan,this);
		clip.btns.grip.addEventListener("onReleaseOutside",stopScan,this);
       
	//	clip.masque.addEventListener("onPress",startScan,this);
	//	clip.masque.addEventListener("onMouseMove",_onMouseMove,this);
	//	clip.masque.addEventListener("onRelease",stopScan,this);
	//	clip.masque.addEventListener("onReleaseOutside",stopScan,this);
	}
	
	private var startMouse:Point;
	public function startScan(width:Number,height:Number) {
		//trace("bro.Loupe.startScan()"+clip.btns.grip);
		if (width!=undefined) clip._x=clip._parent._xmouse-width/2;
		if (height!=undefined) clip._y=clip._parent._ymouse-height/2;
		
		startMouse=new Point(clip._parent._xmouse,clip._parent._ymouse);
		//startMouse=new Point(0,0);
		ClipEvent.setEventsTrigger(clip.btns.grip,"onMouseMove");
		ClipEvent.setEventsTrigger(clip.btns.grip,"onRelease");
		ClipEvent.setEventsTrigger(clip.btns.grip,"onReleaseOutside");
		
	//	ClipEvent.setEventsTrigger(clip.masque,"onMouseMove");
	//	ClipEvent.setEventsTrigger(clip.masque,"onRelease");
	//	ClipEvent.setEventsTrigger(clip.masque,"onReleaseOutside");
	}
	public function stopScan() {
		//trace("bro.Loupe.stopScan()");
		ClipEvent.unsetEventsTrigger(clip.btns.grip,"onMouseMove");
		ClipEvent.unsetEventsTrigger(clip.btns.grip,"onRelease");
		ClipEvent.unsetEventsTrigger(clip.btns.grip,"onReleaseOutside");
		
	//	ClipEvent.unsetEventsTrigger(clip.masque,"onMouseMove");
	//	ClipEvent.unsetEventsTrigger(clip.masque,"onRelease");
	//	ClipEvent.unsetEventsTrigger(clip.masque,"onReleaseOutside");
	
	}
	

	function getPointsRef():Object {
		var loupeCentre:Point=new Point();
		clip.masque.localToGlobal(loupeCentre);
		var refPoint=new Point(loupeCentre);
		clip.img.globalToLocal(loupeCentre);
		clipRef.globalToLocal(refPoint);
		return {zpoint:loupeCentre,ipoint:refPoint};
	}
	
	private var minx:Number;
	private var miny:Number;
	private var maxx:Number;
	private var maxy:Number;
	
	function _onMouseMove(){

		var pos:Point=new Point(clip._x,clip._y);
		var mouseDep:Point=new Point(clip._parent._xmouse,clip._parent._ymouse);
		mouseDep=mouseDep.substract(startMouse);
		pos=pos.add(mouseDep);
		
		if (minx<pos.x && pos.x< maxx) {
			clip._x=pos.x;
		}
		if (miny<pos.y && pos.y< maxy) {
			clip._y=pos.y;
		}

		placeZoom();
		
		startMouse=new Point(clip._parent._xmouse,clip._parent._ymouse);
		//trace("startMouse :"+startMouse);
		//trace(new Point(clip._xmouse,clip._ymouse));
		updateAfterEvent();
		
	}
	
	
}