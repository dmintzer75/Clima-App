//
//  ViewController.swift
//  Clima-App
//
//  Created by Dario Mintzer on 04/01/2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextfield: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //ask for location permission
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        searchTextfield.delegate = self
        
    }
    
    
    @IBAction func locationPressed(_ sender: Any) {
        locationManager.requestLocation()
    }
    
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    //Editing of text field and what to do when it ends
    @IBAction func searchPressed(_ sender: UIButton) {
        
        searchTextfield.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        searchTextfield.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text! != "" {
            return true
        } else {
            textField.placeholder = "No location was selected"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextfield.text { // checks if it is a definite String
            weatherManager.fetchWeather(city)
        }
        searchTextfield.text = ""
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    //When a city is selected, get the weather information from the manager.
    //If the manager finds an error it prints it with didFailWithError
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) { //parameters: the manager, the protocol
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(_ error: Error) {
        print(error)
    }

}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            weatherManager.fetchWeather(latitude: lat, longitude: long)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
