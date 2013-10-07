/**
 * @author Administrator    , pense-tete
 * 14 janv. 08
 */
import GraphicTools.scrollinIt.I_VignettesFactory;
import GraphicTools.scrollinIt.I_vignettes;
import GraphicTools.scrollinIt.FactoryError;
import demoScrollIt.Demo;
import Pt.scan.Souris;

/**
 * 
 */
class demoScrollIt.VignettesFactory implements I_VignettesFactory {
	
	private var clip:MovieClip
	private var demo:Demo;
	
	public function VignettesFactory(clip:MovieClip,demo:Demo) {
		
		this.clip=clip;
		this.demo=demo;
	}
	
	public function create(id:Number):I_vignettes{
		trace("demoScrollIt.VignettesFactory.create("+id+")");
		var index:Number=id%4;
		var clipv:MovieClip= clip.attachMovie("vignette_"+index,"v_"+id,clip.getNextHighestDepth());
		if (clipv==undefined ) {
			throw new FactoryError("index impossible");
		} else {

			return new demoScrollIt.Vignette(clipv,demo,id);
		}

	}

}