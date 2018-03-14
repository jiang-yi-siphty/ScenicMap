# ScenicMap
This is a scenic map app to present my coding skills in Swift.

## Orientation
I have include all dependent cocoa pods in this repo. Please use Xcode to open the ScenicMap.xcworkspace.   

I have used the JSONExport to auto generate data models based on given JSON api repsonse.   
Models are automatically generated by [JSONExport](https://github.com/Ahmed-Ali/JSONExport).  

I am using [Alamofire](https://cocoapods.org/pods/Alamofire) for access API service.  

The [ObjectMapper](https://cocoapods.org/pods/ObjectMapper) helps me to map decoded JSON object.  

## Architeture
RxSwift + MVVM

## Unit Test
Use XCTest framework for test ViewModel by feed mock data.  
Use XCTest framework for test API Web Service Call.  

## COCOAPODS 
**Alamofire**  
**RxSwift**  
**ObjectMapper**  

## TOOLS
**JSONExport**


## TODO list (14th Mar 2018)  
### In the Scenic Table View, the custom scenic table view cells need to be shown.   
### In the Scenic Details View, a text field should be layout to allow user to edit comment for the scenic.  
### In the Scenic Map View, the latest annotation tag should replace the old fashion pin annotation.
### Find better solution to merge default scenic list and firebase scenic list in data model. 
