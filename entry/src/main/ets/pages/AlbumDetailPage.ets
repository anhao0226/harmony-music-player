import router from '@ohos.router';

import { SongModel, defaultSongItem, } from '../view_models/playlist_song_model';
import { AudioService } from '../common/utils/AudioService';
import { AudioPlayController } from '../components/AudioPlayController';
import { getImageMainColor, getNetworkImagePixelMap, rgbaToHexColor } from '../common/utils/ColorUtil';
import { SongItemComponent } from '../components/SongItem';
import { SongInfoDialogContent } from '../components/SongInfoIDialogContent';
import { ArtistAlbumModel, ArtistDetailModel, fetchAlbumDetail, } from '../view_models/ArtistDetailModel';


@Entry
@Component
struct AlbumDetailPage {
  @State pageOffset: number = 0;
  @State playingSong: SongModel = defaultSongItem;
  @State leftBgColor: string = '#B6C5D1';
  @State trackCount: number = 0;
  @State dialogData: SongModel | null = null;
  @State songs: SongModel[] = [];
  @State album: ArtistAlbumModel | null = null;
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogContent({ data: this.dialogData })
  })

  onPageShow() {
    const params = router.getParams();
    const albumId = params['albumId'];
    console.log(albumId.toString());
    this.initData(albumId);
  }

  initData(albumId: number) {
    fetchAlbumDetail(albumId).then(async (data) => {
      this.album = data.album;
      this.songs = data.songs;
      this.updateLeftBackgroundColor(data.album.picUrl);
    })
  }

  async updateLeftBackgroundColor(url: string) {
    try {
      const pixelMap = await getNetworkImagePixelMap(url);
      const mainColor = await getImageMainColor(pixelMap);
      this.leftBgColor = rgbaToHexColor(mainColor);
    } catch (err) {
      console.log(err);
    }
  }

  build() {
    Column() {
      Row() {
        if (this.album) {
          LeftComponent({ album: this.album, bgColor: this.leftBgColor });
        }
        if (this.songs.length > 0) {
          RightComponent({ album: this.album, songs: this.songs });
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
struct LeftComponent {
  private bgColor: string;
  private album: ArtistAlbumModel;

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
        Image(this.album.picUrl)
          .backgroundColor(Color.Gray)
          .width('100%')
          .aspectRatio(1)
          .borderRadius(14)
          .margin({ top: 12 })
          .animation({ curve: Curve.EaseIn })
          .clip(true);

        Text(this.album.name).fontSize(22).fontColor('#FFFFFF');

        Text(this.album.description).fontSize(15).fontColor('#99FFFFFF')
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

@Component
struct RightComponent {
  private album: ArtistAlbumModel;
  private songs: SongModel[] = [];

  build() {
    Column() {
      Row().height(122).width('100%');
      Column() {
        SongsComponent({ hotSongs: this.songs, album: this.album });
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
  private album: ArtistAlbumModel;
  private hotSongs: SongModel[] = [];

  handleItemClick(item: SongModel, index: number): void {
    AudioService.getInstance().initData(this.hotSongs.slice(index));
    AudioService.getInstance().start();
    router.pushUrl({ url: 'pages/SongPlayerPage', params: { songId: item.id } });
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Image($r('app.media.ic_public_play_norm'))
          .width(28)
          .fillColor('#E84026');
        Text(`Play all (${this.album.size})`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold);
      }.height(66).width('100%').padding({ left: 10 });

      List() {
        ForEach(this.hotSongs, (item: SongModel, index: number) => {
          ListItem() {
            SongItemComponent({ data: item });
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




