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
import { AudioPlayController } from '../components/AudioPlayController';
import { SongDataSource } from '../view_models/SongDataSource';
import { getImageMainColor, getNetworkImagePixelMap, rgbaToHexColor } from '../common/utils/ColorUtil';


@Extend(Text) function songTagStyle(color: ResourceColor) {
  .border({ width: 1.4 })
  .borderRadius(3)
  .fontWeight(FontWeight.Bold)
  .borderColor(color)
  .fontColor(color)
  .fontSize(10)
  .padding({ left: 2, right: 2, top: 0.4, bottom: 0.4 })
}

@Entry
@Component
struct PlaylistDetailPage {
  @State currPlayingState: media.AVPlayerState = 'idle';
  @State pageOffset: number = 0;
  @State playlistDetails: PlaylistModel = new PlaylistModel();
  @State playingSong: SongModel = defaultSongItem;
  @State songs: SongDataSource = new SongDataSource();
  @State leftBgColor: string = '#B6C5D1';
  @State trackCount: number = 0;

  onPageShow() {
    // AudioService.getInstance();
    const params = router.getParams();
    this.initData(params['playlistId']);
  }

  async initData(playlistId: number) {
    this.getMoreSongs(playlistId);
    try {
      this.playlistDetails = await getPlaylistDetails(playlistId);
      const pixelMap = await getNetworkImagePixelMap(this.playlistDetails.coverImgUrl)
      const mainColor = await getImageMainColor(pixelMap);
      this.leftBgColor = rgbaToHexColor(mainColor);
    } catch (err) {
      console.log(`ERROR ${err}`);
    }
  }

  @Builder SongTagUI(fee: number) {
    if (fee === 0) {
      // Text('free').songTagStyle('#A6C2BE');
    } else if (fee === 1) {
      Text('VIP').songTagStyle($r('app.color.song_item_tag_color'));
    } else {
      // Text('other').songTagStyle('#F5DC62');
    }
  }

  @Builder SongItemUI(value: SongModel) {
    Row({ space: 10 }) {
      Column({ space: 4 }) {
        Text(value.name)
          .fontSize(20)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor('E5000000');
        //
        Row({ space: 4 }) {
          this.SongTagUI(value.fee);
          Text(formatArtists(value.ar))
            .fontSize(15)
            .fontColor('#66000000')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        };
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);


      Image($r('app.media.ic_public_more_list')).width(30).fillColor('#66000000')

    }.padding(14);
  }

  build() {

    Column() {
      Row() {
        // Left
        Stack() {
          Column().backgroundColor(this.leftBgColor).width('100%').height('100%').animation({ curve: Curve.Linear });
          Column() {
            Row() {
              Image($r('app.media.ic_public_back')).onClick(() => {
                router.back();
              }).width(30).width(30).fillColor(Color.White)
            }
            .height(142)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .width('100%')
            .padding({ left: 34, right: 34 });

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
            // .backgroundColor(Color.Red);
          }
          .height('100%')
          .alignItems(HorizontalAlign.Center)
          .backgroundBlurStyle(BlurStyle.Thin)
          .justifyContent(FlexAlign.Start);
        }.width('34%');

        // Right
        Column() {
          Row().height(122).width('100%');
          Column() {
            Row({ space: 12 }) {
              Image($r('app.media.ic_public_play_norm')).width(28).width(28).fillColor('#E84026');
              Text(`Play all (${this.playlistDetails.trackCount})`).fontSize(16).fontWeight(FontWeight.Bold);
            }.height(66).width('100%').padding({ left: 10 });

            List() {
              LazyForEach(this.songs, (item: SongModel, index: number) => {
                ListItem() {
                  this.SongItemUI(item);
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
            .onReachEnd(() => this.getMoreSongs(this.playlistDetails.id));

          }
          .padding({ left: 12, right: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 14, topRight: 14 })
          .layoutWeight(1);

        }.backgroundColor('#F1F3F5').height('100%').layoutWeight(1);


      }.width('100%').layoutWeight(1);

      AudioPlayController().height(60);
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

