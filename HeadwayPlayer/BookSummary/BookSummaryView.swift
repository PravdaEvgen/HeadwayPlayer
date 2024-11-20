//
//  BookSummaryView.swift
//  HeadwayPlayer
//
//  Created by Yevhen Pravda on 18.11.2024.
//

import SwiftUI
import ComposableArchitecture

struct BookSummaryView: View {
    @Bindable var store: StoreOf<BookSummaryFeature>
    
    var body: some View {
        VStack(spacing: Constants.defaultSpacing) {
            bookCoverImage()
            if !chapterCountTitle.isEmpty {
                mottoView()
            }
            slider()
                .padding(.horizontal)
            playerControls()
            playbackSpeedPicker()
        }
        .padding()
        .alert($store.scope(state: \.errorAlert, action: \.errorAlert))
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private func bookCoverImage() -> some View {
        AsyncImage(url: store.bookSummary?.coverURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: Constants.imageSize.width, height: Constants.imageSize.height)
    }
    
    private func mottoView() -> some View {
        Group {
            Text(chapterCountTitle)
                .font(.subheadline)
                .foregroundStyle(.gray)
            Text(store.chapterMoto)
                .padding(.horizontal)
        }
    }
    
    private func slider() -> some View {
        HStack {
            Text(store.currentProgress.formatTime())
                .frame(width: Constants.durationWidth)
            Slider(
                value: $store.currentProgress,
                in: 0...store.duration,
                onEditingChanged: { isEditing in
                    store.send(.updateIsEditing(isEditing))
                    store.send(.seekTo(store.currentProgress))
                }
            )
            Text(store.duration.formatTime())
                .frame(width: Constants.durationWidth)
        }
    }
    
    private func playerControls() -> some View {
        HStack(spacing: Constants.defaultSpacing) {
            Button {
                store.send(.playPreviousChapter)
            } label: {
                Image(systemName: "backward.fill")
                    .font(Constants.buttonDefaultFont)
                    .foregroundStyle(.black)
            }
            
            Button {
                store.send(.jumpBy(-5))
            } label: {
                Image(systemName: "gobackward.5")
                    .font(Constants.buttonDefaultFont)
                    .foregroundStyle(.black)
            }
            
            Button {
                if store.isPlaying {
                    store.send(.pause)
                } else {
                    store.send(.resume)
                }
            } label: {
                Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                    .font(Constants.playPauseButtonFont)
                    .foregroundStyle(.black)
            }
            
            Button {
                store.send(.jumpBy(10))
            } label: {
                Image(systemName: "goforward.10")
                    .font(Constants.buttonDefaultFont)
                    .foregroundStyle(.black)
            }

            Button {
                store.send(.playNextChapter)
            } label: {
                Image(systemName: "forward.fill")
                    .font(Constants.buttonDefaultFont)
                    .foregroundStyle(.black)
            }
        }
    }
    
    private func playbackSpeedPicker() -> some View {
        Picker("", selection: $store.playbackSpeed) {
            ForEach(store.playbackSpeeds, id: \.self) { speed in
                Text(String(format: "Speed %.1fx", speed))
                    .tag(speed)
            }
        }
        .tint(.black)
        .labelsHidden()
        .pickerStyle(.automatic)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
        )
    }
    
    private var chapterCountTitle: String {
        var result = ""
        if let bookSummary = store.bookSummary, !bookSummary.chapters.isEmpty {
            result = "Key point \(store.currentIndex + 1) of \(bookSummary.chapters.count)"
        }
        
        return result
    }
}

private extension BookSummaryView {
    enum Constants {
        static let defaultSpacing: CGFloat = 20
        static let durationWidth: CGFloat = 50
        static let imageSize: CGSize = CGSize(width: 200, height: 300)
        static let playPauseButtonFont: Font = .system(size: 40, weight: .bold)
        static let buttonDefaultFont: Font = .system(size: 25, weight: .medium)
    }
    
}
