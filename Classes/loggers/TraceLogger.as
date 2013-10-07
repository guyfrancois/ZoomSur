import Message;
import ChangeEvent;
import loggers.ILogger;

/**
 * @see Log.as
 * @author Sascha Wolter (www.saschawolter.de)
 * @version	0.8
 */
class loggers.TraceLogger implements ILogger
{
	public static var LOGGER_NAME:String = "TraceLogger";
	
	// Singleton Pattern	private static var _singleton:ILogger = null;
	
	// Static methods
	public static function getInstance():ILogger
	{
		if (!_singleton)
		{
			_singleton = new TraceLogger();
		}
		return _singleton;
	}
	
	/**
	 * Constructor	 */
	private function TraceLogger()
	{
		// Singleton
	}
	
	/**
	 * Methods	 */
	public function valueChanged(event:ChangeEvent):Void
	{
		sendMessages(event.source);
	}
	
	public function sendMessages(log:Array):Void
	{		
		var message:Message;
		while (log.length>0)
		{
			message = Message(log.shift());
			trace(message);
		}
	}
}