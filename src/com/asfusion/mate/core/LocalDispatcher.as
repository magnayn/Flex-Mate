/*
Copyright 2008 Nahuel Foronda/AsFusion

Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. Y
ou may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 

Unless required by applicable law or agreed to in writing, s
oftware distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and limitations under the License

@ignore
*/
package com.asfusion.mate.core
{
	import com.asfusion.mate.utils.SystemManagerFinder;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;

	/**
	 * GlobalDispatcher is the default dispatcher that "Mate" uses. 
	 * This class functions as a dual dispatcher because we can register to 
	 * listen an event and we will be notified if the event is dispatched in 
	 * the main application and in the SystemManager. 
	 * <p>Because SystemManager is the parent of all the popup windows we can 
	 * listen to events in that display list.</p>
	 */
	public class LocalDispatcher implements IEventDispatcher
	{
		
		/*-.........................................componentDispatcher..........................................*/
		
		public var componentDispatcher:IEventDispatcher;
		
		public function LocalDispatcher(parent:IEventDispatcher)
		{
			this.componentDispatcher = parent;
		}
		
				
		/*-.........................................popupDispatcher..........................................*/
		/**
		 * Returns the system manager as a dispatcher. 
		 * Usually, all the popups are created in this object.
		 * Having a reference to this object allows us listen to events on all popups windows.
		 */
		public function get popupDispatcher():IEventDispatcher
		{
			var application:UIComponent = componentDispatcher as UIComponent;
			return (application.systemManager) ? application.systemManager.topLevelSystemManager : SystemManagerFinder.find().topLevelSystemManager;
		}
	
	
		/*-----------------------------------------------------------------------------------------------------------
		*                             Implementation of IEventDispatcher interface 
		-------------------------------------------------------------------------------------------------------------*/
		
		/*-.........................................addEventListener..........................................*/
		/**
		 * Registers an event listener object with this global EventDispatcher so that the listener receives notification of an event. 
		 * You can register event listeners on all nodes in the display list for a specific type of event, phase, and priority.
		 * We register to listen to events coming from the main application and the popup display list.
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			componentDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
			if(type != "applicationComplete")
			{
				if(!useCapture)
				{		
					trace("Add popupDispathcerListener " + type + "; " + componentDispatcher );
					
					if( listenersArray[type] == null )
						listenersArray[type] = new Dictionary(true);
					
					(listenersArray[type] as Dictionary)[ listener ] = listener;
					
					popupDispatcher.addEventListener(type, filteredEventHandler, false, priority);					
				}
//				if(!useCapture)
//				{
//					// We register also the same listener function in the popupDispatcher. 
//					// The popupDispatcher is systemManager itself and has the applicationDispatcher as one of its children. 
//					// Because we don't want to fire the listener twice, we have an extra listener that will stop the event 
//					// if the event was already handled in the applicationDispatcher.
//					popupDispatcher.addEventListener(type, interceptorEventHandler, useCapture, -100, useWeakReference);
//					popupDispatcher.addEventListener(type, listener, useCapture, -101, useWeakReference);
//				}
			}
		}
		
		private var listenersArray:Object = new Object();
		
		protected function filteredEventHandler(event:Event):void
		{			
			if( !eventHasAlreadyBeenSeen(event) )
			{
				for each(var listener:Function in getListenersForEvent(event) )
				{
					listener(event);
				}
			}
			else
			{
				trace("reject " + event);
			}
		
		}
		
		protected function getListenersForEvent(event:Event):Dictionary
		{
			var dict:Dictionary = listenersArray[event.type] as Dictionary;
			return dict;	
		}
		
		/*-.........................................removeEventListener..........................................*/
		/**
		 * Removes a listener from the EventDispatcher object. If there is no matching listener registered with 
		 * the EventDispatcher object, a call to this method has no effect.
		 */
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			popupDispatcher.removeEventListener(type, listener, useCapture);
			componentDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/*-.........................................dispatchEvent..........................................*/
		/**
		 * Dispatches an event into the event flow. The event target is the EventDispatcher object upon
		 *  which dispatchEvent() is called. We use the application as the dispatcher.
		 */
		public function dispatchEvent(event:Event):Boolean
		{
			return componentDispatcher.dispatchEvent(event);
		}
		
		/*-.........................................hasEventListener..........................................*/
		/**
		 * Checks whether the EventDispatcher object has any listeners registered for a specific type of event. 
		 * This allows you to determine where an EventDispatcher object has altered handling of an event type
		 * in the event flow hierarchy. To determine whether a specific event type will actually trigger an
		 * event listener, use <code>IEventDispatcher.willTrigger()</code>.
		 * 
		 * <p>The difference between <code>hasEventListener()</code> and <code>willTrigger()</code> is that <code>hasEventListener()</code>
		 * examines only the object to which it belongs, whereas <code>willTrigger()</code> examines the entire event
		 * flow for the event specified by the type parameter.</p>
		 */
		public function hasEventListener(type:String):Boolean
		{
			return componentDispatcher.hasEventListener(type);
		}
		
		/*-.........................................willTrigger..........................................*/
		/**
		 * Checks whether an event listener is registered with this EventDispatcher object
		 * or any of its ancestors for the specified event type. This method returns true
		 * if an event listener is triggered during any phase of the event flow when an 
		 * event of the specified type is dispatched to this EventDispatcher object or any of its descendants.
		 * 
		 * <p>The difference between <code>hasEventListener()</code> and <code>willTrigger()</code> is that <code>hasEventListener()</code>
		 * examines only the object to which it belongs, whereas <code>willTrigger()</code> examines the entire event
		 * flow for the event specified by the type parameter.</p>
		 */
		public function willTrigger(type:String):Boolean
		{
			return componentDispatcher.willTrigger(type);;
		}
		
		/*-.........................................interceptorEventHandler..........................................*/
		/**
		 * Every time that the popupDispatcher fires an event, this handler will be called.
		 * This handler will stop the event if the event is coming from the application display list. 
		 * This happens because the SystemManager has the application itself as a child and also all the popups.
		 * We stop the propagation because we don't want to trigger the event twice.
		 */
		protected function interceptorEventHandler(event:Event):void
		{
			var target:DisplayObject = (event.target is DisplayObject) ? event.target as DisplayObject : null;
			
			if(target)
			{
				var isApplicationChild:Boolean = (componentDispatcher as Sprite).contains(target);
				if(event.target == componentDispatcher || isApplicationChild || target.parent == null)
				{
					if(event.eventPhase == EventPhase.BUBBLING_PHASE)
					{
						trace("kill " + event);
						event.stopImmediatePropagation();
					}
				}
			}
			
			trace("nokill " + event);
		}
		
		protected function eventHasAlreadyBeenSeen(event:Event):Boolean
		{
			var target:DisplayObject = (event.target is DisplayObject) ? event.target as DisplayObject : null;
			
			trace("Already seen? " + target + " " + event);
			
			if(target)
			{
				var isApplicationChild:Boolean = (componentDispatcher as Sprite).contains(target);
				if(event.target == componentDispatcher || isApplicationChild || target.parent == null)
				{
					if(event.eventPhase == EventPhase.BUBBLING_PHASE)
					{
						return true;
					}
				}
			}	
			
			return false;
		}
	}
}