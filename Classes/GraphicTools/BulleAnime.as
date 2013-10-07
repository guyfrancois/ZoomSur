/**
 * @author guyf
 */
 
import flash.geom.Rectangle;
import GraphicTools.BOverOutPress;
import org.aswing.Event;
import org.aswing.EventDispatcher;
 
class GraphicTools.BulleAnime extends EventDispatcher {
	/**
	 * quand ferme le commentaire de sylvette
	 * onClose(source:)
	 */	
	public static var ON_CLOSE:String = "onClose";
	
	
	private var clip:MovieClip;
	private var blocText:MovieClip;
	private var fond:MovieClip;
	private var btnFermer:BOverOutPress;
	
	public function BulleAnime(clip:MovieClip) {
		super();
		clip._visible=false;
		this.clip=clip;
		blocText=clip.blocText;
		fond=blocText.fond;
		
		var grid:Rectangle = new Rectangle(20, 20, 230, 310);
		fond.scale9Grid = grid ;
		btnFermer=new BOverOutPress(clip.btn_fermer,true,false);
		btnFermer.addEventListener(BOverOutPress.ON_RELEASE,onBtnFermer,this)
		
		
		
	}
	
	
	function setText(texte:String,x:Number,y:Number) {
		//trace("GraphicTools.BulleAnime.setText(texte, "+x+","+ y+")");
		if (x==undefined) {
			clip._x=0;
		} else {
			clip._x=x;
		}
		if (y==undefined) {
			clip._y=0;
		} else {
			clip._y=y;
		}
		
		
		var tf:TextField=blocText.texte;
		var css:TextField.StyleSheet = new TextField.StyleSheet();
	 	var locRef:Object=this;
		css.onLoad  = function(success:Boolean) {
		 	if (success) {
		  		tf.styleSheet = css;
		  		tf.autoSize="left";
          		tf.htmlText = texte;
          		locRef.dispose();
          		
     		}
		}
		css.load(Pt.Tools.Clips.convertURL("style.css"));
	}
	
	
	private function dispose(){
		clip._visible=true;
		fond._height=blocText.texte._height+20;
		clip.gotoAndPlay(2);
		
	}
	private function onBtnFermer(){
		dispatchEvent(ON_CLOSE,new Event(this,ON_CLOSE));
	}
	
}