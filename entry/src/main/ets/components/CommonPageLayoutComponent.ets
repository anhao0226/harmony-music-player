import router from '@ohos.router';
import effectKit from '@ohos.effectKit';
import {
  createNetworkImagePixelMap,
  getDarkColor,
  getImageMainColor,
  rgbaToHexColor
} from '../common/utils/ColorUtil';
import { CustomImage } from './ImageComponent';
import image from '@ohos.multimedia.image';

@Component
export struct CommonLayout {
  @BuilderParam leftContent: (() => void | void);
  @BuilderParam rightMenu: (() => void | void);
  @BuilderParam rightContent: (() => void | void);

  build() {
    Row() {
      Column() {
        this.leftContent();
      }.width('35%').height('100%');
      Column() {
        Column() {
          this.rightMenu();
        }
        .height(124)
        .width('100%')
        .justifyContent(FlexAlign.End)
        .backgroundColor('#F1F3F5');
        Column() {
          this.rightContent();
        }.backgroundColor('#FFFFFF').layoutWeight(1);
      }.width('65%').height('100%').backgroundColor(Color.Brown);
    }.width('100%').height('100%').backgroundColor(Color.Red);
  }
}


@Component
export struct AlbumImageComponent {
  @Prop imgWidth: number;
  @Prop @Watch('onImageSrcChange') imageSrc: string;
  private imageMainColor: (color: effectKit.Color) => void;

  aboutToAppear() {
    this.onImageSrcChange();
  }

  onImageSrcChange() {
    this.updateBackgroundColor();
  }

  async updateBackgroundColor() {
    if (this.imageMainColor && this.imageSrc.length) {
      try {
        let imageData: image.PixelMap = await createNetworkImagePixelMap(this.imageSrc);
        let mainColor: effectKit.Color = await getImageMainColor(imageData);
        this.imageMainColor(mainColor);
      } catch (e) {
      }
    }
  }

  getImageSrc(): string {
    return this.imageSrc;
  }

  build() {
    Stack() {
      Column()
        .height(this.imgWidth)
        .aspectRatio(1)
        .backgroundColor('#33000000')
        .offset({ x: 10, y: 10 })
        .borderRadius(10);
      CustomImage({
        imageSrc: this.getImageSrc(),
        imageWidth: this.imgWidth,
        imageBorderRadius: 6,
        imageAspectRatio: 1,
      });
    }
  }
}

@Component
export struct SongBaseInfoComponent {
  @Prop text: string;
  @Prop description: string;
  @Prop imageSrc: string;
  @Prop imgWidth: number;
  @BuilderParam closer: (() => void);
  private onColorChange: (mainColor: effectKit.Color) => void;
  //
  @State bgColor: string = '';
  private textColor: ResourceColor = '#A6C2BE';
  private descriptionColor: ResourceColor = '#A6C2BE';

  getImageScr(): string {
    return this.imageSrc;
  }

  getBackgroundColor(): ResourceColor {
    return this.bgColor || $r('app.color.default_background_color');
  }

  build() {
    Column({ space: 20 }) {
      //appbar
      Column() {
        Image($r('app.media.ic_public_arrow_left_line'))
          .width(30).fillColor('#66FFFFFF').onClick(() => router.back());
      }
      .height(124)
      .width('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start)
      .padding(16);
      //
      Column({ space: 20 }) {
        // album
        AlbumImageComponent({
          imageSrc: this.imageSrc,
          imgWidth: this.imgWidth,
          imageMainColor: (color: effectKit.Color) => {
            this.bgColor = rgbaToHexColor(color);
            this.textColor = rgbaToHexColor(getDarkColor(color, 0.1));
            this.descriptionColor = rgbaToHexColor({ ...color, 'alpha': 180 });
            if (this.onColorChange) this.onColorChange(color);
          }
        });
        //
        Column({ space: 10 }) {
          Text(this.text || '')
            .fontSize(22)
            .fontColor(this.textColor)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2);
          Text(this.description || '')
            .fontSize(15)
            .fontColor(this.descriptionColor)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2);
          //
          if (this.closer) this.closer();
        }.alignItems(HorizontalAlign.Start);
      }.width(this.imgWidth);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBackgroundColor())
    .animation({ duration: 325, curve: Curve.EaseIn });
  }
}
