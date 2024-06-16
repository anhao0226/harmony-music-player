import router from '@ohos.router';

import { SongModel, defaultSongItem, } from '../view_models/playlist_song_model';
import { BottomBarControlComponent } from '../components/BottomBarControlComponent';
import { SongDataSource } from '../view_models/SongDataSource';
import { SongInfoDialogComponent } from '../components/SongInfoIDialogContent';
import {
  ArtistAlbumModel,
  ArtistDetailModel,
  ArtistMvModel,
  fetchArtistMv,
  fetchArtistData
} from '../view_models/ArtistDetailModel';
import { CustomTabBar, TabBarItemInterface } from '../components/CustomTabBar';
import { CommonLayoutLComponent, CommonLayoutRComponent } from '../components/CommonPageLayoutComponent';
import { SongListComponent } from '../components/SongListComponent';
import { CommonDataSource } from '../models/CommonDataSource';
import { Song } from '../models/SongModel';
import { fetchArtistDetail, fetchArtistSongs, fetchArtistAlbums, fetchArtistMvs } from '../api/SongApi';
import { Artist, ArtistDetail } from '../models/ArtistDetailModel';
import { HotAlbum } from '../models/ArtistAlbumModel';
import { ImageComponent } from '../components/ImageComponent';
import { Mv } from '../models/ArtistMvModel';

@Entry
@Component
struct ArtistDetailPage {
  private TAG = 'ARTIST_DETAIL_PAGE'
  @State pageOffset: number = 0;
  @State playingSong: SongModel = defaultSongItem;
  @State leftBgColor: string = '#B6C5D1';
  @State trackCount: number = 0;
  @State dialogData: SongModel | null = null;
  @State musicCount: number = 0;
  //
  @State _artist: Artist | null = null;
  private _songs: CommonDataSource<Song> = new CommonDataSource<Song>();
  private _dialogData: Song | null = null
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogComponent({ data: this._dialogData })
  })
  @State tabBarItems: TabBarItemInterface[] = [
    { getText: () => 'Songs' },
    { getText: () => 'Videos' },
    { getText: () => 'Albums' }
  ];

  onPageShow() {
    const params = router.getParams();
    let artistId = 11972054;
    if (params && params.hasOwnProperty('artistId')) {
      artistId = params['artistId'];
    }
    this.initData(artistId);
  }

  initData(artistId: number) {
    fetchArtistDetail(artistId).then((res) => {
      this._artist = res.artist;
    });
    fetchArtistSongs(artistId).then((res) => {
      this._songs.pushDataFromArray(res.songs);
    });
  }

  @Builder TabBarItem(item: TabBarItemInterface, index: number) {
    if (index === 0) {
      SongListComponent({ songCount: this.musicCount, songList: this._songs });
    } else if (index === 1) {
      _MvsComponent({ artistId: this._artist.id });
    } else if (index === 2) {
      _AlbumsComponent({ artistId: this._artist.id });
    } else {
      Text(`Error View`);
    }
  }

  @Builder BodyBuilder() {
    Column() {
      CustomTabBar({
        tabs: $tabBarItems,
        items: $tabBarItems,
        viewBuilder: this.TabBarItem.bind(this)
      });
    }.padding({ left: 16, right: 16 });
  }

  build() {
    Column() {
      Row() {

        CommonLayoutLComponent({
          name: this._artist ? this._artist.name : '',
          description: this._artist ? this._artist.briefDesc : '',
          imgSrc: this._artist ? this._artist.cover : '',
        });

        CommonLayoutRComponent({
          bodyBuilder: this.BodyBuilder.bind(this)
        });

      }.width('100%').layoutWeight(1);

      BottomBarControlComponent().key(this.TAG);

    }.height('100%').width('100%').backgroundColor('#F1F3F5');
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Push });
  }
}

@Component
struct _AlbumsComponent {
  private artistId: number;
  @State _albums: HotAlbum[] = [];

  aboutToAppear() {
    fetchArtistAlbums(this.artistId).then((res) => {
      this._albums = res.hotAlbums;
    })
  }

  build() {
    Column() {
      List() {
        ForEach(this._albums, (item: HotAlbum) => {
          ListItem() {
            Column({ space: 3 }) {
              ImageComponent({ src: `${item.picUrl}?param=200y200`, autoResize: true })
              Text(item.name).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }.padding(6).onClick(() => {
            router.pushUrl({ url: 'pages/AlbumDetailPage', params: { albumId: item.id } });
          })
        }, (item: ArtistAlbumModel) => item.id.toString());
      }
      .lanes(4)
      .align(Alignment.TopStart)
      .height('100%')
      .width('100%')
    }
  }
}

@Component
struct _MvsComponent {
  private artistId: number;
  @State mvs: Mv[] = [];

  aboutToAppear() {
    fetchArtistMvs(this.artistId).then((res) => {
      this.mvs = res.mvs;
    })
  }

  build() {
    Column() {
      List() {
        ForEach(this.mvs, (item: Mv, index: number) => {
          ListItem() {
            Column({ space: 3 }) {
              Image(item.imgurl16v9).aspectRatio(16 / 9).borderRadius(6).clip(true);
              Text(item.name).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }.padding(6).onClick(() => {
            router.pushUrl({ url: 'pages/MvPlayerPage', params: { mvId: item.id } })
          }).width('100%').align(Alignment.Start);
        }, (item: ArtistMvModel, _) => item.id.toString());

      }
      .lanes(4)
      .height(0)
      .width('100%')
      .layoutWeight(1)
    }
  }
}





