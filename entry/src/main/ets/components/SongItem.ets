import { AudioService } from '../common/utils/AudioService';
import { formatArtists, SongModel } from '../view_models/playlist_song_model';


@Extend(Text) function songTagStyle(color: ResourceColor) {
  .border({ width: 1.4 })
  .borderRadius(3)
  .fontWeight(FontWeight.Bold)
  .borderColor(color)
  .fontColor(color)
  .fontSize(10)
  .padding({ left: 2, right: 2, top: 0.4, bottom: 0.4 })
}

@Component
export struct SongItemComponent {
  private data: SongModel;
  private onMoreButtonClick?: (value: SongModel) => void;
  private index: number = 0;
  @StorageProp('IS_PLAYING') @Watch('onStateChange') isPlaying: boolean = false;
  @StorageProp('CURR_AUDIO_ID') @Watch('onCurrAudioIdChange') currAudioId: number = 0;

  @Builder SongTagUI(fee: number) {
    if (fee === 0) {
      // Text('free').songTagStyle('#A6C2BE');
    } else if (fee === 1) {
      Text('VIP').songTagStyle($r('app.color.song_item_tag_color'));
    } else {
      // Text('other').songTagStyle('#F5DC62');
    }
  }

  aboutToAppear() {
    this.isPlaying = AppStorage.Get<boolean>('IS_PLAYING');
    this.currAudioId = AppStorage.Get<number>('CURR_AUDIO_ID');
  }

  onStateChange() {

  }

  onCurrAudioIdChange() {

  }

  @Builder IndexUI(index: number) {
    if (this.currAudioId === this.data.id) {
      Row() {
        AnimationBar({ isPlaying: this.isPlaying ? true : false, itemCount: 4 })
      }.width(40).justifyContent(FlexAlign.Center);
    } else {
      Text(new String(index + 1).padStart(2, '0'))
        .width(40)
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .fontColor('#66000000');
    }
  }

  build() {
    Row({ space: 10 }) {
      this.IndexUI(this.index);
      Column({ space: 4 }) {
        Text(this.data.name)
          .fontSize(20)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor('E5000000');
        Row({ space: 4 }) {
          this.SongTagUI(this.data.fee);
          Text(formatArtists(this.data.ar))
            .fontSize(15)
            .fontColor('#66000000')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);

      Blank();

      Image($r('app.media.ic_public_more_list'))
        .width(36)
        .padding({ left: 5, right: 5 })
        .fillColor('#66000000')
          // .backgroundColor(Color.Red)
        .onClick(() => {
          if (this.onMoreButtonClick) this.onMoreButtonClick(this.data);
        })
    }.padding(12)
  }
}


@Component
struct AnimationBar {
  @Prop itemCount: number;
  @Prop @Watch('onStateChange') isPlaying: boolean;
  @State items: number[] = [];
  private rowWidth = 0;
  private itemWidth = 2;
  private itemMinHeight = 3;
  private itemMaxHeight = 24;
  private space: number = 2;

  aboutToAppear() {
    this.items = new Array<number>(this.itemCount);
    this.items.map(() => 0);
    this.rowWidth = this.itemCount * this.itemWidth + (this.space * (this.itemCount - 1));
    this.startAnimate();
  }

  onStateChange() {
    this.startAnimate();
  }

  startAnimate() {
    if (this.isPlaying) {
      animateTo({
        duration: 325,
        curve: Curve.Ease,
        onFinish: () => this.startAnimate(),
      }, () => {
        for (let index = 0; index < this.itemCount; index++) {
          this.items[index] = Math.max(Math.round(Math.random() * this.itemMaxHeight), this.itemMinHeight);
        }
      })
    }
  }

  @Builder Bar(index: number, itemW: number) {
    Row()
      .width(itemW)
      .height(this.items[index])
      .backgroundColor('#E67C92')
      .borderRadius({ topLeft: this.itemWidth, topRight: this.itemWidth });
  }

  build() {
    Row({ space: this.space }) {
      ForEach(this.items, (_: number, index: number) => {
        this.Bar(index, this.itemWidth);
      }, (_: any, index: number) => `${index}_ITEM_BAR`);
    }.width(this.rowWidth).height(this.itemMaxHeight).alignItems(VerticalAlign.Bottom);
  }
}

