/**
 *
 */
import Pt.Tools.ClipEvent;
import org.aswing.Event;
import org.aswing.EventDispatcher;  
import org.aswing.util.Delegate;

/**
  * comportement d'un menu graphique :
  * structure de clip :
  * fleche : contient un scénario d'au moins la taille du menu maximum 
  * titre : titre du menu , 2 images , 1:fermé, 2 : ouvert
  * _0 à _n : les enfants
  * voir MenuFeuille pour les feuilles
  *
  *contient un scenario d'ouverture, la fermeture en reverse-animation
  *   */
class GraphicTools.MenuFrames extends EventDispatcher {
	 /**
     * pression sur un bouton
     * onPress(source:)
     */ 
    public static var ON_ROLLOVER:String = "onRollOver";
        /**
     * pression sur un bouton
     * onPress(source:)
     */ 
    public static var ON_ROLLOUT:String = "onRollOut";
	/**
	 * pression sur un bouton
	 * onPress(source:)
	 */	
	public static var ON_PRESS:String = "onPress";
	/**
	 * etat de boutons	 */
	public static var BTN_PRESS:Number=2;
	public static var BTN_ON:Number=1;
	/**
	 * navigation vers un contenu
	 * onSelect(source:)
	 */	
	public static var ON_SELECT:String = "onSelect";
	
	/**
	 * navigation vers un contenu feuille
	 * onSelectFeuille(source:MenuFeuille ou MenuV,listemenu/ssMenu array)
	 */	
	public static var ON_SELECTFEUILLE:String = "onSelectFeuille";
	/**
	 * modification de la taille du menu
	 * onNextFrame(source:)
	 */	
	public static var ON_NEXTFRAME:String = "onNextFrame";
	/**
	 * modification de la taille du menu
	 * onPrevFrame(source:)
	 */	
	public static var ON_PREVFRAME:String = "onPrevFrame";
	
	public static var ON_CLOSED= "onClosed";
	public static var ON_OPENED= "onOpened";
	
	private var clip:MovieClip;
	private var fleche_mc:MovieClip;
	private var titre_mc:MovieClip;
	
	private var totalFrames:Number;
	
	private var menuObjectArray:Array;
	/**
	 * Contient :
	 * titre :String
	 * menu : Array	 */
	private var arboMenu:Object;
	
	
	private var lastListMenu:String;
	
	
	private var autoSubOpen:Boolean=true; // ouverture automatique des sous-rubriques
	
	/**
	 * constructeur
	 * @param clip : MovieClip associé à cette objet
	 * @param arboMenu : arborescence de menu (issus d'un XML ) representant la structure du menu
	 * @param margeHaute : marge haute entre cette element et son predecesseur (frere ainé)
	 * @param autoSubOpen : les heritiers ainés s'ouvre automatiquement avec lui. 	 */
	public function MenuFrames(clip:MovieClip,arboMenu:Object,autoSubOpen:Boolean) {
		super();
		//trace("GraphicTools.MenuFrames.MenuFrames("+clip+", arboMenu, "+autoSubOpen+")");
		setAutoSubOpen(autoSubOpen);
		byPress=false;
		this.clip=clip;
		this.arboMenu=arboMenu;
		initClipControle();
		while (	tryAddChild()) {};
		
	}
	private function setAutoSubOpen(val:Boolean){
		if (val!=undefined) {
			autoSubOpen=val;
		}
	}

	public function getName():String{
		return clip._name;
	}
	

	public function setMenu(arboMenu) {
		this.arboMenu=arboMenu;
	}
	
	private function initClipControle(){
		var locRef:MenuFrames=this;
		clip.onUnload=function (){
			//trace("GraphicTools.MenuFrames.initClipControle().onUnload");
			locRef._onUnload();
		}
		//trace("GraphicTools.MenuFrames.initClipControle()");
		
		totalFrames=clip._totalframes;
		fleche_mc=clip.fleche;
		titre_mc=clip.titre;
		//trace("totalFrames: "+totalFrames);
		clip.stop();
		fleche_mc.stop();
		titre_mc.stop();
		initialiseBtn(titre_mc);
		
	}
	
