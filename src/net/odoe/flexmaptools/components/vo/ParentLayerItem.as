package net.odoe.flexmaptools.components.vo
{
    import com.esri.ags.layers.Layer;
    
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    import mx.collections.ArrayCollection;
    
    public class ParentLayerItem extends EventDispatcher
    {
        public function ParentLayerItem()
        {
            sortOrder = 0;
            layers=new ArrayCollection();
        }
        
        public var layer:Layer;
        public var layers:ArrayCollection;
        public var sortOrder:int;
    }
}