//
//  RestaurantLocalDataSource.swift
//  DietShare
//
//  Created by Shuang Yang on 29/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import BTree
import SQLite
import CoreLocation

/**
 * A local data source for Restaurants, implemented with SQLite.
 */
class RestaurantsLocalDataSource: RestaurantsDataSource {
    
    
    private var database: Connection!
    private let restaurantsTable = Table(Constants.Tables.restaurants)
    
    // Columns of the Restaurants table
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let imagePath = Expression<String>("imagePath")
    private let description = Expression<String>("description")
    private let address = Expression<String>("address")
    private let location = Expression<CLLocation>("location")
    private let phone = Expression<String>("phone")
    private let types = Expression<StringList>("types")
    private let posts = Expression<StringList>("posts")
    private let ratings = Expression<RatingList>("ratings")
    private let ratingScore = Expression<Double>("ratingScore")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init(_ restaurants: [Restaurant], _ title: String) {
//        print("RestaurantLocalDataSource initializer called")
        removeDB()
        createDB(title)
        createTable()
        prepopulate(restaurants)
    }
    
    private convenience init() {
        self.init([Restaurant](), Constants.Tables.restaurants)
        prepopulate()
    }
    // A shared instance to be used in a global scope
    static let shared = RestaurantsLocalDataSource()
    
    // Get instance for unit test
    static func getTestInstance(_ restaurants: [Restaurant]) -> RestaurantsLocalDataSource {
        return RestaurantsLocalDataSource(restaurants, Constants.Tables.restaurants + "Test")
    }
    
    // Create a database connection with given title, if such database does not already exist
    private func createDB(_ title: String) {
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent(title).appendingPathExtension("sqlite3") {
            
            self.database = try? Connection(fileUrl.path)
        }
    }
    
