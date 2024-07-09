import media from '@ohos.multimedia.media';
import preferences from '@ohos.data.preferences';
import { AvPlayerState, AvPlayMode } from './AudioConfig';
import { AudioShareData, ListType } from './AudioShareData';
import { Song } from '../../models/SongModel';
import { fetchSongs, fetchSongUrl } from '../../api/SongApi';
import { FromRouterValue } from '../../components/PlaylistDialogComponent';
import { DataSource } from '../../models/DataSource';

export class AudioService {
  protected isPrepare: boolean = false;
  protected avPlayer: media.AVPlayer | null = null;
  protected avPlayerState: AvPlayerState = AvPlayerState.IDLE;
  protected shareData: AudioShareData<Song> = new AudioShareData<Song>();
  protected _fromRouterValue: FromRouterValue = null;

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
  }

  protected initAudioPlayer() {
    media.createAVPlayer().then((avPlayer: media.AVPlayer) => {
      this.avPlayer = avPlayer;
      this.setAVPlayerCallback();
    }).catch((err: Error) => {
      console.log(`CreateAVPlayerError : ${JSON.stringify(err)}`);
    });
  }

  setFromRouterValue(value: FromRouterValue) {
    this._fromRouterValue = value;
  }

  getFromRouterValue(): FromRouterValue {
    return this._fromRouterValue;
  }

  public getAudioId() {
    return this.shareData.currAudioId;
  }

  public getPlayMode() {
    return this.shareData.playMode;
  };

  public setPlayMode(mode: AvPlayMode) {
    this.shareData.playMode = mode;
  }

  public updatePlaylist(values: Song[]) {
    this.shareData.playlist.init(values);
  }

  public listData(lisType: ListType): DataSource<Song> {
    if (lisType === ListType.Play) {
      return this.shareData.playlist;
    } else if (lisType === ListType.Next) {
      return this.shareData.nextPlaylist;
    } else if (lisType === ListType.History) {
      return this.shareData.history;
    }
  }

  public delListItem() {

  }

  public getCurrSong(): Song {
    return this.shareData.currAudioData();
  }

  public currPlayIndex() {
    return this.shareData.currPlayIndex;
  }

  public playPrevious() {
    this.start(this.shareData.nextPlayIndex());
  }

  public playNext() {
    let flag: ListType = ListType.Play;
    let index: number = this.shareData.nextPlayIndex();
    if (this.shareData.nextPlaylist.totalCount()) {
      index = 0;
      flag = ListType.Next;
    }
    this.start(index, flag);
  }

  /**
   * @deprecated
  * @param song
   */
  public addNextPlaySong(song: Song) {
    this.shareData.nextPlaylist.pushData(song);
  }

  public add2NextPlaylist(song: Song) {
    this.shareData.nextPlaylist.pushData(song);
  }

  public nextPlaylist(): DataSource<Song> {
    return this.shareData.nextPlaylist;
  }

  public start(seek?: number, listType?: ListType) {
    let type: ListType = listType || ListType.Play;
    let song: Song = null;
    if (type === ListType.Play) {
      seek = seek || 0;
      song = this.shareData.playlist.getData(seek);
      this.shareData.currPlayIndex = seek;
    } else if (type === ListType.Next) {
      song = this.shareData.nextPlaylist.getData(seek);
      this.shareData.nextPlaylist.delData(seek);
    } else if (type === ListType.History) {
      song = this.shareData.history.getData(seek);
    }
    if (this.shareData.progress > 100000) {
      this.shareData.history.pushData(this.shareData.currAudioData())
    }
    this._initAudioResource(song);
  }

  protected _initAudioResource(song: Song) {
    this.shareData.currAudio = song;
    this.shareData.progress = 0;
    this.shareData.songDuration = song.dt;
    this.shareData.isPlaying = false;
    this.shareData.currAudioId = song.id;

    if (this.avPlayer) {
      this.avPlayer.reset().then(() => {
        fetchSongUrl([song.id], 'standard').then((result) => {
          if (result.length === 1) this.avPlayer.url = result[0].url;
        }).catch((err) => {
          console.log(`ERROR ${err}`);
        });
      });
    }
  }

  /**
   *
   * @param ms
   */
  public seek(ms: number) {
    if (this.isPrepare && this.avPlayerState != AvPlayerState.ERROR) {
      const finalTime = ms <= 0 ? 0 : (ms >= this.avPlayer.duration ? this.avPlayer.duration : ms);
      if (this.avPlayer) this.avPlayer.seek(finalTime);
    }
  }

  // prepared/paused/complete
  public async play() {
    if (this.avPlayer) {
      if (this.avPlayerState === AvPlayerState.IDLE) {
        this.start(this.shareData.currPlayIndex);
      } else {
        this.avPlayer.play().then(() => {
          this.shareData.isPlaying = true;
        });
      }
    }
  }

  public pause() {
    if (this.avPlayer && this.avPlayerState === AvPlayerState.PLAYING) {
      this.avPlayer.pause().then(() => {
        this.shareData.isPlaying = false;
      })
    }
  }

  private handleAudioCompleted() {
    switch (this.shareData.playMode) {
      case AvPlayMode.ORDER:
        if (this.shareData.currPlayIndex < this.shareData.playlist.totalCount() - 1) {
          this.start(this.shareData.currPlayIndex + 1);
        } else this.avPlayer.stop();
        break;
      case AvPlayMode.RANDOM:
        break;
      case AvPlayMode.SINGLE_CYCLE:
        this.avPlayer.play();
        break;
      case AvPlayMode.LIST_CYCLE:
        this.playNext();
        break;
    }
  }

  private setAVPlayerCallback() {
    if (!this.avPlayer) return;

    this.avPlayer.on('seekDone', (seekDoneTime) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });

    this.avPlayer.on('error', (err) => {
      this.avPlayer.reset();
      this.avPlayerState = AvPlayerState.ERROR;
      console.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    });

    this.avPlayer.on('timeUpdate', (value) => {
      this.shareData.progress = value;
    });

    this.avPlayer.on('stateChange', async (state, reason) => {
      switch (state) {
        case 'idle':
          this.avPlayerState = AvPlayerState.IDLE;
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          this.avPlayer.prepare().then(() => {
            console.info('AVPlayer prepare succeeded.');
            this.isPrepare = true;
            this.shareData.validDuration = this.avPlayer.duration;
          }, (err) => {
            console.log(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          this.avPlayerState = AvPlayerState.INITIALIZED;
          break;
        case 'prepared':
          if (this.avPlayer) this.play();
          this.avPlayerState = AvPlayerState.PREPARED;
          console.info('AVPlayer state prepared called.');
          break;
        case 'playing':
          this.avPlayerState = AvPlayerState.PLAYING;
          break;
        case 'paused':
          this.avPlayerState = AvPlayerState.PAUSED;
          break;
        case 'completed':
          this.avPlayerState = AvPlayerState.COMPLETED;
          this.handleAudioCompleted();
          break;
        case 'stopped':
          this.avPlayerState = AvPlayerState.STOPPED;
          this.avPlayer.reset();
          break;
        case 'released':
          this.avPlayerState = AvPlayerState.RELEASED;
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    })
  }

  protected _getPreferences(callback: (prefs: preferences.Preferences) => void) {
    const context: Context = AppStorage.Get('CONTEXT');
    preferences.getPreferences(context, 'AUDIO_SERVICE', (err, _prefs: preferences.Preferences) => {
      if (!err) callback(_prefs);
      else {
        console.log(`Preferences Error code: ${err.code}, message: ${err.message}`);
      }
    });
  }

  public loadCache() {
    this._getPreferences((_prefs: preferences.Preferences) => {
      _prefs.getAll((err, value: Object) => {
        let audioIds: number[] = value['PLAYLIST'];
        if (Array.isArray(audioIds)) {
          fetchSongs(audioIds).then((res) => {
            this.shareData.playlist.pushDataFromArray(res.songs);
            this.shareData.fromJson(value);
          });
        }
      });
    });
  }

  public saveCache() {
    this._getPreferences(async (prefs: preferences.Preferences) => {
      const value = this.shareData.toMap();
      Object.keys(value).forEach(async (key: string) => {
        if (key === 'PLAYLIST') {
          let _playlist: number[] = (value[key] as Song[]).map((item) => item.id);
          await prefs.put(key, _playlist);
        } else {
          await prefs.put(key, value[key]);
        }
      });
      await prefs.flush();
    });
  }
}