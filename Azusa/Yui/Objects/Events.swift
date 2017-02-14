//
//  Events.swift
//  AzusaFramework
//
//  Created by Ushio on 2/11/17.
//

import Foundation

// MARK: - Event

public enum Event : Int {
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

public class EventManager {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public var subscribers : [EventSubscriber] {
        return _subscribers;
    };
    
    // MARK: Private properties
    
    private var _subscribers : [EventSubscriber] = [];
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    public func add(subscriber : EventSubscriber) {
        Logger.log("EventManager: Subscribing to events \"\(subscriber.subscriptions)\" with \(subscriber)");
        
        self._subscribers.append(subscriber);
    }
    
    public func remove(subscriber : EventSubscriber) {
        var removalIndex : Int = -1;
        
        for(currentIndex, currentSubscriber) in self._subscribers.enumerated() {
            if(currentSubscriber.uuid == subscriber.uuid) {
                removalIndex = currentIndex;
            }
        }
        
        if(removalIndex != -1) {
            Logger.log("EventManager: Removing event subscriber \(subscriber)");
            
            self._subscribers.remove(at: removalIndex);
        }
        else {
            Logger.log("EventManager: Failed to remove event subscriber \(subscriber), was not subscribed");
        }
    }
    
    public func emit(event : Event) {
        Logger.log("EventManager: Emitting event Event.\(event)");
        
        for(_, currentSubscriber) in self.subscribers.enumerated() {
            if(currentSubscriber.subscriptions.contains(event)) {
                currentSubscriber.perform(event: event);
            }
        }
    }
}


// MARK: - EventSubscriber

public class EventSubscriber: NSObject {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    public var subscriptions : [Event] = [];
    public var handler : ((Event) -> ())? = nil;
    public var uuid : String = NSUUID().uuidString;
    
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    /// Performs this subscription(called when the subscribed event fires), should be passed the event that fired it
    ///
    /// - Parameter event: The event to say triggered the subscriber
    public func perform(event : Event) {
        self.handler?(event);
    }
    
    
    // MARK: - Initialization and Deinitialization
    
    public init(events : [Event], performer : ((Event) -> ())?) {
        self.subscriptions = events;
        self.handler = performer;
        self.uuid = NSUUID().uuidString;
    }
    
    public override init() {
        super.init();
        
        self.subscriptions = [];
        self.handler = nil;
        self.uuid = NSUUID().uuidString;
    }
}