	private function initialiseBtn(btn_clip:MovieClip) {
		ClipEvent.initialize(btn_clip);
		setTriggers(btn_clip);
		
		btn_clip.addEventListener(ON_PRESS,_onPress,this);
		btn_clip.addEventListener(ON_ROLLOUT,_onRollOut,this);
		btn_clip.addEventListener(ON_ROLLOVER,_onRollOver,this);
		
	}
	
	private function setTriggers(btn_clip:MovieClip) {
		btn_clip.useHandCursor=true;
		ClipEvent.setEventsTrigger(btn_clip,ON_PRESS);
		ClipEvent.setEventsTrigger(btn_clip,ON_ROLLOUT);
		ClipEvent.setEventsTrigger(btn_clip,ON_ROLLOVER);
	}
	
	private function removeTriggers(btn_clip:MovieClip) {
		btn_clip.useHandCursor=false;
		ClipEvent.unsetEventsTrigger(btn_clip,ON_PRESS);
		ClipEvent.unsetEventsTrigger(btn_clip,ON_ROLLOUT);
		ClipEvent.unsetEventsTrigger(btn_clip,ON_ROLLOVER);
	}
	/**
	 * 	 */
	private var byPress:Boolean;
	
	/**
	 * evenement pression sur le titre du menu	 */
	private function _onRollOut(btn_clip:MovieClip) {
		btn_clip.btn.gotoAndStop("OUT");
	}
	private function _onRollOver(btn_clip:MovieClip) {
        btn_clip.btn.gotoAndStop("OVER");
    }
	
	private function _onPress(btn_Clip:MovieClip) {
		btn_Clip.btn.gotoAndStop("OUT");
		switch (btn_Clip) {
			case titre_mc :
			if (titre_mc._currentframe==BTN_ON) {
				byPress=true;
				openMenu();
				dispatchEvent(ON_SELECT,new Event(this,ON_SELECT));
				
			} else {
				closeMenu();
			}
				
				break;
			default :
			//pas de btn ??
				break;
				
		}
	}
	/**
	 * provoque l'ouverture du menu 
	 * ici on supprime l'ecoute sur le titre (pas de fermeture au clic)
	 * @param listeMenu : liste des éléments du menu à ouvrir automatiquement, menu/.../feuille ["_2","_1"]
	 * l'ouverture automatique ne provoque pas d'evenement de contenu ON_SELECTFEUILLE	 */
	public function openMenu(listeMenu:Array){
		//trace("GraphicTools.MenuFrames.openMenu("+listeMenu+")");
		removeTriggers(titre_mc);
		menuObjectArray=new Array();
		titre_mc.gotoAndStop(BTN_PRESS);
		var locRef:MenuFrames=this;
		_prevY=0;
		clip.onEnterFrame = function (){
			locRef.__openning(listeMenu);
		}
	}
	
	/**
	 * ferme les enfants du menu puis le menu lui même	 */
	public function closeMenu(){
		
		var allClose:Boolean=true;
		for (var i:Number =0;i<menuObjectArray.length;i++) {
			if (menuObjectArray[i].isOpen()) {
				allClose=false;
				menuObjectArray[i].addEventListener(ON_CLOSED,_closeMenu,this)
				menuObjectArray[i].setUnpressed();
				
			}
		}
		if (allClose){
			_closeMenu();
		}
		
	}
	
