//
//  ContentView.swift
//  Day2_Session2_TaskGroups
//
//  Created by Jeremy Fleshman on 8/3/21.
//

/**
 ​https://hws.dev/news-1.json
 */

struct NewsStory: Codable, Identifiable {
    let id: Int
    let title: String
    let strap: String
    let url: String
    let main_image: String
    let published_date: String
}

import SwiftUI

struct ContentView: View {
    @State private var stories = [NewsStory]()


    var body: some View {
        NavigationView {
            List(stories) { story in
                VStack(alignment: .leading) {
                    Text(story.title)
                        .font(.headline)

                    Text(story.strap)
                }

            }
            .navigationTitle("Latest News")
            .task(loadStories)
        }
    }

    func loadStories() async {
        do {
            try await withThrowingTaskGroup(of: [NewsStory].self) { group -> Void in
                for i in 1...5 {
                    group.addTask {
                        /// `cooperative cancellation` can ASK that it be canceled
                        /// But there needs to be handling for the cancellation or it'll continue doing its work
                        /// Apple's APIs have implicit cancellation handling to handle this
                        let url = URL(string: "https://hws.dev/news-\(i).json")!
                        let (data, _) = try await URLSession.shared.data(from: url)
                        try Task.checkCancellation()
                        return try JSONDecoder().decode([NewsStory].self, from: data)
                    }

                    for try await result in group {
                        stories.append(contentsOf: result)
                    }

                    stories.sort { $0.id > $1.id }
                }
            }
        } catch {
            print("Failed to load stories \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
