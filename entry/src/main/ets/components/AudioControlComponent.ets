import { AvPlayMode, PlayModeArray } from '../common/utils/AudioConfig';
import { AudioService } from '../common/utils/AudioService';
import { ProgressBarComponent } from './ProgressBarComponent';
import { IconDataInterface } from './SongItemComponent';

export enum ControlActionType {
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
  type?: ControlActionType;
}

export const ControlIcons: ControlIconInterface[] = [
  {
    size: 24,
    fillColor: '#99FFFFFF',
    icon: $r('app.media.ic_public_order_play_line'),
    type: ControlActionType.PLAY_MODE,
  },
  {
    size: 36,
    padding: 6,
    fillColor: '#99FFFFFF',
    icon: $r('app.media.ic_public_skip_back_fill'),
    type: ControlActionType.PLAY_LAST,
    backgroundColor: '#33FFFFFF',
  },
  {
    size: 60,
    padding: 10,
    fillColor: '#99FFFFFF',
    icon: $r('app.media.ic_public_play_large_fill'),
    type: ControlActionType.PLAY_STATE,
    backgroundColor: '#33FFFFFF'
  },
  {
    size: 36,
    padding: 6,
    fillColor: '#99FFFFFF',
    icon: $r('app.media.ic_public_skip_forward_fill'),
    type: ControlActionType.PLAY_NEXT,
    backgroundColor: '#33FFFFFF',
  },
  {
    size: 24,
    fillColor: '#99FFFFFF',
    icon: $r('app.media.ic_public_play_list_line'),
    type: ControlActionType.PLAY_LIST,
  }
]

const PlayModeIcons: Resource[] = [
$r('app.media.ic_public_order_play_line'),
$r('app.media.ic_public_shuffle_line'),
$r('app.media.ic_public_repeat_one_line'),
$r('app.media.ic_public_repeat_2_fill')
];

@Component
export struct AudioControlComponent {
  private icons: ControlIconInterface[] = [];
  @State _fontColor: string = '#FFFFFF';
  @State _sliderSelectedColor: string = '#77FFFFFF';
  private onItemClick: (type: ControlActionType) => void;

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
      Row({ space: 66 }) {
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
  @State _iconData: Resource | null = null;
  @StorageProp('PLAY_MODE') _playMode: number = AvPlayMode.ORDER;
  @StorageProp('IS_PLAYING') @Watch('onPlayStateChange') isPlaying: boolean = false;
  private onItemClick: (value: ControlActionType) => void;

  aboutToAppear() {
    this._iconData = this.icon.icon as Resource;
    if (this.icon.type === ControlActionType.PLAY_MODE) {
      this._iconData = PlayModeIcons[this._playMode];
    } else if (this.icon.type === ControlActionType.PLAY_STATE) {
      this.onPlayStateChange();
    }
  }

  onPlayStateChange() {
    if (this.icon.type === ControlActionType.PLAY_STATE) {
      this._iconData = this.isPlaying ? $r('app.media.ic_public_pause_large_fill') : $r('app.media.ic_public_play_large_fill');
    }
  }

  handleIconClick() {
    if (this.onItemClick) this.onItemClick(this.icon.type);
    switch (this.icon.type) {
      case ControlActionType.PLAY_MODE:
        this.handlePlayModeChange();
        break;
      case ControlActionType.PLAY_LAST:
        AudioService.getInstance().playPrevious();
        break;
      case ControlActionType.PLAY_STATE:
        this.handlePlayStateChange();
        break;
      case ControlActionType.PLAY_NEXT:
        AudioService.getInstance().playNext();
        break;
      case ControlActionType.PLAY_LIST:
      // this.playlistDialogController.open();
        break;
    }
  }

  handlePlayStateChange(): void {
    if (this.isPlaying) AudioService.getInstance().pause();
    else AudioService.getInstance().play();
  }

  handlePlayModeChange() {
    let index = AudioService.getInstance().getPlayMode() + 1;
    if (index > PlayModeArray.length - 1) index = 0;
    this._iconData = PlayModeIcons[index];
    AudioService.getInstance().setPlayMode(PlayModeArray[index]);
  }

  build() {
    Image(this._iconData)
      .aspectRatio(1)
      .width(this.icon.size)
      .fillColor(this.icon.fillColor)
      .backgroundColor(this.icon.backgroundColor)
      .borderRadius(this.icon.size)
      .padding(this.icon.padding)
      .backgroundColor(this.icon.backgroundColor)
      .onClick(() => this.handleIconClick());
  }
}
