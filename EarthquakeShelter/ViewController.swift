//
//  ViewController.swift
//  EarthquakeShelter
//
//  Created by D7703_18 on 2018. 11. 5..
//  Copyright © 2018년 201550057. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, XMLParserDelegate {

    @IBOutlet var myMapView: MKMapView!
    
    var annotation: BusanData?
    var annotations: Array = [BusanData]()
    
    var item: [String:String] = [:]
    var items: [[String:String]] = []
    var currentElement = ""
    
    var address: String?
    var dtl_adres: String?
    var vt_acmdfclty_nm: String?
    var name : String?
    var lat: String?
    var long: String?
    var loc: String?
    var dLat: Double?
    var dLong: Double?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.url(forResource: "Shelter", withExtension: "xml") {
            //print(path)
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parse succeed!")
                    for item in items {
                        print("item \(item["dtl_adres"]!)")
                    }
                } else {
                    print("parse failed!")
                }
            }
        } else {
            print("xml file not found")
        }
        
        // Map
        myMapView.delegate = self
        
        //  초기 맵 region 설정
        zoomToRegion()
        
        for item in items {
            lat = item["xcord"]
            long = item["ycord"]
            name = item["vt_acmdfclty_nm"]
            loc = item["dtl_adres"]
            dLat = Double(lat!)
            dLong = Double(long!)
            annotation = BusanData(coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!), title: name!, subtitle: loc!)
            annotations.append(annotation!)
        }
        myMapView.showAnnotations(annotations, animated: true)
        myMapView.addAnnotations(annotations)

            }
    
    
    func zoomToRegion() {
        let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
        let span = MKCoordinateSpan(latitudeDelta: 0.27, longitudeDelta: 0.27)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
    }
    
    // XMLParser Delegete 메소드
    
    // XML 파서가 시작 테그를 만나면 호출됨
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
    }
    
    // XML 파서가 종료 테그를 만나면 호출됨
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "row" {
            items.append(item)
        }
    }
    
    // 현재 테그에 담겨있는 문자열 전달
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        // 공백제거
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        // 공백체크 후 데이터 뽑기
        if !data.isEmpty {
            item[currentElement] = data
        }
        
    }
    
}
