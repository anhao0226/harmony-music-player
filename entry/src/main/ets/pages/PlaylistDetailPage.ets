import router from '@ohos.router';
import media from '@ohos.multimedia.media';
import {
  ArtistModel,
  getPlaylistSongs,
  SongModel,
  PlaylistModel,
  getPlaylistDetails,
  defaultSongItem,
  formatArtists,
} from '../view_models/playlist_song_model';
import { AudioService } from '../common/utils/AudioService';
import { PlayControlComponent } from '../components/PlayControlComponent';
import { SongDataSource } from '../view_models/SongDataSource';
import { getImageMainColor, getNetworkImagePixelMap, rgbaToHexColor } from '../common/utils/ColorUtil';
import { SongItemComponent } from '../components/SongItem';
import effectKit from '@ohos.effectKit';
import image from '@ohos.multimedia.image';
import { SongInfoDialogContent } from '../components/SongInfoIDialogContent';
import { SplitLayout } from '../components/SplitLayout';


@Entry
@Component
struct PlaylistDetailPage {
  private TAG = 'PLAYLIST_DETAIL_PAGE';
  private playlistId: string;
  @State pageOffset: number = 0;
  @State playingSong: SongModel = defaultSongItem;
  @State songs: SongDataSource = new SongDataSource();
  @State playlistDetails: PlaylistModel = new PlaylistModel();
  @State leftBgColor: string = '#B6C5D1';
  @State trackCount: number = 0;
  @State dialogData: SongModel | null = null;
  songInfoDialogController: CustomDialogController = new CustomDialogController({
    gridCount: 5,
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogContent({ data: this.dialogData })
  })

  onPageShow() {
    const params = router.getParams();
    this.playlistId = params['playlistId'];
    this.initData(params['playlistId']);
  }

  async initData(playlistId: number) {
    this.playlistDetails = await getPlaylistDetails(playlistId);
    getNetworkImagePixelMap(this.playlistDetails.coverImgUrl).then(async (pixelMap: image.PixelMap) => {
      const mainColor = await getImageMainColor(pixelMap);
      this.leftBgColor = rgbaToHexColor(mainColor);
    }).catch((err) => {
    })

  }

  build() {
    Column() {
      Row() {
        SplitLayout({ pos: 'left', bgColor: this.leftBgColor }) {

          Column({ space: 16 }) {
            Image(this.playlistDetails.coverImgUrl)
              .backgroundColor(Color.Gray)
              .width('100%')
              .aspectRatio(1)
              .borderRadius(14)
              .margin({ top: 12 })
              .animation({ curve: Curve.EaseIn })
              .clip(true);
            Text(this.playlistDetails.name).fontSize(22).fontColor('#FFFFFF');
            Text(this.playlistDetails.description).fontSize(15).fontColor('#99FFFFFF')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(4)
          }.width('66%').alignItems(HorizontalAlign.Start)

          Row() {
            Badge({
              count: this.playlistDetails.playCount,
              position: BadgePosition.RightTop,
              style: { badgeSize: 16, badgeColor: '#E84026' }
            }) {
              Image($r('app.media.ic_public_play_norm'))
                .height('100%')
                .constraintSize({ maxHeight: 26 })
                .fillColor('#66000000');
            };
            Image($r('app.media.ic_public_comments'))
              .height('100%')
              .constraintSize({ maxHeight: 30 })
              .fillColor('#66000000');
            Image($r('app.media.ic_public_share_filled'))
              .height('100%')
              .constraintSize({ maxHeight: 30 })
              .fillColor('#66000000');
          }.height(65).width('66%').justifyContent(FlexAlign.SpaceAround)

        }

        SplitLayout({ pos: 'right', bgColor: this.leftBgColor }) {
          Column() {
            Row({ space: 12 }) {
              Image($r('app.media.ic_public_play_norm')).width(28).width(28).fillColor('#E84026');
              Text(`Play all (${this.playlistDetails.trackCount})`).fontSize(16).fontWeight(FontWeight.Bold);
            }.height(66).width('100%').padding({ left: 10 });

            List() {
              LazyForEach(this.songs, (item: SongModel, index: number) => {
                ListItem() {

                  SongItemComponent({ data: item, onMoreButtonClick: (value) => {
                    this.dialogData = value;
                    this.songInfoDialogController.open();
                  } });

                }.onClick(() => this.handleListItemClick(item, index)).width('100%').align(Alignment.Start);

              }, (item: SongModel, index: number) => (item.id + index).toString());

              ListItem() {
                Row() {
                  LoadingProgress().height(30).width(30).color('#B6C5D1');
                  Text('Loading').fontColor('#B6C5D1').margin({ left: 6 });
                }
              }.width('100%').padding(24);

            }
            .lanes(2)
            .width('100%')
            .height(0)
            .layoutWeight(1)
            .divider({ strokeWidth: 1, startMargin: 12, color: '#ffe9f0f0' })
            .onReachEnd(() => {
              const params = router.getParams();
              this.getMoreSongs(params['playlistId']);
            });

          }
          .padding({ left: 12, right: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 14, topRight: 14 })
          .layoutWeight(1);
        }

      }.width('100%').layoutWeight(1);

      PlayControlComponent().key(this.TAG);


    }.height('100%').width('100%');
  }

  pageTransition() {
    PageTransitionEnter({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Pop });
    PageTransitionExit({ duration: 425, curve: Curve.EaseInOut, type: RouteType.Push });
  }

  handleListItemClick(item: SongModel, index: number): void {
    AudioService.getInstance().initData(this.songs.getAllData().slice(index));
    AudioService.getInstance().start();
    router.pushUrl({ url: 'pages/SongPlayerPage', params: { songId: item.id } });
  }

  async getMoreSongs(playlistId: number) {
    const songs = await getPlaylistSongs(playlistId, this.pageOffset);
    this.songs.pushDataFormArray(songs);
  }
}

