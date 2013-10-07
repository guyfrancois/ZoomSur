/**
 * @author GuyF    , pense-tete
 * 4 f�vr. 2010
 */
import org.aswing.EventDispatcher;
import Pt.conteneur.I_resizable;
import Pt.conteneur.accordeon.AccordeonContent;
import Pt.conteneur.accordeon.HeaderAccordeon;
import Pt.conteneur.accordeon.AccordeonItem;
import caurina.transitions.Tweener;

/**
 * 
 */
class Pt.conteneur.AccordeonV extends EventDispatcher implements I_resizable {
	
	private var clip:MovieClip;
	
	private var blockArray:Array;
	private var _height:Number;
	private var _headersHeight:Number;
	static var TWEENTIME:Number=0.5;
	private var tweenTime:Number=TWEENTIME;
	private var _currentItem:Number;
	
	public function get current():Number {
		return _currentItem;
	}
	
	public function AccordeonV(clip:MovieClip) {
		super();
		this.clip=clip;
		blockArray=new Array();
		_headersHeight=0;
	}
	
	public function addItem(clip:MovieClip,title:HeaderAccordeon,content:AccordeonContent) {
			var block:AccordeonItem=new AccordeonItem(clip,title,content);
			var length:Number=blockArray.push(block);
			
			block.addEventListener(HeaderAccordeon.ON_CHANGE,_open,this);
			if (length>1) {
				block.y=blockArray[length-2].getHeight();
			} 
			_headersHeight+=block.getHeight();
			//trace("_headersHeight "+_headersHeight);
	}
	
	private function _open (src:AccordeonItem){
		//trace("_open up" + src);
		// TODO implementer l'ecouter
		openItem(src);
	}
	
	public function getItem(id:Number):AccordeonItem {
		return blockArray[id];
	}
	
	
	public function open(id:Number,direct:Boolean){
		
			_currentItem=id;
		if (direct==true) {
			tweenTime=0;
		}
			openItem(blockArray[id]);
			tweenTime=TWEENTIME;
			
	}
	
	
	private function openItem(currentItem:AccordeonItem) {
		//trace("Pt.conteneur.AccordeonV.openItem("+currentItem+")");
			var _headerPos:Number=0;
			for (var i:Number=0;i<blockArray.length;i++) {
				var block:AccordeonItem=blockArray[i] ;
				if (block!= currentItem) {
					block.close();
				} else {
					currentItem.open();
				}
				//block.y=_headerPos;
					//Tweener.addTween(block, { y:_headerPos ,time:tweenTime } );
					Tweener.addTween(block,{ y:_headerPos ,time:tweenTime })
					
				_headerPos+=block.getHeight();;
				//block.y=_headerPos;
				
			
				
			}	
	}
	
	public function getHeight():Number{
		return _height;
	}

	public function getWidth():Number{
		return null;
	}

	public function resize(width:Number, height:Number) {
		//trace("AccordeonV.resize"+width+" "+height);
	
			_height=height;
			var _headerPos:Number=0;
			for (var i:Number=0;i<blockArray.length;i++) {
				var currentItem:AccordeonItem=blockArray[i];
				
				currentItem.resize(0,_height-(_headersHeight-currentItem.getHeight()));
				currentItem.y=_headerPos;
				_headerPos+=currentItem.getHeight();;
				
			}
	}

}