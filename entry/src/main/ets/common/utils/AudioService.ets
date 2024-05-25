import media from '@ohos.multimedia.media';
import emitter from '@ohos.events.emitter';
import { SongModel, getSongUrl, defaultSongItem } from '../../view_models/playlist_song_model';
import { StorageService } from './StorageService';
import { AvPlayState, SongPlayMode, EventId } from './AudioConfig'


export class AudioService {
  private playIndex: number = 0;
  private playList: SongModel[] = [];
  private isPrepare: boolean = false;
  private avPlayer: media.AVPlayer | null = null;
  private avPlayerState: AvPlayState = AvPlayState.IDLE;
  private playMode: SongPlayMode = SongPlayMode.ORDER;

  constructor() {
    this.initAudioPlayer();
  }

  public static getInstance(): AudioService {
    let audioService: AudioService | undefined = AppStorage.Get('AUDIO_SERVICE');
    if (!audioService) {
      audioService = new AudioService();
      AppStorage.SetOrCreate('AUDIO_SERVICE', audioService);
    }
    return audioService;
    return new AudioService();
  }

  public initAudioPlayer() {
    media.createAVPlayer().then((avPlayer: media.AVPlayer) => {
      this.avPlayer = avPlayer;
      this.setAVPlayerCallback();
    }).catch((err: Error) => {
      console.log(`CreateAVPlayerError : ${JSON.stringify(err)}`);
    });
  }

  public initData(data: SongModel[], index?: number) {
    this.updatePlaylist(data);
    index = index | 0;
    this.updatePlayIndex(index)
    if (data.length > 0 && index < data.length) {
      AppStorage.SetOrCreate('SONG_ITEM', data[index]);
    }
  }

  public getPlayMode() {
    return this.playMode;
  };

  public updatePlayMode(mode: SongPlayMode) {
    this.playMode = mode;
    StorageService.getInstance().put('PLAY_MODE', JSON.stringify(mode));
  }

  private updatePlaylist(data: SongModel[]) {
    this.playList = data;
    StorageService.getInstance().put('PLAY_LIST', JSON.stringify(data));
  }

  private updatePlayIndex(index: number) {
    this.playIndex = index;
    StorageService.getInstance().put('PLAY_INDEX', index);
  }

  public playPrevious() {
    let playIndex = this.playIndex - 1;
    if (this.playIndex === -1) {
      playIndex = this.playList.length - 1;
    }
    this.start(playIndex);
  }

  public playlist(): SongModel[] {
    return this.playList
  };

  public playNext() {
    let playIndex = this.playIndex + 1;
    if (playIndex === this.playList.length) {
      playIndex = 0;
    }
    this.start(playIndex);
  }

  public start(seek?: number) {
    if (this.avPlayer) {
      this.avPlayer.reset().then(async () => {
        const index: number = seek || this.playIndex;
        const song = this.playList[index];
        this.updatePlayIndex(index);
        //
        let data = { 'song': JSON.stringify(song) }
        emitter.emit({ eventId: EventId.CHANGE_SONG }, { data: data });
        //
        AppStorage.SetOrCreate<number>('PROGRESS', 0)
        AppStorage.SetOrCreate<number>('SONG_TIME', song.dt);
        AppStorage.SetOrCreate<boolean>('IS_PLAYING', false);
        AppStorage.SetOrCreate<number>('CURR_AUDIO_ID', song.id);
        //
        getSongUrl(song.id).then((value) => {
          this.avPlayer.url = value.url;
        }).catch((err) => {
          console.log(`ERROR ${err}`);
        })
      });
    }
  }

  public getCurrSong(): SongModel {
    const length = this.playList.length;
    if (!length || this.playIndex > length - 1) return defaultSongItem;
    else return this.playList[this.playIndex];
  }


  public seek(ms: number) {
    if (this.isPrepare && this.avPlayerState != AvPlayState.ERROR) {
      const finalTime = ms <= 0 ? 0 : (ms >= this.avPlayer.duration ? this.avPlayer.duration : ms);
      if (this.avPlayer) this.avPlayer.seek(finalTime);
    }
  }

  public async play() {
    // 通过回调方式开始播放音视频资源，只能在prepared/paused/complete状态调用
    if (this.avPlayer) {
      if (this.avPlayer.state === 'idle') {
        this.start(this.playList[this.playIndex].id);
      } else {
        this.avPlayer.play();
        AppStorage.SetOrCreate<boolean>('IS_PLAYING', true);
      }
    }
  }

  public pause() {
    // 通过回调方式暂停播放音视频资源，只能在playing状态调用
    if (this.avPlayer && this.avPlayerState === AvPlayState.PLAYING) {
      this.avPlayer.pause().then(() => {
        this.avPlayerState = AvPlayState.PAUSED;
        AppStorage.SetOrCreate<boolean>('IS_PLAYING', false);
      })
    }
  }


  // 注册avplayer回调函数
  setAVPlayerCallback() {

    if (!this.avPlayer) {
      console.log(`AVPlayerError`);
      return;
    }

    this.avPlayer.on('seekDone', (seekDoneTime) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })

    this.avPlayer.on('error', (err) => {
      console.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      this.avPlayer.reset();
    })

    this.avPlayer.on('durationUpdate', (duration) => {
      AppStorage.SetOrCreate('DURATION', duration);
    })

    this.avPlayer.on('timeUpdate', (value) => {
      AppStorage.SetOrCreate('PROGRESS', value);
    })

    // 状态机变化回调函数
    this.avPlayer.on('stateChange', async (state, reason) => {
      switch (state) {
        case 'idle':
          this.avPlayerState = AvPlayState.IDLE;
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          this.avPlayer.prepare().then(() => {
            this.isPrepare = true;
            console.info('AVPlayer prepare succeeded.');
          }, (err) => {
            console.log(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          this.avPlayerState = AvPlayState.INITIALIZED;
          break;
        case 'prepared':
          AppStorage.SetOrCreate('DURATION', this.avPlayer.duration);
          if (this.avPlayer) this.play();
          this.avPlayerState = AvPlayState.PREPARED;
          console.info('AVPlayer state prepared called.');
          break;
        case 'playing':
          this.avPlayerState = AvPlayState.PLAYING;
          console.info('AVPlayer state playing called.');
          break;
        case 'paused':
          this.avPlayerState = AvPlayState.PAUSED;
          console.info('AVPlayer state paused called.');
          break;
        case 'completed':
          this.avPlayerState = AvPlayState.COMPLETED;
          switch (this.playMode) {
            case SongPlayMode.ORDER:
              if (this.playIndex < this.playList.length - 1) {
                this.start(this.playIndex + 1);
              } else this.avPlayer.stop();
              break;
            case SongPlayMode.RANDOM:
              break;
            case SongPlayMode.SINGLE_CYCLE:
              this.avPlayer.play();
              break;
            case SongPlayMode.LIST_CYCLE:
              this.playNext();
              break;
          }
          console.info('AVPlayer state completed called.');
          break;
        case 'stopped':
          this.avPlayerState = AvPlayState.STOPPED;
          console.info('AVPlayer state stopped called.');
          this.avPlayer.reset();
          break;
        case 'released':
          this.avPlayerState = AvPlayState.RELEASED;
          console.info('AVPlayer state released called.');
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    })
  }
}