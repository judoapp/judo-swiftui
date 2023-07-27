import SwiftUI
import Judo

struct ContentView: View {
    @State private var counter: Int = 0
    @State private var toggle: Bool = false

    var body: some View {
        VStack {
            Judo.View("Main", component: "Component 1", properties: ["counter": counter, "toggle": $toggle, "image": heart])
                .on("button.pressed") { _ in
                    counter += 1
                }

            Text("Switch is \(toggle ? "On" : "Off")")
        }
    }
    
    var heart: SwiftUI.Image {
        if #available(iOS 15.0, *) {
            return Image(systemName: "star.fill")
                .symbolRenderingMode(.multicolor)
        } else {
            return Image(systemName: "heart.fill")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ContentView()
    }
}
