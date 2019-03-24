//
//  DetailVC.swift
//  WeatherGift
//
//  Created by Kyle Burns on 3/10/19.
//  Copyright © 2019 t. kyle burns. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter = DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, MM dd, y"
    return dateFormatter
}()


class DetailVC: UIViewController {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentPage = 0
    var locationsArray = [WeatherLocation]()
    var locationManager: CLLocationManager
    var currentLocation: CLLocation!
    override func viewDidLoad() {
    
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        if currentPage != 0 {
            self.locationsArray[currentPage].getWeather {
                self.updateUserInterface()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentPage == 0{
            getLocation()
        }
    }
    func updateUserInterface() {
        let location = locationsArray[currentPage]
        locationLabel.text = location.name
//        let dateString = formatTimeForTimeZone(unixDate: location.currentTime, timeZone: location.timeZone)
        let dateString = location.currentTime.format(timeZone: location.timeZone, dateFormatter: dateFormatter)
        dateLabel.text = location.coordinates
        temperatureLabel.text = location.currentTemp
        summaryLabel.text = location.currentTemp
        currentImage.image = UIImage(named: location.currentTemp)
        tableView.reloadData()
        
        
    }
    
//    func formatTimeForTimeZone(unixDate: TimeInterval, timeZone: String) -> String {
//        let usebaleDate = Date(timeIntervalSince1970: unixDate)
//        dateFormatter.timeZone = TimeZone(identifier:  timeZone )
//        let dateString = dateFormatter.string(from: usebaleDate)
//        return dateString
//
//    }
    
}
extension DetailVC: CLLocationManagerDelegate {
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        handleLocationAuthorizationStatus(status: status)
    }
     func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            print("I'm sorry- can't show location. User has not authorized it.")
        case .restricted:
            print("Access denied. Likely parental controls are restricting location services in this app.")
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geoCoder = CLGeocoder()
        var place = ""
        currentLocation = locations.last
        let currentLatitude = currentLocation.coordinate.latitude
        
        let currentLongitude = currentLocation.coordinate.longitude
        let currentCoordinates = "\(currentLatitude),\(currentLongitude)"
        print(currentCoordinates)
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
            if placemarks != nil {
                let placemark = placemarks?.last
                place = (placemark?.name)!
            } else {
                print("Error retreiving place. Error code: \(error!)")
                place = "Unkown Weather Location"
            }
            self.locationsArray[0].name = place
            self.locationsArray[0].coordinates = currentCoordinates
            self.locationsArray[0].getWeather {
                self.updateUserInterface()
            }
        })
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location")
    }
}

extension DetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsArray[currentPage].dailyForecastArray.count
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell", for: indexPath)
        as! DayWeatherCell
        let dailyForecast = locationsArray[currentPage].dailyForecastArray[indexPath.row]
        let timeZone = locationsArray[currentPage].timeZone
        cell.update(with: dailyForecast, timeZone: timeZone)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
}
extension DetailVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 24
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath)
        return hourlyCell
    }
}
