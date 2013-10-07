import Message;
import ChangeEvent;
import loggers.ILogger;
/**
 *
 * @see Log.as
 * @author Dobes Vandermeer
 * @version	0.1
 */
class loggers.NullLogger implements ILogger
{
	public static var LOGGER_NAME:String = "NullLogger";
	/**
	 * Singleton Pattern
	 */
	private static var _singleton:ILogger = null;
	/**
	 * Static methods
	 */
	public static function getInstance ():ILogger
	{
		if (!_singleton)
		{
			_singleton = new NullLogger();
		}
		return _singleton;
	}
	/**
	 * Constructor
	 */
	private function NullLogger ()
	{
		// Singleton
	}
	/**
	 * Methods
	 */
	public function valueChanged(event:ChangeEvent):Void
	{
		sendMessages(event.source);
	}
	public function sendMessages (log:Array):Void
	{	
		var message:Message;
		while (log.length>0)
		{
			message = Message(log.shift());
		}
	}
}