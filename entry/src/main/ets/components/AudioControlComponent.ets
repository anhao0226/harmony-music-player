import { AvPlayMode } from '../common/utils/AudioConfig';
import { AudioService } from '../common/utils/AudioService';
import { ProgressBarComponent } from './ProgressBarComponent';

export enum ControlEventType {
  PLAY_MODE,
  PLAY_LAST,
  PLAY_STATE,
  PLAY_NEXT,
  PLAY_LIST,
}

interface ControlIconInterface {
  size: number;
  icon: Resource | string;
  fillColor: string;
  backgroundColor?: string;
  padding?: number;
  type?: ControlEventType;
}

export const ControlIcons: ControlIconInterface[] = [
  {
    size: 24,
    fillColor: '#66FFFFFF',
    icon: $r('app.media.ic_public_order_play_line'),
    type: ControlEventType.PLAY_MODE,
  },
  {
    size: 32,
    fillColor: '#99FFFFFF',
    icon: $r('app.media.ic_public_skip_back_fill'),
    type: ControlEventType.PLAY_LAST,
  },
  {
    size: 60,
    padding: 10,
    fillColor: '#99FFFFFF',
    // backgroundColor: '#33FFFFFF',
    icon: $r('app.media.ic_public_play_large_fill'),
    type: ControlEventType.PLAY_STATE,
  },
  {
    size: 32,
    fillColor: '#99FFFFFF',
    icon: $r('app.media.ic_public_skip_forward_fill'),
    type: ControlEventType.PLAY_NEXT,
  },
  {
    size: 24,
    fillColor: '#66FFFFFF',
    icon: $r('app.media.ic_public_play_list_line'),
    type: ControlEventType.PLAY_LIST,
  }
]

@Component
export struct AudioControlComponent {
  private icons: ControlIconInterface[] = [];
  @State _fontColor: string = '#FFFFFF';
  @State _sliderSelectedColor: string = '#77FFFFFF';
  private onItemClick: (type: ControlEventType) => void;

  build() {
    Column({ space: 16 }) {
      /**
       * PlayerProgressBar
       */
      ProgressBarComponent({
        fontColor: this._fontColor,
        selectedColor: this._sliderSelectedColor,
      }).width('100%').height(40);

      /**
       * _ControlIconComponent
       */
      Row({ space: 60 }) {
        ForEach(this.icons, (item: ControlIconInterface) => {
          _ControlIconComponent({ icon: item, onItemClick: (value) => {
            if (this.onItemClick) this.onItemClick(value);
          } })
        }, (_, index: number) => `${index}_CONTROL_ICON`);
      }.width('100%').padding({ left: 10, right: 10 }).justifyContent(FlexAlign.Center);
    }
  }
}

@Component
struct _ControlIconComponent {
  private icon: ControlIconInterface | null = null;
  @State _currentIconResource: Resource | null = null;
  @StorageProp('IS_PLAYING') @Watch('onPlayStateChange') isPlaying: boolean = false;
  private onItemClick: (value: ControlEventType) => void;

  aboutToAppear() {
    this._currentIconResource = this.icon.icon as Resource;
    this.onPlayStateChange();
  }

  onPlayStateChange() {
    if (this.icon.type === ControlEventType.PLAY_STATE) {
      this._currentIconResource = this.isPlaying ? $r('app.media.ic_public_pause_large_fill') : $r('app.media.ic_public_play_large_fill');
    }
  }

  handleIconClick() {
    if (this.onItemClick) this.onItemClick(this.icon.type);
    switch (this.icon.type) {
      case ControlEventType.PLAY_MODE:
        this.handlePlayModeChange();
        break;
      case ControlEventType.PLAY_LAST:
        AudioService.getInstance().playPrevious();
        break;
      case ControlEventType.PLAY_STATE:
        this.handlePlayStateChange();
        break;
      case ControlEventType.PLAY_NEXT:
        AudioService.getInstance().playNext();
        break;
      case ControlEventType.PLAY_LIST:
      // this.playlistDialogController.open();
        break;
    }
  }

  handlePlayStateChange() {
    if (this.isPlaying) AudioService.getInstance().pause();
    else AudioService.getInstance().play();
  }

  handlePlayModeChange() {
    const resource = [
    $r('app.media.ic_public_order_play_line'),
    $r('app.media.ic_public_shuffle_line'),
    $r('app.media.ic_public_repeat_one_line'),
    $r('app.media.ic_public_repeat_2_fill')];
    const modeArr = [AvPlayMode.ORDER, AvPlayMode.RANDOM, AvPlayMode.SINGLE_CYCLE, AvPlayMode.LIST_CYCLE];
    let index = AudioService.getInstance().getPlayMode() + 1;
    if (index > modeArr.length - 1) index = 0;
    this._currentIconResource = resource[index];
    AudioService.getInstance().setPlayMode(modeArr[index]);
  }

  build() {
    Image(this._currentIconResource)
      .aspectRatio(1)
      .width(this.icon.size)
      .fillColor(this.icon.fillColor)
      .backgroundColor(this.icon.backgroundColor)
      .borderRadius(this.icon.size)
      .padding(this.icon.padding)
      .onClick(() => this.handleIconClick());
  }
}
