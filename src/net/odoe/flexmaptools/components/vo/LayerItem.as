package net.odoe.flexmaptools.components.vo
{
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.Layer;

	public class LayerItem
	{
		public function LayerItem()
		{
		}

		public var layerId:int;
		public var layerName:String;
		public var layerType:String;
		public var minScale:Number;
		public var maxScale:Number;
		public var legend:Array;
		public var visible:Boolean;
		public var parentLayer:Layer;

		public function toggleVisible(value:Boolean):void
		{
			this.visible=value;
			if (value && !isInVisibleLayers())
			{
				ArcGISDynamicMapServiceLayer(this.parentLayer).visibleLayers.addItem(this.layerId);
			}
			else
			{
				var i:int=ArcGISDynamicMapServiceLayer(this.parentLayer).visibleLayers.getItemIndex(this.layerId);
				ArcGISDynamicMapServiceLayer(this.parentLayer).visibleLayers.removeItemAt(i);
			}
		}
        
        private function isInVisibleLayers():Boolean
        {
            return ArcGISDynamicMapServiceLayer(this.parentLayer).visibleLayers.contains(this.layerId);
        }
	}
}