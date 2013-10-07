import Log;
import Message;
import ChangeEvent;
import loggers.ILogger;

/**
 * @see Log.as
 * @author Sascha Wolter (www.saschawolter.de)
 * @version	0.8
 */
class loggers.OldSocketLogger extends XMLSocket implements ILogger
{
	public static var LOGGER_NAME:String = "OldSocketLogger";
	
	// Singleton Pattern
	private static var _singleton:OldSocketLogger = null;
	
	// Parameters for Socket Server
	private var _connected : Boolean = false;
	private var _connecting : Boolean = false;
	private var _port : Number = 1024;
	
	/**
	 * e. g. use 127.0.0.1 focalhost
	 * or leave _socketURL empty to reference the Host-Computer which serves the application
	 */
	private var _url : String = "127.0.0.1";
	
	/**
	 * Static methods
	 */
	public static function getInstance ():ILogger
	{
		if (!_singleton)
		{
			_singleton = new OldSocketLogger();
		}
		return _singleton;
	}
	
	/**
	 * Constructor
	 */
	private function OldSocketLogger ()
	{
		// Singleton
		connect();
	}
	
	/**
	 * Methods
	 */
 	public function valueChanged(event:ChangeEvent):Void
	{
		sendMessages(event.source);
	}
	
	public function sendMessages (message_list:Array):Void
	{		
		var message:Message;
		while (message_list.length>0 && _connected)
		{
			message = Message(message_list.shift());
			send(messageToXML(message));
		}
		connect();
	}
	
	private function connect ():Void
	{
		if (!_connected && !_connecting)
		{
			_connecting = super.connect(_url, _port);
		}
	}
	
	private function onConnect(success:Boolean):Void
	{
		_connected = success;
		_connecting = false;
		sendMessages(Log.getInstance());
	}
	
	private function onClose():Void
	{
		_connected = false;
		_connecting = false;		
	}
	
	private function messageToXML (message:Message):XML
	{
		var log_xml : XML = new XML ();
		var root_xml : XMLNode;
		var msg_xml : XMLNode;
		msg_xml = log_xml.createTextNode (message.getMessage());
		root_xml = log_xml.createElement ("logEvent");
		root_xml.attributes.level = message.getLevel();
		root_xml.attributes.timestamp = message.getTimestamp().getTime();
		root_xml.attributes.logger = message.getFileName();
		root_xml.appendChild (msg_xml);
		log_xml.docTypeDecl = "";
		log_xml.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
		log_xml.appendChild (root_xml);
		return log_xml;	
	}
}