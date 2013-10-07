/**
 *
 */
import Pt.Tools.ClipEvent;
import org.aswing.Event;
import org.aswing.EventDispatcher;  
import org.aswing.util.Delegate;
import Pt.animate.ClipByFrame;

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
class GraphicTools.MenuV extends EventDispatcher {
	private static var TITREHEIGHT:Number=15;
	private static var ITEMHEIGHT:Number=15;
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
	public static var BTN_PRESS:Number=7;
	public static var BTN_OVER:Number=3;
	public static var BTN_ON:Number=1;
	
	/**	 * Avant le recul d'un menu, demande la surpression eventuelle d'un clip contenu
	 * onPreRem(source:MenuV,clip:MovieClip,currentFrame:Number)	 */
	public static var ON_PREREM:String = "onPreRem";
	/**
	 * avant initialisaton d'un clip contenu,
	 * le moment de créer le clip de menu ou de feuille
	 * onPreInit(source:MenuV,clip:MovieClip,index:Number,currentFrame)
	 * @param clip : clip contenant le nouveau menu ou la feuille
	 * @param index : l'index de l'élément à créer
	 * 
	 * pour un clip de menu, il doit contenir un clip "titre"
	 * 		clip.attachMovie("itemMenu","_"+index,index)
	 *    ou
	 *      clip.attachMovie("itemFeuille","_"+index,index)
	 * 
	 */	
	public static var ON_PREINIT:String = "onPreInit";
	
	
	/**
	 * initialisaton d'un clip contenu
	 * onSelect(source:)
	 */	
	public static var ON_INIT:String = "onInit";
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
	private var currentFrame:Number;
	
	private var menuObjectArray:Array;
	/**
	 * Contient :
	 * titre :String
	 * menu : Array	 */
	private var arboMenu:Object;
	
	private var margeHaute:Number=0;
	
