import router from '@ohos.router';

import { SongModel, defaultSongItem, } from '../view_models/playlist_song_model';
import { AudioService } from '../common/utils/AudioService';
import { AudioPlayController } from '../components/AudioPlayController';
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

@Component
struct LeftComponent {
  private bgColor: string;
  private artist: ArtistDetailModel;

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_back'))
          .width(30)
          .onClick(() => router.back())
          .fillColor(Color.White)
      }
      .height(142)
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 34, right: 34 });

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
    .width('34%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundBlurStyle(BlurStyle.Thin)
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.bgColor)
    .animation({ curve: Curve.Linear });
  }
}


@Entry
@Component
struct ArtistDetailPage {
  @State pageOffset: number = 0;
  @State playingSong: SongModel = defaultSongItem;
  @State songs: SongDataSource = new SongDataSource();
  @State leftBgColor: string = '#B6C5D1';
  @State trackCount: number = 0;
  @State dialogData: SongModel | null = null;
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogContent({ data: this.dialogData })
  })
  @State artistData: ArtistDetailModel | null = null;

  onPageShow() {
    const params = router.getParams();
    const artistId = params['artistId'] as number;
    this.initData(artistId);
  }

  initData(artistId: number) {
    fetchArtistData(artistId).then(async (data) => {
      this.artistData = data.artist;
      this.songs.pushDataFormArray(data.hotSongs);
      try {
        const pixelMap = await getNetworkImagePixelMap(this.artistData.picUrl);
        const mainColor = await getImageMainColor(pixelMap);
        this.leftBgColor = rgbaToHexColor(mainColor);
      } catch (err) {
        console.log(err);
      }
    })

  }

  build() {
    Column() {
      Row() {
        // Left
        if (this.artistData) {
          LeftComponent({ artist: this.artistData, bgColor: this.leftBgColor });
        }
        // Right
        if (this.artistData) {
          RightComponent({ artist: this.artistData, hotSongs: this.songs });
        }
      }.width('100%').layoutWeight(1);
      AudioPlayController().height(60);

    }.height('100%').width('100%').backgroundColor('#F1F3F5');
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Push });
  }
}

@Component
struct RightComponent {
  private artist: ArtistDetailModel;
  private hotSongs: SongDataSource = new SongDataSource();
  private tabItems: string[] = ['Songs', 'Albums', 'Videos'];

  build() {
    Column() {
      Row().height(122).width('100%');
      Column() {

        Tabs() {

          TabContent() {
            SongsComponent({ artist: this.artist, hotSongs: this.hotSongs });
          }.tabBar('Songs')

          TabContent() {
            MvsComponent({ artist: this.artist });
          }.tabBar('Videos')

          TabContent() {
            AlbumsComponent({ artist: this.artist });
          }.tabBar('Albums')

        }.barWidth('100%').barMode(BarMode.Scrollable).barHeight(66);

      }
      .padding({ left: 12, right: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 14, topRight: 14 })
      .layoutWeight(1);

    }.height('100%').layoutWeight(1);
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





