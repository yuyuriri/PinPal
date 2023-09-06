//
//  GooglePlacesManager.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import Foundation
import GooglePlaces
import CoreLocation

struct Place {
    let name: String
    let identifier: String
}

final class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    
    private init() {}
    
    enum PlacesError: Error {
        case failedToFind
        case failedToGetCoordinates
    }
    
    public func setUp() {
        GMSPlacesClient.provideAPIKey("AIzaSyCo8DwtL8P32qoP0b8A_EzsNsM2oNOsbjs")
    }
    
    public func findPlaces(
        query: String,
        completion: @escaping(Result<[Place], Error>) -> Void
    ) {
        let filter = GMSAutocompleteFilter()
        
        client.findAutocompletePredictions(
            fromQuery: query,
            filter: nil,
            sessionToken: nil
        ) { results, error in
             guard let results = results, error == nil else {
                 print("")
                 print("")
                 print(error)
                 print("")
                 print("")
                 completion(.failure(PlacesError.failedToFind))
            return
        }
            
            let places: [Place] = results.compactMap({
                Place(name: $0.attributedFullText.string,
                      identifier: $0.placeID
                )
            })
        
            completion(.success(places))
        }
    }
    
    public func resolveLocation(
        for place: Place,
        completion: @escaping(Result<CLLocationCoordinate2D, Error>) -> Void
    ){
        client .fetchPlace(
            fromPlaceID: place.identifier,
            placeFields: .coordinate,
            sessionToken: nil
        ) { googlePlace, error in
            guard let googlePlace = googlePlace, error == nil else {
                completion(.failure(PlacesError.failedToGetCoordinates))
                return
            }
            
            let coordinate = CLLocationCoordinate2D(
                latitude: googlePlace.coordinate.latitude,
                longitude: googlePlace.coordinate.longitude
            )
            completion(.success(coordinate))
        }
    }
}

