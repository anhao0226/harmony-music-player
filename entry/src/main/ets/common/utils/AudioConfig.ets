/**
 *
 */
export enum EventId {
  CHANGE_SONG = 0,
}

export enum AvPlayerState {
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

export enum AvPlayMode {
  ORDER,
  RANDOM,
  SINGLE_CYCLE,
  LIST_CYCLE
}

export const PlayModeArray = [AvPlayMode.ORDER, AvPlayMode.RANDOM, AvPlayMode.SINGLE_CYCLE, AvPlayMode.LIST_CYCLE];
