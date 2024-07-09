import { DataSource } from '../../models/DataSource';
import { AvPlayMode, PlayModeArray } from './AudioConfig';

export enum ListType { Play, Next, History }

export class AudioShareData<T> {
  //
  public playlist: DataSource<T> = new DataSource<T>();
  //
  public nextPlaylist: DataSource<T> = new DataSource<T>(true);
  //
  public history: DataSource<T> = new DataSource<T>();

  //
  protected _currAudio: T = null;

  set currAudio(value: T) {
    this._currAudio = value;
  }

  //
  protected _currAudioId: number = 0;

  get currAudioId() {
    return this._currAudioId;
  }

  set currAudioId(value: number) {
    AppStorage.SetOrCreate('CURRENT_AUDIO_ID', value);
    this._currAudioId = value;
  }

  // 播放进度
  protected _progress: number = 0;

  get progress(): number {
    return this._progress;
  }

  set progress(value: number) {
    AppStorage.SetOrCreate('PROGRESS', value);
    this._progress = value;
  }

  // 歌曲时长
  private _songDuration: number = 0;

  get songDuration(): number {
    return this._songDuration;
  }

  set songDuration(value: number) {
    AppStorage.SetOrCreate('SONG_DURATION', value);
    this._songDuration = value;
  }

  // 播放的下标
  private _currPlayIndex: number = 0;

  get currPlayIndex(): number {
    return this._currPlayIndex;
  }

  set currPlayIndex(value: number) {
    this._currPlayIndex = value;
  }

  nextPlayIndex(): number {
    const totalCount: number = this.playlist.totalCount();
    return this.currPlayIndex + 1 < totalCount ? this.currPlayIndex + 1 : 0;
  }

  prevPlayIndex(): number {
    const totalCount: number = this.playlist.totalCount();
    return this.currPlayIndex - 1 > 0 ? this.currPlayIndex - 1 : totalCount - 1;
  }

  currAudioData(): T {
    return this._currAudio;
  }

  // 播放状态
  private _isPlaying: boolean = false;

  get isPlaying(): boolean {
    return this._isPlaying;
  }

  set isPlaying(value: boolean) {
    AppStorage.SetOrCreate('IS_PLAYING', value);
    this._isPlaying = value;
  }

  // 播放模式
  protected _playMode: AvPlayMode = AvPlayMode.ORDER;

  get playMode(): AvPlayMode {
    return this._playMode;
  }

  set playMode(value: AvPlayMode) {
    AppStorage.SetOrCreate('PLAY_MODE', value);
    this._playMode = value;
  }

  // 音频有效时间
  private _validDuration: number = 0;

  get validDuration(): number {
    return this._validDuration;
  }

  set validDuration(value: number) {
    AppStorage.SetOrCreate('VALID_DURATION', value);
    this._validDuration = value;
  }

  // key-value
  toMap(): Record<string, any> {
    const result: Record<string, any> = {};
    result['CURRENT_AUDIO_ID'] = this.currAudioId;
    result['PLAY_INDEX'] = this.currPlayIndex;
    result['PLAYLIST'] = this.playlist;
    result['AUDIO_PROGRESS'] = this.progress;
    result['PLAY_MODE'] = this.playMode;
    return result;
  }

  fromJson(json: Object) {
    this.currAudioId = json['CURRENT_AUDIO_ID'];
    if (json['PLAY_MODE'] < PlayModeArray.length) {
      this.playMode = PlayModeArray[json['PLAY_MODE']];
    }
    this.progress = json['AUDIO_PROGRESS'];
    this.currPlayIndex = json['PLAY_INDEX'];
    console.log(JSON.stringify(json));
  }
}
