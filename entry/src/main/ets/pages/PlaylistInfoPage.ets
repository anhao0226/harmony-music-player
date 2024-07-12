import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { BottomBarControlComponent } from '../components/BottomBarControlComponent';
import { SongInfoDialogComponent } from '../components/SongInfoIDialogContent';
import { CommonLayout, SongBaseInfoComponent, } from '../components/CommonPageLayoutComponent';
import { SongListComponent } from '../components/SongListComponent';
import { fetchPlaylistDetail } from '../api/PlaylistApi';
import { Creator, Playlist } from '../view_models/playlist_mode';
import { CustomImage } from '../components/ImageComponent';
import { Song } from '../models/SongModel';
import { fetchSongs } from '../api/SongApi';
import { CommentType } from '../api/CommentApi';
import { ActionType } from '../components/SongItemComponent';
import { DataSource } from '../models/DataSource';

interface MenuItemInterface {
  icon: Resource
  text: (() => string)
  onClick: (() => void) | void;
}

@Component
export struct PlaylistDisplayPage {
  private TAG = 'PLAYLIST_DETAIL_PAGE';
  @State name: string = '';
  @State description: string = '';
  @State pageOffset: number = 0;
  @State albumCoverImg: string = '';
  @State creator: Creator = null;
  @State playCount: number = 0;
  @State trackCount: number = 0;
  @State commentCount: number = 0;
  //
  private songs: DataSource<Song> = new DataSource<Song>();
  private playlist: Playlist = null;
  private _dialogData: Song | null = null;
  //
  private menus: MenuItemInterface[] = [
    {
      icon: $r('app.media.ic_public_play_list_2_line'),
      text: () => `Play all(${this.trackCount.toString()})`,
      onClick: () => {

      }
    },
    {
      icon: $r('app.media.ic_public_disc_line'),
      text: () => this.playCount.toString(),
      onClick: () => {
      }
    },
    {
      icon: $r('app.media.ic_public_message_3_line'),
      text: () => this.commentCount.toString(),
      onClick: () => {
      }
    },
    {
      icon: $r('app.media.ic_public_share_line'),
      text: () => 'Share',
      onClick: () => {
      }
    }
  ];
  //
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    gridCount: 5,
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogComponent({ data: this._dialogData })
  })

  aboutToAppear() {
    // const params = router.getParams();
    let playlistId: number = 24381616;
    // if (params && params.hasOwnProperty('playlistId')) {
    //   playlistId = params['playlistId'];
    // }
    this.initData(playlistId);
    // const context = AppStorage.Get('CONTEXT') as Context;
    // context.resourceManager.getStringValue($r('app.color.main_color')).then((value) => {
    //   // this._mainColor = value;
    // })
  }

  async initData(playlistId: number) {
    fetchPlaylistDetail(playlistId).then((result) => {
      this.name = result.name;
      this.albumCoverImg = result.coverImgUrl;
      this.description = result.description;
      this.creator = result.creator;
      this.playCount = result.playCount;
      this.commentCount = result.commentCount;
      this.trackCount = result.trackCount;
      this.playlist = result;
      this.getMoreSongs();
    });
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Push });
  }

  handleListItemClick(item: Song, index: number): void {
    AudioService.getInstance().updatePlaylist(this.songs.slice(index));
    AudioService.getInstance().start();
    router.pushUrl({
      url: 'pages/SongPlayerPage',
      params: { songId: item.id, from: { id: this.playlist.id, name: 'playlist' } }
    });
  }

  async getMoreSongs() {
    const ids: number[] = [];
    const limit: number = 25;
    for (let i = this.pageOffset; i < (this.pageOffset + limit); i++) {
      ids.push(this.playlist.trackIds[i].id);
    }
    fetchSongs(ids).then((value) => {
      value.songs.forEach((item) => {
        console.log(`Song name  ${JSON.stringify(item.name)}`);
      })

      console.log(value.songs.length.toString());

      this.songs.pushDataFromArray(value.songs);
      this.pageOffset += limit;
    });
  }

  @Builder LoadingIcon() {
    Row() {
      LoadingProgress().height(30).width(30).color('#B6C5D1');
      Text('Loading').fontColor('#B6C5D1').margin({ left: 6 });
    }
  }

  @Builder leftContent() {
    SongBaseInfoComponent({
      imgWidth: 200,
      text: this.name,
      description: this.description,
      imageSrc: this.albumCoverImg,
    }) {
      Row({ space: 10 }) {
        CustomImage({
          imageWidth: 40,
          imageSrc: this.creator ? this.creator.avatarUrl : '',
          imageAspectRatio: 1,
          imageBorderRadius: 40,
        });
        Text(this.creator ? this.creator.nickname : '')
          .fontColor(Color.Orange);
      }.width('100%').justifyContent(FlexAlign.Start);
    };
  }

  @Builder rightContent() {
    SongListComponent({
      lanes: 2,
      songCount: 0,
      onReachEnd: () => this.getMoreSongs(),
      actions: [ActionType.Mv, ActionType.AddToPlaylist, ActionType.MORE],
      data: [{ data: this.songs }],
    });
  }

  @Builder rightMenu() {
    Row() {
      this.iconBuilder(this.menus[0]);
      Blank();
      Row({ space: 10 }) {
        ForEach(this.menus, (item: MenuItemInterface, index: number) => {
          if (index > 0) this.iconBuilder(this.menus[index]);
        }, (_, index: number) => `MENU_ITEM_${index}`);
      }
    }.width('100%').padding(16);
  }

  @Builder iconBuilder(value: any) {
    Row({ space: 8 }) {
      Image(value.icon).height(28).aspectRatio(1).fillColor(Color.Orange);
      Text(value.text()).fontSize(18);
    }
    .onClick(() => value.onClick())
    .justifyContent(FlexAlign.Center);
  }

  build() {
    Column() {
      CommonLayout({
        leftContent: () => this.leftContent(),
        rightMenu: () => this.rightMenu(),
        rightContent: () => this.rightContent(),
      }).layoutWeight(1);
      BottomBarControlComponent().key(this.TAG);
    }
  }
}