import router from '@ohos.router';

import { SongModel, defaultSongItem, } from '../view_models/playlist_song_model';
import { BottomBarControlComponent } from '../components/BottomBarControlComponent';
import { SongInfoDialogComponent } from '../components/SongInfoIDialogContent';
import { ArtistAlbumModel, ArtistMvModel, } from '../view_models/ArtistDetailModel';
import { CustomTabBar, TabBarDataInterface, TabViewBuildData } from '../components/CustomTabBar';
import { CommonLayout, SongBaseInfoComponent } from '../components/CommonPageLayoutComponent';
import { SongListComponent } from '../components/SongListComponent';
import { Song } from '../models/SongModel';
import { fetchArtistDetail, fetchArtistSongs, fetchArtistAlbums, fetchArtistMvs } from '../api/SongApi';
import { Artist, ArtistDetail } from '../models/ArtistDetailModel';
import { HotAlbum } from '../models/ArtistAlbumModel';
import { Mv } from '../models/ArtistMvModel';
import { DataSource } from '../models/DataSource';
import { CustomImage } from '../components/ImageComponent';

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
  @State artist: Artist = null;
  @State tabViewArea: Area = null;
  private songs: DataSource<Song> = new DataSource<Song>();
  private _dialogData: Song | null = null;
  @State artistId: number = 0;
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogComponent({ data: this._dialogData })
  })
  @State tabBarItems: TabBarDataInterface[] = [
    { text: 'Songs' },
    { text: 'Videos' },
    { text: 'Albums' }
  ];

  onPageShow() {
    const params = router.getParams();
    let artistId = 11972054;
    if (params && params.hasOwnProperty('artistId')) {
      artistId = params['artistId'];
    }
    this.artistId = artistId;
    this.initData(artistId);
  }

  initData(artistId: number) {
    fetchArtistDetail(artistId).then((res) => this.artist = res.artist);
    fetchArtistSongs(artistId).then((res) => this.songs.pushDataFromArray(res.songs));
  }

  @Builder TabBarView(data: TabViewBuildData) {
    if (data.index == 0) {
      SongListComponent({
        songCount: this.musicCount,
        data: [{ data: this.songs }],
      });
    } else if (data.index == 1) {
      AristVideosComponent({
        artistId: this.artistId,
      });
    } else if (data.index === 2) {
      AristAlbumsComponent({
        artistId: this.artistId,
      })
    }
  }

  @Builder leftContent() {
    SongBaseInfoComponent({
      imgWidth: 300,
      imageSrc: this.artist ? this.artist.cover : '',
      description: this.artist ? this.artist.briefDesc : '',
      text: this.artist ? this.artist.name : '',
    }) {
    };
  }

  @Builder rightContent() {
    CustomTabBar({
      tabs: $tabBarItems,
      tabAlign: FlexAlign.Center,
      viewBuilder: (data) => this.TabBarView(data),
      onViewSize: (area: Area) => {
        this.tabViewArea = area;
      }
    });
  }

  @Builder rightMenu() {

  }

  build() {
    Column() {
      CommonLayout({
        leftContent: () => this.leftContent(),
        rightContent: () => this.rightContent(),
        rightMenu: () => this.rightMenu(),
      });
      BottomBarControlComponent().key(this.TAG);
    }.height('100%').width('100%').backgroundColor('#F1F3F5');
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Push });
  }
}

@Component
struct AristVideosComponent {
  @Prop artistId: number;
  @State movies: Mv[] = [];

  aboutToAppear() {
    fetchArtistMvs(this.artistId).then((result) => {
      this.movies = result.mvs;
    });
  }

  getImageScr(src: string) {
    return `${src}?param=200y200`;
  }

  build() {
    List({ space: 10 }) {
      ForEach(this.movies, (item: Mv, index: number) => {
        ListItem() {
          Column() {
            CustomImage({
              imageSrc: this.getImageScr(item.imgurl16v9),
              imageAspectRatio: 16 / 9,
              imageWidth: 200,
            });
            Text(item.name).maxLines(2);
          }
        }.onClick(() => {

        });
      }, (item: Mv, _) => `CARD_ITEM_${item.id}`);
    }
    .lanes(5)
    .height(0)
    .width('100%')
    .layoutWeight(1)
    .onAreaChange(() => {

    })
  }
}


@Component
struct AristAlbumsComponent {
  @Prop artistId: number;
  @State albums: HotAlbum[] = [];

  aboutToAppear() {
    fetchArtistAlbums(this.artistId).then((result) => {
      this.albums = result.hotAlbums;
    });
  }

  getImageScr(src: string) {
    return `${src}?param=200y200`;
  }

  build() {
    List({ space: 10 }) {
      ForEach(this.albums, (item: HotAlbum, index: number) => {
        ListItem() {
          Column() {
            CustomImage({
              imageSrc: this.getImageScr(item.picUrl),
              imageAspectRatio: 16 / 9,
              imageWidth: 200,
            });
            Text(item.name).maxLines(2);
          }
        }.onClick(() => {

        });
      }, (item: HotAlbum, _) => `CARD_ITEM_${item.id}`);
    }
    .lanes(5)
    .height(0)
    .width('100%')
    .layoutWeight(1)
    .onAreaChange(() => {

    })
  }
}

