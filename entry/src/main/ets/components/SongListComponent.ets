import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { CommonDataSource } from '../models/CommonDataSource';
import { Song } from '../models/SongModel';
import { FromRouterValue } from './PlaylistDialogComponent';
import { SongInfoDialogComponent } from './SongInfoIDialogContent';
import { SongItemComponent, ActionType } from './SongItemComponent';

@Component
export struct SongListComponent {
  @Prop songCount: number;
  private songList: CommonDataSource<Song>;
  private onReachEnd?: () => void;
  @State dialogData: Song | null = null;
  private dialogController: CustomDialogController = new CustomDialogController({
    gridCount: 5,
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogComponent({ data: this.dialogData })
  });

  handleSongItemClick(item: Song, index: number): void {
    AudioService.getInstance().setPlaylist(this.songList.slice(index));
    AudioService.getInstance().start();
    const fromRouterValue: FromRouterValue = {
      state: router.getState(),
      params: router.getParams(),
    }
    router.pushUrl({
      url: 'pages/SongPlayerPage',
      params: { songId: item.id, from: fromRouterValue }
    });
  }

  handleSongItemActionTap(iconType: ActionType, value: Song) {
    if (iconType === ActionType.MORE) {
      this.dialogData = value;
      this.dialogController.open();
    } else if (iconType == ActionType.Mv) {
      router.pushUrl({ url: 'pages/MvPlayerPage', params: { mvId: value.mv } })
    } else if (iconType === ActionType.AddToPlaylist) {
      AudioService.getInstance().addNextPlaySong(value);
      AlertDialog.show({ message: `We'll play this next` });
    }
  }

  @Builder LoadingUI() {
    Row() {
      LoadingProgress().height(30).width(30).color('#B6C5D1');
      Text('Loading').fontColor('#B6C5D1').margin({ left: 6 });
    }
  }

  build() {
    Column() {
      List() {
        LazyForEach(this.songList, (item: Song, index: number) => {
          ListItem() {
            SongItemComponent({
              data: item,
              actions: [ActionType.Mv, ActionType.AddToPlaylist, ActionType.MORE],
              onActionTap: this.handleSongItemActionTap.bind(this),
              onItemTap: (value: Song) => {
                this.handleSongItemClick(value, index);
              },
            });
          }.width('100%').align(Alignment.Start);
        }, (item: Song, _) => `${item.id}_SONG_ITEM`);

        if (this.songList.totalCount() < this.songCount) {
          ListItem() {
            this.LoadingUI();
          }
        }
      }
      .lanes(2)
      .height(0)
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, endMargin: 16, color: '#ffe9f0f0' })
      .onReachEnd(() => {
        if (this.onReachEnd) this.onReachEnd();
      })
    }
  }
}
