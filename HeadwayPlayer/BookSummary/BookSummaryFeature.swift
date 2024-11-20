//
//  BookSummaryFeature.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 19.11.2024.
//

import Foundation
import ComposableArchitecture
import AVFoundation

@Reducer
struct BookSummaryFeature {
    @Dependency(AudioPlayerKey.self) var audioPlayer
    @Dependency(SummaryProviderKey.self) var summaryProvider
    @Dependency(\.continuousClock) var continuousClock
    
    @ObservableState
    struct State: Equatable {
        @Presents var errorAlert: AlertState<Action.ErrorAlert>?
        
        var bookSummary: BookSummary?
        var chapterMoto = ""
        var duration: Double = 0.0
        var isEditing: Bool = false
        var isPlaying = false
        var currentProgress: Double = 0.0
        var currentIndex = 0
        var playbackSpeed: Float = 1.0
        let playbackSpeeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    }

    enum Action: BindableAction {
        case errorAlert(PresentationAction<ErrorAlert>)
        case onAppear
        case updateIsEditing(Bool)
        case updateBookSummary(BookSummary?)
        case updateCurrentProgress(Double)
        case updateDuration(Double)
        case fetchDuration
        case subscribeToAudioPlayerErrors
        case startDurationUpdateTimer
        case playChapter(Int)
        case seekTo(Double)
        case jumpBy(Double)
        case playNextChapter
        case playPreviousChapter
        case pause
        case resume
        case binding(BindingAction<State>)
        case error(String)
        
        enum ErrorAlert: Equatable {}
    }

    private enum Cancellation {
        case durationUpdateTimer
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .errorAlert:
              return .none
            case .onAppear:
                return .run { send in
                    let summary = try await summaryProvider.fetchSummary()
                    await send(.updateBookSummary(summary))
                }
            case let .updateBookSummary(summary):
                state.bookSummary = summary
                return .concatenate(
                    .send(.playChapter(0)),
                    .send(.subscribeToAudioPlayerErrors),
                    .send(.startDurationUpdateTimer)
                )
            case let .playChapter(index):
                if let bookSummary = state.bookSummary,
                   bookSummary.chapters.count > index,
                   index >= 0 {
                    let chapter = bookSummary.chapters[index]
                    audioPlayer.load(url: chapter.chapterAudioURL)
                    state.isPlaying = audioPlayer.isPlaying
                    state.currentIndex = index
                    state.chapterMoto = chapter.shortMoto
                    return .send(.fetchDuration)
                }
                return .none
            case .binding(\.playbackSpeed):
                audioPlayer.update(playbackSpeed: state.playbackSpeed)
                return .none
            case .binding:
                return .none
            case .subscribeToAudioPlayerErrors:
                return .run { send in
                    for await error in audioPlayer.subscribeToErrors() {
                        await send(.error(error.localizedDescription))
                    }
                }
            case .startDurationUpdateTimer:
                return .run { [isEditing = state.isEditing] send in
                    for await _ in self.continuousClock.timer(interval: .seconds(0.5)) {
                        if audioPlayer.isPlaying,
                           !isEditing {
                            let currentTime = audioPlayer.itemCurrentTime()
                            let duration = try await audioPlayer.itemDuration()
                            let remainingTime = duration - currentTime
                            await send(.updateCurrentProgress(audioPlayer.itemCurrentTime()))
                            if duration.isFinite && remainingTime <= 0.1 {
                                await send(.pause)
                                await send(.playNextChapter)
                            }
                        }
                    }
                }
                .cancellable(id: Cancellation.durationUpdateTimer, cancelInFlight: true)
            case let .updateCurrentProgress(progress):
                state.currentProgress = progress
                return .none
            case .playNextChapter:
                let currentIndex = state.currentIndex + 1
                if let bookSummary = state.bookSummary,
                    currentIndex < bookSummary.chapters.count {
                    return .send(.playChapter(currentIndex))
                }
                
                return .none
            case .playPreviousChapter:
                let currentIndex = state.currentIndex - 1 < 0 ? 0 : state.currentIndex - 1
                return .send(.playChapter(currentIndex))
            case .pause:
                audioPlayer.pause()
                state.isPlaying = audioPlayer.isPlaying
                return .none
            case .resume:
                audioPlayer.play()
                state.isPlaying = audioPlayer.isPlaying
                return .none
            case .fetchDuration:
                return .run { send in
                    let duration = try await audioPlayer.itemDuration()
                    await send(.updateDuration(duration))
                }
            case let .updateDuration(duration):
                state.duration = duration
                return .none
            case let .updateIsEditing(isEditing):
                state.isEditing = isEditing
                return .none
            case let .error(errorDescription):
                state.errorAlert = AlertState {
                    TextState("Error during playback occured")
                } actions: {
                    ButtonState(role: .cancel) {
                      TextState("Got it!")
                    }
                  } message: {
                    TextState(errorDescription)
                  }
                  return .none
            case let .seekTo(value):
                if !state.isEditing {
                    audioPlayer.seek(to: value)
                }
                return .none
            case let .jumpBy(value):
                audioPlayer.jump(by: value)
                return .none
            }
        }
        .ifLet(\.$errorAlert, action: \.errorAlert)
    }
}
