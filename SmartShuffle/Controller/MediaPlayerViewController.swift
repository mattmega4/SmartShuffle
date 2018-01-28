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
  var newSongs = [MPMediaItem]()
  var playedSongs = [MPMediaItem]()
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
        return !self.playedSongs.contains(item)
      }).shuffled()
      
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
    /*counter += 1
     if counter < 3 {
     return
     }*/
    print("############## Song Changed ################")
    print("\(mediaPlayer.nowPlayingItem?.title ?? "")")
    
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
    
    
    if albumIsLocked == true {
      // if count of songs played while on album is greater than or equal to album total count then unlock....
    }
    
    
    
    // TODO: - Moved to line 12
    
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
    mediaPlayer.skipToPreviousItem()
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
    // moved to line 110
  }
  
  
  @IBAction func artistLockButtonTapped(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    artistLockLabel.font = sender.isSelected ? UIFont(name: "Gill Sans-Bold", size: 15.0) : UIFont(name: "Gill Sans", size: 15.0)
    artistLockLabel.tintColor = sender.isSelected ? UIColor.init(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1.0) : UIColor.init(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    if !sender.isSelected {
      guard let currentItem = lastPlayedItem else {
        return
      }
      let artistUnlock = MediaManager.shared.removeArtistLockFor(item: currentItem)
      mediaPlayer.setQueue(with: artistUnlock)
      lockStatus = 3
      return
    }
    lastPlayedItem = mediaPlayer.nowPlayingItem
    lockStatus = 0
  }
  
  
  @IBAction func genreLockButtonTapped(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    genreLockLabel.font = sender.isSelected ? UIFont(name: "Gill Sans-Bold", size: 15.0) : UIFont(name: "Gill Sans", size: 15.0)
    genreLockLabel.tintColor = sender.isSelected ? UIColor.init(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1.0) : UIColor.init(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    
    if !sender.isSelected {
      guard let currentItem = lastPlayedItem else {
        return
      }
      let genreUnlock = MediaManager.shared.removeGenreLockFor(item: currentItem)
      mediaPlayer.setQueue(with: genreUnlock)
      lockStatus = 3
      return
    }
    lastPlayedItem = mediaPlayer.nowPlayingItem
    lockStatus = 2
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

extension Sequence {
  /// Returns an array with the contents of this sequence, shuffled.
  func shuffled() -> [Element] {
    var result = Array(self)
    result.shuffle()
    return result
  }
}

extension MutableCollection {
  /// Shuffles the contents of this collection.
  mutating func shuffle() {
    let c = count
    guard c > 1 else { return }
    
    for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
      let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
      let i = index(firstUnshuffled, offsetBy: d)
      swapAt(firstUnshuffled, i)
    }
  }
}


