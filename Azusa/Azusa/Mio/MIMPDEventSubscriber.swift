//
//  MIMPDEventSubscriber.swift
//  Azusa.Mio
//
//  Created by Ushio on 11/25/16.
//

import Foundation

/// Reperesents an MPD event subscriber
class MIMPDEventSubscriber {
    
    // Variables
    
    /// The closure to call when the event fires
    var eventHandler : ((MIMPDEvent) -> ())? = nil;
    
    /// The events that this item is subscribed to
    var subscriptions : [MIMPDEvent] = [];
    
    /// The UUID of this subscriber(used for comparison checks)
    var uuid : String = NSUUID().uuidString;
    
    func equals(_ comparison : MIMPDEventSubscriber) -> Bool {
        return (self.uuid == comparison.uuid);
    }
    
    // Init
    
    // Init with an event handler and event type
    init(eventHandler : @escaping ((MIMPDEvent) -> ()), subscriptions : [MIMPDEvent]) {
        self.eventHandler = eventHandler;
        self.subscriptions = subscriptions;
        self.uuid = NSUUID().uuidString;
    }
    
    // Blank init
    init() {
        self.eventHandler = nil;
        self.subscriptions = [];
        self.uuid = NSUUID().uuidString;
    }
}
