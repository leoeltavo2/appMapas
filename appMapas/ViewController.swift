//
//  ViewController.swift
//  appMapas
//
//  Created by mac14 on 11/11/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager = CLLocationManager();
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!

    @IBOutlet weak var mapa: MKMapView!
    
    @IBOutlet weak var selector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Delegados
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
    }
    
//boton obtener localizacion
    @IBAction func btnLocation(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "LOCALIZACIÓN", message: "Tú localización es: latitud: \(lat!) y longitud: \(long!)", preferredStyle: .alert)
        
        
        let Aceptar = UIAlertAction(title: "Aceptar", style: .default) { (_) in
        }
        let verMas = UIAlertAction(title: "Ver más", style: .default) { (_) in
            let localizacion = CLLocationCoordinate2DMake(self.lat, self.long)
            //nivel de zoom que queramos
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: localizacion, span: span)
            self.mapa.setRegion(region, animated: true)
            self.mapa.showsUserLocation = true
        }
        
        
        alerta.addAction(Aceptar)
        alerta.addAction(verMas)
        
        present(alerta, animated: true)
    }
    
    //boton cambiar de mapa
    @IBAction func btnCambiarMapa(_ sender: UISegmentedControl) {
        switch selector.selectedSegmentIndex {
        case 0:
            self.mapa.mapType = .standard
        case 1:
            self.mapa.mapType = .satellite
        case 2:
            self.mapa.mapType = .hybrid
        default:
            break
        }
    }
    
    
    
    //MARK: - obtener coordenadas
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            self.lat = location.coordinate.latitude
            self.long = location.coordinate.longitude
        }
        
    }

}

