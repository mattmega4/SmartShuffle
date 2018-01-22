//
//  MediaManager.swift
//  SmartShuffle
//
//  Created by Matthew Howes Singleton on 1/20/18.
//  Copyright © 2018 Matthew Howes Singleton. All rights reserved.
//

import UIKit
import MediaPlayer


class MediaManager: NSObject {
  
  static let shared = MediaManager()
  
  // MARK: - Get All Song Logic
  
  func getAllSongs(completion: @escaping (_ songs: [MPMediaItem]?) -> Void) {
    MPMediaLibrary.requestAuthorization { (status) in
      if status == .authorized {
        let query = MPMediaQuery.songs()
        let songs = query.items
        completion(songs)
      } else {
        completion(nil)
      }
    }
  }

  
  // MARK: - Album Lock Logic
  
  func getSongsWithCurrentAlbumFor(item: MPMediaItem) -> MPMediaQuery {
    let albumFilter = MPMediaPropertyPredicate(value: item.albumTitle, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: MPMediaPredicateComparison.equalTo)
    let predicates: Set<MPMediaPropertyPredicate> = [albumFilter]
    let query = MPMediaQuery(filterPredicates: predicates)
    return query
  }
  
  // MARK: - Artist Lock Logic
  
  func getSongsWithCurrentArtistFor(item: MPMediaItem) -> MPMediaQuery {
    let artistFilter = MPMediaPropertyPredicate(value: item.artist, forProperty: MPMediaItemPropertyArtist, comparisonType: MPMediaPredicateComparison.equalTo)
    let predicates: Set<MPMediaPropertyPredicate> = [artistFilter]
    let query = MPMediaQuery(filterPredicates: predicates)
    return query
  }
  
  // MARK: - Genre Lock Logic
  
  func getSongsWithCurrentGenreFor(item: MPMediaItem) -> MPMediaQuery {
    let genreFilter = MPMediaPropertyPredicate(value: item.genre, forProperty: MPMediaItemPropertyGenre, comparisonType: MPMediaPredicateComparison.equalTo)
    let predicates: Set<MPMediaPropertyPredicate> = [genreFilter]
    let query = MPMediaQuery(filterPredicates: predicates)
    return query
  }
  

  

  
  
  

}
