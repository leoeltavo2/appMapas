//
//  BusquedaViewController.swift
//  appMapas
//
//  Created by mac14 on 11/11/21.
//

import UIKit
import MapKit
import CoreLocation

class BusquedaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //hacer uso del GPS
    var manager = CLLocationManager();

    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var barraBusqueda: UISearchBar!
    @IBOutlet weak var selector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        barraBusqueda.delegate = self
        mapa.delegate = self
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        
        //mejorar la presicion de la localizacion
        manager.desiredAccuracy = kCLLocationAccuracyBest
        //monitorear en todo momento la localizacion
        manager.startUpdatingLocation()
    }
    
    //MARK: - Trazar la ruta
    func trazarRuta(coordenadasDestino: CLLocationCoordinate2D){
        guard let coordinadasOrigen = manager.location?.coordinate else {return}
        
        //crear lugar de origen y destino
        let lugarOrigenMark = MKPlacemark(coordinate: coordinadasOrigen)
        let lugarDestinoMark = MKPlacemark(coordinate: coordenadasDestino)
        
        //crear objeto mapkit Item
        let lugarOrigenItem = MKMapItem(placemark: lugarOrigenMark)
        let lugarDestinoItem = MKMapItem(placemark: lugarDestinoMark)
        
        //solicitar la ruta
        let solicitudDestino = MKDirections.Request()
        solicitudDestino.source = lugarOrigenItem
        solicitudDestino.destination = lugarDestinoItem
        
        //como se va a viajar
        solicitudDestino.transportType = .any
        solicitudDestino.requestsAlternateRoutes = true
        
        let direcciones = MKDirections(request: solicitudDestino)
        direcciones.calculate { (respuesta, error) in
            guard let respuestaSegura = respuesta else{
                if let error = error{
                    print("Error al calcular la ruta \(error.localizedDescription)")
                }
                return
            }
            //si se calculo la ruta
            print(respuestaSegura.routes.count)
            let ruta = respuestaSegura.routes[0]
            
            
            //superponer el mapa
            self.mapa.addOverlay(ruta.polyline)
            self.mapa.setVisibleMapRect(ruta.polyline.boundingMapRect, animated: true)
        }
    }
    
    //modificar mapa
    @IBAction func btnModificarMapa(_ sender: UISegmentedControl) {
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
    
    
    //MARK: - Mostrar ruta encima del mapa
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderizado = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderizado.strokeColor = .magenta
        return renderizado
    }
   
    //MARK: - Metodos CLLManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("se obtuvo la localizacion")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alerta = UIAlertController(title: "ERROR EN LA DIRECCIÓN", message: "La dirección no fue encontrada", preferredStyle: .alert)
        
        
        let Aceptar = UIAlertAction(title: "Aceptar", style: .default)
    
        alerta.addAction(Aceptar)
        
        self.present(alerta, animated: true)
    }

}

extension BusquedaViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        barraBusqueda.resignFirstResponder()
        let geocoder = CLGeocoder()
        
       // if let direccion = barraBusqueda.text{
            geocoder.geocodeAddressString(barraBusqueda.text!) { (places:[CLPlacemark]?, error: Error?) in
                
                //crear ruta destino
                guard let destinoRuta = places?.first?.location else {return}
                
                if error == nil{
                    //mostrar la direccion
                    let place = places?.first
                
                    let anotacion = MKPointAnnotation()
                    anotacion.coordinate = (place?.location?.coordinate)!
                    anotacion.title = self.barraBusqueda.text!
                    //nivel de zoom que queramos
                    let span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                    let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                    //borrar las rutas
                    let overlays = self.mapa.overlays
                    let annotations = self.mapa.annotations
                    self.mapa.removeOverlays(overlays)
                    self.mapa.removeAnnotations(annotations)
                    
                    self.mapa.setRegion(region, animated: true)
                    self.mapa.addAnnotation(anotacion)
                    self.mapa.selectAnnotation(anotacion, animated: true)
                    
                    //mandar llamar trazar ruta
                    
                    self.trazarRuta(coordenadasDestino: destinoRuta.coordinate)
                    
                }else{
                    let alerta = UIAlertController(title: "ERROR EN LA DIRECCIÓN", message: "La dirección '\(self.barraBusqueda.text!)' no fue encontrada", preferredStyle: .alert)
                    
                    
                    let Aceptar = UIAlertAction(title: "Aceptar", style: .default)
                
                    alerta.addAction(Aceptar)
                    
                    self.present(alerta, animated: true)
                }
            }

        //}
        
        
    }
}

