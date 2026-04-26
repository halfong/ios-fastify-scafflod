import SwiftUI

struct UITestBlock: View {
    var body: some View {
        // UI Testing Area
        VStack( alignment: .leading, spacing: 6 ){
          Text("UI Testing").lato(.t3)
          Text("Any text for UI testing purpose. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.").lato(.t4).foregroundColor(.text1)
          Text("For special not important notes, you can pin them to the top of your list for easy access.")
            .lato(.t5).foregroundColor(.text2)

          VStack(alignment: .leading, spacing: 6){
            Text("UI Testing").lato(.t3)
            Text("Any text for UI testing purpose. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.").lato(.t4).foregroundColor(.text1)
            Text("For special not important notes, you can pin them to the top of your list for easy access.")
              .lato(.t5).foregroundColor(.text2)
          }
          .padding(.all,20)
          .background(.bg1)
          .cornerRadius(UISize.cornerRadius)

        }.padding( .horizontal, UISize.screenXPadding)
    }
}