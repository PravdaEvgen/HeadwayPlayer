//
//  HeadwayPlayerTests.swift
//  HeadwayPlayerTests
//
//  Created by Yevhen Pravda on 19.11.2024.
//

import ComposableArchitecture
import Testing
@testable import HeadwayPlayer

@MainActor
struct HeadwayPlayerTests {
    
    @Test
    func bookSummaryFetchOnStart() async {
        let clock = TestClock()
        let localProvider = LocalBookSummaryResources()
        let store = TestStore(initialState: BookSummaryFeature.State()) {
            BookSummaryFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        store.exhaustivity = .off
        
        await store.send(.onAppear)
        await store.receive(\.updateBookSummary) {
            $0.bookSummary = .init(coverURL: localProvider.coverURL, chapters: localProvider.chapters)
        }
    }
    
    @Test
    func bookSummaryFetchOnStartEmpty() async {
        let clock = TestClock()
        let store = TestStore(initialState: BookSummaryFeature.State()) {
            BookSummaryFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        store.exhaustivity = .off
        
        await store.send(.onAppear)
        await store.send(.updateBookSummary(nil)) {
            $0.bookSummary = nil
        }
    }

    @Test
    func errorAlertPresentedAndDismissed() async {
        let store = TestStore(initialState: BookSummaryFeature.State()) {
            BookSummaryFeature()
        }
        store.exhaustivity = .off
        
        await store.send(.error("Test error message")) {
            $0.errorAlert = AlertState {
                TextState("Error during playback occured")
            } actions: {
                ButtonState(role: .cancel) {
                  TextState("Got it!")
                }
              } message: {
                TextState("Test error message")
              }
        }
        await store.send(.errorAlert(.dismiss)) {
            $0.errorAlert = nil
        }
    }
    
    @Test
    func playingNextIsChangingIndex() async {
        let clock = TestClock()
        let store = TestStore(initialState: BookSummaryFeature.State()) {
            BookSummaryFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        store.exhaustivity = .off
        
        await store.send(.onAppear)
        await store.send(.playChapter(0))
        await store.send(.playNextChapter) {
            $0.currentIndex = 0
        }
        await store.send(.playNextChapter) {
            $0.currentIndex = 1
        }
        await store.send(.playNextChapter) {
            $0.currentIndex = 2
        }
        await store.send(.playNextChapter) {
            $0.currentIndex = 3
        }
        await store.send(.playNextChapter) {
            $0.currentIndex = 3
        }
    }
    
    @Test
    func playingPreviousIsChangingIndex() async {
        let clock = TestClock()
        let store = TestStore(initialState: BookSummaryFeature.State()) {
            BookSummaryFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        store.exhaustivity = .off
        
        await store.send(.onAppear)
        await store.send(.playChapter(3))
        await store.send(.playPreviousChapter) {
            $0.currentIndex = 3
        }
        await store.send(.playPreviousChapter) {
            $0.currentIndex = 2
        }
        await store.send(.playPreviousChapter) {
            $0.currentIndex = 1
        }
        await store.send(.playPreviousChapter) {
            $0.currentIndex = 0
        }
        await store.send(.playPreviousChapter) {
            $0.currentIndex = 0
        }
    }
    
    @Test
    func pauseIsPausingPlayIsResuming() async {
        let clock = TestClock()
        let store = TestStore(initialState: BookSummaryFeature.State()) {
            BookSummaryFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        store.exhaustivity = .off
        
        await store.send(.onAppear)
        await store.send(.playChapter(0)) {
            $0.isPlaying = true
        }
        await clock.advance(by: .seconds(2))
        await store.send(.pause) {
            $0.isPlaying = false
        }
        await store.send(.resume) {
            $0.isPlaying = true
        }
    }
    
    @Test
    func seekToValue() async {
        let clock = TestClock()
        let store = TestStore(initialState: BookSummaryFeature.State()) {
            BookSummaryFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
        store.exhaustivity = .off
        
        await store.send(.onAppear)
        await store.send(.playChapter(0))
        await store.send(.startDurationUpdateTimer)
        await store.send(.seekTo(10))
        await clock.advance(by: .seconds(10))
        await store.receive(\.updateCurrentProgress) {
            $0.currentProgress = 10
        }
    }
    
    @Test
    func updateDuration() async {
        let testAudioPlayer = MockAudioPlayer()
        let store = TestStore(initialState: BookSummaryFeature.State()) {
            BookSummaryFeature()
        } withDependencies: {
            $0[AudioPlayerKey.self] = testAudioPlayer
            $0.continuousClock = TestClock()
        }
        store.exhaustivity = .off
        
        await store.send(.onAppear)
        await store.send(.playChapter(0))
        testAudioPlayer.setDuration(10)
        await store.send(.fetchDuration)
        await store.receive(\.updateDuration) {
            $0.duration = 10
        }
    }
}
