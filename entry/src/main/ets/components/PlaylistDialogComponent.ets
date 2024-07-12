import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { ListType } from '../common/utils/AudioShareData';
import { DataSource } from '../models/DataSource';
import { Song } from '../models/SongModel';
import { ActionType } from './SongItemComponent';
import { SongListComponent } from './SongListComponent';

export interface FromRouterValue {
  state: router.RouterState
  params: Object
}

@CustomDialog
export struct PlaylistDialogComponent {
  private onSongItemClick: (song: Song, index: number, flag?: Object) => void;
  private controller?: CustomDialogController
  private fromRouterValue: FromRouterValue = null;
  private bgColor: string = '#FFFFFF';
  @State _routerName: string = '';
  @State _renderNextQueue: Song[] = null;

  aboutToAppear() {
    //
    // if (this.nextPlaylist) {
    //   this._renderNextQueue = [...this.nextPlaylist].reverse();
    // }
    //
    if (this.fromRouterValue) {
      const { name } = this.fromRouterValue.state;
      if (name === 'AlbumDetailPage') {
        this._routerName = 'Album';
      } else if (name === 'ArtistDetailPage') {
        this._routerName = 'Artist';
      } else if (name === 'PlaylistDetailPage') {
        this._routerName = 'Playlist';
      }
    }
  }

  handleSongItemClick(song: Song, index: number, flag?: Object) {
    if (this.onSongItemClick) this.onSongItemClick(song, index, flag);
    this.controller.close();
  }

  @Builder itemHead(text: string) {
    Row() {
      // Text(`${text}(${this.playlist.length} songs)`)
      //   .fontSize(22).fontWeight(FontWeight.Medium);
      Blank();
      Text('Clear')
        .fontSize(22).fontWeight(FontWeight.Medium)
    }.height(72).width('100%').backgroundColor('#FFFFFF').padding({ left: 12, right: 12 });
  }

  @Builder ListGroupHeaderUI(text: string) {
    Column() {
      Row() {
        Text(text)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
          .fontSize(20)
          .fontColor('#66000000');
        Blank()
        Text('Clear')
          .fontWeight(FontWeight.Bold)
          .margin({ right: 10 })
          .fontSize(20)
          .fontColor('#66000000');
      }.width('100%').alignItems(VerticalAlign.Center).height(62);
      Divider().color('#08000000');
    }.backgroundColor(Color.White);
  }

  build() {
    Column() {

      Row()
        .height(5)
        .width('30%')
        .backgroundColor('#19000000')
        .borderRadius(3)
        .margin({ top: 16 });

      /**
       * next
       */
      Swiper() {
        Column() {
          SongListComponent({
            songCount: 0,
            lanes: 1,
            actions: [ActionType.Close],
            navigation: false,
            data: [
              {
                data: AudioService.getInstance().listData(ListType.Next),
                header: () => this.ListGroupHeaderUI('Queue'),
                type: ListType.Next,
              },
              {
                data: AudioService.getInstance().listData(ListType.Play),
                header: () => this.ListGroupHeaderUI('Continue Playing'),
              }
            ]
          }).padding({ left: 12, right: 12 });
        }.height(100).width('100%').backgroundColor(Color.White);
        /**
         * history
         */
        Column() {
          SongListComponent({
            lanes: 1,
            songCount: 0,
            navigation: false,
            data: [
              {
                data: AudioService.getInstance().listData(ListType.History),
                header: () => this.ListGroupHeaderUI('History'),
                type: ListType.History,
              }
            ],
          }).padding({ left: 12, right: 12 });
        }.height(100).width('100%').backgroundColor(Color.White);
      }
      .index(0)
      .height('100%')
      .autoPlay(false)
      .loop(false)
      .layoutWeight(1)
    }
    .height('60%')
    .width('48%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 18, topRight: 18 })
    .clip(true);
  }
}
