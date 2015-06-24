package
{
	import com.pnwrain.flashsocket.events.FlashSocketEvent;
	import com.pnwrain.flashsocket.FlashSocket;
	import fl.controls.Button;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Marcela Errazquin
	 */
	public class Main extends Sprite implements IWebSocketLogger
	{
		private static const CONNECT_LABEL:String = "Connect";
		private static const DISCONNECT_LABEL:String = "Disconnect";
		private static const SEND_APPCONFIG_LABEL:String = "Send AppConfig 10";
		private static const PING_LABEL:String = "PING";
		private static const INSTRUCTIONS:String = "INSTRUCTIONS:\nClick \"Connect\"\nOnce connected, click \"Send AppConfig 10\"\nNotice how there is no \"activated\" response, however there is a \"6\" which I believe is the response to the \"5\" (upgrade) that was sent after receiving the \"3probe\".\nClick \"PING\"\nNotice how the \"activated\" message is received.\nClick\"PING\" again, \"PONG\" response from the initial \"PING\" is received.\nClick \"Send AppConfig 10\" again, another \"PONG\" is received (this one corresponds to the second \"PING\").\n-----------------------------------------\n";
		
		private var _flashSocket:FlashSocket;
		private var _log:TextField;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function log($message:String):void 
		{
			trace($message);
			
			var level:int = 0;
			if ($message.charAt(1) == ":")
			{
				level = int($message.split(":")[0]);
				$message = $message.split(":").slice(1).join(":");
			}
			var color:uint;
			switch(level)
			{
				case 2:
					color = 0xE8B957;
					break;
				case 3:
					color = 0xE659E6;
					break;
				case 4:
					color = 0xFF0000;
					break;
				default:
					color = 0x30A0AD;
				
			}
			var startIndex:int = _log.length;
			_log.appendText($message + "\n");
			_log.setTextFormat(new TextFormat(null, null, color), startIndex, startIndex + $message.length);
			_log.scrollV = _log.maxScrollV;
		}
		
		public function error($message:String):void 
		{
			trace("4:" + $message);
			log("4:" + $message);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			createButtons();
			createLog();
			
		}
		
		private function createButtons():void 
		{
			var connectBtn:Button = addChild(new Button()) as Button;
			connectBtn.label = CONNECT_LABEL;
			connectBtn.x = connectBtn.y = 10;
			connectBtn.addEventListener(MouseEvent.CLICK, buttonHandler);
			
			var disconnectBtn:Button = addChild(new Button()) as Button;
			disconnectBtn.label = DISCONNECT_LABEL;
			disconnectBtn.x = connectBtn.x + connectBtn.width + 20;
			disconnectBtn.y = connectBtn.y;
			disconnectBtn.addEventListener(MouseEvent.CLICK, buttonHandler);
			
			var sendAppConfigBtn:Button = addChild(new Button()) as Button;
			sendAppConfigBtn.label = SEND_APPCONFIG_LABEL;
			sendAppConfigBtn.width = sendAppConfigBtn.width * 1.5;
			sendAppConfigBtn.x = disconnectBtn.x + disconnectBtn.width + 20;
			sendAppConfigBtn.y = disconnectBtn.y;
			sendAppConfigBtn.addEventListener(MouseEvent.CLICK, buttonHandler);
			
			var pingBtn:Button = addChild(new Button()) as Button;
			pingBtn.label = PING_LABEL;
			pingBtn.x = sendAppConfigBtn.x + sendAppConfigBtn.width + 20;
			pingBtn.y = sendAppConfigBtn.y;
			pingBtn.addEventListener(MouseEvent.CLICK, buttonHandler);
			
		}
		
		private function createLog():void 
		{
			_log = addChild(new TextField()) as TextField;
			_log.type = "input";
			_log.x = 10;
			_log.y = 50;
			_log.width = stage.stageWidth - 20;
			_log.height = stage.stageHeight - 70;
			_log.multiline = _log.wordWrap = true;
			_log.border = true;
			
			_log.text = INSTRUCTIONS;
		}
		
		private function buttonHandler($event:MouseEvent):void 
		{
			switch(Button($event.target).label)
			{
				case CONNECT_LABEL:
					connect();
					break;
				case DISCONNECT_LABEL:
					disconnect();
					break;
				case SEND_APPCONFIG_LABEL:
					if (_flashSocket)
					{
						_flashSocket.send( { "appConfig": 10 }, "appconfig");
					}
					else
					{
						error("Not connected");
						
					}
					break;
				case PING_LABEL:
					if (_flashSocket)
					{
						_flashSocket.send(null, "2");
					}
					else
					{
						error("Not connected");
					}
					break;
			}
		}
		
		private function connect():void 
		{
			if (!_flashSocket)
			{
				_flashSocket = new FlashSocket("54.88.182.111:61616", this);
				_flashSocket.addEventListener(FlashSocketEvent.CONNECT, onConnected, false, 0, true);
				_flashSocket.addEventListener(FlashSocketEvent.CLOSE, onClosed, false, 0, true);
				_flashSocket.addEventListener(FlashSocketEvent.MESSAGE, onData, false, 0, true);
				_flashSocket.addEventListener(FlashSocketEvent.CONNECT_ERROR, onError, false, 0, true);
				_flashSocket.addEventListener(FlashSocketEvent.IO_ERROR, onError, false, 0, true);
				_flashSocket.addEventListener(FlashSocketEvent.SECURITY_ERROR, onError, false, 0, true);
			}
			else
			{
				error("Already connected");
				
			}
			
		}
		
		private function disconnect():void 
		{
			if (_flashSocket)
			{
				_flashSocket.removeEventListener(FlashSocketEvent.CONNECT, onConnected);
				_flashSocket.removeEventListener(FlashSocketEvent.CLOSE, onClosed);
				_flashSocket.removeEventListener(FlashSocketEvent.MESSAGE, onData);
				_flashSocket.removeEventListener(FlashSocketEvent.CONNECT_ERROR, onError);
				_flashSocket.removeEventListener(FlashSocketEvent.IO_ERROR, onError);
				_flashSocket.removeEventListener(FlashSocketEvent.SECURITY_ERROR, onError);
				_flashSocket.close();				
			}
			_flashSocket = null;
		}
		
		private function onConnected($event:FlashSocketEvent):void 
		{
			log("3:connected");
		}
		
		private function onClosed($event:FlashSocketEvent):void 
		{
			log("closed");
			disconnect();
		}
		
		private function onError($event:FlashSocketEvent):void 
		{
			error($event.toString());
		}
		
		private function onData($event:FlashSocketEvent):void 
		{
			log("data received");
		}
		
	}
	
}