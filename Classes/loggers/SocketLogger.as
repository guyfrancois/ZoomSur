import Log;
import Message;
import ChangeEvent;
import loggers.ILogger;

/**
 *
 * Important note:
 * 
 * The socketlogger won't work in a web browser unless your machine
 * specifies that it should be allowed - run an HTTP server and create a file
 * called "crossdomain.xml" in the web root which contains:
 *
 * <?xml version="1.0"?>
 * <cross-domain-policy>
 *  <allow-access-from domain="localhost" secure="false"/>
 *  <allow-access-from domain="127.0.0.1" secure="false" />
 *  <allow-access-from domain="theevosystem.com" secure="false" />
 * </cross-domain-policy>
 * 
 * @see Log.as
 * @author Sascha Wolter (www.saschawolter.de)
 * @version	0.8
 */
class loggers.SocketLogger extends XMLSocket implements ILogger
{
	public static var LOGGER_NAME:String = "SocketLogger";
	
	// Singleton Pattern	private static var _singleton:SocketLogger = null;
	
	// Parameters for Socket Server
	private var _connected : Boolean = false;
	private var _connecting : Boolean = false;
	private var _port : Number = 9393;
	/**
	 * e. g. use 127.0.0.1 localhost
	 * or leave _socketURL empty to reference the Host-Computer which serves the application
	 */
	private var _url : String = "127.0.0.1";
	
	// Static methods
	public static function getInstance():ILogger
	{
		if (!_singleton)
		{
			_singleton = new SocketLogger();
		}
		return _singleton;
	}
	
	/**
	 * Constructor	 */
	private function SocketLogger ()
	{
		// Allow port customization through flash vars
		if(_root.socketLoggerPort)
			_port = Number(_root.socketLoggerPort);
		
		// Singleton
		connect();
	}
	
	/**
	 * Methods	 */
 	public function valueChanged(event:ChangeEvent):Void
	{
		sendMessages(event.source);
	}
	
	public function sendMessages(message_list:Array):Void
	{		
		var message:Message;
		while (message_list.length>0 && _connected)
		{
			message = Message(message_list.shift());
			send(messageToXML(message));
		}
		connect();		
	}
	
	private function connect():Void
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
		if(success) {
			sendMessages(Log.getInstance());
		}
	}
	
	private function onClose():Void
	{
		_connected = false;
		_connecting = false;		
	}
	
	private function messageToXML(message:Message):XML
	{
		var message_xml:XML;
		var message_xmlElement:XML;
		//
		message_xmlElement = new XML();
		message_xmlElement.nodeName = "Message";
		message_xmlElement.nodeType = 1;
		message_xmlElement.attributes["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance";
		message_xmlElement.attributes["xsi:noNamespaceSchemaLocation"] = "Message.xsd";
		if (message.getMessage() != undefined)
		{
			message_xmlElement.attributes.message = message.getMessage();
		}
		if (message.getClassName() != undefined)
		{
			message_xmlElement.attributes.className = message.getClassName();
		}
		if (message.getFileName() != undefined)
		{
			message_xmlElement.attributes.fileName = message.getFileName();
		}
		if (message.getLevel() != undefined)
		{
			message_xmlElement.attributes.level = String(message.getLevel());
		}
		if (message.getTimestamp() != undefined)
		{
			message_xmlElement.attributes.timestamp = String(message.getTimestamp().getTime());
		}
		if (message.getLine() != undefined)
		{
			message_xmlElement.attributes.line = String(message.getLine());
		}
		//
		message_xml = new XML();
		message_xml.ignoreWhite = true;
		message_xml.docTypeDecl = "";
		message_xml.xmlDecl = '<?xml version="1.0" encoding="UTF-8"?>';
		message_xml.appendChild(message_xmlElement);
		return	message_xml;
	}
}