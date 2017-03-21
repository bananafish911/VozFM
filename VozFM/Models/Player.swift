//
//  Player.swift
//  VozFM
//
//  Created by Victor on 10/29/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import Foundation

import AVFoundation
import MediaPlayer

import Alamofire
import SwiftyJSON
import Kingfisher

import RxSwift

/// Describes audio player state
///
/// - notConfigured:            initial state, or wrong configuration
/// - paused:                   paused, or ready to play
/// - playing:                  currently playing
/// - interruptedAudio:         playback was interrupted by the incomming call or another app, etc.
/// - interruptedDueInternet:   playback was interrupted due to bad connection
/// - error:                    has been stopped by some error
enum PlayerState {
    case notConfigured, paused, playing, interruptedAudio, interruptedDueInternet, error
}

/// Radio player class
class Player: NSObject {
    
    static let shared = Player()
    
    /// tracklist, last first is the current track
    let recentTracks: Variable<[Track]> = Variable([])
    let state: Variable<PlayerState> = Variable(PlayerState.paused)
    
    private var audioPlayer: AVPlayer? // main player
    private var downloadTaskIsRunning = false
    private let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    private let disposeBag = DisposeBag()
    
    // MARK: - Methods
    
    private override init() {
        super.init()
        
        setupReachabilityObserver()
        
        // Setup audio session
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        setupMPRemoteCommandCenterCommands()
        
        registerForNSNotifications()
        
        setupNowplayingInfoService()
        setupReachabilityObserver()
    }
    
