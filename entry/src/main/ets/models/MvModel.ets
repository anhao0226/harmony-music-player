/**
 *
 */
export interface MvDetailResponse {
  loadingPic: string
  bufferPic: string
  loadingPicFS: string
  bufferPicFS: string
  subed: boolean
  mp: Mp
  data: MvDetail
  code: number
  message: number
}

export interface Mp {
  id: number
  fee: number
  mvFee: number
  payed: number
  pl: number
  dl: number
  cp: number
  sid: number
  st: number
  normal: boolean
  unauthorized: boolean
  msg: any
}

export interface MvDetail {
  id: number
  name: string
  artistId: number
  artistName: string
  briefDesc: string
  desc: any
  cover: string
  coverId_str: string
  coverId: number
  playCount: number
  subCount: number
  shareCount: number
  commentCount: number
  duration: number
  nType: number
  publishTime: string
  price: any
  brs: Br[]
  artists: Artist[]
  commentThreadId: string
  videoGroup: VideoGroup[]
}

export interface Br {
  size: number
  br: number
  point: number
}

export interface Artist {
  id: number
  name: string
  img1v1Url: any
  followed: boolean
}

export interface VideoGroup {
  id: number
  name: string
  type: number
}


/**
 * MvUrlResponse
 */
export interface MvUrlResponse {
  code: number
  data: MvUrl
  message: string
}

export interface MvUrl {
  id: number
  url: string
  r: number
  size: number
  md5: string
  code: number
  expi: number
  fee: number
  mvFee: number
  st: number
  promotionVo: any
  msg: string
}