import router from '@ohos.router';
import window from '@ohos.window';
import { fetchMovieDetail, fetchMovieUrl } from '../api/SongApi';
import { formatDuration } from '../common/utils/TimeUtil';

@Component
struct AppBar {
  @Prop title: string;
  @BuilderParam actions?: (() => void) = this._defaultBuilder;

  @Builder _defaultBuilder() {
  }

  build() {
    Row() {
      // leader
      Row({ space: 20 }) {
        Image($r('app.media.ic_public_arrow_left_line'))
          .fillColor('#99FFFFFF')
          .width(28)
          .aspectRatio(1)
          .onClick(() => {
            router.back();
          });
        Text(this.title).fontColor('#99FFFFFF').fontSize(20);
      }.padding({ left: 16 })

      Blank();
      // actions
      Row() {
        if (this.actions) this.actions();
      }
    }.height(124).width('100%');
  }
}

@Entry
@Component
struct MvPlayerPage {
  @State previewUri: string = '';
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X;
  @State isAutoPlay: boolean = false;
  @State showControls: boolean = true;
  @State sliderStartTime: string = '';
  @State durationStringTime: string = '';
  @State _isPlaying: boolean = false;
  @State _currentTime: number = 0;
  @State _durationTime: number = 0;
  @State _mvName: string = '';
  @State _videoSrc: string = '';
  private _controller: VideoController = new VideoController();

  onPageShow() {
    const params = router.getParams();
    let mvId: number = 5436712;
    if (params && params.hasOwnProperty('mvId')) {
      mvId = params['mvId'];
    }
    this.initData(mvId);
  }

  initData(mvId: number) {
    //
    fetchMovieDetail(mvId).then((res) => {
      this._mvName = res.name;
    })
    //
    fetchMovieUrl(mvId).then((res) => {
      this._videoSrc = res.url;
    });
  }

  handleDoubleTapGestureEvent(event: GestureEvent) {
    if (this._isPlaying) {
      this._controller.pause();
      this._isPlaying = false;
    } else {
      this._controller.start();
      this._isPlaying = true;
    }
  }

  handleOnPrepared() {
    return (event: { duration: number }) => {
      this._durationTime = event.duration
      this._controller.start();
      this._isPlaying = true;
    }
  }

  handleOnUpdate(event ?: { time: number }) {
    this._currentTime = event.time
  }

  @Builder
  BottomControl() {
    Row() {
      Row({ space: 10 }) {
        if (this._isPlaying) {
          Image($r('app.media.ic_public_pause_large_fill')).fillColor(Color.White).width(28)
        } else {
          Image($r('app.media.ic_public_play_large_fill')).fillColor(Color.White).width(28)
        }
      }.margin({ left: 20, right: 40 });
      //
      Row({ space: 4 }) {
        //
        Text(formatDuration(this._currentTime)).fontColor(Color.White)
        //
        Slider({ min: 0, max: this._durationTime, value: this._currentTime })
          .onChange((value: number, mode: SliderChangeMode) => {
            this._controller.setCurrentTime(value);
          })
          .trackColor('#99FFFFFF')
          .selectedColor('#A6C2BE')
          .layoutWeight(1)
        //
        Text(formatDuration(this._durationTime)).fontColor(Color.White)

      }.layoutWeight(1).margin({ right: 20 });
    }.height(56);
  }

  build() {
    Column() {
      AppBar({ title: this._mvName });
      //
      Video({
        src: this._videoSrc,
        previewUri: this.previewUri,
        currentProgressRate: this.curRate,
        controller: this._controller
      })
        .controls(false)
        .gesture(TapGesture({ count: 2 })
          .onAction(this.handleDoubleTapGestureEvent.bind(this)))
        .onPrepared(this.handleOnPrepared())
        .onUpdate(this.handleOnUpdate.bind(this))
        .layoutWeight(1);
      //
      this.BottomControl();
    }.width('100%').height('100%').backgroundColor(Color.Black);
  }
}