import router from '@ohos.router';
import effectKit from '@ohos.effectKit';
import {
  getDarkColor,
  getImageMainColor,
  getLightColor,
  getNetworkImagePixelMap,
  isCloseWhiteColor,
  rgbaToHexColor
} from '../common/utils/ColorUtil';
import { AlbumComponent } from './AlbumComponent';
import { ImageComponent } from './ImageComponent';

const _defaultNavHeight: number = 124;
const _defaultLLayoutWidth = '35%';
const _defaultRLayoutWidth = '65%';

export type BuilderCallback = () => void;

@Component
export struct CommonLayoutRComponent {
  @BuilderParam bodyBuilder?: BuilderCallback = this._defaultCloserBuildFunc;
  @BuilderParam menuBuilder?: BuilderCallback = this._defaultCloserBuildFunc;
  private _bgColor1: string = '#F1F3F5';
  private _bgColor2: string = '#FFFFFF';

  @Builder _defaultCloserBuildFunc() {
  }

  @Builder NavTitle() {
    Column() {
      Blank();
      Row() {
        this.menuBuilder();
      }
      .height(64)
      .width('100%')
      .padding({ left: 18, right: 18 });
    }.height(_defaultNavHeight).width('100%')
  }

  build() {
    Column() {
      this.NavTitle();
      Column() {
        this.bodyBuilder();
      }.padding({ top: 20 })
      .backgroundColor(this._bgColor2)
      .width('100%').layoutWeight(1);
    }
    .height('100%')
    .width(_defaultRLayoutWidth)
    .layoutWeight(1)
    .backgroundColor(this._bgColor1);
  }
}

export interface ColorChangeValue {
  mainColor: string;
  primaryTextColor: string;
  secondaryTextColor: string;
}

@Component
export struct CommonLayoutLComponent {
  @Prop name: string;
  @Prop description: string;
  @Prop @Watch('onImgSrcChange') imgSrc: string;
  private _backBtnColor: string = '#66FFFFFF';
  private onColorChange?: (value: ColorChangeValue) => void;
  @BuilderParam closer?: BuilderCallback = this._defaultCloserBuildFunc;
  //
  @State _mainColor: string = '#A6C2BE';
  @State _primaryTextColor: string = '#A6C2BE';
  @State _secondaryTextColor: string = '#A6C2BE';

  @Builder _defaultCloserBuildFunc() {
  }

  aboutToAppear() {
    this.getResourceValue($r('app.color.main_color')).then((value) => {
      this._mainColor = value;
    })
  }

  getResourceValue(resource: Resource): Promise<string> {
    return AppStorage.Get<Context>('CONTEXT').resourceManager.getStringValue(resource);
  }

  async updateBackgroundColor(color: effectKit.Color) {
    if (!isCloseWhiteColor(color)) {
      this._primaryTextColor = rgbaToHexColor(getDarkColor(color, 0.1));
      this._secondaryTextColor = rgbaToHexColor({ ...color, 'alpha': 180 });
      this._mainColor = rgbaToHexColor(color);
      if (this.onColorChange) this.onColorChange({
        primaryTextColor: this._primaryTextColor,
        secondaryTextColor: this._secondaryTextColor,
        mainColor: this._mainColor,
      });
    }
  }

  onImgSrcChange() {
    // this.updateBackgroundColor(this.imgSrc);
  }

  @Builder NavTitle() {
    Column() {
      Blank();
      Row() {
        Image($r('app.media.ic_public_arrow_left_line'))
          .width(30)
          .fillColor(this._backBtnColor)
          .onClick(() => router.back());
      }
      .height(64)
      .width('100%')
      .padding({ left: 24, right: 24 });
    }.height(_defaultNavHeight).width('100%')
  }

  build() {
    Stack() {
      Column() {
        this.NavTitle();
        Column({ space: 30 }) {
          //
          AlbumComponent({
            src: this.imgSrc,
            getMainColor: (color: effectKit.Color) => {
              this.updateBackgroundColor(color);
            },
          })
          //
          Column({ space: 10 }) {
            Text(this.name || '')
              .fontSize(22)
              .fontColor(this._primaryTextColor)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
            Text(this.description || '')
              .fontSize(15)
              .fontColor(this._secondaryTextColor)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(2);
          }.alignItems(HorizontalAlign.Start);

          if (this.closer) this.closer();

        }.width('66%').alignItems(HorizontalAlign.Start).layoutWeight(1).padding({ top: 20 });
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundBlurStyle(BlurStyle.Thin)
      .justifyContent(FlexAlign.Start);
    }
    .width(_defaultLLayoutWidth)
    .backgroundColor(this._mainColor)
    .animation({ duration: 625, curve: Curve.EaseIn });
  }
}