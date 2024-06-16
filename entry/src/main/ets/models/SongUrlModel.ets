/**
 *
 */
export interface SongUrlResponse {
  data: SongUrl[]
  code: number
  message: string
}

export interface SongUrl {
  id: number
  url: string
  br: number
  size: number
  md5: string
  code: number
  expi: number
  type: string
  gain: number
  peak: number
  fee: number
  uf: any
  payed: number
  flag: number
  canExtend: boolean
  freeTrialInfo: any
  level: string
  encodeType: string
  channelLayout: any
  freeTrialPrivilege: FreeTrialPrivilege
  freeTimeTrialPrivilege: FreeTimeTrialPrivilege
  urlSource: number
  rightSource: number
  podcastCtrp: any
  effectTypes: any
  time: number
  message: any
  levelConfuse: any
}

export interface FreeTrialPrivilege {
  resConsumable: boolean
  userConsumable: boolean
  listenType: any
  cannotListenReason: any
  playReason: any
}

export interface FreeTimeTrialPrivilege {
  resConsumable: boolean
  userConsumable: boolean
  type: number
  remainTime: number
}
