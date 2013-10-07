/**
 * @author Administrator    , pense-tete
 * 29 f�vr. 08
 */
import org.aswing.Event;
import org.aswing.EventDispatcher;
import Pt.image.ImageLoaderClip;

/**
 * 
 */
class Pt.image.LoaderDefine extends EventDispatcher {
	//onLoadComplete(source:ImageLoader, httpStatus:Number)
	static var ON_LOADCOMPLETE:String="onLoadComplete";
	//onLoadError  (source:ImageLoader, errorCode:String, httpStatus:Number)
	static var ON_LOADERROR:String="onLoadError";
	
	//onLoadInit  (source:ImageLoader,cible:MovieClip)
	static var ON_LOADINIT:String="onLoadInit";
	//onLoadProgress  (source:ImageLoader, loadedBytes:Number, totalBytes:Number)
	static var ON_LOADPROGRESS:String="onLoadProgress";
	//onLoadStart  (source:ImageLoader)
	static var ON_LOADSTART:String="onLoadStart";
	
	static var ALIGNTOP:Number=0;
	static var ALIGNLEFT:Number=0;
	static var ALIGNCENTER:Number=1;
	static var ALIGNBOTTOM:Number=2;
	static var ALIGNRIGHT:Number=2;
	
	static var SCALLIN:Number=0; // à l'interieur
	static var SCALLOUT:Number=1; // à l'exterieur
	static var SCALLNONE:Number=-1; // pas de re-scall
	
	static var TYPESWF:Number=1;
	static var TYPEIMG:Number=0;
	
	private var cible:MovieClip;
	var ml:MovieClipLoader;
	
	public function LoaderDefine() {
		super();
	}
	
	public function destroy(){
		abort();
		cible.removeMovieClip();
		delete this;
	}
	
	public function abort(){
		ml.unloadClip(cible);
	}
	/**
 * Appelé chaque fois que le contenu est écrit sur le disque dur au cours du processus de chargement (c'est-à-dire entre MovieClipLoader.onLoadStart et MovieClipLoader.onLoadComplete).
 */
	private function onLoadProgress  (target_mc:MovieClip, loadedBytes:Number, totalBytes:Number) {
		dispatchEvent(ON_LOADPROGRESS,new Event(this,ON_LOADPROGRESS,[loadedBytes,totalBytes]));
	}
 
/**
 * Appelé lorsqu'un appel de MovieClipLoader.loadClip() a commencé à charger un fichier.
 */
	private function onLoadStart  (target_mc:MovieClip) {

		dispatchEvent(ON_LOADSTART,new Event(this,ON_LOADSTART,[target_mc]));
	}
	
	
/**
 * Appelé lorsque le fichier qui a été chargé avec MovieClipLoader.loadClip() a fini son téléchargement.
 */	
	private function onLoadComplete(target_mc:MovieClip, httpStatus:Number) {
		dispatchEvent(ON_LOADCOMPLETE,new Event(this,ON_LOADCOMPLETE,[httpStatus]));
	}
 
/**
 *  Appelé lorsque le chargement d'un fichier chargé avec MovieClipLoader.loadClip() a échoué.
 */
 
	private function onLoadError  (target_mc:MovieClip, errorCode:String, httpStatus:Number) {
		dispatchEvent(ON_LOADERROR,new Event(this,ON_LOADERROR,[errorCode,httpStatus]));
	}

}