package com.asfusion.mate.events
{
	import com.asfusion.mate.core.IEventMap;
	import com.asfusion.mate.core.LocalDispatcher;
	import com.asfusion.mate.core.LocalEventMap;
	import com.asfusion.mate.utils.MatePopUpManager;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.core.IFlexDisplayObject;
	import mx.managers.SystemManager;
	
	public class EventFilter
	{
		public function isRequiredEvent(map:IEventMap, event:Event):Boolean
		{
			if( map is LocalEventMap )
			{
				var eventFrom:Object = event.currentTarget;
				var originator:Object = event.target;
				if( eventFrom is SystemManager && originator is IFlexDisplayObject)
				{
					// Yes, this event has been routed through the systemManager, therefore it 
					// is likely from a popup. Do we care about this popup?
					
					var realParent:DisplayObject = MatePopUpManager.getMapping(originator as IFlexDisplayObject);
					
					// This will be the case if the parent wasn't registered using MatePopupManager..
					if( realParent == null )
						return false;
					
					var mapParent:IFlexDisplayObject = getMapParent(map);
						
					// OK - try to find an event map
					while(realParent != null)
					{						
						if( mapParent == realParent )
							return true;
						
						realParent = realParent.parent;
					}
					
					// No, our map wasn't in this list. So we are not interested.
					return false;
				}
			}
			
			return true;
		}  

		private function getMapParent(map:IEventMap):IFlexDisplayObject
		{
			var disp:IEventDispatcher = map.getDispatcher();
			
			if( disp instanceof LocalDispatcher )
			{
				return IFlexDisplayObject((disp as LocalDispatcher).componentDispatcher);
			}
			
			// Assume just fdo
			return IFlexDisplayObject(disp);
		}
	}
}