import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { Song } from '../models/SongModel';
import { ArtistModel, defaultSongItem, formatArtists, SongModel } from '../view_models/playlist_song_model';
// import { AudioService, EventId, IsPlayingStorageKey, SongItemStorageKey } from '../common/utils/AudioService';
// import emitter from '@ohos.events.emitter';

@Component
export struct BottomBarControlComponent {
  @StorageProp('IS_PLAYING') isPlaying: boolean = false;
  @StorageProp('AUDIO_ID') @Watch('onAudioChange') currAudioId: number = 0;
  @State _songItem: Song | null = null;

  aboutToAppear() {
    this._songItem = AudioService.getInstance().getCurrSong();
  }

  onAudioChange() {
    this._songItem = AudioService.getInstance().getCurrSong()
  }

  build() {
    Row() {
      Row({ space: 12 }) {
        Image(this._songItem === null ? $r('app.media.ic_public_disc_fill') : this._songItem.al.picUrl)
          .width(30)
          .height(30)
          .borderRadius(8)

        Column() {
          Text(this._songItem ? this._songItem.name : '');
          Text(formatArtists(this._songItem ? this._songItem.ar : [])).fontSize(14).fontColor(Color.Gray);
        }.alignItems(HorizontalAlign.Start)
      }

      Blank();
      Row({ space: 16 }) {
        // playing / paused
        Image(this.isPlaying ? $r('app.media.ic_public_pause_large_fill') : $r('app.media.ic_public_play_large_fill'))
          .width(30)
          .onClick(() => {
            if (this.isPlaying) {
              AudioService.getInstance().pause();
            } else {
              AudioService.getInstance().play();
            }
          });

        // next button
        Image($r('app.media.ic_public_skip_forward_fill')).width(30).onClick(() => {
          AudioService.getInstance().playNext();
        })

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