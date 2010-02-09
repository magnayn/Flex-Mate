package com.asfusion.mate.events
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * This event is used by the InjectorRegistry to remove a target frin Injection.
	 */
	public class RemoveInjectorEvent extends InjectorEventBase
	{	
		//-----------------------------------------------------------------------------------------------------------
		//                                          Constructor
		//-------------------------------------------------------------------------------------------------------------
		/**
		 * Constructor
		 */
		public function RemoveInjectorEvent(type:String, target:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			var injectorTarget:Object = target;			
			
			if( !type ) 
			{
				type = getQualifiedClassName(target);
			}
				
			super(type, injectorTarget, bubbles, cancelable);
			
			if(target.hasOwnProperty("id"))
			{
				uid = target["id"];
			}
		}
		
	}
}