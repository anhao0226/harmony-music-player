import router from '@ohos.router';

import { SongModel, defaultSongItem, } from '../view_models/playlist_song_model';
import { AudioService } from '../common/utils/AudioService';
import { PlayControlComponent } from '../components/PlayControlComponent';
import { SongDataSource } from '../view_models/SongDataSource';
import { getImageMainColor, getNetworkImagePixelMap, rgbaToHexColor } from '../common/utils/ColorUtil';
import { SongItemComponent } from '../components/SongItem';
import { SongInfoDialogContent } from '../components/SongInfoIDialogContent';
import {
  ArtistAlbumModel,
  ArtistDetailModel,
  ArtistMvModel,
  fetchArtistAlbums,
  fetchArtistMv,
  fetchArtistData
} from '../view_models/ArtistDetailModel';
import { SplitLayout } from '../components/SplitLayout';
import { CustomTabBar, TabBarItemInterface } from '../components/CustomTabBar';

@Entry
@Component
struct ArtistDetailPage {
  private TAG = 'ARTIST_DETAIL_PAGE'
  @State pageOffset: number = 0;
  @State playingSong: SongModel = defaultSongItem;
  @State songs: SongDataSource = new SongDataSource();
  @State leftBgColor: string = '#B6C5D1';
  @State trackCount: number = 0;
  @State dialogData: SongModel | null = null
  @State artist: ArtistDetailModel | null = null;
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogContent({ data: this.dialogData })
  })
  @State tabBarItems: TabBarItemInterface[] = [
    { getText: () => 'Songs' },
    { getText: () => 'Videos' },
    { getText: () => 'Albums' }
  ];

  onPageShow() {
    const params = router.getParams();
    // const artistId = params['artistId'] as number;
    this.initData(7662);
  }

  initData(artistId: number) {
    console.log(`artistId: ${artistId}`);
    fetchArtistData(artistId).then(async (data) => {
      this.artist = data.artist;
      this.songs.pushDataFormArray(data.hotSongs);
      try {
        const pixelMap = await getNetworkImagePixelMap(this.artist.picUrl);
        const mainColor = await getImageMainColor(pixelMap);
        this.leftBgColor = rgbaToHexColor(mainColor);
      } catch (err) {
        console.log(err);
      }
    })

  }

  @Builder TabBarItem(item: TabBarItemInterface, index: number) {
    if (index === 0) {
      SongsComponent({ artist: this.artist, hotSongs: this.songs });
    } else if (index === 1) {
      MvsComponent({ artist: this.artist });
    } else if (index === 2) {
      AlbumsComponent({ artist: this.artist });
    }
  }

  build() {
    Column() {
      Row() {
        SplitLayout({ pos: 'left', bgColor: this.leftBgColor }) {
          if (this.artist) {
            Column({ space: 16 }) {
              Image(this.artist.picUrl)
                .backgroundColor(Color.Gray)
                .width('100%')
                .aspectRatio(1)
                .borderRadius(14)
                .margin({ top: 12 })
                .animation({ curve: Curve.EaseIn })
                .clip(true);

              Text(this.artist.name).fontSize(22).fontColor('#FFFFFF');

              Text(this.artist.briefDesc).fontSize(15).fontColor('#99FFFFFF')
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(4);

            }.width('66%').alignItems(HorizontalAlign.Start)
          }
        }

        SplitLayout({ pos: 'right', bgColor: this.leftBgColor }) {
          if (this.artist) {
            CustomTabBar({
              items: $tabBarItems,
              viewBuilder: this.TabBarItem.bind(this)
            })
          }
        }

      }.width('100%').layoutWeight(1);

      PlayControlComponent().key(this.TAG);

    }.height('100%').width('100%').backgroundColor('#F1F3F5');
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Push });
  }
}

@Component
struct SongsComponent {
  private artist: ArtistDetailModel;
  private hotSongs: SongDataSource = new SongDataSource();

  handleItemClick(item: SongModel, index: number): void {
    AudioService.getInstance().initData(this.hotSongs.getAllData().slice(index));
    AudioService.getInstance().start();
    router.pushUrl({ url: 'pages/SongPlayerPage', params: { songId: item.id } });
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Image($r('app.media.ic_public_play_norm'))
          .width(28)
          .fillColor('#E84026');
        Text(`Play all (${this.artist.musicSize})`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold);
      }.height(66).width('100%').padding({ left: 10 });

      List() {
        LazyForEach(this.hotSongs, (item: SongModel, index: number) => {
          ListItem() {
            SongItemComponent({ data: item, onMoreButtonClick: (value) => {
            } });
          }.onClick(() => this.handleItemClick(item, index)).width('100%').align(Alignment.Start);

        }, (item: SongModel, _) => item.id.toString());

      }
      .lanes(2)
      .height(0)
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, startMargin: 12, color: '#ffe9f0f0' });
    }
  }
}

@Component
struct AlbumsComponent {
  private artist: ArtistDetailModel;
  @State albums: ArtistAlbumModel[] = [];

  aboutToAppear() {
    fetchArtistAlbums(this.artist.id).then((data) => this.albums = data);
  }

  build() {
    Column() {
      List() {
        ForEach(this.albums, (item: ArtistAlbumModel) => {
          ListItem() {
            Column({ space: 3 }) {
              Image(item.picUrl).aspectRatio(1).borderRadius(6).clip(true);
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
struct MvsComponent {
  private artist: ArtistDetailModel;
  @State mvs: ArtistMvModel[] = [];

  aboutToAppear() {
    fetchArtistMv(this.artist.id).then((data) => {
      this.mvs = data;
    })
  }

  build() {
    Column() {
      List() {
        ForEach(this.mvs, (item: ArtistMvModel, index: number) => {
          ListItem() {
            Column({ space: 3 }) {
              Image(item.imgurl16v9).aspectRatio(16 / 9).borderRadius(6).clip(true);
              Text(item.name).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }.padding(6).onClick(() => {
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