    // Creates restaurant table if it is not already existing
    private func createTable() {
        let createTable = self.restaurantsTable.create(ifNotExists: true) { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.address)
            table.column(self.location)
            table.column(self.phone)
            table.column(self.types)
            table.column(self.description)
            table.column(self.imagePath)
            table.column(self.ratings)
            table.column(self.posts)
            table.column(self.ratingScore)
        }
        do {
            try self.database.run(createTable)
        } catch {
            fatalError("Database not created")
        }
    }
    
    func getAllRestaurants() -> SortedSet<Restaurant> {
        var restaurants = SortedSet<Restaurant>()
        do {
            
            let startTime = CFAbsoluteTimeGetCurrent()
            for restaurant in try database.prepare(restaurantsTable) {
                
                let restaurantEntry = Restaurant(restaurant[id], restaurant[name], restaurant[address],restaurant[location], restaurant[phone], restaurant[types], restaurant[description], restaurant[imagePath], restaurant[ratings], restaurant[posts], restaurant[ratingScore])
                restaurants.insert(restaurantEntry)
            }
            
            print("Time lapsed for getting restaurants: \(CFAbsoluteTimeGetCurrent() - startTime)")
        } catch let error {
            print("failed to get row: \(error)")
        }
        return restaurants
    }
    
    func getRestaurantByID(_ restaurantID: String) -> Restaurant? {
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            let row = restaurantsTable.filter(id == restaurantID)
            for restaurant in try database.prepare(row) {
                let restaurantEntry = Restaurant(restaurant[id], restaurant[name], restaurant[address],restaurant[location], restaurant[phone], restaurant[types], restaurant[description], restaurant[imagePath], restaurant[ratings], restaurant[posts], restaurant[ratingScore])
                return restaurantEntry
            }
            print("Time lapsed for getting restaurant by ID: \(CFAbsoluteTimeGetCurrent() - startTime)")
        } catch let error {
            print("failed to get row: \(error)")
        }
        return nil
    }
    
    func getNumOfRestaurants() -> Int {
        var count = 0
        do {
            count = try database.scalar(restaurantsTable.count)
        } catch let error {
            print("failed to count number of rows: \(error)")
        }
        return count
    }
    
    func addRestaurant(_ newRestaurant: Restaurant) {
        _checkRep()
        do {
//            print("current restaurant id is: \(newRestaurant.getID())")
            try database.run(restaurantsTable.insert(id <- newRestaurant.getID(), name <- newRestaurant.getName(), address <- newRestaurant.getAddress(), location <- newRestaurant.getLocation(), phone <- newRestaurant.getPhone(), types <- newRestaurant.getTypes(), description <- newRestaurant.getDescription(), imagePath <- newRestaurant.getImagePath(), ratings <- newRestaurant.getRatingsID(), posts <- newRestaurant.getPostsID(), ratingScore <- newRestaurant.getRatingScore()))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("insert constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
        _checkRep()
    }
    
    
    func addRestaurants(_ newRestaurants: SortedSet<Restaurant>) {
        _checkRep()
        for newRestaurant in newRestaurants {
            addRestaurant(newRestaurant)
        }
        _checkRep()
    }
    
    func containsRestaurant(_ restaurantID: String) -> Bool {
        let row = restaurantsTable.filter(id == restaurantID)
        do {
            if try database.run(row.update(id <- restaurantID)) > 0 {
                return true
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
        
        return false;
    }
    
    func deleteRestaurant(_ restaurantID: String) {
        _checkRep()
        let row = restaurantsTable.filter(id == restaurantID)
        do {
            if try database.run(row.delete()) > 0 {
                print("deleted the Restaurant")
            } else {
                print("Restaurant not found")
            }
        } catch {
            print("delete failed: \(error)")
        }
        _checkRep()
    }
    
    func updateRestaurant(_ oldRestaurantID: String, _ newRestaurant: Restaurant) {
        _checkRep()
        let row = restaurantsTable.filter(id == oldRestaurantID)
        do {
            if try database.run(row.update(id <- newRestaurant.getID(), name <- newRestaurant.getName(), address <- newRestaurant.getAddress(), location <- newRestaurant.getLocation(), phone <- newRestaurant.getPhone(), types <- newRestaurant.getTypes(), description <- newRestaurant.getDescription(), imagePath <- newRestaurant.getImagePath(), ratings <- newRestaurant.getRatingsID(), posts <- newRestaurant.getPostsID(), ratingScore <- newRestaurant.getRatingScore())) > 0 {
                print("Old Restaurant is updated")
            } else {
                print("Old Restaurant not found")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
        _checkRep()
    }
    
    /**
     * For post publish component
     */
    func searchWithKeyword(_ keyword: String) -> [Restaurant] {
        var restaurants = [Restaurant]()
        let query = restaurantsTable.filter(name.like("%\(keyword)%")).order(ratingScore.desc)
        do {
            for restaurant in try database.prepare(query) {
                let restaurant = Restaurant(restaurant[id], restaurant[name], restaurant[address],restaurant[location], restaurant[phone], restaurant[types], restaurant[description], restaurant[imagePath], restaurant[ratings], restaurant[posts], restaurant[ratingScore])
                restaurants.append(restaurant)
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        
        return restaurants
    }
    
    /**
     * Test functions - to be removed
     */
    
    // MARK: Only for test purpose
    private func removeDB() {
        print("Remove DB called")
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent(Constants.Tables.restaurants).appendingPathExtension("sqlite3") {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    // Only for testing
    
    private func prepopulate(_ restaurants: [Restaurant]) {
        _checkRep()
        if !restaurants.isEmpty  {
            for restaurant in restaurants {
                if !containsRestaurant(restaurant.getID()) {
                    self.addRestaurant(restaurant)
                }
            }
        }
        _checkRep()
    }
    
    private func prepopulate() {
        _checkRep()
        let testRating = Rating.getTestInstance()
        let testRatingList = RatingList()
        testRatingList.addEntry(testRating)

        let restaurants = [
            Restaurant("1", "District 10", "1 Vista Exchange Green, 01-42/K3, Singapore 138617", CLLocation(latitude: 1.3067087, longitude: 103.78788250000002), "66942884", StringList(.RestaurantType, ["American"]), "The NEW District 10 Bar & Grill specialised in nothing but the BEST DRY-AGED MEAT featuring the rare, flavoursome bone-in cuts with high content of natural and healthy marbling that is superb with premium reds. The small and neat 1,800 square-foot restaurant (including Outdoors) comes complete with a European meat showcase and chiller for its premium meats such as 45 days home dry aged corn fed US Prime OP Rib, US Prime, 30 days corn fed dry aged traditional Fiorentina and other bone-in cuts!", "restaurant-1", testRatingList, StringList(.Post), 4.5),
            Restaurant("2", "UNA at One Rochester", "1 Rochester Dr, Singapore 139212", CLLocation(latitude: 1.305308, longitude: 103.787689), "6773 0070", StringList(.RestaurantType, ["Chinese"]), "UNA, the Spanish restaurant housed at the iconic One Rochester, opened its doors on 12 April 2014, and has been credited with setting new al fresco dining standards. UNA presents fresh authentic Spanish tapas and parrilla (Spanish for ‘grill’) in a cosy, breezy al fresco garden setting. Using only fresh, seasonal ingredients, the team of dedicated chefs led by Executive Chef Antonio Oviedo present Spanish cuisine through trendy creations; offering real, unpretentious food that is robust, wholesome and full of flavours.", "vegie-bar.png", testRatingList, StringList(.Post), 4.5),
            Restaurant("3", "Yunnan Garden Restaurant", "1 Fusionopolis Place, #02-02 Galaxis, Singapore 138522", CLLocation(latitude: 1.2992467, longitude: 103.78807260000008), "6665 8888", StringList(.RestaurantType, ["Chinese"]), "A Dim Sum place at the central of Singapore", "restaurant-3", testRatingList, StringList(.Post), 4.5),
            Restaurant("4", "Long Beach @ DEMPSEY", "25 Dempsey Rd, Singapore 249670", CLLocation(latitude: 1.3063069, longitude: 103.81196169999998), "63232222", StringList(.RestaurantType), "A Chinese restaurant good for groups", "restaurant-4", testRatingList, StringList(.Post), 4.5),
            Restaurant("5", "Ah Loy Thai", "9 Tan Quee Lan Street #01-04 Singapore 188098", CLLocation(latitude: 1.298488, longitude: 103.85663499999998), "93297599", StringList(.RestaurantType, ["Thai"]), "This a thai traditional restaurant from shaw tower and we believe in bringing the customer great thai food at a affordable price and all our food is custom make to suit taste buds of Singaporean ! See you soon . Break time from 3 pm to 4.15 pm and open on holidays", "restaurant-5", testRatingList, StringList(.Post), 4.5),
            Restaurant("6", "Soi Thai Soi Nice", "321 Alexandra Rd, #02-01 Alexandra Central Mall, 159971", CLLocation(latitude: 1.2873346, longitude: 103.80505449999998), "62504863", StringList(.RestaurantType, ["Thai"]), "Filled to the brim with assorted ingredients including crayfish, mussels, tiger prawns, roast pork, and enoki mushrooms, we picked the home-made tom yum broth that came with a fiery kick! There was also a good balance of sour and sweet flavours, with fragrant spices and herbs used. I’d recommend you to add the mama instant noodles that had a bouncy texture. #Burpproved", "restaurant-6", testRatingList, StringList(.Post), 4.5),
            Restaurant("7", "Rakuichi Japanese Restaurant", "10 Dempsey Rd, Singapore 247700", CLLocation(latitude: 1.3033906, longitude:103.81048669999996), "64742143", StringList(.RestaurantType, ["Japanese"]), "Japanese cuisine is such an easy dining choice to make. There is always something for everyone. I have been going back to Rakuichi Dempsey for many years due to the casual vibe, good food and peaceful, relaxing ambience! There is ample parking and it's free", "restaurant-4", testRatingList, StringList(.Post), 4.5),
            Restaurant("8", "En Sushi", "#01-02 Income@Prinsep, 30 Prinsep St, 188647", CLLocation(latitude: 1.2989794, longitude: 103.84948370000006), "62531426", StringList(.RestaurantType, ["Japanese"]), "The colourful bara chirashi don sees an assortment of cubed sashimi such as salmon, tuna, yellowtail and octopus tossed in a homemade soy sauce.", "restaurant-8", testRatingList, StringList(.Post), 4.5),
            Restaurant("9", "NY Night Market", "#01-02 Income@Prinsep, 30 Prinsep St, 188647", CLLocation(latitude: 1.3989794, longitude: 103.84948370000006), "62531426", StringList(.RestaurantType, ["Korean"]), "Hailing from Seoul, NY Night Market brings to Singapore a taste of cosmopolitan markets in New York City where one can find a wide array of international street foods, as well as exciting Western fusion delights with a unique Korean touch.", "restaurant-9", testRatingList, StringList(.Post), 4.5),
            Restaurant("10", "Vatos Urban Tacos (South Beach)", "36 Beach Rd, Singapore 189766", CLLocation(latitude: 1.295766, longitude: 103.856179), "63856010", StringList(.RestaurantType, ["Korean"]), "One of Korea’s hottest restaurants, Vatos Urban Tacos, has come to Singapore. Influenced by Mexican street tacos in Los Angeles and home-cooked Korean meals, the menu consists of creations like the Kimchi Carnitas Fries, Galbi Tacos, and Spicy Chicken Quesadillas.", "restaurant-10", testRatingList, StringList(.Post), 4.5),
            Restaurant("11", "Sin Ming Roti Prata (Faisal & Aziz Curry Muslim Food)", "24 Sin Ming Rd, #01-51, Jin Fa Kopitiam, 570024", CLLocation(latitude: 1.3553878, longitude: 103.836408), "64533893", StringList(.RestaurantType, ["Indian"]), "Tasted before quite a few prata places! Sin Ming Roti Prata is one of the few places that was really nice and really worth to go for! ", "restaurant-10", testRatingList, StringList(.Post), 4.5),
            Restaurant("12", "Springleaf Prata Place (The Rail Mall)", "396 Upper Bukit Timah Rd, Singapore 678048", CLLocation(latitude: 1.3583357, longitude: 103.76767470000004), "64932404", StringList(.RestaurantType, ["Indian"]), "The ultimate murtabak is one of the featured creations at Springleaf and I can see why it's one of the highly reviewed items.", "restaurant-12", testRatingList, StringList(.Post), 4.5),
            Restaurant("13", "La Nonna (Holland Village)", "26 Lor Mambong, Singapore 277685", CLLocation(latitude: 1.3116818, longitude: 103.79485469999997), "64681982", StringList(.RestaurantType, ["American"]), "La Nonna, meaning “The Grandmother” in Italian, serves traditional Italian country cuisine, much like what grandma would usually prepare in an unpretentious and inviting Trattoria atmosphere. This is the place for discerning diners who prefer to have a hearty meal with good company, basking in La Nonna’s ineffable rustic charms", "restaurant-13", testRatingList, StringList(.Post), 4.5),
            Restaurant("14", "iSTEAKS Diner (Holland Village)", "17 Lor Liput, Singapore 277731", CLLocation(latitude: 1.3104967, longitude: 103.79518489999998), "64633165", StringList(.RestaurantType, ["American"]), "Loving the tenderness and juiciness of the steak. There's many side choices", "restaurant-14", testRatingList, StringList(.Post), 4.5),
            Restaurant("15", "Joie by Dozo", "181 Orchard Road, #12-01 Orchard Central, 238896", CLLocation(latitude: 1.300778, longitude: 103.839424), "68386966", StringList(.RestaurantType, ["Vegetarian"]), "This light-filled restaurant located at Orchard Central's rooftop garden continually rakes in the crowds with its beautifully presented vegetarian plates — they might even have converted a few stubborn meat eaters! The elegant and tasteful decor is a bonus, making it an ideal location to wine and dine a date or business associate.", "restaurant-15", testRatingList, StringList(.Post), 4.5),
            Restaurant("16", "The Boneless Kitchen (Tai Seng)", "1 Irving Place, Commerze @ Irving #01-31, 369546", CLLocation(latitude: 1.336039, longitude: 103.886072), "84576464", StringList(.RestaurantType, ["Vegetarian"]), "It may be hard to imagine meat-centric Korean fare prepared vegetarian style, but if there's one place that can do it right, it's The Boneless Kitchen.", "restaurant-16", testRatingList, StringList(.Post), 4.5),
            Restaurant("17", "Shelter in The Woods", "22 Greenwood Ave, Singapore 289218", CLLocation(latitude: 1.331449, longitude: 103.80675), "84576464", StringList(.RestaurantType, ["European"]), "A Shelter Like No Other Shelter in the Woods is a traditional rotisserie restaurant single-mindedly devoted to superb food, fine wine and good company. Located in the quiet suburbs of Bukit Timah, it offers family warmth and classic European rustic food underpinned by refined flavours and expert technique.", "restaurant-17", testRatingList, StringList(.Post), 4.5),
            Restaurant("18", "iSTEAKS Diner (Holland Village)", "17 Lor Liput, Singapore 277731", CLLocation(latitude: 1.3104967, longitude: 103.79518489999998), "64633165", StringList(.RestaurantType, ["American"]), "Loving the tenderness and juiciness of the steak. There's many side choices", "restaurant-14", testRatingList, StringList(.Post), 4.5),
            Restaurant("19", "Alaturka Mediterranean & Turkish Restaurant", "15 Bussorah St, Singapore 199436", CLLocation(latitude: 1.301179, longitude: 103.859969), "62940304", StringList(.RestaurantType, ["European"]), "Truly deserving of the Singapore Michelin Bib Gourmand is Alaturka Mediterranean & Turkish Restaurant - situated at Arab street, this authentic Turkish food establishment serves up the best Mediterranean food my tastebuds have ever sampled!", "restaurant-19", testRatingList, StringList(.Post), 4.5),
            Restaurant("20", "HANS IM GLÜCK German Burgergrill", "362 Orchard Rd, International Building, Singapore, 238887", CLLocation(latitude: 1.305977, longitude: 103.83081), "97501488", StringList(.RestaurantType, ["American"]), "This restaurant feels with natural at the outdoor section. Even the decoration on the table. Ordered a grilled chicken burger and top with bacon. The chicken meat is thick and tender.", "restaurant-20", testRatingList, StringList(.Post), 4.5)
        ]

        restaurants.forEach {
            self.addRestaurant($0)
        }

//        for i in 0..<10 {
//            if !containsRestaurant("i") {
//                let randLatOffset = Double(arc4random_uniform(10)) / 100.0
//                let randLongOffset = Double(arc4random_uniform(10)) / 100.0
//                let location = CLLocation(latitude: 1.22512 + randLatOffset, longitude: 103.84985 + randLongOffset)
//                let restaurant = Restaurant(String(i), "Salad Heaven", "1 Marina Boulevard, #03-02", location, "98765432", StringList(.RestaurantType), "The first Vegetarian-themed salad bar in Singapore. We provide brunch and lunch.", "vegie-bar.png", testRatingList, StringList(.Post), 4.5)
//
//                let types: [RestaurantType] = [.Vegetarian, .European]
//                restaurant.setTypes(types)
//                self.addRestaurant(restaurant)
//                }
//
//        }
//        for i in 10..<20 {
//            if !containsRestaurant("i") {
//                let randLatOffset = Double(arc4random_uniform(10)) / 100.0
//                let randLongOffset = Double(arc4random_uniform(10)) / 100.0
//                let location = CLLocation(latitude: 1.25212 + randLatOffset, longitude: 103.71985 + randLongOffset)
//                let restaurant = Restaurant(String(i), "Burger Shack", "1 Boon Lay Road, #03-02", location, "98700432", StringList(.RestaurantType), "The first Burger Shack in Singapore. We provide awesomeness.", "burger-shack.jpg", testRatingList, StringList(.Post), 3.0)
//
//                let types: [RestaurantType] = [.American, .European]
//                restaurant.setTypes(types)
//                self.addRestaurant(restaurant)
//            }
//
//        }
//
//        let locationFar = CLLocation(latitude: 2.35212, longitude: 103.81985)
//        let restaurantFar = Restaurant(String(21), "Salad Heaven Far, High Rating", "1 Marina Boulevard, #03-02", locationFar, "98765432", StringList(.RestaurantType), "The first Vegetarian-themed salad bar in Singapore. We provide brunch and lunch.", "vegie-bar.png", testRatingList, StringList(.Post), 5.0)
//        self.addRestaurant(restaurantFar)
////
//        let locationClose = CLLocation(latitude: 0.35212, longitude: 103.81985)
//        let restaurantClose = Restaurant(String(22), "Salad Heaven Close, Low Rating", "1 Marina Boulevard, #03-02", locationClose, "98765432", StringList(.RestaurantType), "The first Vegetarian-themed salad bar in Singapore. We provide brunch and lunch.", "vegie-bar.png", testRatingList, StringList(.Post), 4.0)
//        self.addRestaurant(restaurantClose)
        _checkRep()
    }
    
    // Check representation of the datasource
    private func _checkRep() {
        assert(checkIDUniqueness(), "IDs should be unique")
        assert(checkColumnUniqueness(), "Column titles should be unique")
    }
    
    private func checkIDUniqueness() -> Bool {
        var IdSet = Set<String>()
        var IdArray = [String]()
        do {
            for Id in try database.prepare(restaurantsTable.select(id)) {
                IdArray.append(Id[id])
                IdSet.insert(Id[id])
                if IdSet.count != IdSet.count {
                    return false
                }
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        
        return true
    }
    
    private func checkColumnUniqueness() -> Bool {
        var columnNameSet = Set<String>()
        var columnNameArray = [String]()
        do {
            let tableInfo = try database.prepare("PRAGMA table_info(table_name)")
            for line in tableInfo {
                columnNameSet.insert(line[1] as! String)
                columnNameArray.append(line[1] as! String)
                if columnNameArray.count != columnNameSet.count {
                    return false
                }
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        
        return true
    }
    
}

// Conform CLLocation to Value for SQLite
extension CLLocation: Value {
    public class var declaredDatatype: String {
        return String.declaredDatatype
    }
    public class func fromDatatypeValue(_ locationString: String) -> CLLocation {
        let coordinates = locationString.components(separatedBy: CharacterSet(charactersIn: "<,>")).flatMap({
            Double($0)
        })
        
        assert(coordinates.count == 2)
        
        let location = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
        return location
    }
    public var datatypeValue: String {
        let locationString = "<\(self.coordinate.latitude),\(self.coordinate.longitude)>"
        return locationString
    }
}

