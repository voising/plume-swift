import Foundation

struct Quote {
    let text: String
    let author: String
}

class QuoteService {
    static let shared = QuoteService()
    
    private let quotes: [Quote] = [
        Quote(text: "The journey of a thousand miles begins with one step.", author: "Lao Tzu"),
        Quote(text: "What you do today can improve all your tomorrows.", author: "Ralph Marston"),
        Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
        Quote(text: "Your limitation—it's only your imagination.", author: "Unknown"),
        Quote(text: "Great things never come from comfort zones.", author: "Unknown"),
        Quote(text: "Success doesn't just find you. You have to go out and get it.", author: "Unknown"),
        Quote(text: "The harder you work for something, the greater you'll feel when you achieve it.", author: "Unknown"),
        Quote(text: "Dream bigger. Do bigger.", author: "Unknown"),
        Quote(text: "Don't stop when you're tired. Stop when you're done.", author: "Unknown"),
        Quote(text: "Wake up with determination. Go to bed with satisfaction.", author: "Unknown"),
        Quote(text: "Do something today that your future self will thank you for.", author: "Sean Patrick Flanery"),
        Quote(text: "Little things make big days.", author: "Unknown"),
        Quote(text: "It's going to be hard, but hard does not mean impossible.", author: "Unknown"),
        Quote(text: "Don't wait for opportunity. Create it.", author: "Unknown"),
        Quote(text: "Sometimes we're tested not to show our weaknesses, but to discover our strengths.", author: "Unknown"),
        Quote(text: "The key to success is to focus on goals, not obstacles.", author: "Unknown"),
        Quote(text: "Dream it. Believe it. Build it.", author: "Unknown"),
        Quote(text: "Be grateful for what you have while working for what you want.", author: "Unknown"),
        Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
        Quote(text: "Everything you've ever wanted is on the other side of fear.", author: "George Addair"),
        Quote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins"),
        Quote(text: "In the middle of every difficulty lies opportunity.", author: "Albert Einstein"),
        Quote(text: "What we think, we become.", author: "Buddha"),
    ]
    
    func dailyQuote() -> Quote {
        // Use date as seed for consistent quote per day
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysSince1970 = Int(today.timeIntervalSince1970 / 86400)
        let index = daysSince1970 % quotes.count
        return quotes[index]
    }
    
    func randomQuote() -> Quote {
        quotes.randomElement() ?? quotes[0]
    }
}
