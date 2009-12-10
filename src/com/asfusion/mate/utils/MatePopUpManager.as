package com.asfusion.mate.utils
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	
	public class MatePopUpManager
	{
		private static var creationMap:Dictionary = new Dictionary(true); 
		
		public static function createPopUp(parent:DisplayObject,
                                       className:Class,
                                       modal:Boolean = false,
                                       childList:String = null):IFlexDisplayObject
	    {   
			var popup:IFlexDisplayObject = PopUpManager.createPopUp(parent, className, modal, childList);
			
			// Register relationship
			creationMap[popup] = parent;
			
			return popup;
	    }
	    
	    public static function addPopUp(window:IFlexDisplayObject,
                    parent:DisplayObject,
                    modal:Boolean = false,
                    childList:String = null):void
		{
			PopUpManager.addPopUp(window, parent, modal, childList);
			
			creationMap[window] = parent;
		}
	    
	    public static function getMapping(popup:IFlexDisplayObject):DisplayObject
	    {
	    	return creationMap[popup];
	    }

	}
}