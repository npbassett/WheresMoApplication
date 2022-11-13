//
//  Location.swift
//  WheresMo
//
//  Created by Neil Bassett on 11/12/22.
//

import Foundation
import CoreLocation

struct Location: Identifiable, Codable, Equatable {
    var id = UUID()
    var latitude: Double
    var longitude: Double
    var landmark = ""
    var placedBy = ""
    var date = Date()
    var description = ""
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static let exampleLocation = Location(id: UUID(),
                                          latitude: 40.02628625601256,
                                          longitude: -105.24369218832722,
                                          landmark: "Vision Quest Brewery",
                                          placedBy: "Susan Cassada",
                                          date: Date(),
                                          description: "Located on bottom left of refrigerator door behind the bar.")
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}
