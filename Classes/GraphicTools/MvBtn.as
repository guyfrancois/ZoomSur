/**
 * @author Administrator    , pense-tete
 * 6 d�c. 07
 */
import org.aswing.util.Delegate;
/**
 * 
 */
class GraphicTools.MvBtn extends MovieClip {
	[Inspectable(defaultValue="GraphicTools.BOnOutSelect")]
	var className:String;
	[Inspectable(defaultValue=true)]
	var enable:Boolean ;
	[Inspectable(defaultValue=false)]
	var bascule:Boolean ;
	[Inspectable(defaultValue="gotoAndPlay")]
	var gotoMethode:String ;
	[Inspectable(defaultValue="mvBtnlistenner")]
	var listenner:String ;
	
	private var inner_cls:Function;
	private var inner_intance:Object;
	
	public function MvBtn() {
		
		if (inner_cls == undefined)
		{
			inner_cls = mx.utils.ClassFinder.findClass(className);
		}
		var methode:Function=Delegate.create(this,this[gotoMethode]);
		inner_intance = new inner_cls(this,enable,bascule,methode);
		if (inner_intance == null)
		{
			//trace( "Could not construct a Object - new "+className+" ");
		}
		
	}
	
	private  function initialize(){
		var oListenner:Object=Pt.Tools.Chaines.findObject(listenner);
		if (oListenner==undefined) {
			//trace("pas d'écouteur pour "+this+" : "+listenner)
		} else {
			trace ("écouteur pour "+this+" : "+listenner);
		}
		inner_intance.addEventListener(oListenner);
		inner_intance.dispatchAction("onLoad");
	}
	
	public function onLoad(){
		initialize();
		
	}
	public function onUnLoad(){
		inner_intance.dispatchAction("onUnLoad");
		
	}

}