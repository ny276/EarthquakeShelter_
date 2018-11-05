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
    
    var item:[String:String] = [:]  // item[key] => value
    var items:[[String:String]] = []
    var currentElement = ""
    
    var tPM10: String?
    var address: String?
    var lat: String?
    var long: String?
    var loc: String?
    var dLat: Double?
    var dLong: Double?
    var vPM10Cai: String?
    
    let addrs:[String:[String]] = [
        "태종대" : ["영도구 전망로 24", "35.0597260", "129.0798400", "태종대유원지관리사무소", "도시대기", "녹지지역"],
        "전포동" : ["부산진구 전포대로 175번길 22", "35.1530480", "129.0635640","경남공고 옥상", "도시대기",  "상업지역"],
        "광복동" : ["중구 광복로 55번길 10", "35.0999630", "129.0304170", "광복동 주민센터", "도시대기", "상업지역"],
        "장림동" : ["사하구 장림로 161번길 2", "35.0829920", "128.9668750", "사하여성회관", "도시대기","공업지역"],
        "학장동" : ["사상구 대동로 205", "35.1460850", "128.9838270", "학장초등학교", "도시대기","공업지역"],
        "덕천동" : ["북구 만덕대로 155번길 81", "35.2158660", "129.0197570", "한국환경공단", "도시대기", "주거지역"],
        "연산동" : ["연제구 중앙대로 1065번길 14", "35.1841140", "129.0786090", "연제초등학교", "도시대기", "주거지역"],
        "대연동" : ["남구수영로 196번길 80", "35.1303210", "129.0876850", "부산공업고등학교", "도시대기", "주거지역"],
        "청룡동" : ["금정구 청룡로 25", "35.2752570", "129.0898810","청룡노포동 주민센터 옥상", "도시대기", "주거지역"],
        "기장읍" : ["기장군 기장읍 읍내로 69", "35.2460560", "129.2118280","기장초등학교 옥상", "도시대기", "주거지역"],
        "대저동" : ["강서구 낙동북로 236", "35.2114600", "128.9547110","대저차량사업소 옥상", "도시대기", "녹지지역"],
        "부곡동" : ["금정구 부곡로 156번길 7", "35.2298390", "129.0927140","부곡2동 주민센터 옥상", "도시대기", "주거지역"],
        "광안동" : ["수영구 수영로 521번길 55", "35.1527040", "129.1078090","구 보건환경연구원 3층", "도시대기", "주거지역"],
        "명장동" : ["동래구 명장로 32", "35.2047550", "129.1043270","명장동 주민센터 옥상", "도시대기", "주거지역"],
        "녹산동" : ["강서구 녹산산업중로 333", "35.0953270", "128.8556680", "(주)삼성전기부산사업장 옥상", "도시대기",  "공업지역"],
        "용수리" : ["기장군 정관면 용수로4", "35.3255580", "129.1801400", "정관면 주민센터 2층 옥상", "도시대기", "주거지역"],
        "좌동"  : ["해운대구 양운로 91", "35.1708900", "129.1742250", "좌1동 주민센터 옥상", "도시대기", "주거지역"],
        "수정동" : ["동구 구청로 1", "35.1293350", "129.0454230", "동구청사 옥상", "도시대기", "주거지역"],
        "대신동" : ["서구 대신로 150", "35.1173230", "129.0156410", "부산국민체육센터", "도시대기", "주거지역"],
        "온천동" : ["동래구 중앙대로 동래역", "35.2056140", "129.0785020", "동래지하철 앞", "도로변", "상업지역"],
        "초량동" : ["동구 초량동 윤흥신장군 동상앞", "35.11194650", "129.0354560", "윤흥신장군 동상 앞", "도로변", "상업지역"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.url(forResource: "Shelter", withExtension: "xml") {
            //print(path)
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parse succeed!")
                    for item in items {
                        print("item pm10 = \(item["pm10"]!)")
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
            let dSite = item["site"]
            print("dSite = \(String(describing: dSite))")
            
            // 추가 데이터 처리
            for (key, value) in addrs {
                if key == dSite {
                    address = value[0]
                    lat = value[1]
                    long = value[2]
                    loc = value[3]
                    dLat = Double(lat!)
                    dLong = Double(long!)
                }
            }
            
            // 파싱 데이터 처리
            let dPM10 = item["pm10"]
            let dPM10Cai = item["pm10Cai"]
            
            print("dMP10 = \(String(describing: dPM10))")
            print("dPM10Cai = \(String(describing: dPM10Cai))")
            
            switch dPM10Cai {
            case "1": vPM10Cai = "좋음"
            case "2": vPM10Cai = "보통"
            case "3": vPM10Cai = "나쁨"
            case "4": vPM10Cai = "아주나쁨"
            default : vPM10Cai = "오류"
            }
            
            //            if dPM10Cai == "1" {
            //                vPM10Cai = "좋음"
            //            } else if dPM10Cai == "2" {
            //                vPM10Cai = "보통"
            //            } else if dPM10Cai == "3" {
            //                vPM10Cai = "나쁨"
            //            } else if dPM10Cai == "4" {
            //                vPM10Cai = "아주나쁨"
            //            } else {
            //                vPM10Cai = "오류"
            //            }
            
            let subtitleOut =  "PM10 " + vPM10Cai! + " " + dPM10! + " ug/m3 "
            
            annotation = BusanData(coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!), title: dSite!, subtitle: subtitleOut, pm10: dPM10!, pm10Cai: dPM10Cai!)
            
            annotations.append(annotation!)
            myMapView.showAnnotations(annotations, animated: true)
            //            myMapView.addAnnotations(annotations)
            
        }
    }
    
    func zoomToRegion() {
        let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
        let span = MKCoordinateSpan(latitudeDelta: 0.27, longitudeDelta: 0.27)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        //        if annotation.isKind(of: MKUserLocation.self) {
        //            return nil
        //        }
        
        if annotation.isKind(of: BusanData.self) {
            var annotationView = myMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                // 미세먼지 농도에 따라 pin의 색깔을 바꿈
                let castBusanData = annotation as! BusanData
                let pm10Val = castBusanData.pm10Cai
                switch pm10Val {
                case "4": annotationView?.pinTintColor = UIColor.red // 매우나쁨
                case "3": annotationView?.pinTintColor = UIColor.brown // 나쁨
                case "2": annotationView?.pinTintColor = UIColor.blue // 보통
                case "1" : annotationView?.pinTintColor = UIColor.green // 좋음
                default: annotationView?.pinTintColor = UIColor.black // 오류
                }
                
            } else {
                annotationView?.annotation = annotation
            }
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            
            return annotationView
        }
        return nil
    }
    
    // XML Parsing Delegate 메소드
    // XMLParseDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        print("data = \(data)")
        if !data.isEmpty {
            item[currentElement] = data
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "row" {
            items.append(item)
        }
    }
}
