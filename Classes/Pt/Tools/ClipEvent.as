/**
 * @author GuyF , pense-tete.com
 * @date 7 févr. 07
 * 
 */
 
import org.aswing.Event;
import org.aswing.IEventDispatcher;
import org.aswing.EventDispatcher;
import org.aswing.util.ArrayUtils;
import org.aswing.util.Delegate;
import org.aswing.util.StringUtils;

/**
 * Ajoute au MovieClip une couche de gestionnaire d'evenement compatible avec asWing
 *  */

class Pt.Tools.ClipEvent {
	
	static function destroy(clip) {
		delete clip.listeners ;
		delete clip.addEventListener;
		delete clip.removeEventListener;
		delete clip.dispatchEvent;
		delete clip.fireActionEvent;
		delete clip.createEventObj;
		
	}
	/**
	 * initialise le clip en ajoutant les fonctionnalité pour la gestion des evenements	 */
	static function initialize(clip:MovieClip):Void {
		
		//clip.EventDispatcher=function() {
			clip.listeners = new Array();
		//}
		clip.addEventListener=function (eventTypeOrLis:Object, func:Function, obj:Object):Object{
			var listener:Object = EventDispatcher.createEventListener(eventTypeOrLis, func, obj); 
			clip.listeners.push(listener);
			return listener;
		}
	
	/**
	 * Remove the specified event listener.
	 * @param listener the listener which will be removed.
	 */
		clip.removeEventListener=function (listener:Object):Void{
			ArrayUtils.removeFromArray(clip.listeners, listener);
		}
		
	/**
	 * dispatchEvent(name:String, event:Event)<br>
	 * dispatchEvent(event:Event) default the the listener's method name to event's type name.
	 * <p>
	 * @param name the listener's method name
	 * @param event the event object, event.target = the component object
	 */
		clip.dispatchEvent=function (name:Object, event:Event):Void{
			
			/*trace("ClipEvent "+clip._name+" dispatchEvent name:"+name);
			//trace(" event getType:"+event.getType());
			//trace(" event getSource:"+event.getSource());
			//trace(" event getArguments:"+event.getArguments());*/
			var funcName:String;
			if(event == undefined){
				event = Event(name);
				funcName = event.getType();
			}else{
				funcName = String(name);
			}
			var n:Number = clip.listeners.length;
			if(n > 0){
				var i:Number = -1;
				while((++i) < n){
				//	//trace(" event listener:"+clip.listeners[i]+" Class:"+clip.listeners[i].CLASS);
					clip.listeners[i][funcName].apply(clip.listeners[i], event.getArguments());
				}
			}
		}
	
	/**
	 * fireActionEvent()<br>
	 * fireActionEvent(arg1, arg2...)<br>
	 * Fires a ON_ACT event.
	 * @param arg1 arg1, arg2... the additonal params need pass to the handlers
	 */
		clip.fireActionEvent=function ():Void{
			clip.dispatchEvent(EventDispatcher.ON_ACT, new Event(clip, EventDispatcher.ON_ACT, arguments));
		}
	
	/**
	 * createEventObj(type:String)<br>
	 * createEventObj(type:String, arg)<br>
	 * createEventObj(type:String, arg1, arg2, ...)<br>
	 * 
	 * Creates new event object for the current scope.
	 * 
	 * @param type the event name
	 * @param arg the additional arguments to be passed to the event handler.
	 * @return constructed event object
	 */
		clip.createEventObj=function (type:String):Event{
			return ( new Event(this, type, arguments.slice(1)) );
		}
		
	
	}
	
	/**
	 * ajoute un evenement movieClip a surveiller
	 * exemple :
	 * ClipEvent.setEventsTrigger(survol_mc,"onRollOver");
	 * ensuite il est possible de surveiller l'evenement :
	 * survol_mc.addEventListener("onRollOver",_RollOverSurvol,this)
	 * 
	 * _RollOverSurvol peut avoir la forme :
	 * function _RollOverSurvol(source:MovieClip)
	 * avec source : le clip emetteur	 */
	static function setEventsTrigger(clip:MovieClip,eventName:String):Void {
		if (clip.listeners==undefined) {
			initialize(clip);
		}
		//trace("ClipEvent.setEventsTrigger("+clip+" "+eventName+")");
		clip[eventName]=function (){
	
			clip.dispatchEvent(eventName, new Event(clip, eventName, arguments));
		}
	}
	static function unsetEventsTrigger(clip:MovieClip,eventName:String):Void {
		//trace("ClipEvent.unsetEventsTrigger("+clip+" "+eventName+")");
		delete clip[eventName];
	}
}