/**
 *
 */
import GraphicTools.BOverOutPress;
/**
 *
 */
class GraphicTools.BOverOutSelect extends BOverOutPress {
	private  var IMG_OVER:String="OVER";
	private  var IMG_OUT:String="OUT";
	private  var IMG_PRESS:String="SELECT";
	private  var IMG_ON:String="SELECT";
	private  var IMG_OFF:String="OUT";
	
	
	public function BOverOutSelect(btn:MovieClip,enable:Boolean,bascule:Boolean,methode:Function,images:Object,reclic:Boolean) {
		super(btn,enable,bascule,methode,images,reclic);
		
	}
	
}