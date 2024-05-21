import {
  getImageMainColor,
  rgbaToHexColor,
  getDarkColor,
  getNetworkImagePixelMap
} from '../common/utils/ColorUtil';
import { defaultSongItem, formatArtists, SongModel } from '../view_models/playlist_song_model';
import wantAgent from '@ohos.app.ability.wantAgent';
import { WantAgent } from '@ohos.wantAgent';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import notificationManager from '@ohos.notificationManager';
import { AudioService } from '../common/utils/AudioService';
import emitter from '@ohos.events.emitter';
import { SongListCustomDialog } from '../components/SongListCustomDialog';
import { EventId, SongPlayMode } from '../common/utils/AudioConfig';
import { PlayerProgressBar } from '../components/PlayerProgressBar';
import { SongInfoDialogContent } from '../components/SongInfoIDialogContent';


let localStorage = new LocalStorage({ 'PropA': 47 });

@Entry(localStorage)
@Component
struct SongPlayerPage {
  @State bgColor: string = '#B6C5D1';
  @State defaultColor: string = "#FFFFFF";
  @State playIconColor: string = '#77FFFFFF';
  @State sliderSelectedColor: string = '#77FFFFFF';
  @State context: Context = getContext(this);
  @State imageData: Resource | PixelMap = $r('app.media.ic_device_earphone_filled');
  @State songItem: SongModel = defaultSongItem;
  @State songPlayMode: SongPlayMode = SongPlayMode.ORDER;
  @State playModeIconResource: Resource = $r('app.media.ic_public_order_play');
  //
  @StorageProp('IS_PLAYING') isPlay: boolean = false;
  @StorageProp('CURR_AUDIO_ID') @Watch('onCurrAudioChange') currAudioId: number = 0;
  // //
  dialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Bottom,
    builder: SongListCustomDialog({
      songs: AudioService.getInstance().playlist(),
      onItemClick: (_, index) => {
        AudioService.getInstance().start(index);
      }
    }),
  })
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogContent({ data: AudioService.getInstance().getCurrSong() })
  })

  onPageShow() {
    this.initData(AudioService.getInstance().getCurrSong());
    emitter.on({ eventId: EventId.CHANGE_SONG }, async (data: emitter.EventData) => {
      this.initData(JSON.parse(data.data['song']));
    })

  }

  onPageHide() {
    emitter.off(EventId.CHANGE_SONG);
  }

  async initData(song: SongModel) {
    this.songItem = song;
    this.imageData = await getNetworkImagePixelMap(song.al.picUrl);
    const mainColor = await getImageMainColor(this.imageData)
    this.bgColor = rgbaToHexColor(mainColor);
    this.sliderSelectedColor = rgbaToHexColor(getDarkColor(mainColor, 0.2));
  }

  formatTime(value: number): string {
    const toSecond = value / 1000;
    return `${this.fillZero(toSecond / 60)}:${this.fillZero(toSecond % 60)}`;
  }

  fillZero(value: number): string {
    return value < 10 ? `0${parseInt(value.toString())}` : `${parseInt(value.toString())}`;
  }

  onCurrAudioChange() {

  }

  @Builder NavTitle() {
    Row() {
      Column({ space: 6 }) {
        Text(this.songItem.id > 0 ? this.songItem.name : "Unknown")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.defaultColor);

        Text(formatArtists(this.songItem.ar)).fontColor(this.defaultColor).onClick(() => {
          this.songInfoDialogController.open();
        })


      }.alignSelf(ItemAlign.End)
    }
    // .backgroundColor(Color.Red)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceAround);
  }

  @Builder SongPlayModeUI() {
    Image(this.playModeIconResource)
      .width(40)
      .height(40)
      .fillColor(this.defaultColor)
      .padding(6)
      .onClick(() => this.handlePlayModeChange())
  }

  build() {
    Navigation() {
      Column() {

        Row() {
          if (this.songItem.id > 0) {
            Image(this.songItem.al.picUrl)
              .width(320)
              .height(320)
              .borderRadius(160)
              .borderColor(this.sliderSelectedColor);
          } else {
            Image($r('app.media.ic_device_earphone_filled'))
              .width(320)
              .height(320);
          }
        }.layoutWeight(1);

        Column({ space: 20 }) {
          PlayerProgressBar({
            fontColor: this.defaultColor,
            selectedColor: this.sliderSelectedColor
          }).width('80%').height(40);
          //
          Row({ space: 50 }) {
            this.SongPlayModeUI();

            Image($r('app.media.ic_public_play_last'))
              .width(30)
              .onClick(() => {
                AudioService.getInstance().playPrevious()
              })
              .width(50)
              .padding(10)
              .borderRadius(25)
              .fillColor(this.defaultColor)
              .backgroundColor('#33FFFFFF');

            Image(this.isPlay ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'))
              .animation({ duration: 300, curve: Curve.Linear })
              .onClick(() => {
                if (this.isPlay) {
                  AudioService.getInstance().pause();
                } else {
                  AudioService.getInstance().play();
                }
              })
              .width(70)
              .padding(12)
              .borderRadius(35)
              .fillColor(this.defaultColor)
              .backgroundColor('#33FFFFFF');

            Image($r('app.media.ic_public_play_next'))
              .width(50)
              .padding(10)
              .borderRadius(30)
              .fillColor(this.defaultColor)
              .backgroundColor('#33FFFFFF')
              .onClick(() => {
                AudioService.getInstance().playNext();
              });

            Image($r('app.media.ic_public_drawer'))
              .width(30)
              .fillColor(this.defaultColor)
              .onClick(() => {
                this.dialogController.open();
              });
          }
        }
        .height(200)
        .justifyContent(FlexAlign.Center)

      }
      .height('100%')
      .width('100%')
    }
    .title(this.NavTitle())
    .titleMode(NavigationTitleMode.Free)
    .navBarWidth('100%')
    .backgroundColor(this.bgColor)
    .animation({ duration: 300, curve: Curve.Linear });
  }

  pageTransition() {
    PageTransitionEnter({ duration: 310, curve: Curve.LinearOutSlowIn })
      .slide(SlideEffect.Bottom);
    PageTransitionExit({ duration: 310, curve: Curve.LinearOutSlowIn })
      .slide(SlideEffect.Bottom);
  }

  pushNotification() {
    notificationManager.isSupportTemplate('downloadTemplate').then((value) => {
      console.log(`Template: ${value}`);
    }).catch((err) => {
      console.error(`Failed to support download template notification. Code is ${err.code}, message is ${err.message}`);
    });

  }

  handlePlayModeChange() {
    const resource = [$r('app.media.ic_public_order_play'), $r('app.media.ic_public_random'), $r('app.media.ic_public_single_cycle'), $r('app.media.ic_public_list_cycle')];
    const modeArr = [SongPlayMode.ORDER, SongPlayMode.RANDOM, SongPlayMode.SINGLE_CYCLE, SongPlayMode.LIST_CYCLE];
    let index = AudioService.getInstance().getPlayMode() + 1;
    if (index > modeArr.length - 1) index = 0;
    this.songPlayMode = modeArr[index];
    this.playModeIconResource = resource[index];
    AudioService.getInstance().updatePlayMode(this.songPlayMode);
  }

  startContinuousTask() {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{
        bundleName: 'com.example.netease_cloud_music',
        abilityName: 'com.example.netease_cloud_music.EntryAbility',
      }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      backgroundTaskManager.startBackgroundRunning(this.context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj)
        .then(() => {
          console.info(`Succeeded in operationing startBackgroundRunning.`);
        }).catch((err) => {
        console.error(`Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
      })
    })
  }

  stopContinuousTask() {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
      console.info(`Succeeded in operationing stopBackgroundRunning.`);
    }).catch((err) => {
      console.error(`Failed to operation stopBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
    });
  }
}