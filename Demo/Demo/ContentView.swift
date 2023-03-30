import SwiftUI
import Judo

struct ContentView: View {
    @State private var counter: Int = 0

    var body: some View {
        Judo.View("Main", component: "Component 1", properties: ["counter": counter, "image": heart])
            .on("button.pressed") { _ in
                counter += 1
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
