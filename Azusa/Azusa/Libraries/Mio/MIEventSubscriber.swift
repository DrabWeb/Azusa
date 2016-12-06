//
//  MIEventSubscriber.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The event subscriber for Mio
class MIEventSubscriber : AZEventSubscriber {
    /// The event subscribers for this subscriber
    var subscriptions : [AZEventSubscription] {
        return self._subscriptions;
    };
    
    /// The subscriber objects to this event subscriber
    var _subscriptions : [AZEventSubscription] = [];
    
    /// Adds the given event subscription to this subscriber
    func add(subscriber : AZEventSubscription) {
        
    }
    
    /// Removes the given event subscription
    func remove(subscriber : AZEventSubscription) {
        
    }
    
    /// Emits the given event for this event subscriber
    func emit(event : AZEvent) {
        
    }
}

/// The object representing an event subscription in Mio
class MIEventSubscription : AZEventSubscription {
    /// The event this subscription is subscribed to
    var event : AZEvent = .none;
    
    /// Performs this subscription(called when the subscribed event fires)
    func perform() {
        
    }
    
    required init() {
        self.event = .none;
    }
}
