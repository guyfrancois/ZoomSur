/**
 *
 */
import Pt.Tools.ClipEvent;
import GraphicTools.BOverOutPress;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import org.aswing.util.Delegate;
/**
 *
 */
class GraphicTools.BOverOutSelectON extends BOverOutPress {
	private  var IMG_OVER:String="OVER";
	private  var IMG_OUT:String="OUT";
	private  var IMG_PRESS:String="SELECT";
	private  var IMG_ON:String="SELECT";
	private  var IMG_OFF:String="OUT";
	
	
	public function BOverOutSelectON(btn:MovieClip,enable:Boolean) {
		super(btn,enable,true);
		
	}
	
	
	private function _onRelease(){
        if (_bascule) {
            setEnable(!_enable);
        }
        dispatchEvent(ON_RELEASE,new Event(this,ON_RELEASE,[btn]));
    }
    private var _enable:Boolean;
    private function unsetEvents(){
        _enable=false;
        goto(IMG_ON);
  
    }
    
    private function _onRollOut(){
    	if (_enable) {
            goto(IMG_OFF);
    	} else {
    		 goto(IMG_ON);
    	}
    	 dispatchEvent(ON_OUT,new Event(this,ON_OUT,[btn]));
    }    
    
    private function setEnable(etat:Boolean) {
        if (_enable!=etat) {
            if (etat) {
                setEvents();
            } else {
                unsetEvents();
            }
        }
            
    }
    
	
}