import effectKit from '@ohos.effectKit';
import image from '@ohos.multimedia.image';
import { createNetworkImagePixelMap } from '../common/utils/ColorUtil';

@Component
export struct ImageComponent {
  @Prop @Watch('onSrcChange') src: string;
  private componentWidth: number;
  private autoResize: boolean = false;
  private borderRadius_: number = 10;
  private onComplete?: (src: string, value: image.PixelMap) => void;
  private onCache?: (src: string, data?: image.PixelMap) => Promise<image.PixelMap>;
  //
  @State _imageData: image.PixelMap = null;
  @State _isComplete: boolean = false;

  onSrcChange() {
    this.handleImageData();
  }

  aboutToAppear() {
    this.handleImageData();
  }

  async handleImageData() {
    let imageData: image.PixelMap | undefined = null;
    if (this.onCache) {
      imageData = await this.onCache(this.src);
    }
    if (!imageData) {
      try {
        imageData = await createNetworkImagePixelMap(this.src);
      } catch (err) {
        console.log(`CreateNetworkImagePixelMap Error code: ${err.code} message: ${err.message}`);
      }
    }
    this._imageData = imageData;
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        if (this._imageData != null) {
          Image(this._imageData)
            .height(this.autoResize ? null : this.componentWidth)
            .aspectRatio(1)
            .borderRadius(this.borderRadius_)
            .autoResize(this.autoResize)
            .onComplete((event) => {
              this._isComplete = true;
              if (this.onComplete) this.onComplete(this.src, this._imageData);
            });
        }
        Column() {
          Image($r('app.media.ic_public_disc_fill')).fillColor('#354B47').width(30);
        }
        .height(this.componentWidth)
        .aspectRatio(1)
        .backgroundColor('#B6C6B3')
        .justifyContent(FlexAlign.Center)
        .borderRadius(10)
        .opacity(this._isComplete ? 0 : 1)
        .animation({ duration: 625, curve: Curve.Linear });
      };
    }
  }
}