import effectKit from '@ohos.effectKit';
import image from '@ohos.multimedia.image';
import { getImageMainColor } from '../common/utils/ColorUtil';
import { ImageComponent } from './ImageComponent';

@Component
export struct AlbumComponent {
  @Prop @Watch('onSrcChange') src: string;
  private componentWidth: number;
  private componentHeight: number;
  private getMainColor: (color: effectKit.Color) => void;

  onSrcChange() {
    console.log(`AlbumComponent ${this.src}`);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .height(320)
        .aspectRatio(1)
        .backgroundColor('#33000000')
        .offset({ x: 10, y: 10 })
        .borderRadius(10);
      ImageComponent({
        src: this.src,
        componentWidth: 320,
        onComplete: (src: string, data: image.PixelMap) => {
          getImageMainColor(data).then((color) => {
            if (this.getMainColor) this.getMainColor(color);
          }).catch((err) => {
            console.log(err);
          })
        },
        onCache: async (src: string) => {
          // return AppStorage.Get(src);
          return null;
        }
      });
    }.width('100%');
  }
}
