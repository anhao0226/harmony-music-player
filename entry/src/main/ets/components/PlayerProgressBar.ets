import { AudioService } from '../common/utils/AudioService';

@Component
export struct PlayerProgressBar {
  @Prop fontColor: string;
  @Prop selectedColor: string;
  @StorageProp('DURATION') duration: number = 0;
  @StorageProp('PROGRESS') progress: number = 0;
  @StorageProp('SONG_TIME') songTime: number = 0;
  private maxWidth: number = 0;

  formatTime(value: number): string {
    const toSecond = value / 1000;
    return `${this.fillZero(toSecond / 60)}:${this.fillZero(toSecond % 60)}`;
  }

  fillZero(value: number): string {
    return value < 10 ? `0${parseInt(value.toString())}` : `${parseInt(value.toString())}`;
  }

  onMeasure(children: Array<LayoutChild>, constraint: ConstraintSizeOptions) {
    children.forEach((child) => {
      this.maxWidth = constraint.maxWidth as number;
      child.measure(constraint);
    })
  }

  calcValidMarkPos(): number {
    let result: number = 0;
    if (Math.abs(this.songTime - this.duration) < 1000) result = 0;
    else if (this.songTime && this.duration) {
      result = (this.duration / this.songTime) * (this.maxWidth - 120);
    }
    return result;
  }

  build() {
    Row() {
      Text(this.formatTime(this.progress))
        .width(60)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center);
      Stack({ alignContent: Alignment.Start }) {
        Slider({ min: 0, max: this.songTime, value: this.progress })
          .blockColor(this.selectedColor)
          .selectedColor(this.selectedColor)
          .onChange((value: number, model: SliderChangeMode) => {
            if (model === SliderChangeMode.End) {
              AudioService.getInstance().seek(value);
            }
          });
        Row()
          .width(10)
          .height(10)
          .backgroundColor(this.selectedColor)
          .margin({ left: `${this.calcValidMarkPos()}px` })
          .visibility(this.calcValidMarkPos() ? Visibility.Visible : Visibility.Hidden)
          .borderRadius(10);
      }.layoutWeight(1);
      Text(this.formatTime(this.songTime))
        .width(60)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center);
    }.height('100%')
  }
}