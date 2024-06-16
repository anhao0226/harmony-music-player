import { Song } from '../models/SongModel';
import { formatArtists } from '../view_models/playlist_song_model';
import { IconComponent } from './IconComponent';


@Extend(Text) function songTagStyle(color: ResourceColor, borderColor: ResourceColor) {
  .border({ width: 1 })
  .borderRadius(3)
  .fontWeight(FontWeight.Bold)
  .borderColor(borderColor)
  .fontColor(color)
  .fontSize(10)
  .padding({ left: 2, right: 2 })
}


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
  private componentPadding: Length | Padding = 12;
  private rowSpace: number | string = 0;
  //
  private onItemTap?: (value: Song) => void;
  private onActionTap: (action: ActionType, value: Song) => void;
  @BuilderParam iconBuilder: (data: Song) => void = this._defaultBuilderFunc;

  @Builder _defaultBuilderFunc(data: Song) {
  }
  //
  @State _renderActions: IconDataInterface[] = null;
  @StorageProp('IS_PLAYING') @Watch('onStateChange') isPlaying: boolean = false;
  @StorageProp('AUDIO_ID') @Watch('onAudioIdChange') _currAudioId: number = 0;

  @Builder SongTagUI(fee: number) {
    if (fee === 0) {
      // Text('free').songTagStyle('#A6C2BE');
    } else if (fee === 1) {
      Text('VIP').songTagStyle($r('app.color.song_item_tag_color'), '#99E84026');
    } else {
      // Text('other').songTagStyle('#F5DC62');
    }
  }

  @Builder SongQualityTagUI() {
    if (this.data.hr) {
      Text('Hi-Res').songTagStyle('#F9A01E', '#99F9A01E')
    } else if (this.data.sq) {
      Text('SQ').songTagStyle($r('app.color.song_item_tag_color'), '#99E84026')
    }
  }

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

  @Builder PlayStateIcon() {
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
        /**
         *
         */
        Text(this.data.name)
          .fontSize(20)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor(this.fontColor)
          .fontWeight(FontWeight.Normal);
        /**
         *
         */
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
          this.PlayStateIcon();
          ForEach(this._renderActions, (item: IconDataInterface) => {
            IconComponent({
              iconSize: item.size,
              iconColor: item.color,
              resource: item.resource,
              onTap: () => this.onActionTap(item.type, this.data),
            });
          }, (item: IconDataInterface) => `${item.type}_ICON_ITEM`);
        }
      }
    }.padding(this.componentPadding).onClick(() => {
      if (this.onItemTap) this.onItemTap(this.data);
    })
  }
}


// @Component
// struct AnimationBar {
//   @Prop itemCount: number;
//   @Prop @Watch('onStateChange') isPlaying: boolean;
//   @State items: number[] = [];
//   private itemWidth = 2;
//   private itemMinHeight = 3;
//   private itemMaxHeight = 24;
//   private space: number = 2;
//   private _width = 0;
//
//   aboutToAppear() {
//     this.items = new Array<number>(this.itemCount);
//     this.items.map(() => 0);
//     this._width = this.itemCount * this.itemWidth + (this.space * (this.itemCount - 1));
//     this.startAnimate();
//   }
//
//   onStateChange() {
//     this.startAnimate();
//   }
//
//   startAnimate() {
//     if (this.isPlaying) {
//       animateTo({
//         duration: 325,
//         curve: Curve.Ease,
//         onFinish: () => this.startAnimate(),
//       }, () => {
//         for (let index = 0; index < this.itemCount; index++) {
//           const height = Math.round(Math.random() * this.itemMaxHeight);
//           this.items[index] = Math.max(height, this.itemMinHeight);
//         }
//       })
//     }
//   }
//
//   @Builder Bar(index: number, itemW: number) {
//     Row()
//       .width(itemW)
//       .height(this.items[index])
//       .backgroundColor('#E67C92')
//       .borderRadius({ topLeft: this.itemWidth, topRight: this.itemWidth });
//   }
//
//   build() {
//     Row({ space: this.space }) {
//       ForEach(this.items, (_: number, index: number) => {
//         this.Bar(index, this.itemWidth);
//       }, (_: any, index: number) => `${index}_ITEM_BAR`);
//     }.width(this._width).height(this.itemMaxHeight).alignItems(VerticalAlign.Bottom);
//   }
// }
//
