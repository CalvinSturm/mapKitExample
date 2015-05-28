//Calvin MapKit example
//5/11/15


import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate  {

    @IBOutlet weak var theMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var address = "1911 Johnson Ave San Luis Obispo, CA 93401"
        var address2 = "1010 Murray Ave San Luis Obispo, CA 93405"
        var address3 = "1288 Morro St #200 San Luis Obispo, CA 93401"
        
        var addressArr: [String] = [address, address2, address3]
        
        for index in addressArr {
            loadAddy(index)
        }
        
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                var latView:CLLocationDegrees = 0.04
                var longView:CLLocationDegrees = 0.04
                //amount the region is zoomed out
                var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latView, longView)
                //default region view
                var region:MKCoordinateRegion = MKCoordinateRegionMake(placemark.location.coordinate, theSpan)
                
                self.theMapView.setRegion(region, animated: true)
            }
            
        })        
        
    }
    //geocoder, forward geocoding to get a coordinate from a address
    func loadAddy(address: String) {
        var geocoder = CLGeocoder()
    
        // default placemark is the address
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                //we add info on placemarks
                var annotation = MKPointAnnotation()
                
                annotation.coordinate = placemark.location.coordinate
                annotation.title = placemark.name
                annotation.subtitle = "Some sub title"
                
                self.theMapView.addAnnotation(annotation)
                self.mapView(self.theMapView, viewForAnnotation: annotation)
                
            }
        })
    }
    
    //creates info button on annotation
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
            
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
        }
        return nil
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
            
            let pinAnnotation = view.annotation
            //retrieve coordinates from tapped detail disclosure
            var reverseGeo = CLLocation(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude)

            var geocoder = CLGeocoder()
            //reverse geocode coordinates to display a user friendly address in apple maps
            geocoder.reverseGeocodeLocation(reverseGeo, completionHandler: { (placemarks, e) -> Void in
                if let error = e {
                    println("error")
                } else {
                    
                    let placemarkArray = placemarks as! [CLPlacemark]
                    var pm : CLPlacemark!
                    pm = placemarkArray[0]
                    
                    let placemark = MKPlacemark(coordinate: pinAnnotation.coordinate, addressDictionary: pm.addressDictionary)
                   
                    var mapItem = MKMapItem(placemark: placemark)
                    //custom title and subtitle from pin annotations can be displayed on apple maps
                    mapItem.name = pinAnnotation.title
                    mapItem.name = pinAnnotation.subtitle
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    //sends direction request to apple maps
                    mapItem.openInMapsWithLaunchOptions(launchOptions)
                    
                }
                
            })
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

