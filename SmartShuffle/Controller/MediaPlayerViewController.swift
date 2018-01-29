//
//  MediaPlayerViewController.swift
//  SmartShuffle
//
//  Created by Matthew Howes Singleton on 1/16/18.
//  Copyright © 2018 Matthew Howes Singleton. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import MBProgressHUD


class MediaPlayerViewController: UIViewController {
  
  @IBOutlet weak var albumArtImageView: UIImageView!
  @IBOutlet weak var songProgressView: UIProgressView!
  @IBOutlet weak var songProgressSlider: UISlider!
  @IBOutlet weak var songTimePlayedLabel: UILabel!
  @IBOutlet weak var songTimeRemainingLabel: UILabel!
  @IBOutlet weak var songNameLabel: UILabel!
  @IBOutlet weak var songArtistLabel: UILabel!
  @IBOutlet weak var songAlbumLabel: UILabel!
  @IBOutlet weak var rewindSongButton: UIButton!
  @IBOutlet weak var playPauseSongButton: UIButton!
  @IBOutlet weak var forwardSongButton: UIButton!
  @IBOutlet weak var volumeLessIconImageView: UIImageView!
  @IBOutlet weak var volumeView: UIView!
  @IBOutlet weak var volumeMoreIconImageView: UIImageView!
  @IBOutlet weak var albumLockIconButton: UIButton!
  @IBOutlet weak var albumLockLabel: UILabel!
  @IBOutlet weak var artistLockIconButton: UIButton!
  @IBOutlet weak var artistLockLabel: UILabel!
  @IBOutlet weak var genreLockIconButton: UIButton!
  @IBOutlet weak var genreLockLabel: UILabel!
  
  
  var isPlaying = false
  var albumIsLocked = false
  var artistIsLocked = false
  var genreIsLocked = false
  
  // idea
  var albumQuery: MPMediaQuery?
  var artistQuery: MPMediaQuery?
  var genreQuery: MPMediaQuery?
  // idea
  
