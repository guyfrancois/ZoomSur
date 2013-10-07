/**
 * @author Administrator    , pense-tete
 * 30 nov. 07
 */
/**
 * 
 */
class Pt.Temporise {
	private var _delai:Number;
	private var interval:Number;
	private var func;
	private var oneShoot:Boolean;
	private var count:Number;
	private var maTrace:Function=Pt.Out.p;
	/**
	 * @param delai : temps entre appel
	 * @param func : function de signal : func(this,count)
	 * @param oneShoot : true : 1seul fois, sinon repetition	 */
	public function Temporise(delai:Number,func:Function,oneShoot:Boolean) {
		maTrace("Pt.Temporise.Temporise(delai="+delai+", func, oneShoot="+oneShoot+")");
		count=0;
		this.func=func;
		this.oneShoot=oneShoot;
		_delai=delai;
		interval=setInterval(this,"CALLBACK",delai);
	}
	function getCALLBACKinRun():Function{
		return func
	}
	function changeCALLBACKinRun(func:Function) {
		this.func=func;
	}
	function CALLBACK(){
		count++;
		if (oneShoot) {
			clearInterval(interval);
		}
		//maTrace("Pt.Temporise.CALLBACK()");
		func(this,count);
	}
	
	public function getFunc():Function{
		return func
	}
	
	public function pause(){
		clearInterval(interval);
	}
	public function reprise(){
		clearInterval(interval);
		if (func==null) return;
		interval=setInterval(this,"CALLBACK",_delai);
	}
	
	public function destroy(){
		//maTrace("Pt.Temporise.destroy()");
		func=null;
		clearInterval(interval);
	}
	
	public function remove(){
		//maTrace("Pt.Temporise.destroy()");
		if (func==null) return;
		clearInterval(interval);
	}
	
}