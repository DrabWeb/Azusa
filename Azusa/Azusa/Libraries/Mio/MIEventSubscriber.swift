//
//  MIEventSubscriber.swift
//  Azusa.Mio
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The event subscriber for Mio
class MIEventSubscriber : AZEventSubscriber {
    
    var subscriptions : [AZEventSubscription] {
        return self._subscriptions;
    };
    
    var _subscriptions : [AZEventSubscription] = [];
    
    func add(subscriber : AZEventSubscription) {
        
    }
    
    func remove(subscriber : AZEventSubscription) {
        
    }
    
    func emit(event : AZEvent) {
        
    }
}

/// The object representing an event subscription in Mio
class MIEventSubscription : AZEventSubscription {
    var event : AZEvent = .none;
    
    func perform() {
        
    }
    
    required init() {
        self.event = .none;
    }
}
