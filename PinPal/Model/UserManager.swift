//
//  UserManager.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserManager {
    var accountName = String()
    
    let db = Firestore.firestore()
    
    func getUserDisplayName(completion: @escaping (String) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users")
            .whereField("uid", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion("")
                } else {
                    print(snapshot!.documents)
                    for document in snapshot!.documents {
                        let data = document.data()
                        let displayName = data["display_name"] as? String ?? "user"
                        self.accountName = displayName
                        
                        completion(displayName)
                    }
                }
            }
    }
    
    func updateAccount(displayName: String, userID: String) {
        
        // アップデートするデータを作成する
        var data: [String: Any] = [
            "display_name": displayName
        ]
        
        // Firestoreのデータをアップデートする
        let usersCollection = db.collection("users")
        let userRef = usersCollection.document(userID)
        userRef.updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document updated")
            }
        }
    }
}

