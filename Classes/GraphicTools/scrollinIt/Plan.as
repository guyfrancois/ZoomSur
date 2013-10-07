/**
 * @author Administrator    , pense-tete
 * 11 janv. 08
 */
import org.aswing.EventDispatcher;
import org.aswing.Event;
import GraphicTools.scrollinIt.*;

/**
 * gestionnaire de plan de scroll vertical ou horizontal d'elements multiples
 *  - contruire le gestionnaire
 *  - ajoutApres() -> parametre : un objet generateur d'elements
 */
class GraphicTools.scrollinIt.Plan extends EventDispatcher {
	
	private static var ON_CHANGE:String = "onChange";
	
	static public var HSENS:Number=0;// sens horizontal par defaut
	static public var VSENS:Number=1;// sens vertical
	
	
	
	private var clip:MovieClip;
	
	private var sens:Number;
	
	private var size:Number;
	private var sizeBefore:Number;
	
	private var genSize:Number;
	private var genSizeBefore:Number;
	
	private var espace:Number;
	
	/** recuperation de position indiferencié */
	private var getSize:Function;
	public var getPos:Function;
	//private var setPos:Function;
	private var getBoundMin:Function;
	private var getBoundMax:Function;
	
	private var initialPos:Number;
	
	private var currentIdMax:Number;
	private var currentIdMin:Number;
	
	private var listeElements:Array; // liste des elements actuellement gérés
	
	private var factory:I_VignettesFactory;
	
	/**
	 * contructeur de plan de scroll
	 * @param clip : contiendra les éléments à déplacer
	 * @param size : taille maximal que peut atteindre le plan après 0 (limite d'interaction) 
	 * @param sizeBefore : taille maximal que peut atteindre le plan avant 0 (positif)(limite d'interaction)
	 * @param genSize : tailles maximal du generateur
	 * @param genSizeBefore : tailles maximal du generateur avant 0 (positif)
	 * @param espace : espacement entre les éléments ajoutés
	 * @param sens : orientation du deplacement ( HSENS ou VSENS )	 */
	public function Plan(clip:MovieClip,size:Number,espace:Number,sens:Number,sizeBefore:Number,genSize:Number,genSizeBefore:Number) {
		super();
		//trace("GraphicTools.scrollinIt.Plan.Plan("+clip+", "+size+", "+espace+", "+sens+")");
		this.clip=clip;
		if (sens==VSENS) {
			sens=VSENS;
			getPos=getPosY;
			//setPos=setPosY;
			getSize=getHeight;
			getBoundMin=getBoundMinY;
			getBoundMax=getBoundMaxY;
		} else {
			sens=HSENS;
			getPos=getPosX;
			//setPos=setPosX;		
			getSize=getWidth;	
			getBoundMin=getBoundMinX;
			getBoundMax=getBoundMaxX;
		}
		this.size=size;
		this.espace=espace;

		
		this.sizeBefore=sizeBefore;
		if (this.sizeBefore==undefined) {
			this.sizeBefore=0;
		}
		
		this.genSize=genSize;
		if (this.genSize==undefined) {
			this.genSize=size;
		}
		
		this.genSizeBefore=genSizeBefore;
		if (this.genSizeBefore==undefined) {
			this.genSizeBefore=sizeBefore;
		}

		this.initialPos=getPos();

		currentIdMax=undefined;
		currentIdMin=undefined;
		listeElements=new Array();
	}
	
	public function setDefaultFactory(factory:I_VignettesFactory) {
		this.factory=factory;
	}

