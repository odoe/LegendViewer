package net.odoe.flexmaptools.components.helpers
{
    import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
    import com.esri.ags.layers.ArcGISImageServiceLayer;
    import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
    import com.esri.ags.layers.Layer;
    import com.esri.ags.utils.JSON;
    
    import flash.utils.ByteArray;
    
    import mx.collections.ArrayCollection;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.http.HTTPService;
    import mx.utils.Base64Decoder;
    
    import net.odoe.flexmaptools.components.vo.LayerItem;
    import net.odoe.flexmaptools.components.vo.LegendItem;
    import net.odoe.flexmaptools.components.vo.ParentLayerItem;
    
    import org.osflash.signals.Signal;
    import org.osflash.signals.natives.NativeSignal;
    
    /**
     *
     * @author rrubalcava
     */
    public class LayerExtractor
    {
        /**
         * Signal that will dispatch the results of this tool.
         * @default
         */
        public var extractReady:Signal;
        
        private var visibleLayers:ArrayCollection;
        
        private var p_layer:ParentLayerItem;
        
        public function LayerExtractor()
        {
            extractReady=new Signal(ParentLayerItem);
        }
        
        /**
         * This function will extract the Legend data from the Legend REST endpoint
         * for an <code>ArcGISDynamicMapServiceLayer</code> to display that data.
         * @param lyr
         */
        public function extractLegend(lyr:Layer):void
        {
            if (lyr is ArcGISDynamicMapServiceLayer)
                visibleLayers=ArcGISDynamicMapServiceLayer(lyr).visibleLayers;
            p_layer=new ParentLayerItem();
            p_layer.layer=lyr;
            
            requestLegend(lyr);
        }
        
        private function requestLegend(lyr:Layer):void
        {
            var url:String = getURL(lyr);
            if (url != "none")
            {
                var service:HTTPService=getLegendService(url);
                var resultSignal:NativeSignal=new NativeSignal(service, ResultEvent.RESULT, ResultEvent);
                var faultSignal:NativeSignal=new NativeSignal(service, FaultEvent.FAULT, FaultEvent);
                
                faultSignal.addOnce(function(e:FaultEvent):void
                {
                    trace("error in calling legend service:", e.message);
                });
                
                resultSignal.addOnce(function(e:ResultEvent):void
                {
                    var results:Array=JSON.decode(String(e.result)).layers;
                    
                    processResults(results, lyr);
                });
                
                service.send({f: "json", pretty: "false"});
            }
        }
        
        private function getLegendService(url:String):HTTPService
        {
            var service:HTTPService=new HTTPService();
            service.url=url + "/legend";
            service.resultFormat="text";
            return service;
        }
        
        private function processResults(results:Array, lyr:Layer):void
        {
            // traverse the JSON results of the Legend
            // REST endpoint and extract all the data
            for each (var item:Object in results)
            {
                var lyrItem:LayerItem=getLayerData(item, lyr);
                p_layer.layers.addItem(lyrItem);
            }
            extractReady.dispatch(p_layer);
        }
        
        private function getLayerData(item:Object, lyr:Layer):LayerItem
        {
            var lyrItem:LayerItem=new LayerItem();
            lyrItem.layerId=item.layerId;
            lyrItem.layerName=item.layerName;
            lyrItem.layerType=item.layerType;
            lyrItem.minScale=item.minScale;
            lyrItem.maxScale=item.maxScale;
            if (visibleLayers)
                lyrItem.visible=visibleLayers.contains(lyrItem.layerId);
            lyrItem.parentLayer=lyr;
            lyrItem.legend=getLegendArray(item);
            
            return lyrItem;
        }
        
        private function getLegendArray(item:Object):Array
        {
            var items:Array=[];
            for each (var lg:Object in item.legend)
            {
                if (lg)
                {
                    var legend:LegendItem=getLegendData(lg);
                    items.push(legend);
                }
            }
            return items;
        }
        
        private function getLegendData(lg:Object):LegendItem
        {
            var legend:LegendItem=new LegendItem();
            legend.label=lg.label;
            legend.url=lg.url;
            legend.imageData=jsonToByteArray(String(lg.imageData));
            legend.contentType=lg.contentType;
            return legend;
        }
        
        private function jsonToByteArray(json:String):ByteArray
        {
            // need to decode the JSON string of the Image Binary Data
            // into a useable ByteArray
            // This may add a little overhead, but still works well.
            var dec:Base64Decoder=new Base64Decoder();
            dec.decode(json);
            return dec.toByteArray();
        }
        
        private function getURL(lyr:Layer):String
        {
            if (lyr is ArcGISDynamicMapServiceLayer)
                return ArcGISDynamicMapServiceLayer(lyr).url;
            else if (lyr is ArcGISTiledMapServiceLayer)
                return ArcGISTiledMapServiceLayer(lyr).url;
            else if (lyr is ArcGISImageServiceLayer)
                return ArcGISImageServiceLayer(lyr).url;
            else
                return "none";
        }
    }
}