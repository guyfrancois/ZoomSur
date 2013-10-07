/**
 * @author guyf
 */
class Pt.Tools.Permute {
	static public function calcul(taille:Number):Array{
		var tableau:Array=new Array(taille);
		for (var i : Number = 0; i < taille; i++) {
			tableau[i]=i;
		}
		for (var i : Number = 0; i < taille; i++) {
			var max=taille-i;
			var alea:Number=Math.floor(Math.random()*(max));
			var val:Number=tableau[alea+i]
			tableau[alea+i]=tableau[i];
			tableau[i]=val;
		}
		return tableau;
	}
}