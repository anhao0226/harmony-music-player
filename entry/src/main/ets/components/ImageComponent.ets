import image from '@ohos.multimedia.image';
import { createNetworkImagePixelMap } from '../common/utils/ColorUtil';

/**
 * @deprecated
 */
@Component
export struct ImageComponent {
  @Prop @Watch('onSrcChange') src: string;
  private componentWidth: number;
  private imageWidth: number = 100;
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
            .height(this.autoResize ? null : (this.imageWidth || this.componentWidth))
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


enum ImageState { Loading, Error, Normal };

@Component
export struct CustomImage {
  @Prop @Watch('onSrcChange') imageSrc: string;
  @Prop imageWidth: number;
  @BuilderParam loadingComponent: (() => void | void) = this._defaultLoadingBuilder;
  @BuilderParam errorComponent: (() => void | void) = this._defaultLoadingBuilder;
  @State protected state: ImageState = ImageState.Loading;
  private imageAspectRatio: number = 0.9;
  private imageBorderRadius: number = 2;
  private autoResize: boolean = false;
  private onComplete?: () => void;

  onSrcChange() {

  }

  @Builder _defaultLoadingBuilder() {
    Image($r('app.media.ic_public_disc_fill')).fillColor('#354B47').width(30);
  }

  @Builder _imageStateWrapper() {
    if (this.state !== ImageState.Normal) {
      Column() {
        if (this.state === ImageState.Loading) {
          this.loadingComponent();
        } else if (this.state === ImageState.Error) {
          this.errorComponent();
        }
      }
      .width(this.imageWidth)
      .aspectRatio(this.imageAspectRatio)
      .backgroundColor('#B6C6B3')
      .justifyContent(FlexAlign.Center)
      .borderRadius(this.imageBorderRadius)
      .transition({ type: TransitionType.Insert, opacity: 1 })
      .transition({ type: TransitionType.Delete, opacity: 0 })
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Image(this.imageSrc)
          .width(this.imageWidth)
          .aspectRatio(this.imageAspectRatio)
          .borderRadius(this.imageBorderRadius)
          .autoResize(this.autoResize)
          .onComplete((event) => {
            animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
              this.state = ImageState.Normal;
              this.loadingComponent = null;
            })
            if (this.onComplete) this.onComplete();
          })
          .onError(() => {
            animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
              this.state = ImageState.Error;
            })
          });

        if (this.state === ImageState.Loading) {
          this._imageStateWrapper();
        } else if (this.state === ImageState.Error) {
          this._imageStateWrapper();
        }
      }
    }
  }
}