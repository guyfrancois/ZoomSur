/**
 *
 */
import GraphicTools.BOverOutPress;
/**
 *
 */
class GraphicTools.BOnOutSelect extends BOverOutPress {
	private  var IMG_OVER:String="OVER";
	private  var IMG_OUT:String="ON";
	private  var IMG_PRESS:String="SELECT";
	private  var IMG_ON:String="SELECT";
	private  var IMG_OFF:String="ON";
	
	
	public function BOnOutSelect(btn:MovieClip,enable:Boolean,bascule:Boolean,methode:Function) {
		super(btn,enable,bascule,methode);
		
	}
	
}