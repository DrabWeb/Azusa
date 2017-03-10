//
//  PlayerBarController.swift
//  Azusa
//
//  Created by Ushio on 2/10/17.
//

import Cocoa
import Yui

class PlayerBarController: NSViewController {
    
    // MARK: - Properties
    
    // MARK: Public Properties
    
    /// Passed the time in seconds to seek to
    var onSeek : ((Int) -> Void)? = nil;
    
    /// Passed the current repeat mode
    var onRepeat : ((RepeatMode) -> Void)? = nil;
    
    /// Passed the current playing state
    var onPrevious : ((PlayingState) -> Void)? = nil;
    
    /// Passed the current playing state
    var onPausePlay : ((PlayingState) -> Void)? = nil;
    
    /// Passed the current playing state
    var onNext : ((PlayingState) -> Void)? = nil;
    
    /// Passed if shuffle is currently on
    var onShuffle : ((Bool) -> Void)? = nil;
    
    /// Passed the current volume
    var onVolumeChanged : ((Int) -> Void)? = nil;
    
    /// Called when the mini queue is opened
    var onQueueOpen : (() -> Void)? = nil;
    
    var timeDisplayMode : TimeDisplayMode = .timeLeft {
        didSet {
            refreshProgress();
        }
    }
    
    var isQueueOpen : Bool {
        return miniQueue != nil;
    }
    
    var canSkipPrevious : Bool {
        get {
            return previousButton.isEnabled;
        }
        set {
            previousButton.isEnabled = newValue;
        }
    }
    
    var canSkipNext : Bool {
        get {
            return nextButton.isEnabled;
        }
        set {
            nextButton.isEnabled = newValue;
        }
    }
    
    // MARK: Private Properties
    
    private var playingState : PlayingState = .stopped;
    private var repeatMode : RepeatMode = .none;
    private var shuffling : Bool = false;
    private var song : Song? = nil;
    private weak var miniQueue : MiniQueueController? = nil;
    
    private var volume : Int {
        get {
            return volumeSlider.integerValue;
        }
        set {
            volumeSlider.integerValue = newValue;
        }
    }
    
    private var progress : Int {
        return progressSlider.integerValue;
    }
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var progressLabel: NSTextField!
    @IBOutlet private weak var progressSlider: NSSlider!
    @IBOutlet private weak var coverImageView: NSImageView!
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var artistAlbumLabel: NSTextField!
    @IBOutlet private weak var repeatButton: NSButton!
    @IBOutlet private weak var previousButton: NSButton!
    @IBOutlet private weak var pausePlayButton: NSButton!
    @IBOutlet private weak var nextButton: NSButton!
    @IBOutlet private weak var shuffleButton: NSButton!
    @IBOutlet private weak var volumeSlider: NSSlider!
    
    // MARK: IBActions
    
    @IBAction private func progressSlider(_ sender: NSSlider) {
        // Released
        if(NSApp.currentEvent!.type == NSEventType.leftMouseUp) {
            invokeOnSeek();
        }
        // Dragging
        else {
            display(progress: sender.integerValue);
        }
    }
    
    @IBAction private func repeatButton(_ sender: NSButton) {
        invokeOnRepeat();
    }
    
    @IBAction private func previousButton(_ sender: NSButton) {
        invokeOnPrevious();
    }
    
    @IBAction private func pausePlayButton(_ sender: NSButton) {
        invokeOnPausePlay();
    }
    
    @IBAction private func nextButton(_ sender: NSButton) {
        invokeOnNext();
    }
    
    @IBAction private func shuffleButton(_ sender: NSButton) {
        invokeOnShuffle();
    }
    
    @IBAction private func volumeSlider(_ sender: NSSlider) {
        invokeOnVolumeChanged();
    }
    
//    @IBAction private func volumeMinButton(_ sender: NSButton) {
//        volumeSlider.doubleValue = volumeSlider.minValue;
//        invokeOnVolumeChanged();
//    }
//    
//    @IBAction private func volumeMaxButton(_ sender: NSButton) {
//        volumeSlider.doubleValue = volumeSlider.maxValue;
//        invokeOnVolumeChanged();
//    }
    
