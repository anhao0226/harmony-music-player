import router from '@ohos.router';
import { Song } from '../models/SongModel';
import { ImageComponent } from './ImageComponent';
import { ActionType, SongItemComponent } from './SongItemComponent';

export interface FromRouterValue {
  state: router.RouterState
  params: Object
}

@CustomDialog
export struct PlaylistDialogComponent {
  private playlist: Song[] = [];
  private nextPlaylist: Song[];
  private history: Song[];
  private onSongItemClick: (song: Song, index: number, flag?: Object) => void;
  private controller?: CustomDialogController
  private fromRouterValue: FromRouterValue = null;
  private bgColor: string = '#FFFFFF';
  @State _routerName: string = '';
  @State _renderNextQueue: Song[] = null;

  aboutToAppear() {
    //
    if (this.nextPlaylist) {
      this._renderNextQueue = [...this.nextPlaylist].reverse();
    }
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
      Text(`${text}(${this.playlist.length} songs)`)
        .fontSize(22).fontWeight(FontWeight.Medium);
      Blank();
      Text('Clear')
        .fontSize(22).fontWeight(FontWeight.Medium)
    }.height(72).width('100%').backgroundColor('#FFFFFF').padding({ left: 12, right: 12 });
  }

  @Builder SongItemIconBuilder(data: Song) {
    ImageComponent({
      src: `${data.al.picUrl}`,
      componentWidth: 32,
    })
  }

  build() {
    Column() {

      Swiper() {
        Column() {
          List() {
            if (this._renderNextQueue && this._renderNextQueue.length) {
              ListItemGroup({ header: this.itemHead('Queue') }) {
                ForEach(this._renderNextQueue, (item: Song, index: number) => {
                  ListItem() {
                    SongItemComponent({
                      data: item,
                      actions: [ActionType.Close],
                      rowSpace: 10,
                      onItemTap: (data: Song) => {
                        this.handleSongItemClick(data, index, { type: 'next' });
                      },
                    });
                  }
                }, (item: Song, index) => `${item.id}_DIALOG_ITEM`);
              }.divider({ strokeWidth: 1 }).padding({ left: 16, right: 16 });
            }

            /**
             *
             */
            ListItemGroup({ header: this.itemHead('Play in order') }) {
              ForEach(this.playlist, (item: Song, index: number) => {
                ListItem() {
                  SongItemComponent({
                    data: item,
                    actions: [ActionType.Close],
                    rowSpace: 10,
                    onItemTap: (data: Song) => {
                      this.handleSongItemClick(data, index, { type: 'list' });
                    },
                  });
                }
              }, (item: Song, index) => `${item.id}_DIALOG_ITEM`);
            }.divider({ strokeWidth: 1 }).padding({ left: 16, right: 16 });
          }.height('100%').width('100%').layoutWeight(1).sticky(StickyStyle.Header);
        }.height('100%').width('100%').layoutWeight(1);

        /**
         *
         */
        Column() {
          this.itemHead('History');
          List() {
            ForEach(this.history, (item: Song, index: number) => {
              ListItem() {
                SongItemComponent({
                  data: item,
                  actions: [ActionType.Close],
                  onItemTap: (data: Song) => {
                    this.handleSongItemClick(data, index, { type: 'history' });
                  },
                });
              }
            }, (item: Song, index) => `${item.id}_DIALOG_ITEM`);
          }.height('100%').width('100%').layoutWeight(1);
        }.height('90%')
      }
      .height('100%')
      .autoPlay(false)
      .index(0)
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