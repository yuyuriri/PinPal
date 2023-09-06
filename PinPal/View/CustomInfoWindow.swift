//
//  CustomInfoWindow.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import Foundation
import GoogleMaps
import FirebaseFirestore
import FirebaseFirestoreSwift

class CustomInfoWindow: UIView {
    //後で消す
    let uuid = UUID()
    
    var view : UIView!
    var marker: CustomMarker?
    
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var saveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //cellに表示されているパーツにデータを割り振る
    func setupCustomInfoWindow() {
    }
    
    
    
    func loadView() -> CustomInfoWindow{
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
        return customInfoWindow
    }
    
    // fireStoreで、markersを更新する
    @IBAction func savehitokoto() {
       
        marker?.title = contentTextView.text
        
        guard let roomID = UserDefaults.standard.string(forKey: "currentRoomID") else { return }
        
        Firestore.firestore().collection("rooms").document(roomID).getDocument() { (snaps, error) in
            do {
                guard var uploadRoomData = try snaps?.data(as: UploadRoomData.self) else { return }
                
                uploadRoomData.markers[self.marker!.index].title = self.marker!.title!
                
                try Firestore.firestore().collection("rooms").document(roomID).setData(from: uploadRoomData)
            } catch {
                print(error)
            }
        }
    }
}

