import ChangeEvent;

/**
 * @see Log.as
 * @author Sascha Wolter (www.saschawolter.de)
 * @version	0.8
 */
interface loggers.ILogger
{
	// public static function getInstance():ILogger;
	public function sendMessages(list:Array):Void;
	public function valueChanged(event:ChangeEvent):Void;
}