    private func setupMPRemoteCommandCenterCommands() {
        // Setup control center commands
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { (remoteEvent) -> MPRemoteCommandHandlerStatus in
            self.play()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.pauseCommand.addTarget { (remoteEvent) -> MPRemoteCommandHandlerStatus in
            self.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        commandCenter.togglePlayPauseCommand.addTarget { (remoteEvent) -> MPRemoteCommandHandlerStatus in
            if self.state.value == .playing{
                self.pause()
            } else {
                self.play()
            }
            return MPRemoteCommandHandlerStatus.success
        }
    }
    
    private func registerForNSNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(audioSessionEventNotification(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        nc.addObserver(self, selector: #selector(audioSessionDidChangeRouteNotification(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange,  object: nil)
        nc.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: audioPlayer?.currentItem)
        nc.addObserver(self, selector: #selector(playerItemPlaybackStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: audioPlayer?.currentItem)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - RX setup
    
    private func setupNowplayingInfoService() {
        recentTracks.asObservable()
            .subscribe(onNext: { (tracks) in
                if let track = tracks.first {
                    let art = MPMediaItemArtwork(image: track.image.value)
                    let info: [String : Any] = [
                        MPMediaItemPropertyTitle: track.title,
                        MPMediaItemPropertyArtist: track.artist,
                        MPMediaItemPropertyArtwork: art
                    ]
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    
                    track.image.asObservable()
                        .subscribe(onNext: { (image) in
                            var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
                            _ = info?.updateValue(MPMediaItemArtwork(image: image), forKey: MPMediaItemPropertyArtwork)
                            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                        })
                        .addDisposableTo(self.disposeBag)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Utility methods
    
    // player initialization
    private func preparePlayer() {
        // FIXME not the most elegant way
        let url = Constants.Api.AudioStreamURL
        
        objc_sync_enter(self) // just in case, preventing kvo issue
        // remove observes for metadata updates
        audioPlayer?.currentItem?.removeObserver(self, forKeyPath: "timedMetadata", context: nil)
        audioPlayer?.removeObserver(self, forKeyPath: "status", context: nil)
        
        audioPlayer?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        audioPlayer?.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
        audioPlayer?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull", context: nil)
        
        // observe for metadata updates, buffer state
        let playerItem = AVPlayerItem(url: url)
        playerItem.addObserver(self, forKeyPath: "timedMetadata", options: [.new], context: nil)
        
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: [.new], context: nil)
        // configure player:
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        objc_sync_exit(self)
    }
    
    /// Checks if currentItem's asset is playable:
    ///
    /// - Returns: true if playable
    private func isCurrentItemPlayable() -> Bool {
        guard let urlAsset = audioPlayer?.currentItem?.asset as? AVURLAsset else {
            return false
        }
        return urlAsset.isPlayable
    }
    
    // MARK: - KVO callbacks
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Player:
        if (object as? AVPlayer) === audioPlayer {
            if keyPath == "status" {
                kvoAVPlayerStatusUpdatedCallback()
            }
        }
        // Current Item:
        if (object as? AVPlayerItem) === audioPlayer?.currentItem {
            if keyPath == "timedMetadata" {
                kvoTimedMetadataUpdatedCallback()
            }
        }
    }
    
    /// AVPlayer status updated:
    private func kvoAVPlayerStatusUpdatedCallback() {
        // Check if current item URL is playable
        guard !isCurrentItemPlayable() else {
            return // seems to be OK
        }
        
        state.value = .error
        
        if UIApplication.shared.applicationState == .active {
            let okayAlert = UIAlertController.okayAlert(title: "Помилка", message: "не можу програвати, перевірте підключення до інтернету")
            okayAlert.presentOnAppRootVC()
        }
    }
    
    /// Metadata updated:
    private func kvoTimedMetadataUpdatedCallback() {
        if downloadTaskIsRunning {
            return
        }
        
        downloadTaskIsRunning = true
        getRecentTracks()
    }
    
    // MARK: - NotificationCenter callbacks
    
    /// AVPlayerItemFailedToPlayToEndTime
    @objc private func playerItemFailedToPlayToEndTime(notification: Notification) {
        if self.state.value == .playing {
            debugPrint("metadata is empty - forcing play")
            self.play()
        }
    }
    
    /// AVPlayerItemPlaybackStalled
    @objc private func playerItemPlaybackStalled(notification: Notification) {
        guard let item = notification.object as? AVPlayerItem else {
            return
        }
        debugPrint("playerItemPlaybackStalled \(item)")
    }
    
    // MARK: AVAudioSession notification
    
    /// Audiosession interruption:
    @objc private func audioSessionEventNotification(notification: Notification) {
        guard let interruptionTypeCode = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else {
            return
        }
        guard let interruption = AVAudioSessionInterruptionType(rawValue: interruptionTypeCode) else {
            return
        }
        
        switch interruption {
        case .began:
            debugPrint("interruption began")
            if self.state.value == .playing {
                self.state.value = .interruptedAudio
                self.audioPlayer?.pause()
            }
        case .ended:
            debugPrint("interruption ended")
            if state.value == .interruptedAudio {
                self.play()
            }
        }
    }
    
    @objc private func audioSessionDidChangeRouteNotification(notification: Notification) {
        guard let reasonKey = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt else {
            return
        }
        if reasonKey == AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue {
            pause()
        }
    }
    
    // MARK: - Networking here
    
    // Internet reachability service
    private func setupReachabilityObserver() {
        reachabilityManager?.listener = { status in
            
            debugPrint("reachability status changed: \(status)")
            
            if status == .notReachable {
                if self.state.value == .playing {
                    self.pause(reason: .interruptedDueInternet)
                }
            } else {
                if self.state.value == .interruptedDueInternet {
                    self.play()
                }
            }
        }
        
        // start listening
        reachabilityManager?.startListening()
    }
    
    private func getRecentTracks() {
        
        // tracks are comparable by _timestamp: Int
        // this API returns last played tracks, so we should appennd only new ones
        let fetchedTracks = recentTracksObservable().asObservable().subscribe(onNext: { [weak self] (newTracks) in
            self?.recentTracks.value.insert(contentsOf: newTracks, at: 0) // Cuz first [0] is the latest one
        }, onError: { [weak self] (error) in
            self?.downloadTaskIsRunning = false
        }, onCompleted: { [weak self] in
            // completed
            self?.downloadTaskIsRunning = false
            if let recentTracks = self?.recentTracks.value {
                self?.recentTracks.value = Array(recentTracks.suffix(30)) // limited
            }
        }, onDisposed: { [weak self] in
            self?.downloadTaskIsRunning = false
        })
        fetchedTracks.addDisposableTo(disposeBag)
    }
    
    private func recentTracksObservable() -> Observable<[Track]> {
        
        return Observable<[Track]>.create({ (observer) -> Disposable in
            // Fetch Request
            let request = Alamofire.request(Constants.Api.RecentSongs.url, parameters: Constants.Api.RecentSongs.params)
                .validate(statusCode: 200..<300)
                .responseJSON { [weak self] response in
                    if let error = response.result.error {
                        debugPrint("HTTP Request failed: \(response.result.error)")
                        observer.onError(error)
                        return
                    }
                    
                    guard let value = response.result.value, let tracks = JSON(value)["data"][0].array else {
                        debugPrint("Error parsing response result: \(response.result)")
                        observer.onError(NSError(domain: "Error", code: 0, userInfo: ["description" : "Error parsing response result: \(response.result)"]))
                        return
                    }
                    
                    // array arrives sorted: latest song is first, [0]
                    var newTracks = Array<Track>()
                    
                    for trackJson in tracks {
                        let aTrack = Track(json: trackJson)
                        newTracks.append(aTrack)
                    }
                    
                    // filter only new tracks
                    let mostRecentTimestamp = self?.recentTracks.value.first?.timeStamp ?? 0
                    newTracks = newTracks.filter({ (track) -> Bool in
                        return track.timeStamp > mostRecentTimestamp
                    })
                    
                    observer.onNext(newTracks)
                    observer.onCompleted()
            }
            
            return Disposables.create(with: {
                //Cancel the connection if disposed
                request.cancel()
            })
        })
    }
    
    // MARK: - Public methods
    
    func play() {
        // reload player
        preparePlayer()
        audioPlayer?.play()
        state.value = .playing
    }
    
    func pause(reason: PlayerState = .paused) {
        audioPlayer?.pause()
        state.value = reason
    }
    
}
