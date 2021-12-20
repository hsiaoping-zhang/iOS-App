//
//  LocationManager.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/5/2.
//

import Foundation
import MapKit


class locationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var currentUserLogitude: Double = currentLongitude
    @Published var currentUserLatitude: Double = currentLatitude
    @Published var currentUserArea = "B"
    @Published var currentUserCity = "A"
    @Published var rangeArea = "500 M"
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        if manager.authorizationStatus == .authorizedWhenInUse{
            print("authorized...")
            manager.startUpdatingLocation()
        }
        else{
            print("no authorized...")
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("Current location: (", locations[0].coordinate.latitude, ",", locations[0].coordinate.longitude, ")")
        print(locations)
        self.currentUserLogitude = locations[0].coordinate.longitude
        self.currentUserLatitude = locations[0].coordinate.latitude
//        currentLatitude = locations[0].coordinate.latitude
//        currentLongitude = locations[0].coordinate.longitude
        
        let ceo: CLGeocoder = CLGeocoder()
        let loc: CLLocation = CLLocation(latitude: currentUserLatitude, longitude: currentUserLogitude)
        
//        22.986995400154647, 120.23785530239013 狸小路
        
        // English
//        let geocoder = CLGeocoder()
//        geocoder.reverseGeocodeLocation(loc) { (placemarksArray, error) in
//                for i in placemarksArray!{
//                    let country = i.country ?? ""
//                    let county = i.subAdministrativeArea ?? ""
//                    let code = i.postalCode ?? ""
//                    let area = i.locality ?? ""
//                    print("address info: \(country), (\(code))\(county), \(area)")
//                }
//            }
        
        // Chinese
        let locale = Locale(identifier: "zh_TW")
        if #available(iOS 11.0, *) {
            ceo.reverseGeocodeLocation(loc, preferredLocale: locale) {
                (placemarks, error) in
                if error == nil {
                    let pm = placemarks! as [CLPlacemark]
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        let country = pm.country ?? ""
                        let county = pm.subAdministrativeArea ?? ""
                        let code = pm.postalCode ?? ""
                        let area = pm.locality ?? ""
                        print("地址: \(country), (\(code))\(county), \(area)")
                        currentCity = county
                        currentArea = area
                        self.currentUserCity = county
                        self.currentUserArea = area
                        currentPostalCode = Int(code) ?? 100
                        print(currentCity, currentArea)
                    }
                }
            }
        }
        
    }
}
