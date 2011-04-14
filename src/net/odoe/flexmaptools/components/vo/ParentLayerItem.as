package net.odoe.flexmaptools.components.vo
{
    import com.esri.ags.layers.Layer;
    
    import mx.collections.ArrayCollection;
    
    public class ParentLayerItem
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