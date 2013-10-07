import loggers.*;

/**
 * 
 * @see Log.as
 * @author Sascha Wolter (www.saschawolter.de)
 * @version	0.8
 */
class loggers.LoggerFactory
{
	public static function createLogger(loggerName:String):ILogger
	{
		var logger:ILogger;
		switch (loggerName)
		{
			case NullLogger.LOGGER_NAME:
				logger = NullLogger.getInstance();
				break;
				
			case FlashoutLogger.LOGGER_NAME:
				logger = FlashoutLogger.getInstance();
				break;
				
			case OldSocketLogger.LOGGER_NAME:
				logger = OldSocketLogger.getInstance();
				break;
						 
			case SocketLogger.LOGGER_NAME:
				logger = SocketLogger.getInstance();
				break;
				
			case TraceLogger.LOGGER_NAME:
				logger = TraceLogger.getInstance();
				break;
							
			default:
				logger = SocketLogger.getInstance();
			 	break;			
		}
		return logger;
	}
	
}