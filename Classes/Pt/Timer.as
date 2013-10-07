/**
 * @author Administrator    , pense-tete
 * 30 nov. 07
 */
/**
 * 
 */
class Pt.Timer {
	private var interval:Number;
	private var func;
	private var maTrace:Function;//=Pt.Out.p;
	private var delai:Number;// delai avant reprise, change avec une pause
	
	private var startTime:Number;
	public function Timer(delai:Number,func:Function) {
		maTrace("Pt.Temporise.Temporise(delai="+delai+", func)");
		this.func=func;
		this.delai=delai;
		startTime=getTimer() ;
		interval=setInterval(this,"CALLBACK",delai);
	}
	function CALLBACK(){
		clearInterval(interval);
		func(this,delai);
	}
	
	public function destroy(){
		//maTrace("Pt.Temporise.destroy()");
		clearInterval(interval);
	}
	
	public function pause(){
		var ltime=getTimer();
		delai=delai-(ltime-startTime);
		startTime=ltime;
		clearInterval(interval);
	}
	public function reprise(){
		interval=setInterval(this,"CALLBACK",delai);
	}
	
	public function remove(){
		//maTrace("Pt.Temporise.destroy()");
		clearInterval(interval);
	}
	
}