  var newSongs = [MPMediaItem]()
  var currentSong: MPMediaItem?
  let mediaPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
  //  let mediaPlayer = MPMusicPlayerApplicationController.applicationMusicPlayer
  var songTimer: Timer?
  var firstLaunch = true
  var lastPlayedItem: MPMediaItem?
  var volumeControlView = MPVolumeView()
  var lockStatus = -1
  var counter = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mediaPlayer.beginGeneratingPlaybackNotifications()
    NotificationCenter.default.addObserver(self, selector: #selector(songChanged(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    
    albumArtImageView.createRoundedCorners()
    setUpAudioPlayerAndGetSongsShuffled()
    clearSongInfo()
    songProgressSlider.addTarget(self, action: #selector(playbackSlider(_:)), for: .valueChanged)
    volumeControlView.showsVolumeSlider = true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if volumeView.subviews.count == 0 {
      let myVolumeView = MPVolumeView(frame: volumeView.bounds)
      volumeView.addSubview(myVolumeView)
    }
  }
  
  
  // MARK: - Initial Audio Player setup Logic
  
  func setUpAudioPlayerAndGetSongsShuffled() {
    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
    try? AVAudioSession.sharedInstance().setActive(true)
    MBProgressHUD.showAdded(to: view, animated: true)
    MediaManager.shared.getAllSongs { (songs) in
      guard let theSongs = songs else {
        return
      }
      
      self.newSongs = theSongs.filter({ (item) -> Bool in
        return !MediaManager.shared.playedSongs.contains(item)
      })
      
      self.mediaPlayer.setQueue(with: MPMediaItemCollection(items: self.newSongs))
      self.mediaPlayer.shuffleMode = .songs
      self.mediaPlayer.repeatMode = .none
      self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
        DispatchQueue.main.async {
          MBProgressHUD.hide(for: self.view, animated: true)
        }
      })
    }
  }
  
  
  // MARK: - Playback Slider
  
  @objc func playbackSlider(_ slider: UISlider) {
    if slider == songProgressSlider {
      mediaPlayer.currentPlaybackTime = Double(slider.value)
    }
  }
  
  
  // MARK: - Logic for Song Change & NSNotification
  
  @objc func songChanged(_ notification: Notification) {
    counter += 1
     if counter < 3 {
     return
     }

    songProgressSlider.maximumValue = Float(mediaPlayer.nowPlayingItem?.playbackDuration ?? 0)
    songProgressSlider.minimumValue = 0
    songProgressSlider.value = 0
    songProgressView.progress = 0
    songTimePlayedLabel.text = getTimeElapsed()
    songTimeRemainingLabel.text = getTimeRemaining()
    
    if !firstLaunch {
      getCurrentlyPlayedInfo()
    } else {
      firstLaunch = false
    }
    rewindSongButton.isEnabled = mediaPlayer.indexOfNowPlayingItem != 0
    
    if let nowPlaying = mediaPlayer.nowPlayingItem {
      albumLockIconButton.isEnabled = MediaManager.shared.getSongsWithCurrentAlbumFor(item: nowPlaying).items?.count ?? 0 > 1
      MediaManager.shared.playedSongs.append(nowPlaying)

      if self.albumIsLocked || self.artistIsLocked || self.genreIsLocked {
        MediaManager.shared.lockedSongs.append(nowPlaying)
      }
      
      if albumIsLocked && MediaManager.shared.hasPlayedAllSongsFromAlbumFor(song: nowPlaying) {
        albumLockButtonTapped(albumLockIconButton)
        MediaManager.shared.lockedSongs.removeAll()
      }
      if artistIsLocked && MediaManager.shared.hasPlayedAllSongsFromArtistFor(song: nowPlaying) {
        artistLockButtonTapped(artistLockIconButton)
         MediaManager.shared.lockedSongs.removeAll()
      }
      if genreIsLocked && MediaManager.shared.hasPlayedAllSongsFromGenreFor(song: nowPlaying) {
        genreLockButtonTapped(genreLockIconButton)
         MediaManager.shared.lockedSongs.removeAll()
      }
      
    }
    
  }
  
  // MARK: - Reset Buttons and Labels
  
  func resetLockButtonsAndLabels() {
    self.albumLockIconButton.isSelected = false
    self.genreLockIconButton.isSelected = false
    self.albumLockIconButton.isSelected = false
    self.albumLockLabel.font = UIFont(name: "Gill Sans", size: 15.0)
    self.artistLockLabel.font = UIFont(name: "Gill Sans", size: 15.0)
    self.genreLockLabel.font = UIFont(name: "Gill Sans", size: 15.0)
    self.albumLockLabel.tintColor = UIColor.init(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    self.artistLockLabel.tintColor = UIColor.init(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    self.genreLockLabel.tintColor = UIColor.init(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1.0)
  }
  
  
  // MARK: - Clear Song Info
  
  func clearSongInfo() {
    albumArtImageView.image = #imageLiteral(resourceName: "testAlbumCover")
    songNameLabel.text = ""
    songArtistLabel.text = ""
    songAlbumLabel.text = ""
  }
  
  
  // MARK: - Song Remaining & Duration Logic
  
  func getTimeRemaining() -> String {
    let secondsRemaining = songProgressSlider.maximumValue - songProgressSlider.value
    let minutes = Int(secondsRemaining / 60)
    let seconds = String(format: "%02d", Int(secondsRemaining - Float(60  * minutes)))
    return "\(minutes):\(seconds)"
  }
  
  func getTimeElapsed() -> String {
    let secondsElapsed = songProgressSlider.value
    let minutes = Int(secondsElapsed / 60)
    let seconds = String(format: "%02d", Int(secondsElapsed - Float(60  * minutes)))
    return "\(minutes):\(seconds)"
  }
  
  func updateCurrentPlaybackTime() {
    let elapsedTime = mediaPlayer.currentPlaybackTime
    songProgressSlider.value = Float(elapsedTime)
    songProgressView.progress = Float(elapsedTime / Double(songProgressSlider.maximumValue))
    songTimePlayedLabel.text = getTimeElapsed()
    songTimeRemainingLabel.text = getTimeRemaining()
  }
  
  
  // MARK: - Song Metadata Logic
  
  func getCurrentlyPlayedInfo() {
    
    if let songTitle = mediaPlayer.nowPlayingItem?.title {
      songNameLabel.text = songTitle
    } else {
      songNameLabel.text = ""
    }
    if let songArtist = mediaPlayer.nowPlayingItem?.artist {
      songArtistLabel.text = songArtist
    } else {
      songArtistLabel.text = ""
    }
    if let songAlbum = mediaPlayer.nowPlayingItem?.albumTitle {
      songAlbumLabel.text = songAlbum
    } else {
      songAlbumLabel.text = ""
    }
    if let artwork = mediaPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 400, height: 400)) {
      self.albumArtImageView.image = artwork
    } else {
      self.albumArtImageView.image = #imageLiteral(resourceName: "testAlbumCover")
    }
  }
  
  
  // MARK: - IB Actions
  
  // MARK: - Song Control Button Actions
  
  @IBAction func rewindSongButtonTapped(_ sender: UIButton) {
    
    let secondsElapsed = songProgressSlider.value
    let minutes = Int(secondsElapsed / 60)
    let seconds = Int(secondsElapsed - Float(60  * minutes))
    if seconds < 5 {
      mediaPlayer.skipToPreviousItem()
    } else {
      mediaPlayer.skipToBeginning()
    }
    
    
//    mediaPlayer.skipToPreviousItem()
    
    
    getCurrentlyPlayedInfo()
  }
  
  
  @IBAction func forwardSongButtonTapped(_ sender: UIButton) {
    mediaPlayer.skipToNextItem()
    getCurrentlyPlayedInfo()
    
  }
  
  @IBAction func playPauseSongButtonTapped(_ sender: UIButton) {
    isPlaying = !isPlaying
    sender.isSelected = isPlaying
    
    self.isPlaying ? self.mediaPlayer.play() : self.mediaPlayer.pause()
    
    getCurrentlyPlayedInfo()
    if isPlaying {
      songTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
        self.updateCurrentPlaybackTime()
      })
    } else {
      songTimer?.invalidate()
    }
  }
  
  
  // MARK: - Smart Shuffle Button Actions
  
  @IBAction func albumLockButtonTapped(_ sender: UIButton) {
    if let nowPlaying = mediaPlayer.nowPlayingItem {
      if sender.isSelected {
        sender.isSelected = false
        albumIsLocked = false
        let lockRemovedQuery = MediaManager.shared.removeAlbumLockFor(item: nowPlaying)
        let lockRemovedDescriptor = MPMusicPlayerMediaItemQueueDescriptor(query: lockRemovedQuery)
        mediaPlayer.prepend(lockRemovedDescriptor)
        mediaPlayer.prepareToPlay()
      } else {
        sender.isSelected = true
        albumIsLocked = true
        let albumQuery = MediaManager.shared.getSongsWithCurrentAlbumFor(item: nowPlaying)
        let albumDescriptor = MPMusicPlayerMediaItemQueueDescriptor(query: albumQuery)
        mediaPlayer.prepend(albumDescriptor)
        mediaPlayer.prepareToPlay()
      }
    }
  }
  
  
  @IBAction func artistLockButtonTapped(_ sender: UIButton) {
    if let nowPlaying = mediaPlayer.nowPlayingItem {
      if sender.isSelected {
        sender.isSelected = false
        artistIsLocked = false
        let lockRemovedQuery = MediaManager.shared.removeArtistLockFor(item: nowPlaying)
        let lockRemovedDescriptor = MPMusicPlayerMediaItemQueueDescriptor(query: lockRemovedQuery)
        mediaPlayer.prepend(lockRemovedDescriptor)
        mediaPlayer.prepareToPlay()
      } else {
        sender.isSelected = true
        artistIsLocked = true
        let artistQuery = MediaManager.shared.getSongsWithCurrentAlbumFor(item: nowPlaying)
        let artistDescriptor = MPMusicPlayerMediaItemQueueDescriptor(query: artistQuery)
        mediaPlayer.prepend(artistDescriptor)
        mediaPlayer.prepareToPlay()
      }
    }
  }
  
  
  @IBAction func genreLockButtonTapped(_ sender: UIButton) {
    if let nowPlaying = mediaPlayer.nowPlayingItem {
      if sender.isSelected {
        sender.isSelected = false
        genreIsLocked = false
        let lockRemovedQuery = MediaManager.shared.removeGenreLockFor(item: nowPlaying)
        let lockRemovedDescriptor = MPMusicPlayerMediaItemQueueDescriptor(query: lockRemovedQuery)
        mediaPlayer.prepend(lockRemovedDescriptor)
        mediaPlayer.prepareToPlay()
      } else {
        sender.isSelected = true
        albumIsLocked = true
        let genreQuery = MediaManager.shared.getSongsWithCurrentGenreFor(item: nowPlaying)
        let genreDescriptor = MPMusicPlayerMediaItemQueueDescriptor(query: genreQuery)
        mediaPlayer.prepend(genreDescriptor)
        mediaPlayer.prepareToPlay()
      }
    }
  }
  
  
}



// MARK: - AVAudioPlayerDelegate Extension

extension MediaPlayerViewController: AVAudioPlayerDelegate {
  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    print("error")
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    print("finished playing")
    
  }

}
