//
//  NewWorkoutViewController.swift
//  Aqua Sport Tracking
//
//  Created by Marcos Timm on 17/06/17.
//  Copyright © 2017 Timm. All rights reserved.
//


import UIKit
import CoreLocation
import HealthKit
import MapKit

class NewWorkoutViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var workoutAction: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let workout = Workout()
    
    var seconds     = 0.0
    var distance    = 0.0
    var instantPace = 0.0
    var trainingHasBegun: Bool = false
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        workoutAction.backgroundColor = UIColor.init(red: 74.0/250, green: 164.0/250, blue: 218.0/250, alpha: 1.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10.0
        locationManager.requestAlwaysAuthorization()
        
        mapView.showsUserLocation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    @IBAction func startTracking(_ sender: Any) {
        
        if trainingHasBegun == false {
            trainingHasBegun = true
            seconds = 0.0
            distance = 0.0
            locations.removeAll(keepingCapacity: false)
            
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(self.eachSecond),
                                         userInfo: nil,
                                         repeats: true)
            startLocationUpdates()
            
            trainingHasBegun = true;
            workoutAction.setTitle("Stop", for: .normal)
            workoutAction.backgroundColor = .red
        } else {
            trainingHasBegun = false
            workoutAction.backgroundColor = .blue
            stopWorkout()
            saveWorkout()
        }
        
        print("trainingHasBegun: ", trainingHasBegun)
    }
    
    func stopTimer() {
        
        timer.invalidate()
        print("Timer invalidate")
    }
    
    func startLocationUpdates() {
        
        locationManager.startUpdatingLocation()
    }
    
    func stopWorkout() {
        
        stopTimer()
        locationManager.stopUpdatingLocation()
    }
    
    
    func eachSecond(timer: Timer) {
        
        seconds += 1
        
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: seconds)
        timeLabel.text = secondsQuantity.description
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        distanceLabel.text = distanceQuantity.description
        
        let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
        paceLabel.text = paceQuantity.description
    }
    
    func saveWorkout() {
        
        workout.distance = Float(distance)
        workout.duration = Int(seconds)
        workout.timestamp = NSDate()
        
        for location in locations {
            let _location = Location()
            _location.timestamp = location.timestamp as NSDate
            _location.latitude = location.coordinate.latitude
            _location.longitude = location.coordinate.longitude
            workout.locations.append(_location)
        }
        
        print(workout)
        
        if workout.save() {
            print("Run saved!")
        } else {
            print("Could not save the run!")
        }
        
        
    }

}


// MARK: - CLLocationManagerDelegate
extension NewWorkoutViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            if location.horizontalAccuracy < 10 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distance(from: self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    instantPace = location.distance(from: self.locations.last!)/(location.timestamp.timeIntervalSince(self.locations.last!.timestamp))
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                    
                    mapView.add(MKPolyline(coordinates: &coords, count: coords.count))
                    
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
    
}


// MARK: - MKMapViewDelegate
extension NewWorkoutViewController: MKMapViewDelegate {
    
    
}
