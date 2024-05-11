import window from '@ohos.window'
@Entry
@Component
struct Setting {
  @State message: string = 'Hello World'
  private subWindow: window.Window

  aboutToAppear(){
    this.subWindow = window.findWindow('myCustomDialog');
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%').width('100%').backgroundColor(Color.Brown)
  }
}