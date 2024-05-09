export enum EventId {
  CHANGE_SONG = 0,
}

export enum SongPlayMode {
  ORDER,
  RANDOM,
  SINGLE_CYCLE,
  LIST_CYCLE
}

/*
  idle,
  initialized,
  'prepared',
  'playing',
  'paused',
  'completed',
  'stopped',
  'released',
  'error'
 */

export enum AvPlayState {
  IDLE,
  INITIALIZED,
  PREPARED,
  PLAYING,
  PAUSED,
  COMPLETED,
  STOPPED,
  RELEASED,
  ERROR,
  LOADING,
}