	private var lastListMenu:String;
	
	
	private var autoSubOpen:Boolean=false; // ouverture automatique des sous-rubriques
	private var _skipSubMenu:Boolean=false; // ne pas attendre la fermeture des ssmenus
	/**
	 * constructeur
	 * @param clip : MovieClip associé à cette objet
	 * @param arboMenu : arborescence de menu (issus d'un XML ) representant la structure du menu
	 * @param margeHaute : marge haute entre cette element et son predecesseur (frere ainé)
	 * @param autoSubOpen : les heritiers ainés s'ouvre automatiquement avec lui. 	 */
	 private var cbf:ClipByFrame;
	public function MenuV(clip:MovieClip,arboMenu:Object,margeHaute:Number,autoSubOpen:Boolean) {
		super();
		//trace("GraphicTools.MenuV.MenuV("+clip+", arboMenu, "+margeHaute+", autoSubOpen)");
		this.margeHaute=margeHaute;
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
	
	
	public function skipSubMenu(skip:Boolean) {
		_skipSubMenu=skip;
	}
	public function getClip():MovieClip {
		return clip;
	}

	public function getName():String{
		return clip._name;
	}
	
	public function getMargeHaute():Number{
		return margeHaute;
	}
	
	public function setMenu(arboMenu) {
		this.arboMenu=arboMenu;
	}
	
	private function initClipControle(){
		var locRef:MenuV=this;
		clip.onUnload=function (){
		//	//trace("GraphicTools.MenuV.initClipControle().onUnload");
			locRef._onUnload();
		}
		//trace("GraphicTools.MenuV.initClipControle()");
		menuObjectArray=new Array();
		if (clip.totalframes==undefined) {
			totalFrames=clip._totalframes;
		} else {
			totalFrames=clip.totalframes;
		}
		currentFrame=1;
		fleche_mc=clip.fleche;
		titre_mc=clip.titre;
		clip.titre.hitArea._visible=false;
		this.cbf=new ClipByFrame(titre_mc);
		//trace("totalFrames: "+totalFrames);
		clip.stop();
		fleche_mc.stop();
		titre_mc.stop();
		initialiseBtn(titre_mc);
		dispatchEvent(ON_INIT,new Event(this,ON_INIT,[getClip()]));
		
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
		if (isOpen()) {
			cbf.goto(BTN_PRESS);
		} else {
			cbf.goto(BTN_ON);
		}
		
	}
	private function _onRollOver(btn_clip:MovieClip) {
        cbf.goto(BTN_OVER);
    }
	
	private function _onPress(btn_Clip:MovieClip) {
		
		
		switch (btn_Clip) {
			case titre_mc :
			if (isOpen()) {
				closeMenu();
			} else {
				
				byPress=true;
				openMenu();
				dispatchEvent(ON_SELECT,new Event(this,ON_SELECT));
				
			}
			/*if (titre_mc._currentframe==BTN_ON) {
				
			} else {
				
			}*/
				
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
		//trace("GraphicTools.MenuV.openMenu("+listeMenu+")");
		removeTriggers(titre_mc);
		cbf.goto(BTN_PRESS);
		
		var locRef:MenuV=this;
		_prevY=titre_mc._y+titre_mc._height;
		clip.onEnterFrame = function (){
			locRef.__openning(listeMenu);
		}
	}
	
	/**
	 * ferme les enfants du menu puis le menu lui même	 */
	public function closeMenu(){
		if (_skipSubMenu) {
			_closeMenu();
			return;
		}
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
		var locRef:MenuV=this;
		clip.onEnterFrame = function (){
			locRef.__closing();
		}
	}
	/**
	 * internal , reservé à l'enterframe du clip en ouverture	 */
	
	function nextFrame(){
		clip.nextFrame();	
		fleche_mc.nextFrame();
		currentFrame+=1;
	} 
	
	function prevFrame(){
		clip.prevFrame();	
		fleche_mc.prevFrame();
		currentFrame-=1;
		if (currentFrame<=0) currentFrame=1;
	} 
	 
	private function getCurrentFrame():Number {
		return currentFrame;
	}
	 
	function __openning(listeMenu:Array){
		//trace("GraphicTools.MenuV.__openning(listeMenu)");
		updateSize();
		//trace((getCurrentFrame()<totalFrames)+" "+getCurrentFrame()+"<"+totalFrames)
		if (getCurrentFrame()<totalFrames) {
			this.nextFrame();
			
			while (	tryAddChild()) {};
			dispatchEvent(ON_NEXTFRAME,new Event(this,ON_NEXTFRAME));
		} else {
			//while (	tryAddChild()) {};
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
							 menuObjectArray[i].setUnpressed();
						}
					}
					
				}
				 else {
				 	//trace("GraphicTools.MenuV.__openning("+listeMenu+")");
				 	var countStart : Number = 0;
				 	if (autoSubOpen && byPress) {
						menuObjectArray[0].setPressed(byPress);
						countStart=1;
					}
					for (var i:Number=countStart; i < menuObjectArray.length; i++) {
						//trace("try to close "+i+" "+menuObjectArray[i].getClip())
						//trace("menuObjectArray[id] instanceof GraphicTools.MenuFeuille :"+(menuObjectArray[i] instanceof GraphicTools.MenuFeuille));
						
						 menuObjectArray[i].setUnpressed();
						
					}
					
				}
				
			
		    dispatchEvent(ON_OPENED,new Event (this,ON_OPENED));
			delete clip.onEnterFrame;
			
		}
		
	}

