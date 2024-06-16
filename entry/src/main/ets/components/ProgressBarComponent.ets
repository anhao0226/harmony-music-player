import { AudioService } from '../common/utils/AudioService';

@Component
export struct ProgressBarComponent {
  @Prop fontColor: string;
  @Prop selectedColor: string;
  @State trialDurationPointOffsetX: number = 0;
  private sliderWidth: number = 0;
  @StorageProp('PROGRESS') _progress: number = 0;
  @StorageProp('SONG_DURATION') _songDuration: number = 0;

  formatTime(value: number): string {
    const toSecond = value / 1000;
    return `${this.fillZero(toSecond / 60)}:${this.fillZero(toSecond % 60)}`;
  }

  fillZero(value: number): string {
    return value < 10 ? `0${parseInt(value.toString())}` : `${parseInt(value.toString())}`;
  }

  updateTrialDurationPointOffsetX() {
    // let offsetX: number = 0;
    // if (Math.abs(this.songDuration - this.validDuration) < 1000) offsetX = 0;
    // else if (this.songDuration && this.validDuration) {
    //   offsetX = (this.validDuration / this.songDuration) * this.sliderWidth;
    // }
    // this.trialDurationPointOffsetX = offsetX;
  }

  onAudioIdChange() {
    this.updateTrialDurationPointOffsetX();
  }

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.Start }) {
        Slider({ min: 0, max: this._songDuration, value: this._progress })
          .blockColor(this.selectedColor)
          .selectedColor(this.selectedColor)
          .onAreaChange((oldVal: Area, newVal: Area) => {
            this.sliderWidth = newVal.width as number;
            this.updateTrialDurationPointOffsetX();
          })
          .onChange((value: number, model: SliderChangeMode) => {
            if (model === SliderChangeMode.End) {
              AudioService.getInstance().seek(value);
            }
          });
        Row()
          .width(10)
          .height(10)
          .backgroundColor(this.selectedColor)
          .offset({ x: this.trialDurationPointOffsetX })
          .visibility(this.trialDurationPointOffsetX ? Visibility.Visible : Visibility.Hidden)
          .borderRadius(10);
      }.layoutWeight(1);
      /**
       *
       */
      Row() {
        Text(this.formatTime(this._progress))
          .fontSize(14)
          .fontColor('#66FFFFFF')
          .textAlign(TextAlign.Center);
        Text('Standard').fontColor('#66FFFFFF').textAlign(TextAlign.Center).fontSize(14);
        Text(this.formatTime(this._songDuration))
          .fontSize(14)
          .fontColor('#66FFFFFF')
          .textAlign(TextAlign.Center);
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 7, right: 7 });
    }.height('100%').width('100%');
  }
}