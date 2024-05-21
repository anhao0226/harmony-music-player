import router from '@ohos.router';

import { SongModel, defaultSongItem, } from '../view_models/playlist_song_model';
import { AudioService } from '../common/utils/AudioService';
import { PlayControlComponent } from '../components/PlayControlComponent';
import { getImageMainColor, getNetworkImagePixelMap, rgbaToHexColor } from '../common/utils/ColorUtil';
import { SongItemComponent } from '../components/SongItem';
import { SongInfoDialogContent } from '../components/SongInfoIDialogContent';
import { ArtistAlbumModel, ArtistDetailModel, fetchAlbumDetail, } from '../view_models/ArtistDetailModel';
import { SplitLayout } from '../components/SplitLayout';


@Entry
@Component
struct AlbumDetailPage {
  private readonly TAG = 'ALBUM_DETAIL_PAGE'
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
        // LEFT
        SplitLayout({ pos: 'left', bgColor: this.leftBgColor }) {
          if (this.album) {
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

            }.width('66%').alignItems(HorizontalAlign.Start);
          }
        }
        // RIGHT
        SplitLayout({ pos: 'right', bgColor: this.leftBgColor }) {
          if (this.songs.length > 0) {
            Column() {
              SongsComponent({ hotSongs: this.songs, album: this.album });
            }
            .padding({ left: 12, right: 12 })
            .backgroundColor('#FFFFFF')
            .borderRadius({ topLeft: 14, topRight: 14 })
            .layoutWeight(1);
          }
        }
      }.width('100%').layoutWeight(1);

      //
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




