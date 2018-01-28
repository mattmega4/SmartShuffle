//
//  TempFile.swift
//  SmartShuffle
//
//  Created by Matthew Howes Singleton on 1/24/18.
//  Copyright © 2018 Matthew Howes Singleton. All rights reserved.
//

import Foundation


/*  if let currentItem = lastPlayedItem {
 if lockStatus != -1  {
 
 // MARK: - Lock Status Logic
 
 if lockStatus == 2 {
 lockStatus = -1
 print("Lock status 2")
 let genreQuery = MediaManager.shared.getSongsWithCurrentGenreFor(item: currentItem)
 if let songs = genreQuery.items {
 let filteredSongs = songs.filter({ (item) -> Bool in
 return !self.playedSongs.contains(item)
 })
 if filteredSongs.count > 0 {
 mediaPlayer.setQueue(with: MPMediaItemCollection(items: filteredSongs))
 //            self.mediaPlayer.shuffleMode = .songs
 self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
 DispatchQueue.main.async {
 MBProgressHUD.hide(for: self.view, animated: true)
 }
 self.mediaPlayer.play()
 })
 }
 }
 
 } else if lockStatus == 1 {
 lockStatus = -1
 print("Lock status 1")
 let albumQuery = MediaManager.shared.getSongsWithCurrentAlbumFor(item: currentItem)
 if let songs = albumQuery.items {
 let filteredSongs = songs.filter({ (item) -> Bool in
 return !self.playedSongs.contains(item)
 })
 if filteredSongs.count > 0 {
 mediaPlayer.setQueue(with: MPMediaItemCollection(items: filteredSongs))
 //            self.mediaPlayer.shuffleMode = .songs
 self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
 DispatchQueue.main.async {
 MBProgressHUD.hide(for: self.view, animated: true)
 }
 self.mediaPlayer.play()
 })
 }
 }
 } else if lockStatus == 0 {
 lockStatus = -1
 print("Lock status 0")
 let artistQuery = MediaManager.shared.getSongsWithCurrentArtistFor(item: currentItem)
 if let songs = artistQuery.items {
 let filteredSongs = songs.filter({ (item) -> Bool in
 return !self.playedSongs.contains(item)
 })
 if filteredSongs.count > 0 {
 mediaPlayer.setQueue(with: MPMediaItemCollection(items: filteredSongs))
 //            self.mediaPlayer.shuffleMode = .songs
 self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
 DispatchQueue.main.async {
 MBProgressHUD.hide(for: self.view, animated: true)
 }
 self.mediaPlayer.play()
 })
 }
 }
 }
 if lockStatus == 3 {
 lockStatus = -1
 print("Lock status 3")
 setUpAudioPlayerAndGetSongsShuffled()
 self.mediaPlayer.prepareToPlay(completionHandler: { (error) in
 
 self.mediaPlayer.play()
 })
 }
 }
 else if let nowPlaying = mediaPlayer.nowPlayingItem {
 if !playedSongs.contains(nowPlaying) {
 playedSongs.append(nowPlaying)
 } else {
 resetLockButtonsAndLabels()
 
 MediaManager.shared.removeAlbumLockFor(item: currentItem)
 MediaManager.shared.removeArtistLockFor(item: currentItem)
 MediaManager.shared.removeGenreLockFor(item: currentItem)
 //        self.setUpAudioPlayerAndGetSongsShuffled()
 }
 }
 }
 if let nowPlaying = mediaPlayer.nowPlayingItem {
 if !playedSongs.contains(nowPlaying) {
 playedSongs.append(nowPlaying)
 }
 }*/






/*albumLockLabel.font = sender.isSelected ? UIFont(name: "Gill Sans-Bold", size: 20.0) : UIFont(name: "Gill Sans", size: 16.0)
 albumLockLabel.tintColor = sender.isSelected ? UIColor.init(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1.0) : UIColor.init(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1.0)
 if !sender.isSelected {
 guard let currentItem = lastPlayedItem else {
 return
 }
 let albumUnlock = MediaManager.shared.removeAlbumLockFor(item: currentItem)
 mediaPlayer.setQueue(with: albumUnlock)
 lockStatus = 3
 return
 }*/




//    if let songs = albumQuery.items {
//      let filteredSongs = songs.filter({ (item) -> Bool in
//        return !self.playedSongs.contains(item)
//      })
//      if filteredSongs.count > 0 {
//        let descriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: MPMediaItemCollection(items: filteredSongs))
//        mediaPlayer.prepend(descriptor)
// }

//}

//lastPlayedItem = mediaPlayer.nowPlayingItem
//lockStatus = 1



