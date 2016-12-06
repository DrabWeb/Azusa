//
//  AZEventSubscriber.swift
//  Azusa
//
//  Created by Ushio on 12/5/16.
//

import Foundation

/// The different types of events emitted by Azusa
enum AZEvent : Int {
    /// The default event, represents nothing
    case none
    
    /// The music player has connected
    case connect
    
    /// The music player has disconnected
    case disconnect
    
    /// The music database has been updated
    case database
    
    /// The current queue has been modified
    case queue
    
    /// The music player has been started, stopped or seeked
    case player
    
    /// The volume has been changed
    case volume
    
    /// An option like repeat, random, crossfade, etc. was modified
    case options
}

/// The basic object for managing event emission
class AZEventSubscriber {
    /// The event subscriptions to this subscriber
    var subscriptions : [AZEventSubscription] {
        return self._subscriptions;
    };
    
    /// The subscription objects to this event subscriber
    var _subscriptions : [AZEventSubscription] = [];
    
    /// Adds the given subscription to this subscriber
    ///
    /// - Parameter subscription: The subscription to subscribe with
    func add(subscription : AZEventSubscription) {
        // Add the given subscriber to `_subscriptions`
        self._subscriptions.append(subscription);
    }
    
    /// Removes the given subscription from this subscriber
    ///
    /// - Parameter subscription: The subscription to remove
    func remove(subscription : AZEventSubscription) {
        /// The index of the subscription to remove in `subscriptions`
        var removalIndex : Int = -1;
        
        // For every subscriber in `_subscriptions`...
        for(currentIndex, currentSubscription) in self._subscriptions.enumerated() {
            // If the current subscription's ID is equal to `subscription`'s...
            if(currentSubscription.uuid == subscription.uuid) {
                // Set `removalIndex` to the current index
                removalIndex = currentIndex;
            }
        }
        
        // If `removalIndex` was set...
        if(removalIndex != -1) {
            // Remove the subscription at `removalIndex` in `subscriptions`
            self._subscriptions.remove(at: removalIndex);
        }
    }

    /// Emits the given event on this subscriber
    ///
    /// - Parameter event: The event to emit
    func emit(event : AZEvent) {
        AZLogger.log("AZEventSubscriber: Emitting event AZEvent.\(event)");
        
        // For every item in `subscriptions`...
        for(_, currentSubscription) in self.subscriptions.enumerated() {
            // If the current subscription's event is equal to the emitted event
            if(currentSubscription.events.contains(event)) {
                // Perform the current subscription
                currentSubscription.perform(event: event);
            }
        }
    }
}

/// The object representing an event subscription in Mio
class AZEventSubscription {
    /// The events this subscription is subscribed to
    var events : [AZEvent] = [];
    
    /// The performer for this subscription, passed the event that triggered it
    var performer : ((AZEvent) -> ())? = nil;
    
    /// The UUID of this subscription(reset when calling an init)
    var uuid : String = NSUUID().uuidString;
    
    /// Performs this subscription(called when the subscribed event fires), should be passed the event that fired it
    ///
    /// - Parameter event: Should be the event that fired this perform
    func perform(event : AZEvent) {
        // Call the performer
        self.performer?(event);
    }
    
    init(events : [AZEvent], performer : ((AZEvent) -> ())?) {
        self.events = events;
        self.performer = performer;
        self.uuid = NSUUID().uuidString;
    }
    
    init() {
        self.events = [];
        self.performer = nil;
        self.uuid = NSUUID().uuidString;
    }
}
