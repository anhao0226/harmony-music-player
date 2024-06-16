import { AvPlayMode } from './AudioConfig';

interface ShareDataInterface {
  id: number;
}

export class AudioShareData<T extends ShareDataInterface> {
  // 当前播放音频id
  protected _audioId: number = 0;

  get audioId(): number {
    return this._audioId;
  }

  set audioId(value: number) {
    AppStorage.SetOrCreate('AUDIO_ID', value);
    this._audioId = value;
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
  private _playIndex: number = 0;

  get playIndex(): number {
    return this._playIndex;
  }

  set playIndex(value: number) {
    this._playIndex = value;
  }

  nextIndex(): number {
    const curr = this._playIndex + 1;
    return curr >= this._playlist.length ? 0 : curr;
  }

  prevIndex() {
    const curr = this._playIndex - 1;
    return curr > 0 ? curr : this._playlist.length - 1;
  }

  // 历史播放记录
  protected _history: T[];

  set history(value: T[]) {
    this._history = value;
  }

  get history(): T[] | null {
    return this._history
  }

  // 播放列表
  private _playlist: T[] = [];

  get playlist(): T[] {
    return this._playlist;
  }

  set playlist(value: T[]) {
    this._playlist = value;
  }

  getCurrAudio(): T | null {
    let length: number = this._playlist.length;
    if (length && this._playIndex < length) {
      return this._playlist[this._playIndex];
    }
    return null;
  }

  getAudioByIndex(index: number): T | null {
    if (index < this._playlist.length && index >= 0) {
      return this._playlist[index];
    }
    return null;
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
  private _playMode: AvPlayMode = AvPlayMode.ORDER;

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

  // 存储待播放的列表
  protected _nextQueue: T[] = null;

  get nextQueue(): T[] | null {
    return this._nextQueue;
  }

  set nextQueue(value: T[]) {
    this._nextQueue = value;
  }

  nextQueueCount(): number {
    return this._nextQueue ? this._nextQueue.length : 0;
  }

  addNextPlaySong(value: T) {
    if (!this._nextQueue) this._nextQueue = [];
    this._nextQueue.push(value);
  }

  // key-value
  toMap(): Record<string, any> {
    const result: Record<string, any> = {};
    result['AUDIO_ID'] = this._audioId;
    result['PLAY_INDEX'] = this._playIndex;
    result['PLAYLIST'] = this._playlist;
    result['AUDIO_PROGRESS'] = this._progress;
    result['PLAY_MODE'] = this._playMode;
    return result;
  }

  fromJson(json: Object) {
    this.audioId = json['AUDIO_ID'];
    this.playMode = json['PLAY_MODE'];
    this.progress = json['AUDIO_PROGRESS'];
    this._playIndex = json['PLAY_INDEX'];
  }
}
