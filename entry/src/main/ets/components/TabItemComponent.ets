import router from '@ohos.router'
import image from '@ohos.multimedia.image';
import { PlaylistDataSource } from '../view_models/PlaylistDataSource';
import { CategoryModel, getHighQualityPlaylist, PlaylistModel } from '../view_models/playlist_song_model'
import { CustomImage } from './CustomImage';


@Component
export struct TabItemComponent {
  private category: CategoryModel;
  scroller: Scroller = new Scroller()
  @State playlists: PlaylistDataSource = new PlaylistDataSource();
  @State currentBp: string = 'unknown';
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.isLoading = true;
    getHighQualityPlaylist(this.category.name, 0).then((data: PlaylistModel[]) => {
      const length = data.length;
      for (let index = 0; index < length; index++) {
        this.playlists.pushData(data[index]);
      }
      setTimeout(() => this.isLoading = false, 800);
    })
  }

  @Builder Wrapper() {

  }

  build() {
    Row() {
      if (!this.isLoading) {
        List() {
          LazyForEach(this.playlists, (item: PlaylistModel, index: number) => {
            ListItem() {
              Column({ space: 12 }) {
                Stack({ alignContent: Alignment.BottomStart }) {
                  CustomImage({ src: item.coverImgUrl });
                  Row({ space: 6 }) {
                    Image($r('app.media.ic_public_play_norm'))
                      .width(22)
                      .width(22)
                      .fillColor('#FFFFFF');
                    Text(item.playCount.toString()).fontColor('#FFFFFF').fontSize(12);
                  }.padding(12);
                }

                Text(item.name).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis });
              }
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 6, right: 6 }).margin({ top: 20 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/PlaylistDetailPage', params: { 'playlistId': item.id } })
              })
            }
          }, (item: PlaylistModel, index) => (item.id + index).toString())
        }.width('100%').height('100%').lanes(6);
      } else {
        Column() {
          LoadingProgress().height(52).width(52).color('#B6C5D1');
          Text('Loading').fontColor('#B6C5D1').margin({ left: 6 }).fontSize(18);
        }.width('100%');
      }
    }.backgroundColor('#F1F3F5').height('100%').padding({ left: 20, right: 20});
  }
}