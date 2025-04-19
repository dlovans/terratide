import Foundation

enum TideCategory: String, CaseIterable, Codable {
    // Social and Community
    case social = "Social"
    case networking = "Networking"
    // Outdoor and Adventure
    case outdoor = "Outdoor"
    case hiking = "Hiking"
    case biking = "Biking"
    case climbing = "Climbing"
    case camping = "Camping"
    case beach = "Beach"
    case sports = "Sports"
    case running = "Running"
    case swimming = "Swimming"
    
    // Food and Drinks
    case food = "Food"
    case coffee = "Coffee"
    case brunch = "Brunch"
    case dinner = "Dinner"
    case cooking = "Cooking"
    case baking = "Baking"
    case wine = "Wine Tasting"
    case beer = "Beer Tasting"
    
    // Arts and Culture
    case arts = "Arts"
    case music = "Music"
    case concerts = "Concerts"
    case theater = "Theater"
    case museums = "Museums"
    case photography = "Photography"
    case dance = "Dance"
    case writing = "Writing"
    case reading = "Book Club"
    
    // Learning and Growth
    case learning = "Learning"
    case language = "Language Exchange"
    case coding = "Coding"
    case business = "Business"
    case investing = "Investing"
    case career = "Career"
    case workshop = "Workshop"
    
    // Wellness and Health
    case wellness = "Wellness"
    case yoga = "Yoga"
    case meditation = "Meditation"
    case fitness = "Fitness"
    case mental = "Mental Health"
    
    // Gaming and Digital
    case digital = "Digital"
    case gaming = "Gaming"
    case videoGames = "Video Games"
    case boardGames = "Board Games"
    case roleplay = "Role-Playing"
    case vr = "Virtual Reality"
    
    // Travel and Exploration
    case travel = "Travel"
    case localTourism = "Local Tourism"
    case roadTrip = "Road Trip"
    case backpacking = "Backpacking"
    
    // Causes and Activism
    case volunteering = "Volunteering"
    case environment = "Environmental"
    case community = "Community Service"
    case activism = "Activism"
    
    // Miscellaneous
    case pets = "Pets & Animals"
    case crazy = "Crazy"
    case spontaneous = "Spontaneous"
    case mystery = "Mystery"
    case other = "Other"

    // Random
    case random = "Random"
    case anythingCanHappen = "Anything Can Happen"
    case notDecided = "Not Decided"
    
    // Helper method to get categories by group
    static func categoriesByGroup() -> [String: [TideCategory]] {
        return [
            "Social & Community": [.social, .networking],
            "Outdoor & Adventure": [.outdoor, .hiking, .biking, .climbing, .camping, .beach, .sports, .running, .swimming],
            "Food & Drinks": [.food, .coffee, .brunch, .dinner, .cooking, .baking, .wine, .beer],
            "Arts & Culture": [.arts, .music, .concerts, .theater, .museums, .photography, .dance, .writing, .reading],
            "Learning & Growth": [.learning, .language, .coding, .business, .investing, .career, .workshop],
            "Wellness & Health": [.wellness, .yoga, .meditation, .fitness, .mental],
            "Gaming & Digital": [.digital, .gaming, .videoGames, .boardGames, .roleplay, .vr],
            "Travel & Exploration": [.travel, .localTourism, .roadTrip, .backpacking],
            "Causes & Activism": [.volunteering, .environment, .community, .activism],
            "Miscellaneous": [.pets, .crazy, .spontaneous, .mystery, .other],
            "Random": [.random, .anythingCanHappen, .notDecided]
        ]
    }
}
