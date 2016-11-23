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
                print("Output of \"\(self.commandField.stringValue)\": \n\(output)");
            });
        });
        
        /// A test string for testing MISong parsing
        let songTestString : String = "file: K-On!/K-ON MHB D1/01 Cagayake! GIRLS.mp3\n" +
        "Last-Modified: 2015-06-12T17:07:42Z\n" +
        "Artist: HO-KAGO TEA TIME/Toyasaki Aki & Hisaka Youko & Satou Satomi & Kotobuki Minako\n" +
        "Album: K-ON! MUSIC HISTORY'S BOX CD1\n" +
        "Title: Cagayake! GIRLS\n" +
        "Track: 1\n" +
        "Genre: Anime\n" +
        "Date: 2013\n" +
        "Disc: 1/15\n" +
        "AlbumArtist: HO-KAGO TEA TIME\n" +
        "Time: 250\n" +
        "Pos: 0\n" +
        "Id: 47\n"
        
        /// The song from 'songTestString'
        let song : MISong = MISong(string: songTestString);
        
        // Print the song's description
        print(song.description);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
