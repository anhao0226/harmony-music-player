import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { BottomBarControlComponent } from '../components/BottomBarControlComponent';
import { SongInfoDialogComponent } from '../components/SongInfoIDialogContent';
import {
  ColorChangeValue,
  CommonLayoutLComponent,
  CommonLayoutRComponent
} from '../components/CommonPageLayoutComponent';
import { SongListComponent } from '../components/SongListComponent';
import { fetchPlaylistDetail } from '../api/PlaylistApi';
import { Creator, Playlist } from '../view_models/playlist_mode';
import { ImageComponent } from '../components/ImageComponent';
import { CommonDataSource } from '../models/CommonDataSource';
import { Song } from '../models/SongModel';
import { fetchSongs } from '../api/SongApi';
import { CommentType } from '../api/CommentApi';
import { ActionType } from '../components/SongItemComponent';
import { DataSource } from '../models/DataSource';

@Entry
@Component
struct PlaylistDetailPage {
  private TAG = 'PLAYLIST_DETAIL_PAGE';
  @State pageOffset: number = 0;
  private _dialogData: Song | null = null;
  private _songs: DataSource<Song> = new DataSource<Song>();
  //
  @State _name: string = '';
  @State _albumSrc: string = '';
  @State _description: string = '';
  @State _trackCount: number = 0;
  @State _commentCount: number = 0;
  @State _creator: Creator = null;
  @State _iconColor: string = '';
  @State _textColor: string = '';
  @State _playCount: number = 0;
  private _playlistDetail: Playlist | null = null;
  //
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    gridCount: 5,
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogComponent({ data: this._dialogData })
  })

  onPageShow() {
    const params = router.getParams();
    let playlistId: number = 24381616;
    if (params && params.hasOwnProperty('playlistId')) {
      playlistId = params['playlistId'];
    }
    this.initData(playlistId);
    const context = AppStorage.Get('CONTEXT') as Context;
    context.resourceManager.getStringValue($r('app.color.main_color')).then((value) => {
      // this._mainColor = value;
    })
  }

  async initData(playlistId: number) {
    // playlist detail
    fetchPlaylistDetail(playlistId).then((result) => {
      console.log(JSON.stringify(result));
      this._playlistDetail = result;
      this._name = result.name;
      this._trackCount = result.trackCount;
      this._description = result.description;
      this._albumSrc = result.coverImgUrl;
      this._commentCount = result.commentCount;
      this._creator = result.creator;
      this._playCount = result.playCount;
      this.getMoreSongs();
    });
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Push });
  }

  handleListItemClick(item: Song, index: number): void {
    AudioService.getInstance().updatePlaylist(this._songs.slice(index));
    AudioService.getInstance().start();
    router.pushUrl({
      url: 'pages/SongPlayerPage',
      params: { songId: item.id, from: { id: this._playlistDetail.id, name: 'playlist' } }
    });
  }

  async getMoreSongs() {
    const ids: number[] = [];
    const limit: number = 25;
    for (let i = this.pageOffset; i < (this.pageOffset + limit); i++) {
      ids.push(this._playlistDetail.trackIds[i].id);
    }
    fetchSongs(ids).then((value) => {
      value.songs.forEach((item) => {
        console.log(`Song name  ${JSON.stringify(item.name )}`);
      })
      this._songs.pushDataFromArray(value.songs);
      this.pageOffset += limit;
    });
  }

  @Builder LoadingIcon() {
    Row() {
      LoadingProgress().height(30).width(30).color('#B6C5D1');
      Text('Loading').fontColor('#B6C5D1').margin({ left: 6 });
    }
  }

  @Builder IconBuilder(icon: Resource, text: () => string, onClick?: () => void) {
    Row({ space: 6 }) {
      Image(icon)
        .height('100%')
        .height(28)
        .alignSelf(1)
        .aspectRatio(1)
        .fillColor(this._iconColor);
      Text(text());
    }.onClick(() => {
      if (onClick) onClick();
    })
  }

  @Builder RMenuBuild() {
    Row() {
      Row({ space: 12 }) {
        Image($r('app.media.ic_public_play_list_2_line')).width(28).fillColor(this._iconColor);
        Text(`Play all (${this._trackCount})`).fontColor('E5000000').fontSize(20);
      }.height('100%').layoutWeight(1);
      Blank();
      Row({ space: 24 }) {
        this.IconBuilder($r('app.media.ic_public_disc_line'),
          () => this._playCount.toString());
        this.IconBuilder($r('app.media.ic_public_message_3_line'),
          () => this._commentCount.toString(),
          () => {
            router.pushUrl({
              url: 'pages/Comments',
              params: { id: this._playlistDetail.id, type: CommentType.PLAYLIST }
            });
          });
        this.IconBuilder($r('app.media.ic_public_share_line'),
          () => 'Share');
      }
    }
  }

  @Builder RBodyBuild() {
    Column() {
      SongListComponent({
        lanes: 2,
        songCount: this._trackCount,
        onReachEnd: () => this.getMoreSongs(),
        actions: [ActionType.Mv, ActionType.AddToPlaylist, ActionType.MORE],
        data: [{ data: this._songs }],
      });
    }.padding({ left: 16, right: 16 }).layoutWeight(1);
  }

  @Builder CreatorUI() {
    Row({ space: 10 }) {
      ImageComponent({ componentWidth: 36, src: this._creator.avatarUrl, borderRadius_: 36 });
      Text(this._creator.nickname).fontColor(this._textColor);
    }
  }

  build() {
    Column() {
      Row() {
        /**
         *
         */
        CommonLayoutLComponent({
          name: this._name,
          description: this._description,
          imgSrc: this._albumSrc,
          onColorChange: (value: ColorChangeValue) => {
            this._iconColor = value.mainColor;
            this._textColor = value.secondaryTextColor;
          }
        }) {
          if (this._creator) this.CreatorUI();
        }

        CommonLayoutRComponent({
          menuBuilder: this.RMenuBuild.bind(this),
          bodyBuilder: this.RBodyBuild.bind(this),
        });
      }.width('100%').layoutWeight(1);
      /**
       *
       */
      BottomBarControlComponent().key(this.TAG);
    }
  }
}