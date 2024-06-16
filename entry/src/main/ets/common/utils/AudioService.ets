import media from '@ohos.multimedia.media';
import preferences from '@ohos.data.preferences';
import { SongModel, getSongUrl } from '../../view_models/playlist_song_model';
import { AvPlayerState, AvPlayMode } from './AudioConfig';
import { AudioShareData } from './AudioShareData';
import { Song } from '../../models/SongModel';
import { fetchSongs, fetchSongUrl } from '../../api/SongApi';

export class AudioService {
  private _isPrepare: boolean = false;
  private _avPlayer: media.AVPlayer | null = null;
  private _avPlayerState: AvPlayerState = AvPlayerState.IDLE;
  private _shareData: AudioShareData<Song> = new AudioShareData<Song>();

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

  public initAudioPlayer() {
    media.createAVPlayer().then((_avPlayer: media.AVPlayer) => {
      this._avPlayer = _avPlayer;
      this.setAVPlayerCallback();
    }).catch((err: Error) => {
      console.log(`CreateAVPlayerError : ${JSON.stringify(err)}`);
    });
  }

  /**
   *
   * @returns
   */
  public getAudioId() {
    return this._shareData.audioId;
  }

  /**
   *
   * @returns
   */
  public getPlayMode() {
    return this._shareData.playMode;
  };

  /**
   *
   * @param mode
   */
  public setPlayMode(mode: AvPlayMode) {
    this._shareData.playMode = mode;
  }

  /**
   *
   * @param data
   */
  public setPlaylist(data: Song[]) {
    this._shareData.playlist = data;
  }

  public playlist(): Song[] {
    return this._shareData.playlist;
  };

  public history(): Song[] {
    return this._shareData.history;
  }

  /**
   *
   */
  public playPrevious() {
    this.start(this._shareData.prevIndex());
  }

  /**
   *
   */
  public playIndex() {
    return this._shareData.playIndex;
  }

  /**
   *
   */
  public playNext() {
    let flag: { type: string } = null;
    let index = this._shareData.nextIndex();
    if (this._shareData.nextQueueCount()) {
      flag = { type: 'next' };
      index = 0
    }
    this.start(index, flag);
  }

  /**
   *
   * @param song
   */
  public addNextPlaySong(song: Song) {
    this._shareData.addNextPlaySong(song);
  }

  /**
   *
   * @returns
   */
  public nextPlaylist(): Song[] | null {
    return this._shareData.nextQueue;
  }


  /**
   *
   * @param seek
   */
  public start(seek?: number, flag?: Object) {
    //
    let listType: string = 'list';
    if (flag && flag.hasOwnProperty('type')) {
      listType = flag['type'];
    }
    //
    if (listType === 'list') {
      seek = seek || 0;
      let data = this._shareData.getAudioByIndex(seek);
      this._shareData.playIndex = seek;
      this._initAudioResource(data);
    } else if (listType === 'next') {
      const endIndex = this._shareData.nextQueueCount() - seek - 1;
      const data = this._shareData.nextQueue[endIndex];
      this._shareData.nextQueue = this._shareData.nextQueue.slice(0, endIndex);
      this._initAudioResource(data);
    } else if (listType === 'history') {

    }
  }

  /**
   *
   * @param song
   */
  protected _initAudioResource(song: Song) {
    this._shareData.progress = 0;
    this._shareData.songDuration = song.dt;
    this._shareData.isPlaying = false;
    this._shareData.audioId = song.id;
    if (this._avPlayer) {
      this._avPlayer.reset().then(() => {
        fetchSongUrl([song.id], 'standard').then((result) => {
          if (result.length === 1) this._avPlayer.url = result[0].url;
        }).catch((err) => {
          console.log(`ERROR ${err}`);
        });
      });
    }
  }

  /**
   *
   * @returns
   */
  public getCurrSong(): Song {
    return this._shareData.getCurrAudio();
  }

  /**
   *
   * @param ms
   */
  public seek(ms: number) {
    if (this._isPrepare && this._avPlayerState != AvPlayerState.ERROR) {
      const finalTime = ms <= 0 ? 0 : (ms >= this._avPlayer.duration ? this._avPlayer.duration : ms);
      if (this._avPlayer) this._avPlayer.seek(finalTime);
    }
  }

  // prepared/paused/complete
  public async play() {
    if (this._avPlayer) {
      if (this._avPlayerState === AvPlayerState.IDLE) {
        this.start(this._shareData.playIndex);
      } else {
        this._avPlayer.play().then(() => {
          this._shareData.isPlaying = true;
        });
      }
    }
  }

  public pause() {
    if (this._avPlayer && this._avPlayerState === AvPlayerState.PLAYING) {
      this._avPlayer.pause().then(() => {
        this._shareData.isPlaying = false;
      })
    }
  }

  private handleAudioCompleted() {
    switch (this._shareData.playMode) {
      case AvPlayMode.ORDER:
        if (this._shareData.playIndex < this._shareData.playlist.length - 1) {
          this.start(this._shareData.playIndex + 1);
        } else this._avPlayer.stop();
        break;
      case AvPlayMode.RANDOM:
        break;
      case AvPlayMode.SINGLE_CYCLE:
        this._avPlayer.play();
        break;
      case AvPlayMode.LIST_CYCLE:
        this.playNext();
        break;
    }
  }

  private setAVPlayerCallback() {
    if (!this._avPlayer) return;

    this._avPlayer.on('seekDone', (seekDoneTime) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });

    this._avPlayer.on('error', (err) => {
      this._avPlayer.reset();
      this._avPlayerState = AvPlayerState.ERROR;
      console.error(`Invoke _avPlayer failed, code is ${err.code}, message is ${err.message}`);
    });

    this._avPlayer.on('timeUpdate', (value) => {
      this._shareData.progress = value;
    });

    this._avPlayer.on('stateChange', async (state, reason) => {
      switch (state) {
        case 'idle':
          this._avPlayerState = AvPlayerState.IDLE;
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          this._avPlayer.prepare().then(() => {
            console.info('AVPlayer prepare succeeded.');
            this._isPrepare = true;
            this._shareData.validDuration = this._avPlayer.duration;
          }, (err) => {
            console.log(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          this._avPlayerState = AvPlayerState.INITIALIZED;
          break;
        case 'prepared':
          if (this._avPlayer) this.play();
          this._avPlayerState = AvPlayerState.PREPARED;
          console.info('AVPlayer state prepared called.');
          break;
        case 'playing':
          this._avPlayerState = AvPlayerState.PLAYING;
          break;
        case 'paused':
          this._avPlayerState = AvPlayerState.PAUSED;
          break;
        case 'completed':
          this._avPlayerState = AvPlayerState.COMPLETED;
          this.handleAudioCompleted();
          break;
        case 'stopped':
          this._avPlayerState = AvPlayerState.STOPPED;
          this._avPlayer.reset();
          break;
        case 'released':
          this._avPlayerState = AvPlayerState.RELEASED;
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
        this._shareData.fromJson(value);
        let audioIds: number[] = value['PLAYLIST'];
        if (Array.isArray(audioIds)) {
          fetchSongs(audioIds).then((res) => {
            this._shareData.playlist = res.songs;
          });
        }
      });
    });
  }

  public saveCache() {
    this._getPreferences(async (prefs: preferences.Preferences) => {
      const value = this._shareData.toMap();
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