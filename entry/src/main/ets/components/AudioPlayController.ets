import router from '@ohos.router';
import { AudioService } from '../common/utils/AudioService';
import { ArtistModel, defaultSongItem, formatArtists, SongModel } from '../view_models/playlist_song_model';
// import { AudioService, EventId, IsPlayingStorageKey, SongItemStorageKey } from '../common/utils/AudioService';
// import emitter from '@ohos.events.emitter';

@Component
export struct AudioPlayController {
  @StorageProp('IS_PLAYING') isPlaying: boolean = false;
  @StorageProp('CURR_AUDIO_ID') @Watch('onCurrAudioChange') currAudioId: number = 0;
  @State currSongItem: SongModel = defaultSongItem;

  aboutToAppear(){
    this.currSongItem = AudioService.getInstance().getCurrSong();
  }

  onCurrAudioChange() {
    this.currSongItem = AudioService.getInstance().getCurrSong();
  }

  build() {
    Row() {
      Row({ space: 12 }) {
        Image(this.currSongItem.id > 0 ? this.currSongItem.al.picUrl : $r('app.media.ic_public_music_filled'))
          .width(30)
          .height(30)
          .borderRadius(8);

        Column() {
          Text(this.currSongItem.name);
          Text(formatArtists(this.currSongItem.ar)).fontSize(14).fontColor(Color.Gray);
        }.alignItems(HorizontalAlign.Start);
      }

      Blank();
      Row({ space: 16 }) {
        // playing / paused
        Image(this.isPlaying ? $r('app.media.ic_public_pause') : $r('app.media.ic_public_play'))
          .width(30)
          .onClick(() => {
            if (this.isPlaying) {
              AudioService.getInstance().pause();
            } else {
              AudioService.getInstance().play();
            }
          });

        // next button
        Image($r('app.media.ic_public_play_next')).width(30).onClick(() => {
          // AudioService.getInstance().playNext();
        })

      }.padding({ right: 20 })
    }
    .onClick(() => {
      router.pushUrl({ url: 'pages/SongPlayerPage' });
    })
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F1F3F5');
  }
}