//
//  Events.swift
//  Azusa
//
//  Created by Ushio on 2/11/17.
//

import Foundation

// MARK: - Event

enum Event : Int {
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

// MARK: - EventManager

class EventManager {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var subscriptions : [AZEventSubscription] {
        return _subscriptions;
    };
    
    // MARK: Private properties
    
    private var _subscriptions : [AZEventSubscription] = [];
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    func add(subscription : EventSubscription) {
        // TODO: Migrate over the logger
        print("EventManager: Subscribing to events \"\(subscription.events)\" with \(subscription)");
        
        self._subscriptions.append(subscription);
    }
    
    func remove(subscription : EventSubscription) {
        var removalIndex : Int = -1;
        
        for(currentIndex, currentSubscription) in self._subscriptions.enumerated() {
            if(currentSubscription.uuid == subscription.uuid) {
                removalIndex = currentIndex;
            }
        }
        
        if(removalIndex != -1) {
            print("EventManager: Removing event subscriber \(subscription)");
            
            // Remove the subscription at `removalIndex` in `subscriptions`
            self._subscriptions.remove(at: removalIndex);
        }
        else {
            print("EventManager: Failed to remove event subscriber \(subscription), was not subscribed");
        }
    }
    
    func emit(event : AZEvent) {
        AZLogger.log("EventManager: Emitting event Event.\(event)");
        
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


// MARK: - EventSubscriber

class EventSubscriber: NSObject {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    var subscriptions : [Event] = [];
    var handler : ((AZEvent) -> ())? = nil;
    var uuid : String = NSUUID().uuidString;
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    /// Performs this subscription(called when the subscribed event fires), should be passed the event that fired it
    ///
    /// - Parameter event: The event to say triggered the subscriber
    func perform(event : AZEvent) {
        self.performer?(event);
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    init(events : [AZEvent], performer : ((AZEvent) -> ())?) {
        self.events = events;
        self.performer = performer;
        self.uuid = NSUUID().uuidString;
    }
    
    override init() {
        super.init();
        
        self.events = [];
        self.performer = nil;
        self.uuid = NSUUID().uuidString;
    }
}
