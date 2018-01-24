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
  var newSongs = [MPMediaItem]()
  var playedSongs = [MPMediaItem]()
  var currentSong: MPMediaItem?
  let mediaPlayer = MPMusicPlayerApplicationController.applicationMusicPlayer   //systemMusicPlayer created lag
  var songTimer: Timer?
  var firstLaunch = true
  var lastPlayedItem: MPMediaItem?
  var volumeControlView = MPVolumeView()
  var lockStatus = -1 // 0 artist, 1 album, 2 genre, 3 all
  
  
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
    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    try? AVAudioSession.sharedInstance().setActive(true)
    MBProgressHUD.showAdded(to: view, animated: true)
    MediaManager.shared.getAllSongs { (songs) in
      guard let theSongs = songs else {
        return
      }
 
      
      
      self.newSongs = theSongs.filter({ (item) -> Bool in
        return !self.playedSongs.contains(item)
      })
      
      
     
//      let bob = MediaManager.shared.getAudioFor(item: self.newSongs)
      
      
      self.mediaPlayer.setQueue(with: MPMediaItemCollection(items: self.newSongs))
      
      self.mediaPlayer.shuffleMode = .songs
      self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
        MBProgressHUD.hide(for: self.view, animated: true)
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
    print("\(mediaPlayer.nowPlayingItem?.genre ?? "")")
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
    guard let currentItem = lastPlayedItem else {
      return
    }
    
    
   

    
    if !playedSongs.contains(currentItem) {
      playedSongs.append(currentItem)
    }
    
    // MARK: - Lock Status Logic
    
    if lockStatus == 2 {
      lockStatus = -1
      let genreQuery = MediaManager.shared.getSongsWithCurrentGenreFor(item: currentItem)
      mediaPlayer.setQueue(with: genreQuery)
      self.mediaPlayer.shuffleMode = .songs
      self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
        MBProgressHUD.hide(for: self.view, animated: true)
        self.mediaPlayer.play()
      })
    } else if lockStatus == 1 {
      lockStatus = -1
      let albumQuery = MediaManager.shared.getSongsWithCurrentAlbumFor(item: currentItem)
      mediaPlayer.setQueue(with: albumQuery)
      self.mediaPlayer.shuffleMode = .songs
      self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
        MBProgressHUD.hide(for: self.view, animated: true)
        self.mediaPlayer.play()
      })
    } else if lockStatus == 0 {
      lockStatus = -1
      let artistQuery = MediaManager.shared.getSongsWithCurrentArtistFor(item: currentItem)
      mediaPlayer.setQueue(with: artistQuery)
      self.mediaPlayer.shuffleMode = .songs
      self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
        MBProgressHUD.hide(for: self.view, animated: true)
        self.mediaPlayer.play()
      })
    }
    if lockStatus == 3 {
      lockStatus = -1
      setUpAudioPlayerAndGetSongsShuffled()
      self.mediaPlayer.prepareToPlay(completionHandler: { (error) in

        self.mediaPlayer.play()
      })
    }
    
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
    self.isPlaying ? self.mediaPlayer.prepareToPlay { (error) in
      if error != nil {
        self.mediaPlayer.play()
      } else {
        print(error?.localizedDescription ?? "")
      }
      } : mediaPlayer.pause()
    
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
    sender.isSelected = !sender.isSelected
    albumLockLabel.font = sender.isSelected ? UIFont(name: "Gill Sans-Bold", size: 20.0) : UIFont(name: "Gill Sans", size: 16.0)
    albumLockLabel.tintColor = sender.isSelected ? UIColor.init(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1.0) : UIColor.init(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    if !sender.isSelected {
      guard let currentItem = lastPlayedItem else {
        return
      }
      let albumUnlock = MediaManager.shared.removeAlbumLockFor(item: currentItem)
      mediaPlayer.setQueue(with: albumUnlock)
      lockStatus = 3
      return
    }
    lastPlayedItem = mediaPlayer.nowPlayingItem
    lockStatus = 1
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
