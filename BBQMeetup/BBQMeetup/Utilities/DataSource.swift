//
//  DataSource.swift
//  BBQMeetup
//
//  Created by Alex Paul on 7/19/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

class DataSource: UITableViewDiffableDataSource<ItemType, Item> {
    
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sections = ItemType.allCases.sorted { $0 < $1 }
    return sections[section].rawValue
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    guard let user = Auth.auth().currentUser else {
        return false
    }
    
    if let item = itemIdentifier(for: indexPath) {
        if item.personId != user.uid {return false}
    }
    
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    guard let user = Auth.auth().currentUser else {
        return
    }
    
    if editingStyle == .delete {
      if let item = itemIdentifier(for: indexPath) {
        // client security rule to prevent accidental deletiong from another user
        if item.personId != user.uid { return }
        DatabaseService.shared.deleteItem(item: item) { [weak self] (result) in
          guard let self = self else { return }
          switch result {
          case .failure(let error):
            print(error)
          case .success:
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            self.apply(snapshot, animatingDifferences: true)
          }
        }
      }
    }
  }
}
