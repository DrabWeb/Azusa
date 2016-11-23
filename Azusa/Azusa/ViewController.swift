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
    
    /// The field for entering the MPD command to run
    @IBOutlet weak var commandField: NSTextField!
    
    /// A 'MITCPCommunications' object for testing
    var communications : MITCPCommunications? = nil;
    
    /// When the user presses the "Run" button...
    @IBAction func runButtonPressed(_ sender: Any) {
        // If communications is nil...
        if(communications == nil) {
            // Create the communications object with the entered address and port
            communications = MITCPCommunications(host: addressField.stringValue, port: Int(portField.intValue));
        }
        
        // Connect to the server
        communications!.connect(completionHandler: { socket in
            // Get the output of the entered command
            self.communications!.outputOf(command: self.commandField.stringValue, completionHandler: { output in
                // Display the output
//                print("Output of \"\(self.commandField.stringValue)\": \n\(output)");
                
                var outputSplitAtNewLine : [String] = output.components(separatedBy: "\n");
                
                outputSplitAtNewLine.removeFirst();
                outputSplitAtNewLine.removeLast();
                
                var cleanedOutput : String = "";
                
                for(currentIndex, currentLine) in outputSplitAtNewLine.enumerated() {
                    cleanedOutput = cleanedOutput + currentLine + ((currentIndex == (outputSplitAtNewLine.count - 1)) ? "" : "\n");
                }
                
                for(_, currentSong) in MISong.from(songList: cleanedOutput).enumerated() {
                    print(currentSong.debugDescription);
                }
            });
        });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