	private function ajoutapres(factory:I_VignettesFactory):Boolean{
		//trace("GraphicTools.scrollinIt.Plan.ajoutapres(factory)");
		if (factory==undefined) {
			if (this.factory==undefined) {
				//trace("scrollinIt.Plan.ajoutapres(factory) : factory indefinie");
			}
			factory=this.factory;
		} 
		/*
		//trace("getBoundMax():"+getBoundMax());
		//trace(" initialPos:"+initialPos);
		//trace(" size:"+size);
		//trace(" getBoundMax()<initialPos+size:"+(getBoundMax()<initialPos+size));
		*/
		var currentIdMax:Number=this.currentIdMax;
		var currentIdMin:Number=this.currentIdMin;
		
		if (getWidth()==0 || getBoundMax()<initialPos+genSize ) {
			if (currentIdMax==undefined) {
				currentIdMax=0;
				currentIdMin=0;
			} else {
				currentIdMax=currentIdMax+1;
			}
			
			var vignette:I_vignettes;
			var lastVignette:I_vignettes=listeElements[listeElements.length-1];
			if (lastVignette==undefined) {
				vignette=factory.create(currentIdMax);
				if (vignette==null) return false;
				vignette.setPos(0);
			} else {
				vignette=factory.create(currentIdMax);
				if (vignette==null) return false;
				vignette.setPos(lastVignette.getPos()+lastVignette.getSize()+espace);
			}
			vignette.addEventListener(ON_CHANGE,this.onVignetteChange,this);
			this.currentIdMax=currentIdMax;
			this.currentIdMin=currentIdMin;
			listeElements.push(vignette);
			return true
		}
		return false;

	}
	
	private function ajoutavant (factory:I_VignettesFactory):Boolean{
		//trace("GraphicTools.scrollinIt.Plan.ajoutavant(factory)");
		
		if (factory==undefined) {
			if (this.factory==undefined) {
				//trace("scrollinIt.Plan.ajoutapres(factory) : factory indefinie");
			}
			factory=this.factory;
		} 
		var currentIdMax:Number=this.currentIdMax;
		var currentIdMin:Number=this.currentIdMin;

		if (getWidth()==0 || getBoundMin()>initialPos-genSizeBefore ) {
			if (currentIdMin==undefined) {
				currentIdMax=0;
				currentIdMin=0;
			} else {
				currentIdMin=currentIdMin-1;
			}
			var vignette:I_vignettes;
			
			if (getSize()>0) {
				
					vignette=factory.create(currentIdMin);
					if (vignette==null) return false;

				vignette.setPos(listeElements[0].getPos()-vignette.getSize()-espace);
				
			} else {

					vignette=factory.create(currentIdMin);
					if (vignette==null) return false;
				vignette.setPos(0);
			}
			vignette.addEventListener(ON_CHANGE,this.onVignetteChange,this);
			listeElements.unshift(vignette);
			this.currentIdMax=currentIdMax;
			this.currentIdMin=currentIdMin;
			return true
		}
		return false;
		
	}
	
	public function fill(factory:I_VignettesFactory){
		while (ajoutapres(factory)) {
		}
		while (ajoutavant(factory)) {
		}
	}	
	
	
	
	private function supprimeavant ():Boolean{
		//trace("GraphicTools.scrollinIt.Plan.supprimeavant()");
		var premier:I_vignettes=listeElements[0];
		if (getBoundMin()+premier.getSize()<initialPos-genSizeBefore && premier!=undefined) {
			currentIdMin+=1;
			premier.remove();
			listeElements.shift();
			return true;
		}
		return false;
	}
	
	private function supprimeapres ():Boolean{
		//trace("GraphicTools.scrollinIt.Plan.supprimeapres()");
		var premier:I_vignettes=listeElements[listeElements.length-1];
		if (getBoundMax()>initialPos+genSize+premier.getSize() && premier!=undefined) {
			currentIdMax-=1;
			premier.remove();
			listeElements.pop();
			return true;
		}
		return false;
	}
	
	public function getDepToVignette(vignette:I_vignettes):Number{
		var dep:Number;
		vignette.getPos();
		
		return dep;
	}
	
	public var blocGauche:Boolean=false;
	public var blocDroit:Boolean=false;
	
	
	public function deplacer(scroll:Number,factory:I_VignettesFactory):Boolean{
		blocGauche=false;
		blocDroit=false;
		var hadAjout:Boolean;
			if (scroll>0) {
					setPos(getPos()-scroll);
					while (hadAjout=ajoutapres(factory)){
						
					};
					while (supprimeavant()) {
						
					}
				
			} else {
					setPos(getPos()-scroll);
					while (hadAjout=ajoutavant(factory))	{
						
					}
					
					while (supprimeapres()) {
						
					}
				
			}

		if (hadAjout==false) {
			
			if (getBoundMax()<=size) blocDroit=true;
			
			if (getBoundMax()<size) {// || getBoundMin()>(-sizeBefore) ) {
				
				setPos(getPos()-getBoundMax()+size);
			}
			if (getBoundMin()>(-sizeBefore)) blocGauche=true;
			if (getBoundMin()>(-sizeBefore)) {// || getBoundMin()>(-sizeBefore) ) {
				
				setPos(getPos()-getBoundMin()-sizeBefore);
			}
			
			//trace("blocage factory : ");
		}
		return hadAjout;
		
	}
	
	
	public function clear(){
		for (var i : Number = 0; i < listeElements.length; i++) {
			var premier:I_vignettes=listeElements[i];
			premier.remove();
		}
		currentIdMax=undefined;
		currentIdMin=undefined;
		listeElements=new Array();
		setPos(initialPos);
		
	}
	
