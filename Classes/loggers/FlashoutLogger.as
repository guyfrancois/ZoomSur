import Message;
import ChangeEvent;
import loggers.ILogger;

/**
 * @see Log.as
 * @author Sascha Wolter (www.saschawolter.de)
 * @version	0.8
 */
class loggers.FlashoutLogger implements ILogger
{
	public static var LOGGER_NAME:String = "FlashoutLogger";
	
	// Singleton Pattern	private static var _singleton:ILogger = null;
	
	// Added for Flashout
	private static var FLASHOUT_LEVELS:Array = ["default_log","error_log", "warning_log", "error_log", "info_log", "error_log", "warning_log", "debug_log"];
	
	// Static methods
	public static function getInstance ():ILogger
	{
		if (!_singleton)
		{
			_singleton = new FlashoutLogger();
		}
		return _singleton;
	}
	
	// set to false forces the logger to send Warnings and Errors only (to improve performance)
	private var _showAllMessages:Boolean = true;
	
	/**
	 * Constructor	 */
	private function FlashoutLogger()
	{
		// Singleton
	}
	
	/**
	 * Methods	 */
	public function valueChanged(event:ChangeEvent):Void
	{
		sendMessages(event.source);
	}
		 
	public function sendMessages (log:Array):Void
	{		
		var message:Message;
		var level:Number;
		while (log.length>0)
		{
			message = Message(log.shift());
			level = message.getLevel();
			if (_showAllMessages || level == Log.ERROR || level == Log.WARNING) 
			{
				fscommand(FLASHOUT_LEVELS[level], message.getTimestamp() + " : " + message.getMessage());
			}
		}
	}
}