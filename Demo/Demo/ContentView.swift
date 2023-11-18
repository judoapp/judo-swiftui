import SwiftUI
import Judo

struct ContentView: View {
    @State private var counter: Int = 0
    @State private var toggle: Bool = false

    var body: some View {
        VStack {
            
            // From bundle, name extensions
            
            JudoView("Main")
                .component(.component1)
                .property(.counter, $counter)
                .property(.toggle, $toggle)
                .property(.image, star)
                .action(.buttonPressed) { _ in
                    counter += 1
                }
            
            Divider()
            
            // From URL, stringly typed
            
            let url = URL(string: "https://assets.rover.io/judo/example.judo")
            
            JudoAsyncView(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .failure(let error):
                    JudoErrorView(error).onAppear {
                        logError(error)
                    }
                case .success(let judoView):
                    judoView
                        .component("Component 1")
                        .properties([
                            "counter": $counter,
                            "toggle": $toggle
                        ])
                        .action("button.pressed") { _ in
                            counter += 1
                        }

                }
            }
        }
    }
    
    private var star: SwiftUI.Image {
        if #available(iOS 15.0, *) {
            return Image(systemName: "star.fill")
                .symbolRenderingMode(.multicolor)
        } else {
            return Image(systemName: "star.fill")
        }
    }
    
    private func logError(_ error: JudoError) {
        switch error {
        case .fileNotFound(let fileName):
            print("Judo: The file \"\(fileName)\" could not found")
        case .dataCorrupted:
            print("Judo: Unable to open file, data corrupted")
        case .emptyFile:
            print("Judo: Unable to open file, the file does not contain any components")
        case .downloadFailed(let statusCode, let underlyingError):
            print("Judo: Download failed with status code \(statusCode)")
            print("Judo: \(underlyingError.localizedDescription)")
        }
    }
}

extension ComponentName {
    static let component1 = ComponentName("Component 1")
}

extension PropertyName {
    static let counter = PropertyName("counter")
    static let toggle = PropertyName("toggle")
    static let image = PropertyName("image")
}

extension ActionName {
    static let buttonPressed = ActionName("button.pressed")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ContentView()
    }
}