	/** function de recuperation de position*/
	private function getPosX():Number {
		return clip._x;
	}
	private function getPosY():Number {
		return clip._y;
	}
	
	private function setPos(x:Number) {
	
		for (var i : Number = 0; i < listeElements.length; i++) {
			listeElements[i].setPos(listeElements[i].getPos()+(x-getPos()));
		}
		//clip._x=x;
		//updateAfterEvent();
	}
	/*
	private function setPosY(y:Number){
		listeElements[i].setPos(listeElements[i].getPos()-(x-getPos()));
		updateAfterEvent();
	}
	*/
	private function getWidth():Number {
		return clip._width;
	}
	private function getHeight():Number {
		return clip._height;
	}
	
	private function getBoundMinY(){
		var bound:Object=clip.getBounds(clip._parent);
		return bound.yMin;
		
	}
	private function getBoundMaxY(){
		var vignette:I_vignettes=listeElements[listeElements.length-1];
		var yMax:Number=vignette.getPos()+vignette.getSize();
		var p:Object= {x:0,y:yMax};
		clip.localToGlobal(p);
		clip._parent.globalToLocal(p);
		/*
		var bound:Object=clip.getBounds(clip._parent);
		return bound.yMax;
		*/
		return p.y;
	}
	private function getBoundMinX(){
		var bound:Object=clip.getBounds(clip._parent);
		return bound.xMin;
		
	}
	private function getBoundMaxX(){
		var vignette:I_vignettes=listeElements[listeElements.length-1];
		var xMax:Number=vignette.getPos()+vignette.getSize();
		var p:Object= {x:xMax,y:0};
		clip.localToGlobal(p);
		clip._parent.globalToLocal(p);
		/*
		var bound:Object=clip.getBounds(clip._parent);
		return bound.xMax;
		*/
		return p.x;
	}
	
	public function findIdVignette(vignette:I_vignettes):Number{
		for (var i : Number = 0; i < listeElements.length; i++) {
			if (listeElements[i]==vignette) return i;
		}
		return undefined;
	}
	
	private function onVignetteChange(vignette:I_vignettes) {
		var id:Number=findIdVignette(vignette);
		var lastVignette:I_vignettes=vignette;
		for (var i : Number = id+1; i < listeElements.length; i++) {
			var nextVignette:I_vignettes=listeElements[i];
			nextVignette.setPos(lastVignette.getPos()+lastVignette.getSize()+espace);	
			lastVignette=nextVignette;
		}
		if (!ajoutapres()) {
			supprimeapres();
		}
	}
	
	public function goToVignette(id:Number):I_vignettes {
		var vignette:I_vignettes;
		while (listeElements[0].getId()>id) {
			if (!deplacer(listeElements[0].getSize())) return undefined;
		}
		while (listeElements[listeElements.length-1].getId()<id) {
			if (!deplacer(-listeElements[listeElements.length-1].getSize())) return undefined;
		}
		for (var i : Number = 0; i < listeElements.length; i++) {
			
			if (listeElements[i].getId()==id) {
				vignette=listeElements[i];
				break;
			} 
		}
		if (vignette==undefined ) {
			return undefined	
		} else {
			deplacer(vignette.getPos());
			return vignette;
		}
		
	}
	
	public function findVignette(id:Number):I_vignettes {
		for (var i : Number = 0; i < listeElements.length; i++) {
			
			if (listeElements[i].getId()==id) {
				return listeElements[i];
				break;
			} 
		}
	}

}