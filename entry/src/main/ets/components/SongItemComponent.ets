import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { Song } from '../models/SongModel';
import { formatArtists } from '../view_models/playlist_song_model';
import { IconComponent } from './IconComponent';
import { SongInfoDialogComponent } from './SongInfoIDialogContent';

export interface IconDataInterface {
  size: number,
  color: string,
  resource: Resource,
  type: ActionType,
}

export enum ActionType { Mv, AddToPlaylist, MORE, Close }

const fixedSongItemIcons: IconDataInterface[] = [
  {
    size: 24,
    color: '#66000000',
    resource: $r('app.media.ic_public_movie_line'),
    type: ActionType.Mv,
  },
  {
    size: 24,
    color: '#66000000',
    resource: $r('app.media.ic_public_play_list_add_line'),
    type: ActionType.AddToPlaylist,
  },
  {
    size: 24,
    color: '#66000000',
    resource: $r('app.media.ic_public_more_2_fill'),
    type: ActionType.MORE,
  },
  {
    size: 24,
    color: '#66000000',
    resource: $r('app.media.ic_public_close_line'),
    type: ActionType.Close,
  }
]

@Component
export struct SongItemComponent {
  private data: Song;
  private fontColor: string = '#E5000000';
  private iconColor: string = '#66000000';
  private actions: ActionType[] = null;
  private rowSpace: number | string = 0;
  private componentPadding: Length | Padding = 16;
  //
  private onItemTap?: (value: Song) => void;
  private onActionTap: (action: ActionType, value: Song) => void;
  @BuilderParam iconBuilder: (data: Song) => void = this._defaultBuilderFunc;

  @Builder _defaultBuilderFunc(data: Song) {
  }
  //
  @State _renderActions: IconDataInterface[] = null;
  @StorageProp('IS_PLAYING') @Watch('onStateChange') isPlaying: boolean = false;
  @StorageProp('CURRENT_AUDIO_ID') @Watch('onAudioIdChange') _currAudioId: number = 0;
  protected shareDialogData: Song = null;
  protected songDetailController: CustomDialogController = new CustomDialogController({
    gridCount: 5,
    alignment: DialogAlignment.Center,
    builder: SongInfoDialogComponent({ data: this.shareDialogData })
  });

  aboutToAppear() {
    this.initData();
  }

  initData() {
    if (this.actions) {
      let actions: IconDataInterface[] = [];
      const index: number = this.actions.indexOf(ActionType.Mv);
      if (index > -1 && !this.data.mv) this.actions.splice(index, 1);
      this.actions.forEach((value: ActionType) => actions.push(fixedSongItemIcons[value]));
      this._renderActions = actions;
    }
  }

  onStateChange() {

  }

  onAudioIdChange() {

  }

  handleAction(action: ActionType) {
    if (action === ActionType.MORE) {
      this.shareDialogData = this.data;
      this.songDetailController.open();
    } else if (action == ActionType.Mv) {
      router.pushUrl({ url: 'pages/MvPlayerPage', params: { mvId: this.data.mv } });
    } else if (action === ActionType.AddToPlaylist) {
      AudioService.getInstance().add2NextPlaylist(this.data);
      AlertDialog.show({ message: `We'll play this next` });
    } else if (action === ActionType.Close) {
      // TODO
    }
    if(this.onActionTap) this.onActionTap(action, this.data);
  }

  @Builder TagBuilder(text: string, color: ResourceColor, borderColor: ResourceColor) {
    Text(text)
      .border({ width: 1 })
      .borderRadius(3)
      .fontWeight(FontWeight.Bold)
      .borderColor(borderColor)
      .fontColor(color)
      .fontSize(10)
      .padding({ left: 2, right: 2 });
  }

  @Builder SongTagUI(fee: number) {
    if (fee === 1) {
      this.TagBuilder('VIP', $r('app.color.song_item_tag_color'), '#99E84026');
    } else if (fee === 1) {
    } else {
    }
  }

  @Builder SongQualityTagUI() {
    if (this.data.hr) {
      this.TagBuilder('Hi-Res', '#F9A01E', '#99F9A01E');
    } else if (this.data.sq) {
      this.TagBuilder('SQ', $r('app.color.song_item_tag_color'), '#99E84026');
    }
  }

  @Builder PlayStateIconBuilder() {
    if (this._currAudioId == this.data.id) {
      IconComponent({
        iconColor: '#E84026',
        iconSize: 28,
        resource: $r('app.media.ic_public_rhythm_line')
      });
    }
  }

  build() {
    Row({ space: this.rowSpace }) {
      Column({ space: 4 }) {
        //
        Text(`${this.data.name}`)
          .fontSize(20)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor(this.fontColor)
          .fontWeight(FontWeight.Normal);
        //
        Row({ space: 4 }) {
          this.SongTagUI(this.data.fee);
          this.SongQualityTagUI();
          Text(formatArtists(this.data.ar))
            .fontSize(15)
            .fontColor(this.iconColor)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);
      //
      Blank();
      //  actions
      if (this._renderActions) {
        Row({ space: 20 }) {
          this.PlayStateIconBuilder();
          ForEach(this._renderActions, (item: IconDataInterface) => {
            Image(item.resource).width(item.size).fillColor(item.color).onClick(() => {
              this.handleAction(item.type);
            });
          }, (item: IconDataInterface) => `${item.type}_ICON_ITEM`);
        }
      }
    }.padding(this.componentPadding).onClick(() => {
      if (this.onItemTap) this.onItemTap(this.data);
    })
  }
}