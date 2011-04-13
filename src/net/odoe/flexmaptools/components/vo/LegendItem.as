package net.odoe.flexmaptools.components.vo
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	public class LegendItem extends EventDispatcher
	{
		public function LegendItem()
		{
		}

		public var label:String;
		public var url:String;
		public var imageData:ByteArray;
		public var contentType:String;
	}
}