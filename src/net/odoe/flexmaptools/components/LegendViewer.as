package net.odoe.flexmaptools.components
{
    import com.esri.ags.Map;
    import com.esri.ags.events.LayerEvent;
    import com.esri.ags.events.MapEvent;
    import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
    import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
    import com.esri.ags.layers.Layer;
    
    import mx.collections.ArrayCollection;
    import mx.collections.Sort;
    import mx.collections.SortField;
    
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
            prepareSort();
        }
        
        private function prepareSort():void
        {
            sortLegend = true;
            var sortField:SortField = new SortField();
            sortField.name = "sortOrder";
            sortField.numeric = true;
            sort = new Sort();
            sort.fields = [sortField];
            sortLayerList();
        }
        
        private function sortLayerList():void
        {
            layers.sort = sort;
            layers.refresh();
        }
        
        [SkinPart(required="true")]
        /**
         * Required List that must be in Skin
         * @default
         */
        public var legendDataGroup:DataGroup;
        
        public var sortLegend:Boolean;
        
        protected var _map:Map;
        
        private var layerAdded:NativeSignal;
        private var layerRemoved:NativeSignal;
        
        protected var layers:ArrayCollection;
        protected var sort:Sort;
        
        /**
         * Regular Expression to prevent random GraphicsLayers from being added to List.
         * Using regular expression, because there may be cases where you want
         * a user to control a GraphicsLayer, in which case you should give it a
         * distinctive name.
         * @default
         */
        protected var reg1:RegExp = /GraphicsLayer\w/;
        
        /**
         * Regular Expression to prevent random FeatureLayers from being added to List.
         * Using regular expression, because there may be cases where you want
         * a user to control a FeatureLayer, in which case you should give it a
         * distinctive name.
         * @default
         */
        protected var reg2:RegExp = /FeatureLayer\w/;
        
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
                if (lyr.map)
                {
                    extractLayerData(lyr);
                }
                else
                    waitForLayer(lyr);
            }
        }
        
        private function isValidLayer(name:String):Boolean
        {
            return (!reg1.test(name) && !reg2.test(name));
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
            if (isValidLayer(lyr.name))
            {
                if (isUseableLayer(lyr))
                {
                    var extract:LayerExtractor=new LayerExtractor();
                    extract.extractReady.add(function(item:ParentLayerItem):void
                    {
                        addToLayers(item);
                        extract=null;
                    });
                    extract.extractLegend(lyr);
                }
                else
                {
                    var p_item:ParentLayerItem=new ParentLayerItem();
                    p_item.layer=lyr;
                    addToLayers(p_item);
                }
            }
        }
        
        // do image services have legends?
        private function isUseableLayer(lyr:Layer):Boolean
        {
            return lyr is ArcGISDynamicMapServiceLayer || lyr is ArcGISTiledMapServiceLayer; // || lyr is ArcGISImageServiceLayer 
        }
        
        private function addToLayers(item:ParentLayerItem):void
        {
            item.sortOrder = findSortId(item.layer.id);
            layers.addItem(item);
        }
        
        private function findSortId(layerId:String):int
        {
            var length:int = _map.layerIds.length;
            for (var i:int = 0; i < length; i++)
            {
                if (_map.layerIds[i] == layerId)
                {
                    return i;
                }
            }
            return 0;
        }
    }
}