//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Kyle Burns on 3/17/19.
//  Copyright © 2019 t. kyle burns. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherDetail: WeatherLocation{
    
    struct HourlyForecast {
        var hourlyTime: Double
        var hourlyTemperature: Double
        var hourlyPrecipProb: Double
        var hourlyIcon: String
    }
    
    struct DailyForecast {
        var dailyMaxTemp: Double
        var dailyMinTemp: Double
        var dailyDate: Double
        var dailySummary: String
        var dailyIcon: String
        
    }
    
    var currentTemp = "--"
    var dailySummary = ""
    var currentIcon = ""
    var currentTime = 0.0
    var timeZone = ""
    var hourlyForcastArray = [HourlyForecast]()
    var dailyForecastArray = [DailyForecast]()
    
    
    
    func getWeather(completed: @escaping() -> ()) {
        let weatherURL = urlBase + urlAPIKey + coordinates
        AlamoFire.request(weatherURL).responseJSON { response in
            switch response.result {
            case.success(let value):
                let json = JSON(value)
                if let temperature = json["currently"]["temperature"].double {
                    print("***** temperature inside getWeather = \(temperature)")
                    let roundedTemp = String(format: "%3.f", temperature )
                    self.currentTemp = roundedTemp + "°"
                } else {
                    print("Could get the temperature")
                }
                if let summary = json["daily"]["summary"].string {
                    
                    self.currentIcon = icon
                } else {
                    print("could not return a temperature")
                }
                if let icon = json["currently"]["icon"].string {
                    self.currentIcon = icon
                }else{
                    print("could not return an icon")
                }
                if let icon = json["timezone"].string {
                    self.timeZone = timeZone
                }else{
                    print("could not return a timezone")
                }
                if let icon = json["currently"]["time"].double {
                    self.currentTime = time
                }else{
                    print("could not return a time")
                }
                
                let dailyDataArray = json["daily"]["data"]
                self.dailyForecastArray = []
                let days = min(7, dailyDataArray.count-1)
                for day in 1 ...days {
                    let maxTemp = json["daily"]["data"][day]["tempatureHigh"].doubleValue
                    let minTemp = json["daily"]["data"][day]["tempatureLow"].doubleValue
                    let dateValue = json["daily"]["data"][day]["time"].doubleValue
                    let icon = json["daily"]["data"][day]["icon"].stringValue
                    let dailySummary = json["daily"]["data"][day]["summary"].stringValue
                    let newDailyForecast = DailyForecast(dailyMaxTemp: maxTemp, dailyMinTemp: minTemp, dailyDate: dateValue, dailySummary: dailySummary, dailyIcon: icon)
                    self.dailyForecastArray.append(newDailyForecast)
                }
                
                
                let hourlyDataArray = json["hourly"]["data"]
                self.hourlyForcastArray = []
                let hours = min(24, hourlyDataArray.count-1)
                for hour in 1...hours {
                    let hourlyTime = json["hourly"]["data"][hour]["time"].doubleValue
                    let hourlyTemperature = json["hourly"]["data"][hour]["temperature"].doubleValue
                    let hourlyPrecipProb = json["hourly"]["data"][hour]["preciProbabilty"].doubleValue
                    let hourlyIcon = json["hourly"]["data"][hour]["icon"].stringValue
                    let newHourlyForecast = HourlyForecast(hourlyTime: hourlyTime, hourlyTemperature: hourlyTemperature, hourlyPrecipProb: hourlyPrecipProb, hourlyIcon: hourlyIcon)
                    self.hourlyForcastArray.append(newHourlyForecast)
                    
                }
                print("**** \(self.hourlyForecastArray)")
            
                
                
                
                
            case.failure(let error):
                print(error)
            }
            completed()
            
        }
        
    }
}
