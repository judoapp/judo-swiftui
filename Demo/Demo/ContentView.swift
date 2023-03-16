import SwiftUI
import Judo

struct ContentView: View {
    var body: some View {
        Judo.View("Main", component: "Component 1")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ContentView()
    }
}
