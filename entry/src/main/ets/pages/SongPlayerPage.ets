import { rgbaToHexColor } from '../common/utils/ColorUtil';
import { formatArtists } from '../view_models/playlist_song_model';
import notificationManager from '@ohos.notificationManager';
import { AudioService } from '../common/utils/AudioService';
import { SongInfoDialogComponent } from '../components/SongInfoIDialogContent';
import { LyricComponent } from '../components/LyricComponent';
import { AudioControlComponent, ControlEventType, ControlIcons } from '../components/AudioControlComponent';
import { fetchSongs } from '../api/SongApi';
import router from '@ohos.router';
import { AlbumComponent } from '../components/AlbumComponent';
import { Song } from '../models/SongModel';
import { FromRouterValue, PlaylistDialogComponent } from '../components/PlaylistDialogComponent';
import { IconComponent } from '../components/IconComponent';
import { CommentType } from '../api/CommentApi';
import effectKit from '@ohos.effectKit';


const storage = new LocalStorage({
  'SONG_ID': 0,
  'SONG_DURATION': 0,
  'MAIN_COLOR': '#B6C5D1',
});

@Entry(storage)
@Component
struct SongPlayerPage {
  private readonly TAG: string = 'SONG_PLAYER_PAGE';
  private _fromRouterValue: FromRouterValue = null;
  @State defaultColor: string = "#FFFFFF";
  @State playIconColor: string = '#77FFFFFF';
  @State _albumImageSrc: string = '';
  @State _songName: string = 'Unknown';
  @State _artistsText: string = 'unknown';
  @State _mainColor: string = '#A6C2BE';
  @State _leftWidth: number = 0;
  @StorageProp('AUDIO_ID') @Watch('onAudioChange') _audioId: number = 0;

  /**
   * songInfoDialogController
   */
  private songInfoDialogController: CustomDialogController = new CustomDialogController({
    gridCount: 5,
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogComponent({
      data: AudioService.getInstance().getCurrSong(),
    })
  });

  /**
   * playlistDialogController
   */
  private playlistDialogController: CustomDialogController = new CustomDialogController({
    gridCount: 7,
    customStyle: true,
    alignment: DialogAlignment.Bottom,
    builder: PlaylistDialogComponent({
      bgColor: this._mainColor,
      fromRouterValue: this._fromRouterValue,
      history: AudioService.getInstance().history(),
      playlist: AudioService.getInstance().playlist(),
      nextPlaylist: AudioService.getInstance().nextPlaylist(),
      onSongItemClick: (value: Song, index: number, flag: Object) => {
        AudioService.getInstance().start(index, flag);
      },
    }),
  });

  onPageShow() {
    let songId: number = this._audioId;
    const params = router.getParams();
    if (params) {
      if (params.hasOwnProperty('songId')) {
        songId = params['songId']
      }
      if (params.hasOwnProperty('from') && params['from']) {
        this._fromRouterValue = params['from'];
      }
    }

    this.initData(songId);
  }

  onAudioChange() {
    this.initData(this._audioId);
  }

  async initData(songId: number) {
    fetchSongs([songId]).then((result) => {
      const { songs } = result;
      if (songs.length > 0) {
        const song = songs[0];
        this._songName = song.name;
        this._artistsText = formatArtists(song.ar);
        this._albumImageSrc = song.al.picUrl;
      }
    });
  }

  @Builder NavTitle() {
    Row() {
      Row() {
        IconComponent({
          iconColor: '#99FFFFFF',
          resource: $r('app.media.ic_public_arrow_left_line'),
          onTap: () => router.back()
        });
      }.padding({ left: 24 });
      Column({ space: 6 }) {
        Text(this._songName)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.defaultColor);

        Text(this._artistsText)
          .fontColor(this.defaultColor)
          .onClick(() => {
            this.songInfoDialogController.open();
          })
      }.alignSelf(ItemAlign.End).layoutWeight(1);

      Row() {
        IconComponent({
          iconColor: '#99FFFFFF',
          resource: $r('app.media.ic_public_message_3_line'),
          onTap: () => {
            router.pushUrl({ url: 'pages/Comments', params: { id: this._audioId, type: CommentType.MUSIC } });
          }
        });
        IconComponent({
          iconColor: '#99FFFFFF',
          resource: $r('app.media.ic_public_album_fill'),
          onTap: () => {
          }
        });
      }.padding({ right: 24 });
    }
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Bottom)
  }

  build() {
    Column() {
      Column() {
        Column() {
          this.NavTitle();
        }.height(106).width('100%');

        Column() {
          //
          Row({}) {
            /**
             * left
             */
            Column() {
              AlbumComponent({
                src: this._albumImageSrc,
                getMainColor: (color: effectKit.Color) => {
                  const hexColor = rgbaToHexColor(color);
                  this._mainColor = hexColor;
                }
              }).width('100%');
            }
            .width('50%')
            .height('100%')
            .onAreaChange((_, newVal: Area) => {
              this._leftWidth = newVal.width as number;
            }).justifyContent(FlexAlign.SpaceAround);

            /**
             * right
             */
            Row() {
              LyricComponent().height(320);
            }.width('50%').height('100%');


          }.layoutWeight(1).width('100%');
          /**
           * AudioControlComponent
           */
          AudioControlComponent({
            icons: ControlIcons,
            onItemClick: (value) => {
              if (value === ControlEventType.PLAY_LIST) {
                this.playlistDialogController.open();
              }
            }
          }).margin({ bottom: 40 });


        }.layoutWeight(1).width('84%');
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this._mainColor)
      .animation({ duration: 625, curve: Curve.EaseIn })
      .justifyContent(FlexAlign.Center);
    }.backgroundColor('#A6C2BE');
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
}

@Component
struct _SongDetailDialogComponent {
  build() {

  }
}

// startContinuousTask() {
//   let wantAgentInfo: wantAgent.WantAgentInfo = {
//     wants: [{
//       bundleName: 'com.example.netease_cloud_music',
//       abilityName: 'com.example.netease_cloud_music.EntryAbility',
//     }],
//     operationType: wantAgent.OperationType.START_ABILITY,
//     requestCode: 0,
//     wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
//   }
//
//   wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
//     backgroundTaskManager.startBackgroundRunning(this.context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj)
//       .then(() => {
//         console.info(`Succeeded in operationing startBackgroundRunning.`);
//       }).catch((err) => {
//       console.error(`Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
//     })
//   })
// }
//
// stopContinuousTask() {
//   backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
//     console.info(`Succeeded in operationing stopBackgroundRunning.`);
//   }).catch((err) => {
//     console.error(`Failed to operation stopBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
//   });
// }
