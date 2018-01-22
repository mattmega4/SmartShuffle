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
  
  
  //func getPermission(completion)
  
  
  func getSongsWithCurrentGenreFor(item: MPMediaItem) -> MPMediaQuery {
  
    let genreFilter = MPMediaPropertyPredicate(value: item.genre, forProperty: MPMediaItemPropertyGenre, comparisonType: MPMediaPredicateComparison.equalTo)
    let predicates: Set<MPMediaPropertyPredicate> = [genreFilter]
    let query = MPMediaQuery(filterPredicates: predicates)
    return query
  }
  
  func removeLock() {
    
  }
  
  
  

}
