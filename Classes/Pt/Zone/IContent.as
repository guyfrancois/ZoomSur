/**
 * @author Administrator    , pense-tete
 * 7 avr. 08
 */
import org.aswing.IEventDispatcher;


/**
 * 
 */
interface Pt.Zone.IContent extends IEventDispatcher {
	
	public function create(contentType:String,ref:String):MovieClip;
	public function setTexte(dataXML:Object):MovieClip;
	
	public function remove(ref:String);
	public function removeAll();
	
	public function close();
	public function open();
	
	public function hideAll();
	
	public function hide(ref:String,duree:Number,CALLBACK:Function);
	
	public function show(ref:String,duree:Number,CALLBACK:Function);
	
	
	public function pause(); // une transition en cours -> la pauser
	public function reprise(); // une transition en cours -> sortie de pause
	
	public function  clear();
	public function  setLegende(texte:String);
	
	public function setInLoad();
	public function setInPlay();
	public function transfert(objet:Object);
	public function destroy();
	
}