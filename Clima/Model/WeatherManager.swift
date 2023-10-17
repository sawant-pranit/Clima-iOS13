//
//  WeatherManager.swift
//  Clima
//
//  Created by pranit on 30/08/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather : WeatherModel)
    
    func didFailWithError(error : Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=0304d8afbe4597f9e7ee5039754ff441&units=metric"
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName : String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        	performRequest(urlString: urlString)
        print("\(urlString)")
    }
    
    func fetchWeather(latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    private func performRequest(urlString : String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            
            task.resume()
        }
    }
    
    private func handle(data: Data?, response : URLResponse?, error: Error?) {
        if(error != nil) {
            delegate?.didFailWithError(error: error!)
            return
        }
        
        if let safeData = data{
            parseJson(weatherData: safeData)
            // let dataString = String(data: safeData, encoding: .utf8)
            // print("Response-> \(String(describing: dataString))")
        }
    }
    
    func parseJson(weatherData : Data) {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            // print("Temp: \(decodedData.main.temp)")
            // print(getConditionName(weatherId: decodedData.weather[0].id))
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weatherModel = WeatherModel(conditionId: id, cityName: name, tempreature: temp)
            self.delegate?.didUpdateWeather(weather: weatherModel)
            print(weatherModel.conditionName)
        } catch {
            delegate?.didFailWithError(error: error)
        }
    }
        
    
}
