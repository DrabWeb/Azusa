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

/// The protocol for subscribing to music player related events in Azusa
protocol AZEventSubscriber {
    /// The event subscriptions to this subscriber
    var subscriptions : [AZEventSubscription] { get };
    
    /// The subscription objects to this event subscriber
    var _subscriptions : [AZEventSubscription] { get set };
    
    /// Adds the given subscription to this subscriber
    ///
    /// - Parameter subscriber: The subscription to subscribe with
    func add(subscriber : AZEventSubscription);
    
    /// Removes the given subscription from this subscriber
    ///
    /// - Parameter subscriber: The subscription to remove
    func remove(subscriber : AZEventSubscription);
    
    /// Emits the given event on this subscriber
    ///
    /// - Parameter event: The event to emit
    func emit(event : AZEvent);
}

/// The protocol for defining an Azusa event susbcription
protocol AZEventSubscription {
    /// The event this subscription is subscribed to
    var event : AZEvent { get set };
    
    /// Performs this subscription(called when the subscribed event fires)
    func perform();
    
    init();
}
