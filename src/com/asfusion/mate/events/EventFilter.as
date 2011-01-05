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
	
	/**
	 * All Local Event maps will receive events that originate from Dialog boxes.
	 * However, we only want to look at events that have "come from" events that were
	 * created by the view that a particular map is for. We look at the dialog 'real' parent
	 * (Registered through the MatePopupManager) and natural parent-child relationships
	 */ 
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
											
					return findMatchingParent(mapParent, realParent);
				}
			}
			
			return true;
		}  
		
		private function findMatchingParent(mapParent:IFlexDisplayObject, realParent:DisplayObject):Boolean
		{
			if( mapParent == null || realParent == null)
				return false;
			
			if( mapParent == realParent )
				return true;
		
			return findMatchingParent(mapParent, realParent.parent) || findMatchingParent(mapParent, MatePopUpManager.getMapping(realParent as IFlexDisplayObject));						
		}

		private function getMapParent(map:IEventMap):IFlexDisplayObject
		{
			var disp:IEventDispatcher = map.getDispatcher();
			
			if( disp is LocalDispatcher )
			{
				return IFlexDisplayObject((disp as LocalDispatcher).componentDispatcher);
			}
			
			// Assume just fdo
			return IFlexDisplayObject(disp);
		}
	}
}