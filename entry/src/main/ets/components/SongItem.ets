import { AudioService } from '../common/utils/AudioService';
import { formatArtists, SongModel } from '../view_models/playlist_song_model';
import { AnimationBar } from './AnimationBar';

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

  build() {
    Row({ space: 10 }) {

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
        };
      }.alignItems(HorizontalAlign.Start).layoutWeight(1);

      Blank();

      AnimationBar({ isPlaying: this.isPlaying ? true : false, barCount: 6 })
        .visibility(this.currAudioId === this.data.id ? Visibility.Visible : Visibility.Hidden);

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