/**
 * internal, reservé à la fermeture du clip (enterFrame) */
	function __closing(){
		updateSize();
		if (getCurrentFrame()>1) {
			_onPreRemFeuille(this,clip,getCurrentFrame())
			this.prevFrame();
			
			dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME));
		} else {
			cbf.goto(BTN_ON);
			_onPreRemFeuille(this,clip,getCurrentFrame())
			menuObjectArray=new Array();
			lastListMenu="";
			dispatchEvent(ON_CLOSED,new Event(this,ON_CLOSED));
			delete clip.onEnterFrame;
			
		}
		
	}
	
	private var _prevY:Number;
	
	
	private function createChild_feuille(child:MovieClip,decalageY:Number):GraphicTools.MenuFeuille{
		//trace("GraphicTools.MenuV.createChild_feuille("+child+","+decalageY+" ):"+child._y);
		return new GraphicTools.MenuFeuille(child,undefined,child._y-decalageY);
	}
	private function createChild_Menu(child:MovieClip,decalageY:Number,autoSubOpen:Boolean,struct:Object){
		return new MenuV(child,struct,child._y-decalageY,autoSubOpen);
	}
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
		if (menuObjectArray.length==0) {
		_prevY=titre_mc._y+titre_mc._height;	
		} else {
		var _prevMc:MovieClip= 	menuObjectArray[menuObjectArray.length-1].getClip();
		_prevY=_prevMc._y+_prevMc._height;	
		}
		_onPreInitFeuille(this,clip,menuObjectArray.length,getCurrentFrame());
		if ((child=clip["_"+menuObjectArray.length])!=undefined) {
			 
		   var ssMenu:Object=arboMenu.menu[menuObjectArray.length];
		   if (ssMenu.menu!=undefined || child.titre!=undefined ) {
		   	// 	c'est un sous menu
		   	childObject = createChild_Menu(child,_prevY,autoSubOpen,ssMenu);
		   	_prevY=child._y+child._height;
		   	childObject.addEventListener(ON_NEXTFRAME,_onNextFrame,this);
		   	childObject.addEventListener(ON_PREVFRAME,_onPrevFrame,this);
		   	childObject.addEventListener(ON_SELECTFEUILLE,_onSelectFeuille,this);
		   	childObject.addEventListener(ON_OPENED,_onOpened,this);
		   	childObject.addEventListener(ON_CLOSED,_onClosed,this);
		   	childObject.addEventListener(ON_PREINIT,_onPreInitFeuille,this)
		   	childObject.addEventListener(ON_PREREM,_onPreRemFeuille,this)
		   	
		   	
		   } else {
		   	// c'est une feuille
			childObject=createChild_feuille(child,_prevY);
			_prevY=child._y+child._height;
		   }
		   	menuObjectArray.push(childObject);
		   	_onInitFeuille(childObject,child);
			childObject.addEventListener(GraphicTools.MenuFeuille.ON_SELECT,_onSelect,this)
			childObject.addEventListener(GraphicTools.MenuFeuille.ON_INIT,_onInitFeuille,this)
		   return true 
		} else {
			return false
		}
	}
	
	/**
	 * reaction de l'affichage (fleche) sur la modification des enfants directs en fermeture	 */
	private function _onPrevFrame(src,frames:Number){
		//trace("GraphicTools.MenuV._onPrevFrame(src, "+frames+")");
		updateSize();
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
		updateSize();
		dispatchEvent(ON_NEXTFRAME,new Event(this,ON_NEXTFRAME));
		
	}
	
	/**
	 * met à jour la disposition des éléments de menu	 */
	private function updateSize(){
		//trace("GraphicTools.MenuV.updateSize()"+clip);
		var posy:Number=0;
	
		if(titre_mc!=undefined) {
		 posy=titre_mc._y+menuObjectArray[0].getMargeHaute();
		} else {
		 posy=menuObjectArray[0].getMargeHaute();
		}
		for (var i:Number =1; i<menuObjectArray.length;i++) {
			clip["_"+i]._y=Math.floor(posy)+1;
			var prev:Object=menuObjectArray[i-1];
			var prevC:MovieClip=clip["_"+(i-1)];
			if ( prev instanceof MenuV && prev.isOpen()) {  
				clip["_"+i]._y=prevC._y+prevC._height+menuObjectArray[i].getMargeHaute();
				
			} else {
				clip["_"+i]._y=prevC._y+prevC._height+menuObjectArray[i].getMargeHaute();
			}
		}
	}
	
	/**
	 * reservé à la gestion de fermeture du menu (evenement onUnLoad du clip)	 */
	function _onUnload(){
		//trace("GraphicTools.MenuV._onUnload()"+getCurrentFrame());
		if (getCurrentFrame()>1) {
			dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME,[getCurrentFrame()-1]));
		}
	}
	/**
	 * suppression d'une feuille
	 */
	private function _onPreRemFeuille(src:Object,clip:MovieClip,currentFrame:Number) {
		//trace("GraphicTools.MenuV._onPreRemFeuille("+clip+","+currentFrame+")");

		dispatchEvent(ON_PREREM,new Event(this,ON_PREREM,[clip,currentFrame]));
	}

	/**
	 * creation d'une feuille
	 */
	private function _onPreInitFeuille(src:Object,clip:MovieClip,index:Number,currentFrame:Number) {
	//	//trace("GraphicTools.MenuV._onPreInitFeuille("+clip+","+index+","+currentFrame+")");

		dispatchEvent(ON_PREINIT,new Event(this,ON_PREINIT,[clip,index,currentFrame]));
	}
		
	/**
	 * initialisation d'une feuille	 */
	private function _onInitFeuille(src:Object,clip:MovieClip) {
		//trace("GraphicTools.MenuV._onInitFeuille(src)");
		//trace(src.getClip());
		dispatchEvent(ON_INIT,new Event(this,ON_INIT,[clip]));
	}
	/**
	 * gére la reponse du menu à un selection chez un de ses enfants
	 * mise à jour des enfants.
	 * envoi un signal de contenu si il s'agit d'une feuille
	 * @param src source de l'emission du signal (un enfant) , MenuV ou MenuFeuille
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
		}else {
			_onSelectFeuille(src,[src.getName()]);
		}
		
	}
	
	/**
	 * propage vers la racine d'un signal de contenu en completant la liste de menu avec le nom du menu courant
	 *  @param src source de l'emission du signal (un enfant) , MenuV ou MenuFeuille
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
		//trace("GraphicTools.MenuV.setPressed("+byPress+")");
		if (byPress==true) {
			this.byPress=true;
		}
		openMenu();
	}
	
	/**
	 * referme le menu	 */
	public function setUnpressed(){
		//trace("GraphicTools.MenuV.setUnpressed()"+getClip());
		closeMenu();
	}
	
	/**
	 * informe sur l'etat du menu	 */
	public function isOpen():Boolean {
		//trace("GraphicTools.MenuV.isOpen()"+(clip._currentframe>1));
		return getCurrentFrame()>1;
		//return menuObjectArray.length>0;
	}
	
	
	
	private function _onOpened(){
		fleche_mc.nextFrame();
		updateSize();
		dispatchEvent(ON_NEXTFRAME,new Event(this,ON_NEXTFRAME));
	
	}
	private function _onClosed(src:MenuV){
		
		//trace("GraphicTools.MenuV._onClosed()");
		fleche_mc.prevFrame();
		updateSize();
		dispatchEvent(ON_PREVFRAME,new Event(this,ON_PREVFRAME));
	}
	
	public function reset(listMenu:Array){
		//trace("GraphicTools.MenuV.reset("+listMenu+")");
		//trace(listMenu.join("")+" == "+lastListMenu);
		openMenu(listMenu);
		/*
		if (listMenu.join("")!=lastListMenu) {
			titre_mc.gotoAndStop(BTN_ON);
            menuObjectArray=new Array();
            lastListMenu="";
            clip.gotoAndStop(1); 
            fleche_mc.gotoAndStop(1);
            openMenu(listMenu);
			
		} 
		*/
	}
	
	
	
}