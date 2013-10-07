/**
 * @author Administrator
 */
import cine.Navigator; 
import cine.Vignette;
import org.aswing.Event;
import org.aswing.EventDispatcher;
class GraphicTools.ScollPlan extends EventDispatcher {
	/**
	 * Definition des evenements leves	 */
	 /**
	  * à la selection d'une vignette
	  * parametre :
	  * 	id de la vignette selectionné	  */
	  
	static var ON_SELECT:String="onSelect";
	/**
	 * à l'arrêt du défilement
	 *
	 * 			 */
	static var ON_STOP:String="onStop";
	 
	var ay0:Number;			//point d'oginine de la gestion	
	var plan:MovieClip;		//clip de scrolling
	var height:Number;       //largeur de la gestion
	var listeElem:Array;	// liste des elements affichés
	var espace:Number ; // espace entre les elements
	var nom:String ; // prefix des elements
	var nb:Number ; // nombre d'éléments differants
	var delay:Number=5;
	private var scrollPas:Number=5;
	var _interval:Number;
	
	private var lastVignette:Vignette;
	private var scrollTotal:Number;
	
	
	public function ScollPlan(plan:MovieClip,nom:String,nb:Number,height:Number,espace:Number) {
		super();
		//trace("Jeux.Scroller.ScollPlan.ScollPlan("+plan+", nom, nb, width, espace)");
		this.plan=plan;
		ay0=plan._y;
		this.height=height;
		this.espace=espace;
		this.nom=nom;
		this.nb=nb;
		this.id=0;
		permutation=[0,1,2,3,4,5,6,7];
		listeElem=new Array();
		
		
	}
	
	/**
	 * entiers aléatoires compris entre min et max (inclus) : 
	 * 	 */
	 var permutation:Array;
	 var id:Number;
	function randRange():Number {
	   if (id==nb) {
	   	id=0;
       
	   }
	   var val:Number= permutation[id];
	   id++;
	   
       return val;
	}

	public function reset(id:Number){
		if (id!=undefined) {
			this.id=id;
		} else {
			this.id=0;
		}
		delete lastVignette;
		lastVignette=undefined;
		
		plan._y=ay0;
		for (var j : String in listeElem) {
			//trace(j+" "+listeElem[j]);
			//removeMovieClip(listeElem[j]);
			listeElem[j].removeMovieClip();
		}
		listeElem=new Array();
		fill();
		
	}
	
	public function ajoutapres():Boolean{
	//	//trace("Jeux.Scroller.ScollPlan.ajoutapres()");
		var bound:Object=plan.getBounds(plan._parent);
		//trace(plan);
		//trace(plan._parent);
		//trace(bound.yMax);
		//trace(ay0+height);
		if (bound.yMax<ay0+height) {
			
			
			var prof:Number=plan.getNextHighestDepth();
			var id:String=String(randRange(0,nb-1));
			var clip:MovieClip=plan.attachMovie(nom+id,"a_"+prof,prof);
			var vign:cine.Vignette= new cine.Vignette(clip,id);
			vign.addEventListener(Vignette.ON_MEDIA,onMedia,this);
			clip.enabled=false;
			if (listeElem.length>0) {
				var el:MovieClip=listeElem[listeElem.length-1];
				clip._y=el._y+el._height+espace;
			} else {
				clip._y=0;
			}
			listeElem.push(clip);
			return true
		}
		//trace(plan.getBounds(plan._parent).yMax);
		
		return false;
	}
	
	public function supprimeavant ():Boolean{
		var bound:Object=plan.getBounds(plan._parent);
		var premier:MovieClip=listeElem[0];
		if (bound.yMin+premier._height<ay0) {
			premier.removeMovieClip();
			listeElem.shift();
			return true;
		}
		return false;
	}
	function fill(){
			var prof:Number=plan.getNextHighestDepth();
			var id:String=String(randRange(0,nb-1));
			//trace("GraphicTools.ScollPlan.fill():"+(nom+id));
			var clip:MovieClip=plan.attachMovie(nom+id,"a_"+prof,prof);
			var vign:cine.Vignette= new cine.Vignette(clip,id);
			vign.addEventListener(Vignette.ON_MEDIA,onMedia,this);
			if (listeElem.length>0) {
				var el:MovieClip=listeElem[listeElem.length-1];
				clip._y=el._y+el._height+espace;
			} else {
				clip._y=0;
			}
			
			listeElem.push(clip);
		while (ajoutapres()) {
		}
		for (var j : String in listeElem) {
			
			listeElem[j].enabled=true;
		}
		
	}

	private function onMedia(source:Vignette,id:String){
		//trace("GraphicTools.ScollPlan.onMedia(source, "+id+")");
		Navigator.getInstance().setSsTheme("1");
		Navigator.getInstance().setTheme(id);
		Navigator.getInstance().updateValue();
	}

	function deplacer(scroll:Number){
		plan._y-=scroll;
		ajoutapres();
		supprimeavant();
	}
	
	
	

	
	private function _onClicVignette(source:Vignette,id:String) {
		dispatchEvent(ON_SELECT,new Event(this,ON_SELECT,[id]));
		if (lastVignette!=source) {
		    lastVignette.enable();
			lastVignette=source;
			startScroll();
		} else {
			
			dispatchEvent(ON_STOP,new Event(this,ON_STOP,[id]));
		}
		
	}
	
	private function startScroll(){
		for (var j : String in listeElem) {
			listeElem[j].enabled=false;
		}
		scrollTotal=lastVignette.getClip()._y-listeElem[0]._y;
		
		//trace("listeElem[0]._y"+listeElem[0]._y);
		//trace("lastVignette.getClip()._y"+lastVignette.getClip()._y);
		//trace(scrollTotal);
		//trace("scrollPas "+scrollPas);
		
		
		clearInterval(_interval);
		_interval=setInterval(this,"scroll",delay);
	}
	private function scroll(){
		if (scrollTotal-scrollPas<=0) {
			deplacer(scrollTotal);
			clearInterval(_interval);
			for (var j : String in listeElem) {
				listeElem[j].enabled=true;
			}
			dispatchEvent(ON_STOP,new Event(this,ON_STOP,[id-1]));
		} else {
			deplacer(scrollPas);
			scrollTotal-=scrollPas;
		}
		updateAfterEvent();
		
	}
	
	public function setCurrent(id:String) {
		//trace("GraphicTools.ScollPlan.setCurrent("+id+")");
		for (var i : Number = 0; i < listeElem.length; i++) {
			if (listeElem[i]._objet.getId()==id) {
				listeElem[i]._objet.setCurrent();
				_onClicVignette(listeElem[i]._objet,id);
				return;
			}
		}
	}
	

}