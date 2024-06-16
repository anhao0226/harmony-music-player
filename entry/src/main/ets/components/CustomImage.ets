import image from '@ohos.multimedia.image';

@Component
export struct CustomImage {
  private src: string | image.PixelMap | Resource = '';
  @State isComplete: boolean = false;
  @Prop imageWidth: number;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image(this.src)
        .width(this.imageWidth)
        .height(this.imageWidth)
        .aspectRatio(1)
        .borderRadius(10)
        .onComplete((event) => {
          this.isComplete = true;
        });

      Column() {
        Image($r('app.media.ic_public_album_fill')).width(60).height(60);
      }
      .width(this.imageWidth)
      .height(this.imageWidth)
      .backgroundColor('#19000000')
      .borderRadius(10)
      .opacity(this.isComplete ? 0 : 1)
      .animation({ duration: 325, curve: Curve.Ease })
      .justifyContent(FlexAlign.Center)
    }
  }
}