	/**
	 * ferme le menu, sans prise en compte des enfants	 */
	private function _closeMenu(){
		
		setTriggers(titre_mc);
		var locRef:MenuFrames=this;
		clip.onEnterFrame = function (){
			locRef.__closing();
		}
	}
	/**
	 * internal , reservé à l'enterframe du clip en ouverture	 */
	function __openning(listeMenu:Array){
		if (clip._currentframe<totalFrames) {
			clip.nextFrame();	
			fleche_mc.nextFrame();
			while (	tryAddChild()) {};
			dispatchEvent(ON_NEXTFRAME,new Event(this,ON_NEXTFRAME));
		} else {
			if (listeMenu!=undefined ) {
				if (listeMenu.length>0) {
					var id:Number=listeMenu.shift().substring(1);
					for (var i : Number = 0; i < menuObjectArray.length; i++) {
						if (id==i) {
							 if (menuObjectArray[id] instanceof GraphicTools.MenuFeuille) {
                                 menuObjectArray[id].setPressed(false)
                            } else {
                                 menuObjectArray[id].openMenu(listeMenu)
                            }
						} else {
							 menuObjectArray[id].setUnPressed();
						}
					}
					
				} else {
					menuObjectArray[0].setPressed(true);
					if (menuObjectArray[0] instanceof GraphicTools.MenuFeuille) {
						_onSelectFeuille(menuObjectArray[0],[menuObjectArray[0].getName()]);
					}
				}
			} else if ( byPress==true && autoSubOpen) {
		    	menuObjectArray[0].setPressed(byPress);
		    	byPress=false;
		    	if (menuObjectArray[0] instanceof GraphicTools.MenuFeuille) {
					_onSelectFeuille(menuObjectArray[0],[menuObjectArray[0].getName()]);
				}
		    }
		    dispatchEvent(ON_OPENED,new Event (this,ON_OPENED));
			delete clip.onEnterFrame;
			
		}
		
	}

/**
 * internal, reservé à la fermeture du clip (enterFrame) */
	function __closing(){

		if (clip._currentframe>1) {
			clip.prevFrame();	
			fleche_mc.prevFrame();
			dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME));
		} else {
			titre_mc.gotoAndStop(BTN_ON);
			menuObjectArray=new Array();
			lastListMenu="";
			dispatchEvent(ON_CLOSED,new Event(this,ON_CLOSED));
			delete clip.onEnterFrame;
			
		}
		
	}
	
	private var _prevY:Number;
	
	/**
	 * tente d'ajouter un enfant au menu pendant l'ouverture (frame par frame) du menu
	 * conditions :
	 * 	existance dans l'arborescence de donnée
	 * 	existance du clip
	 * 	le type de l'enfant depend de l'arborescence de donnée
	 * 	@return reussite à l'ajour d'un enfant	 */
	private function tryAddChild():Boolean{
		var child:MovieClip;
		var childObject:EventDispatcher;
		//trace("GraphicTools.MenuFrames.tryAddChild()");
		if ((child=clip["_"+menuObjectArray.length])!=undefined) {
		   trace(child);	 
		   var ssMenu:Object=arboMenu.menu[menuObjectArray.length];
		   if (ssMenu.menu!=undefined || child.titre!=undefined ) {
		   	//trace("c'est un sous menu");
		   	childObject = new MenuFrames(child,ssMenu,autoSubOpen);
		   	_prevY=child._y;
		   	childObject.addEventListener(ON_NEXTFRAME,_onNextFrame,this);
		   	childObject.addEventListener(ON_PREVFRAME,_onPrevFrame,this);
		   	childObject.addEventListener(ON_SELECTFEUILLE,_onSelectFeuille,this);
		   	childObject.addEventListener(ON_OPENED,_onOpened,this);
		   	childObject.addEventListener(ON_CLOSED,_onClosed,this);
		   	
		   	
		   	
		   } else {
		   	//trace("c'est une feuille");
			childObject=new GraphicTools.MenuFeuille(child,undefined,child._y-_prevY);
			_prevY=child._y;
		   }
		   	menuObjectArray.push(childObject);
			childObject.addEventListener(GraphicTools.MenuFeuille.ON_SELECT,_onSelect,this)
		   return true 
		} else {
			return false
		}
	}
	
	/**
	 * reaction de l'affichage (fleche) sur la modification des enfants directs en fermeture	 */
	private function _onPrevFrame(src,frames:Number){
		//trace("GraphicTools.MenuFrames._onPrevFrame(src, "+frames+")");

		if (frames!=undefined) {
			
			fleche_mc.gotoAndStop(fleche_mc._currentframe-frames);
			dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME,[frames]));
		} else {
			fleche_mc.prevFrame();
			dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME));
		}
		
	}
	
	/**
	 * reaction de l'affichage (fleche) sur la modification des enfants directs en ouverture
	 */
	private function _onNextFrame(src){
		fleche_mc.nextFrame();
		
		dispatchEvent(ON_NEXTFRAME,new Event(this,ON_NEXTFRAME));
		
	}
	

	/**
	 * reservé à la gestion de fermeture du menu (evenement onUnLoad du clip)	 */
	function _onUnload(){
		//trace("GraphicTools.MenuFrames._onUnload()"+clip._currentframe);
		if (clip._currentframe>1) {
			dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME,[clip._currentframe-1]));
		}
	}
	
	/**
	 * gére la reponse du menu à un selection chez un de ses enfants
	 * mise à jour des enfants.
	 * envoi un signal de contenu si il s'agit d'une feuille
	 * @param src source de l'emission du signal (un enfant) , MenuFrames ou MenuFeuille
	 * @param listMenu : contient le nom de l'enfant (si s'est une feuille)	 */
	private function _onSelect(src:Object,listeMenu:Array) {
		for (var i : Number = 0; i < menuObjectArray.length; i++) {
			if (menuObjectArray[i]!=src ) {
				if (menuObjectArray[i].isOpen())
					menuObjectArray[i].setUnpressed();
			} else {
				menuObjectArray[i].setPressed();
			}
		}
		if (src instanceof GraphicTools.MenuFeuille) {
			_onSelectFeuille(src,listeMenu);
		}
		
	}
	
	/**
	 * propage vers la racine d'un signal de contenu en completant la liste de menu avec le nom du menu courant
	 *  @param src source de l'emission du signal (un enfant) , MenuFrames ou MenuFeuille
	 *  @param listeMenu : liste des éléments de menu , de la racine à la feuille	 */
	private function _onSelectFeuille (src:Object,listeMenu:Array) {
		lastListMenu=listeMenu.join("");
		listeMenu.unshift(getName());
		dispatchEvent(ON_SELECTFEUILLE,new Event(this,ON_SELECTFEUILLE,[listeMenu]));
	
	}
	
	/**
	 * Met l'element à l'etat ouvert
	 * @param byPress : la commande doit être considéré comme issus d'une action utilisateur	 */
	public function setPressed(byPress:Boolean){
		//trace("GraphicTools.MenuFrames.setPressed("+byPress+")");
		if (byPress==true) {
			this.byPress=true;
		}
		openMenu();
	}
	
	/**
	 * referme le menu	 */
	public function setUnpressed(){
		closeMenu();
	}
	
	/**
	 * informe sur l'etat du menu	 */
	public function isOpen():Boolean {
		//trace("GraphicTools.MenuFrames.isOpen()"+(clip._currentframe>1));
		return clip._currentframe>1;
		//return menuObjectArray.length>0;
	}
	
	
	
	private function _onOpened(){
		fleche_mc.nextFrame();
		dispatchEvent(ON_NEXTFRAME,new Event(this,ON_NEXTFRAME));
	
	}
	private function _onClosed(src:MenuFrames){
		
		//trace("GraphicTools.MenuFrames._onClosed()");
		fleche_mc.prevFrame();

		dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME));
	}
	
	public function reset(listMenu:Array){
		//trace("GraphicTools.MenuFrames.reset("+listMenu+")");
		//trace(listMenu.join("")+" == "+lastListMenu);
		if (listMenu.join("")!=lastListMenu) {
			titre_mc.gotoAndStop(BTN_ON);
            menuObjectArray=new Array();
            lastListMenu="";
            clip.gotoAndStop(1); 
            fleche_mc.gotoAndStop(1);
            openMenu(listMenu);
			
		} 
		
	}
	
	
	
}