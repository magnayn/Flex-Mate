package com.asfusion.mate.events
{
	import flash.utils.getQualifiedClassName;
	
	/**
	 * This event is used by the InjectorRegistry to register a target for Injection.
	 */
	public class InjectorEvent extends InjectorEventBase
	{
		//-----------------------------------------------------------------------------------------------------------
		//                                          Public Constants
		//------------------------------------------------------------------------------------------------------------
		
		public static const INJECT_DERIVATIVES:String = "injectDerivativesInjectorEvent";
		
		//-----------------------------------------------------------------------------------------------------------
		//                                          Constructor
		//-------------------------------------------------------------------------------------------------------------
		/**
		 * Constructor
		 */
		public function InjectorEvent(type:String, target:Object, bubbles:Boolean=false, cancelable:Boolean=false)
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