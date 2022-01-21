//
//  WeatherManager.swift
//  Clima-App
//
//  Created by Dario Mintzer on 09/01/2022.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) //Must be able to update weather
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=0fc2a3664007dc8230a4e73b7a6463c3&units=metric"
    
    func fetchWeather(_ cityName: String) {
        
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        
        //1. Create a URL
        if let url = URL(string: urlString) {
        
            //2. Create a url session
            
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let name = decodedData.name
            let temp = decodedData.main.temp
            let id = decodedData.weather[0].id
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch  {
            delegate?.didFailWithError(error)
            return nil
        }
    }
    

    
}
