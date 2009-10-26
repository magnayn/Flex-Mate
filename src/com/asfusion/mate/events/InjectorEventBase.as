package com.asfusion.mate.events
{
	import flash.events.Event;
	
	public class InjectorEventBase extends Event
	{
		//-----------------------------------------------------------------------------------------------------------
		//                                          Public Properties
		//------------------------------------------------------------------------------------------------------------
		/**
		 * Target that wants to register for Injection.
		 */
		public var injectorTarget:Object;
		
		/**
		 * Unique identifier to distinguish the target
		 */
		public var uid:*;
		
		public function InjectorEventBase(type:String, injectorTarget:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);			
			this.injectorTarget = injectorTarget;
		}
	}
}