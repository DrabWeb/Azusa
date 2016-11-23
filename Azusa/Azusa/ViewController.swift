//
//  ViewController.swift
//  Azusa
//
//  Created by Ushio on 11/22/16.
//

import Cocoa
import CocoaAsyncSocket

class ViewController: NSViewController, GCDAsyncSocketDelegate {

    /// The field for entering the address to connect to
    @IBOutlet weak var addressField: NSTextField!
    
    /// The field for entering the port to connect to
    @IBOutlet weak var portField: NSTextField!
    
    var communications : MITCPCommunications? = nil;
    
    /// When the user presses the "Run Tests" button...
    @IBAction func runTestsButtonPressed(_ sender: Any) {
        communications = MITCPCommunications(host: addressField.stringValue, port: Int(portField.intValue));
        
        communications!.connect(completionHandler: { socket in
            self.communications!.outputOf(command: "stats", completionHandler: { output in
                print("Got output:");
                print(output);
            });
        });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
