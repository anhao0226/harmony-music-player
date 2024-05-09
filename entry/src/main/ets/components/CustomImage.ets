import image from '@ohos.multimedia.image';

@Component
export struct CustomImage {
  private src: string | image.PixelMap | Resource = '';
  private isComplete: boolean = true;

  build() {
    if (!this.isComplete) {
      Row(){
        LoadingProgress().height(42)
      }.aspectRatio(1).backgroundColor(Color.Gray).borderRadius(6);
    } else {
      Image(this.src).aspectRatio(1).borderRadius(6).onComplete((event) => {
        this.isComplete = true;
      })
    }
  }
}