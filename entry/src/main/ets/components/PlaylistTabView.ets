import router from '@ohos.router'
import { PlaylistDataSource } from '../view_models/PlaylistDataSource';
import { CategoryModel, getHighQualityPlaylist, PlaylistModel } from '../view_models/playlist_song_model'
import { TabBarDataInterface } from './CustomTabBar';
import { CustomImage } from './ImageComponent';


@Component
export struct PlaylistTabView {
  @Prop @Watch('onViewWidthChange') viewWidth: number;
  @State currentBp: string = 'unknown';
  @State isLoading: boolean = false;
  @State showMask: boolean = true;
  private category: TabBarDataInterface;
  private scroller: Scroller = new Scroller()
  private playlists: PlaylistDataSource = new PlaylistDataSource();
  private _lastUpdateTime: number = 0;
  @State itemWidth: number = 100;

  aboutToAppear() {
    this.initData(this._lastUpdateTime);
  }

  onViewWidthChange() {
    this.itemWidth = (this.viewWidth - 5 * 12) / 6;
  }

  setImageSize(src: string, width: number, height: number): string {
    return `${src}?param=${width}y${height}`
  }

  initData(before: number) {
    getHighQualityPlaylist(this.category.text, before).then((data: PlaylistModel[]) => {
      this.playlists.pushDataFromArray(data);
      this._lastUpdateTime = data[data.length - 1].updateTime;
    })
  }

  @Builder ListItemBuild(item: PlaylistModel) {
    Column({ space: 12 }) {
      CustomImage({
        imageSrc: this.setImageSize(item.coverImgUrl, 400, 400),
        imageWidth: this.itemWidth,
        imageAspectRatio: 1,
        imageBorderRadius: 6
      });
      Text(item.name).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width(this.itemWidth)
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      router.pushUrl({ url: 'pages/PlaylistDetailPage', params: { 'playlistId': item.id } });
    })
  }

  build() {
    Column() {
      Stack() {
        List({ space: 12 }) {
          LazyForEach(this.playlists, (item: PlaylistModel, index: number) => {
            ListItem() {
              this.ListItemBuild(item);
            }.margin({ top: 10 })
          }, (item: PlaylistModel, index) => `PLAYLIST_ITEM_${item.id}`);
        }
        .lanes(6)
        .width('100%')
        .height('100%')
        .onReachEnd(() => {
          this.initData(this._lastUpdateTime);
        });

        Column() {
          LoadingProgress().height(52).width(52).color('#B6C5D1');
          Text('Loading').fontColor('#B6C5D1').margin({ left: 6 }).fontSize(18);
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F1F3F5')
        .justifyContent(FlexAlign.Center)
        .visibility(this.isLoading ? Visibility.Visible : Visibility.None);
      }
    }.backgroundColor('#F1F3F5').height('100%').width('100%');
  }
}


