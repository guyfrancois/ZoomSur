/**
 * @author Administrator    , pense-tete
 * 13 f�vr. 08
 */
/**
 * 
 */
class Pt.draw.Primitive {
	
	static public function polygone(target_mc:MovieClip,listePoint:Array,color,alpha) {
		target_mc.moveTo(listePoint[0].x, listePoint[0].y);
		target_mc.beginFill(color, alpha);
		for (var i:Number=listePoint.length;i>0;) {
			i--;
			target_mc.lineTo(listePoint[i].x, listePoint[i].y);
		}
		target_mc.endFill();
	}
	
	
	
	static	public function rectangle(target_mc:MovieClip,x:Number,y:Number,width:Number,height:Number,color:Number,alpha:Number):Void{
		//trace("Pt.draw.Primitive.rectangle("+target_mc+", "+x+", "+y+", "+width+", "+height+", color, alpha)");
		var lalpha:Number=0;
		var lcolor:Number=0;
		if (color!=undefined) {
			lcolor=color;
		}
		if (alpha!=undefined) {
			lalpha=alpha;
		}
		target_mc.beginFill(lcolor, lalpha);
		target_mc.lineStyle(1, lcolor, lalpha);
		target_mc.moveTo(x, y);
		target_mc.lineTo(x+width,y);
		target_mc.lineTo(x+width,y+height);
		target_mc.lineTo(x,y+height);
		target_mc.lineTo(x,y);
		target_mc.endFill();
	}
	
}