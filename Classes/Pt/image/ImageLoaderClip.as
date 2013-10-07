/**
 * @author GuyF , pense-tete.com
 * @date 5 mars 07
 * 
 */
 
class Pt.image.ImageLoaderClip {
	static var lastInstance:ImageLoaderClip;
	private var maxWidth:Number;
	private var maxHeight:Number;
	private var cible:MovieClip;
	
	private var x:Number;
	private var y:Number;
	/**
	 * clip affichant la progression du chargement	 */
	private var imageLoaderClip:MovieClip
	/**
	 * Affiche un chargeur dans un clip specifique pour le centrage du chargeur
	 * imageLoaderClip= new ImageLoaderClip(clip_de _contenu,maxWidth,maxHeight); 
	 * implement un ecouteur de chargement :
	 * mcLoader.addListener(imageLoaderClip)	 */
	public function ImageLoaderClip(cible:MovieClip,maxWidth:Number,maxHeight:Number,x:Number,y:Number) {
		this.cible=cible;
		this.maxHeight=maxHeight;
		this.maxWidth=maxWidth;
		this.x=0;
		if (x!=undefined) {
			this.x=x;
		} 
		this.y=0;
		if (y!=undefined) {
			this.y=y;
		} 
		
		
	}
	
	
	function onLoadComplete(target_mc:MovieClip, httpStatus:Number) {
		efface();
	}
 
 /**
  *  Appelé lorsque le chargement d'un fichier chargé avec MovieClipLoader.loadClip() a échoué.
  */
 
	function onLoadError  (target_mc:MovieClip, errorCode:String, httpStatus:Number) {
			efface();
	}

 
 /**
  * Appelé une fois les actions de la première image du clip chargé exécutées.
  */
	function onLoadInit  (target_mc:MovieClip) {

		
	}
 
 /**
  * Appelé chaque fois que le contenu est écrit sur le disque dur au cours du processus de chargement (c'est-à-dire entre MovieClipLoader.onLoadStart et MovieClipLoader.onLoadComplete).
  */
	function onLoadProgress  (target_mc:MovieClip, loadedBytes:Number, totalBytes:Number) {
		imageLoaderClip.barre._xscale=loadedBytes*100/totalBytes;
	
	}
 
 /**
  * Appelé lorsqu'un appel de MovieClipLoader.loadClip() a commencé à charger un fichier.
  */
	function onLoadStart  (target_mc:MovieClip) {
		//trace("Pt.image.ImageLoaderClip.onLoadStart(target_mc)");
		lastInstance.efface();
		lastInstance=this;
		
		imageLoaderClip=cible.attachMovie("imgLoader","imgLoader",cible.getNextHighestDepth());
		imageLoaderClip._x=this.x+maxWidth/2;
		imageLoaderClip._y=this.y+maxHeight/2;
		imageLoaderClip.barre._xscale=0;
		//trace(imageLoaderClip);
		
	
	}
	
	function efface(){
		imageLoaderClip.removeMovieClip();
		//delete this;
	}
	
}