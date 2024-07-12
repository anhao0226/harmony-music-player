import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { Song } from '../models/SongModel';
import { ArtistModel, defaultSongItem, formatArtists, SongModel } from '../view_models/playlist_song_model';
import { AnimatedCrossFade } from './AnimatedCrossFade';

@Component
export struct BottomBarControlComponent {
  @StorageProp('IS_PLAYING') isPlaying: boolean = false;
  @StorageProp('CURRENT_AUDIO_ID') @Watch('onAudioChange') currAudioId: number = 0;
  @StorageProp('PROGRESS') progress: number = 0;
  @StorageProp('SONG_DURATION') songDuration: number = 0;
  @State _songItem: Song | null = null;

  aboutToAppear() {
    this._songItem = AudioService.getInstance().getCurrSong();
  }

  onAudioChange() {
    this._songItem = AudioService.getInstance().getCurrSong()
  }

  @Builder IconBuilder(src: Resource, size: number, onTap: () => void) {
    Image(src).width(size).fillColor($r('app.color.main_color')).onClick(() => onTap());
  }

  build() {
    Row() {
      Row({ space: 12 }) {
        Image(this._songItem === null ? $r('app.media.ic_public_disc_fill') : this._songItem.al.picUrl)
          .width(38)
          .height(38)
          .fillColor($r('app.color.main_color'))
          .borderRadius(8);
        Column() {
          Text(this._songItem ? this._songItem.name : '');
          Text(formatArtists(this._songItem ? this._songItem.ar : [])).fontSize(14).fontColor(Color.Gray);
        }.alignItems(HorizontalAlign.Start);
      }

      Blank();
      Row({ space: 20 }) {
        // prev button
        this.IconBuilder($r('app.media.ic_public_skip_back_fill'), 24, () => {
          AudioService.getInstance().playPrevious();
        })
        // playing / paused
        Stack() {
          //
          Progress({ value: this.progress, total: this.songDuration, type: ProgressType.Ring })
            .width(35).height(35).color($r('app.color.main_color')).style({ scaleWidth: 2, strokeWidth: 2 });
          //
          AnimatedCrossFade({
            state: this.isPlaying ? true : false,
            duration: 200,
            firstChild: () => this.IconBuilder($r('app.media.ic_public_pause_large_fill'), 24, () => {
              AudioService.getInstance().pause();
            }),
            secondChild: () => this.IconBuilder($r('app.media.ic_public_play_large_fill'), 24, () => {
              AudioService.getInstance().play();
            }),
          });
        }
        // next button
        this.IconBuilder($r('app.media.ic_public_skip_forward_fill'), 24, () => {
          AudioService.getInstance().playNext();
        });
      }.padding({ right: 20 })
    }
    .onClick(() => {
      router.pushUrl({ url: 'pages/SongPlayerPage' });
    })
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F1F3F5');
  }
}