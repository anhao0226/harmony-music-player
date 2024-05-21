import router from '@ohos.router';

@Component
export struct SplitLayout {
  @Prop bgColor: string;
  @BuilderParam closer: () => void;
  private pos: 'left'| 'right' = 'left';

  @Builder NavTitle() {
    Row() {
      Image($r('app.media.ic_public_back'))
        .width(30)
        .fillColor(Color.White)
        .onClick(() => router.back())
    }
    .height(142)
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ left: 34, right: 34 });
  }

  build() {
    if (this.pos === 'left') {
      // LEFT
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.bgColor)
          .animation({ curve: Curve.Linear });
        Column() {
          this.NavTitle();
          this.closer();
        }
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .backgroundBlurStyle(BlurStyle.Thin)
        .justifyContent(FlexAlign.Start);
      }.width('34%');
    } else if (this.pos === 'right') {
      // RIGHT
      Column() {
        Row().height(122).width('100%');
        Column() {
          this.closer()
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 14, topRight: 14 })
        .layoutWeight(1);
      }.backgroundColor('#F1F3F5').height('100%').layoutWeight(1);
    }
  }
}

