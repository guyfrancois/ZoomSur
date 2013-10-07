/**
 * @author Administrator    , pense-tete
 * 9 avr. 08
 */
import GraphicTools.I_Lecteur;
import org.aswing.EventDispatcher;
/**
 * 
 */
class media.FluxUnique  extends EventDispatcher implements  I_Lecteur {
	public static var prevInstance:I_Lecteur;
	
	
	
	public function FluxUnique() {
		super();
		
	}
	
	private function setUnique(){
		if (FluxUnique.prevInstance!=this) {
            			FluxUnique.prevInstance.stop();
            			FluxUnique.prevInstance=this;
        }
		
	}
	
	function destroy(){
		
	}
	function play(){
		
	}
	function stop(){
		
	}
	function pause(){
		
	}
}