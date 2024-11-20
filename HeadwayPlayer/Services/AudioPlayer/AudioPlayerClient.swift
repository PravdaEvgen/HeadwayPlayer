//
//  AudioPlayerClient.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 19.11.2024.
//

import AVFoundation

final class AudioPlayer: AudioPlayerProtocol {
    private let player: AVPlayer
    private(set) var isPlaying = false
    private var playbackSpeed: Float = 1.0 {
        didSet {
            guard isPlaying else { return }
            player.rate = playbackSpeed
        }
    }
    
    private var currentItemObservation: NSKeyValueObservation?
    private var playerItemErrorObservation: NSKeyValueObservation?
    private var playerStatusObservation: NSKeyValueObservation?
    
    init(player: AVPlayer = .init()) {
        self.player = player
    }
    
    func load(url: URL) {
        player.pause()
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.playImmediately(atRate: playbackSpeed)
        isPlaying = true
    }
    
    func play() {
        player.playImmediately(atRate: playbackSpeed)
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        isPlaying = false
    }
    
    func seek(to value: Double) {
        let targetTime = CMTime(seconds: value, preferredTimescale: 1000)
        player.seek(to: targetTime)
    }
    
    func update(playbackSpeed: Float) {
        self.playbackSpeed = playbackSpeed
    }
    
    func jump(by seconds: Double) {
        let currentTime = itemCurrentTime()
        let newTime = currentTime + seconds
        seek(to: newTime)
    }
    
    func itemDuration() async throws -> Double {
        let duration = try await player.currentItem?.asset.load(.duration) ?? .zero
        
        return CMTimeGetSeconds(duration)
    }
    
    func itemCurrentTime() -> Double {
        let currentTime = player.currentItem?.currentTime() ?? .zero
        
        return CMTimeGetSeconds(currentTime)
    }
    
    func subscribeToErrors() -> AsyncStream<Error> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }
            
            self.currentItemObservation = player.observe(
                \.currentItem,
                 options: [.new, .initial]
            ) { [weak self] _, change in
                if let newItem = change.newValue as? AVPlayerItem {
                    self?.observeError(for: newItem, continuation: continuation)
                }
            }
            
            self.playerStatusObservation = player.observe(
                \.status,
                 options: [.new, .initial]
            ) { [weak self] _, change in
                if let self,
                    let status = change.newValue,
                    status == .failed,
                    let error = self.player.error {
                    continuation.yield(error)
                }
            }

            continuation.onTermination = { [weak self] _ in
                self?.currentItemObservation?.invalidate()
                self?.playerItemErrorObservation?.invalidate()
                self?.playerStatusObservation?.invalidate()
            }
        }
    }
}

private extension AudioPlayer {
    func observeError(for item: AVPlayerItem, continuation: AsyncStream<Error>.Continuation) {
        playerItemErrorObservation?.invalidate()
        playerItemErrorObservation = item.observe(
            \.error,
             options: [.new, .initial]
        ) { item, _ in
            if let error = item.error {
                continuation.yield(error)
            }
        }
    }
}