    // MARK: - Methods
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        refresh();
    }
    
    func display(queue : [Song]) {
        miniQueue?.songs = queue;
    }
    
    func display(status : PlayerStatus) {
        display(song: status.currentSong);
        volume = status.volume;
        display(repeatMode: status.repeatMode);
        display(shuffling: status.isRandom);
        display(playingState: status.playingState);
        display(progress: status.elapsedTime);
    }
    
    func display(song : Song) {
        self.song = song;
        
        ArtworkCache.global.getArt(of: song, withSize: .thumb, completion: { cover in
            if self.song != nil  {
                if self.song! == song {
                    self.coverImageView.image = cover;
                }
            }
        });
        titleLabel.stringValue = song.displayTitle;
        artistAlbumLabel.stringValue = "\(song.displayArtist) - \(song.displayAlbum)";
        progressSlider.maxValue = Double(song.duration);
        refreshProgress();
    }
    
    func display(progress : Int) {
        progressSlider.integerValue = progress;
        
        switch timeDisplayMode {
            case .timeLeft:
                progressLabel.stringValue = "\(MusicUtilities.displayTime(from: progress)) / -\(MusicUtilities.displayTime(from: (song?.duration ?? 0) - progress))";
                break;
            
            case .duration:
                progressLabel.stringValue = "\(MusicUtilities.displayTime(from: progress)) / \(MusicUtilities.displayTime(from: song?.duration ?? 0))";
                break;
        }
    }
    
    func display(playingState : PlayingState) {
        self.playingState = playingState;
        
        switch playingState {
            case .stopped,  .paused:
                pausePlayButton.image = NSImage(named: "Play")!;
                break;
            
            case .playing:
                pausePlayButton.image = NSImage(named: "Pause")!;
                break;
        }
    }
    
    func display(repeatMode : RepeatMode) {
        self.repeatMode = repeatMode;
        
        switch repeatMode {
            case .none:
                repeatButton.image = NSImage(named: "Repeat")!;
                repeatButton.alphaValue = 0.5;
                break;
            
            case .queue:
                repeatButton.image = NSImage(named: "Repeat")!;
                repeatButton.alphaValue = 1.0;
                break;
            
            case .single:
                repeatButton.image = NSImage(named: "RepeatSingle")!;
                repeatButton.alphaValue = 1.0;
                break;
        }
    }
    
    func display(shuffling : Bool) {
        self.shuffling = shuffling;
        
        shuffleButton.alphaValue = shuffling ? 1.0 : 0.5;
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let mq = segue.destinationController as? MiniQueueController {
            miniQueue = mq;
            mq.loadView();
            onQueueOpen?();
        }
    }
    
    // MARK: Private methods
    
    /// Refreshes the views to match the stored values
    private func refresh() {
        display(playingState: playingState);
        display(repeatMode: repeatMode);
        display(shuffling: shuffling);
        refreshProgress();
        
        if song != nil {
            display(song: song!);
        }
    }
    
    private func refreshProgress() {
        display(progress: progress);
    }
    
    private func invokeOnSeek() {
        onSeek?(progress);
    }
    
    private func invokeOnRepeat() {
        onRepeat?(repeatMode);
    }
    
    private func invokeOnPrevious() {
        onPrevious?(playingState);
    }
    
    private func invokeOnPausePlay() {
        onPausePlay?(playingState);
    }
    
    private func invokeOnNext() {
        onNext?(playingState);
    }
    
    private func invokeOnShuffle() {
        onShuffle?(shuffling);
    }
    
    private func invokeOnVolumeChanged() {
        onVolumeChanged?(volume);
    }
}

enum TimeDisplayMode {
    case timeLeft, duration
}
