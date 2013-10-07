/**
 * @author Administrator    , pense-tete
 * 14 janv. 08
 */
import demoScrollIt.*;
import GraphicTools.scrollinIt.*;
import org.aswing.util.Delegate;
import Pt.scan.Souris;
import Pt.scan.OverOut;
import Pt.Temporise;
/**
 * 
 */
class demoScrollIt.Demo {
	private var clip:MovieClip;
	private var plan:Plan;
	private	var avTempo:Temporise;
	private var apTempo:Temporise;
	private var MouseScan:Souris;
	
	private var factDep:Number=2;
	private var maxDep:Number=10;
	
	public function Demo(clip:MovieClip) {
		trace("demoScrollIt.Demo.Demo("+clip+")");
		this.clip=clip;
		plan=new Plan(clip.plan,890,10,Plan.HSENS);
		var factory:VignettesFactory=new VignettesFactory(clip.plan,this);
		MouseScan=new Souris(clip.plan);
		MouseScan.addEventListener(Souris.ON_MOUSEMOVE,_onMouseMove,this)
		
		
		var avOver:OverOut=new OverOut(clip.av);
		avOver.addEventListener(OverOut.ON_ROLLOUT,_avOut,this);
		avOver.addEventListener(OverOut.ON_ROLLOVER,_avOver,this);
		var apOver:OverOut=new OverOut(clip.ap);
		apOver.addEventListener(OverOut.ON_ROLLOUT,_apOut,this);
		apOver.addEventListener(OverOut.ON_ROLLOVER,_apOver,this);
		avOver.startScan();
		apOver.startScan();
		MouseScan.startScan();
		plan.setDefaultFactory(factory);
		plan.fill();
	}
	
	private function _onMouseMove(src:Souris,dx:Number,dy:Number){
		if (src.hasMouseOver()) {
			if (!src.hasMouseOver(true)) {
				plan.deplacer(dx*factDep)
			}
		}
	}
	
	
	public function onMouseMoveVignette(src:Souris,dx:Number,dy:Number){
		//trace(src.getMousePos()+" "+src.hasMouseOver()+" "+src.getClip()+" "+src.getClip()._x+" "+src.getClip()._y);
		
		
		if (src.hasMouseOver()) {
			//trace("demoScrollIt.Demo.onMouseMoveVignette(src, dx, dy) "+MouseScan.getDPoint().x);
			var x:Number=src.getMousePos().x-src.getClip()._x;
			var Dx:Number=MouseScan.getDPoint().x;
			var width:Number=src.getClip()._width;
			var dep:Number=x*(x-width)*4/(width*width)+1;
			//trace(width+" "+x+" "+dep)
			var depMov:Number=Dx*dep*factDep;
			if (Math.abs(depMov)>maxDep) {
				if (Dx>0) {
					plan.deplacer(maxDep);
				} else {
					plan.deplacer(-maxDep);
				}
			} else {
				plan.deplacer(depMov);
			}
		}
	}
	

	private function _avOver(){
		avTempo.remove();
		avTempo=new Temporise(10,Delegate.create(plan, plan.deplacer,-maxDep));
	}
	private function _avOut(){
		avTempo.remove();
	}
	private function _apOver(){
		apTempo.remove();
		apTempo=new Temporise(10,Delegate.create(plan, plan.deplacer,maxDep));
	}
	private function _apOut(){
		apTempo.remove();
	}
	
	
	
}