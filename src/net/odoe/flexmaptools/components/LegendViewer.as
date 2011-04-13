package net.odoe.flexmaptools.components
{
	import com.esri.ags.Map;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.events.MapEvent;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	import com.esri.ags.layers.Layer;
	
	import mx.collections.ArrayCollection;
	
	import net.odoe.flexmaptools.components.helpers.LayerExtractor;
	import net.odoe.flexmaptools.components.vo.ParentLayerItem;
	
	import org.osflash.signals.natives.NativeSignal;
	
	import spark.components.DataGroup;
	import spark.components.SkinnableContainer;

	public class LegendViewer extends SkinnableContainer
	{
		public function LegendViewer()
		{
			super();
			layers=new ArrayCollection();
		}

		[SkinPart(required="true")]
		/**
		 * Required List that must be in Skin
		 * @default
		 */
		public var legendDataGroup:DataGroup;

		private var _map:Map;

		private var layerAdded:NativeSignal;
		private var layerRemoved:NativeSignal;

		protected var layers:ArrayCollection;

		public function set map(value:Map):void
		{
			_map=value;

			extractLayers();

			layerAdded=new NativeSignal(_map, MapEvent.LAYER_ADD, MapEvent);
			layerAdded.add(onLayerAdded);

			layerRemoved=new NativeSignal(_map, MapEvent.LAYER_REMOVE, MapEvent);
			layerRemoved.add(onLayerRemoved);
		}

		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == legendDataGroup)
				legendDataGroup.dataProvider=layers;
		}

		private function onLayerAdded(e:MapEvent):void
		{
			// need to wait for the layer to fully load or some values will be null
			waitForLayer(e.layer);
		}

		private function onLayerRemoved(e:MapEvent):void
		{
			for each (var p:ParentLayerItem in layers)
			{
				if (p.layer == e.layer)
				{
					var i:int=layers.getItemIndex(p);
					layers.removeItemAt(i);
				}
			}
		}

		private function extractLayers():void
		{
			for each (var lyr:Layer in _map.layers)
			{
				if (!lyr.map)
				{
					waitForLayer(lyr);
				}
				else
					extractLayerData(lyr);
			}
		}

		private function waitForLayer(lyr:Layer):void
		{
			var lyrSignal:NativeSignal=new NativeSignal(lyr, LayerEvent.LOAD, LayerEvent);
			lyrSignal.addOnce(function(e:LayerEvent):void
			{
				extractLayerData(lyr);
			});
		}


		private function extractLayerData(lyr:Layer):void
		{
			if (lyr is ArcGISDynamicMapServiceLayer)
			{
				var extract:LayerExtractor=new LayerExtractor();
				extract.extractReady.add(function(item:ParentLayerItem):void
				{
					layers.addItem(item);
					extract=null;
				});
				extract.extractLegend(ArcGISDynamicMapServiceLayer(lyr));
			}
			else
			{
				var p_item:ParentLayerItem=new ParentLayerItem();
				p_item.layer=lyr;
				layers.addItem(p_item);
			}
		}
	}
}