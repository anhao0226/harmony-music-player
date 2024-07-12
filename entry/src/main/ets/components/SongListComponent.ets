import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { ListType } from '../common/utils/AudioShareData';
import { CommonDataSource } from '../models/CommonDataSource';
import { DataSource } from '../models/DataSource';
import { Song } from '../models/SongModel';
import { FromRouterValue } from './PlaylistDialogComponent';
import { SongInfoDialogComponent } from './SongInfoIDialogContent';
import { SongItemComponent, ActionType } from './SongItemComponent';

export interface ListDataInterface {
  data: DataSource<Song>
  header?: (() => any)
  type?: ListType
}

@Component
export struct SongListComponent {
  @Prop songCount: number;
  private lanes: number = 2;
  private actions: ActionType[] = [];
  private navigation: boolean = true;
  private data: ListDataInterface[];
  private onReachEnd?: () => void;

  handleSongItemClick(listData: ListDataInterface, item: Song, index: number): void {
    let listType: ListType = listData.type || ListType.Play;
    if (listType == ListType.Play) {
      AudioService.getInstance().updatePlaylist(listData.data.slice(index));
      AudioService.getInstance().start();
    } else if (listType == ListType.Next) {
      AudioService.getInstance().start(index, listData.type);
    } else if (listType == ListType.History) {
      AudioService.getInstance().start(index, listData.type);
    }

    const fromRouterValue: FromRouterValue = {
      state: router.getState(),
      params: router.getParams(),
    }

    const options: router.RouterOptions = {
      url: 'pages/SongPlayerPage',
      params: { songId: item.id, from: fromRouterValue }
    }

    if (this.navigation) {
      router.pushUrl(options);
    } else {
      router.replaceUrl(options)
    }
  }

  @Builder LoadingUI() {
    Row() {
      LoadingProgress().height(30).width(30).color('#B6C5D1');
      Text('Loading').fontColor('#B6C5D1').margin({ left: 6 });
    }
  }

  @Builder ListItemUI(data: ListDataInterface, item: Song, index: number) {
    SongItemComponent({
      data: item,
      actions: this.actions,
      onActionTap: (action, value) => {},
      onItemTap: (value: Song) => {
        this.handleSongItemClick(data, value, index);
      },
    }).padding({ left: 10, right: 10 });
  }

  build() {
    Column() {
      List() {
        ForEach(this.data, (item: ListDataInterface, _) => {
          ListItemGroup({ header: item.data.totalCount() ? item.header : null }) {
            LazyForEach(item.data, (item_: Song, index_: number) => {
              ListItem() {
                this.ListItemUI(item, item_, index_);
              }.align(Alignment.Start);
            }, (item_: Song, _) => `${item_.id}_SONG_ITEM`);
          }.divider({ strokeWidth: 1, startMargin: 10, endMargin: 10, color: '#ffe9f0f0' });
        }, (_, index: number) => `${index}_LIST_GROUP`);
      }
      .lanes(this.lanes)
      .height(0)
      .width('100%')
      .layoutWeight(1)
      .sticky(StickyStyle.Header)
      .onReachEnd(() => {
        if (this.onReachEnd) this.onReachEnd();
      });
    }
  }
}
