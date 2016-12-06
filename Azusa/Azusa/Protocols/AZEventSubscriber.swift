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
    
    /// The song database has been modified after 'update'
    case database
    
    /// The music datanase has been updated
    case update
    
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
    
    /// Adds the given event subscription to this subscriber
    func add(subscriber : AZEventSubscription);
    
    /// Removes the given event subscription
    func remove(subscriber : AZEventSubscription);
    
    /// Emits the given event for this event subscriber
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
