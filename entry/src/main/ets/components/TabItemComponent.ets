import router from '@ohos.router'
import { PlaylistDataSource } from '../view_models/PlaylistDataSource';
import { CategoryModel, getHighQualityPlaylist, PlaylistModel } from '../view_models/playlist_song_model'
import { CustomImage } from './CustomImage';


@Component
export struct TabItemComponent {
  @State currentBp: string = 'unknown';
  @State isLoading: boolean = false;
  @State showMask: boolean = true;
  @State imageWidth: number = 0;
  @State _itemH: number = 0;
  private category: CategoryModel;
  private scroller: Scroller = new Scroller()
  private playlists: PlaylistDataSource = new PlaylistDataSource();
  private onDataChange: (value: PlaylistModel) => void;
  private _lastUpdateTime: number = 0;

  aboutToAppear() {
    this.getData(this._lastUpdateTime);
  }

  getData(before: number) {
    getHighQualityPlaylist(this.category.name, before).then((data: PlaylistModel[]) => {
      if (data.length) {
        if (this.onDataChange) this.onDataChange(data[0]);
      }
      this.playlists.pushDataFromArray(data);
      this._lastUpdateTime = data[data.length - 1].updateTime;
    })
  }

  @Builder ListItemBuild(item: PlaylistModel) {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        CustomImage({ src: item.coverImgUrl, imageWidth: this.imageWidth });
        Row({ space: 6 }) {
          Image($r('app.media.ic_public_more_2_fill'))
            .width(22).fillColor('#FFFFFF');
          Text(item.playCount.toString())
            .fontColor('#FFFFFF').fontSize(12);
        }.padding(12);
      }
      //
      Row() {
        Text(item.name).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });
      }.height(46).alignItems(VerticalAlign.Top);

    }.justifyContent(FlexAlign.Start).onClick(() => {
      router.pushUrl({ url: 'pages/PlaylistDetailPage', params: { 'playlistId': item.id } });
    })
  }

  build() {
    Column() {
      Stack() {
        Row() {
          List({ space: 12 }) {
            LazyForEach(this.playlists, (item: PlaylistModel, index: number) => {
              ListItem() {
                this.ListItemBuild(item);
              }.margin({ top: 10 })
            }, (item: PlaylistModel, index) => (item.id + index).toString())
          }
          .lanes(6)
          .width('100%')
          .height('100%')
          .onAreaChange((_: Area, newVal: Area) => {
            const totalSpace: number = 5 * 10;
            this.imageWidth = (newVal.width as number - totalSpace) / 6;
          })
          .onReachEnd(() => {
            this.getData(this._lastUpdateTime);
          });

        }.padding({ left: 20, right: 20 })
        //
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
    }.backgroundColor('#F1F3F5').height('100%');
  }
}


