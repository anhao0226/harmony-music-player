export interface SearchResponse {
  result: SearchResult
  code: number
}

export interface SearchResult {
  song: SearchSongResult
  voice: Voice
  new_mlog: NewMlog
  code: number
  playList: PlayList
  artist: Artist5
  album: Album2
  sim_query: SimQuery
  rec_type: any
  rec_query: any[]
  voicelist: Voicelist
  user: User
  order: string[]
}

export interface SearchSongResult {
  moreText: string
  songs: Song[]
  more: boolean
  ksongInfos: KsongInfos
  resourceIds: number[]
}

export interface Song {
  name: string
  id: number
  pst: number
  t: number
  ar: Ar[]
  alia: string[]
  pop: number
  st: number
  rt?: string
  fee: number
  v: number
  crbt: any
  cf: string
  al: Al
  dt: number
  h: H
  m: M
  l: L
  sq?: Sq
  hr?: Hr
  a: any
  cd: string
  no: number
  rtUrl: any
  ftype: number
  rtUrls: any[]
  djId: number
  copyright: number
  s_id: number
  mark: number
  originCoverType: number
  originSongSimpleData?: OriginSongSimpleData
  tagPicList: any
  resourceState: boolean
  version: number
  songJumpInfo: any
  entertainmentTags: any
  single: number
  noCopyrightRcmd: any
  mst: number
  cp: number
  mv: number
  rtype: number
  rurl: any
  publishTime: number
  showRecommend: boolean
  recommendText: string
  officialTags: string[]
  privilege: Privilege
  alg: string
  specialTags: any[]
  tns?: string[]
}

export interface Ar {
  id: number
  name: string
  tns: string[]
  alias: string[]
  alia?: string[]
}

export interface Al {
  id: number
  name: string
  picUrl: string
  tns: string[]
  pic_str: string
  pic: number
}

export interface H {
  br: number
  fid: number
  size: number
  vd: number
  sr: number
}

export interface M {
  br: number
  fid: number
  size: number
  vd: number
  sr: number
}

export interface L {
  br: number
  fid: number
  size: number
  vd: number
  sr: number
}

export interface Sq {
  br: number
  fid: number
  size: number
  vd: number
  sr: number
}

export interface Hr {
  br: number
  fid: number
  size: number
  vd: number
  sr: number
}

export interface OriginSongSimpleData {
  songId: number
  name: string
  artists: Artist[]
  albumMeta: AlbumMeta
}

export interface Artist {
  id: number
  name: string
}

export interface AlbumMeta {
  id: number
  name: string
}

export interface Privilege {
  id: number
  fee: number
  payed: number
  st: number
  pl: number
  dl: number
  sp: number
  cp: number
  subp: number
  cs: boolean
  maxbr: number
  fl: number
  toast: boolean
  flag: number
  preSell: boolean
  playMaxbr: number
  downloadMaxbr: number
  maxBrLevel: string
  playMaxBrLevel: string
  downloadMaxBrLevel: string
  plLevel: string
  dlLevel: string
  flLevel: string
  rscl: any
  freeTrialPrivilege: FreeTrialPrivilege
  rightSource: number
  chargeInfoList: ChargeInfoList[]
}

export interface FreeTrialPrivilege {
  resConsumable: boolean
  userConsumable: boolean
  listenType: any
  cannotListenReason: any
}

export interface ChargeInfoList {
  rate: number
  chargeUrl: any
  chargeMessage: any
  chargeType: number
}

export interface KsongInfos {
  "1357375695": N1357375695
}

export interface N1357375695 {
  androidDownloadUrl: string
  accompanyId: string
  deeplinkUrl: string
}

export interface Voice {}

export interface NewMlog {
  more: boolean
  resources: any[]
}

export interface PlayList {
  moreText: string
  more: boolean
  playLists: PlayList2[]
  resourceIds: number[]
}

export interface PlayList2 {
  id: number
  name: string
  coverImgUrl: string
  creator: Creator
  subscribed: boolean
  trackCount: number
  userId: number
  playCount: number
  bookCount: number
  specialType: number
  officialTags: string[]
  action: any
  actionType: any
  recommendText: any
  score: any
  description: string
  highQuality: boolean
  track: Track
  alg: string
}

export interface Creator {
  nickname: string
  userId: number
  userType: number
  avatarUrl: string
  authStatus: number
  expertTags: any
  experts: any
}

export interface Track {
  name: string
  id: number
  position: number
  alias: any[]
  status: number
  fee: number
  copyrightId: number
  disc: string
  no: number
  artists: Artist2[]
  album: Album
  starred: boolean
  popularity: number
  score: number
  starredNum: number
  duration: number
  playedNum: number
  dayPlays: number
  hearTime: number
  ringtone: string
  crbt: any
  audition: any
  copyFrom: string
  commentThreadId: string
  rtUrl: any
  ftype: number
  rtUrls: any[]
  copyright: number
  hMusic: HMusic
  mMusic: MMusic
  lMusic: LMusic
  bMusic: BMusic
  mp3Url: any
  rtype: number
  rurl: any
  mvid: number
}

export interface Artist2 {
  name: string
  id: number
  picId: number
  img1v1Id: number
  briefDesc: string
  picUrl: string
  img1v1Url: string
  albumSize: number
  alias: any[]
  trans: string
  musicSize: number
  topicPerson: number
}

export interface Album {
  name: string
  id: number
  idStr: any
  type: string
  size: number
  picId: number
  blurPicUrl: string
  companyId: number
  pic: number
  picUrl: string
  publishTime: number
  description: string
  tags: string
  company?: string
  briefDesc: string
  artist: Artist3
  songs: any[]
  alias: string[]
  status: number
  copyrightId: number
  commentThreadId: string
  artists: Artist4[]
  onSale: boolean
  picId_str?: string
}

export interface Artist3 {
  name: string
  id: number
  picId: number
  img1v1Id: number
  briefDesc: string
  picUrl: string
  img1v1Url: string
  albumSize: number
  alias: any[]
  trans: string
  musicSize: number
  topicPerson: number
}

export interface Artist4 {
  name: string
  id: number
  picId: number
  img1v1Id: number
  briefDesc: string
  picUrl: string
  img1v1Url: string
  albumSize: number
  alias: any[]
  trans: string
  musicSize: number
  topicPerson: number
}

export interface HMusic {
  name: any
  id: number
  size: number
  extension: string
  sr: number
  dfsId: number
  bitrate: number
  playTime: number
  volumeDelta: number
}

export interface MMusic {
  name: any
  id: number
  size: number
  extension: string
  sr: number
  dfsId: number
  bitrate: number
  playTime: number
  volumeDelta: number
}

export interface LMusic {
  name: any
  id: number
  size: number
  extension: string
  sr: number
  dfsId: number
  bitrate: number
  playTime: number
  volumeDelta: number
}

export interface BMusic {
  name: any
  id: number
  size: number
  extension: string
  sr: number
  dfsId: number
  bitrate: number
  playTime: number
  volumeDelta: number
}

export interface Artist5 {
  moreText: string
  artists: Artist6[]
  more: boolean
  resourceIds: number[]
}

export interface Artist6 {
  id: number
  name: string
  picUrl: string
  alias: string[]
  albumSize: number
  picId: number
  fansGroup: any
  img1v1Url: string
  img1v1: number
  transNames?: string[]
  mvSize: number
  followed: boolean
  alg: string
  trans?: string
  accountId?: number
  identityIconUrl?: string
  alia?: string[]
}

export interface Album2 {
  moreText: string
  albums: Album3[]
  more: boolean
  resourceIds: number[]
}

export interface Album3 {
  name: string
  id: number
  type: string
  size: number
  picId: number
  blurPicUrl: string
  companyId: number
  pic: number
  picUrl: string
  publishTime: number
  description: string
  tags: string
  company: string
  briefDesc: string
  artist: Artist7
  songs: any
  alias: string[]
  status: number
  copyrightId: number
  commentThreadId: string
  artists: Artist8[]
  paid: boolean
  onSale: boolean
  picId_str: string
  alg: string
}

export interface Artist7 {
  name: string
  id: number
  picId: number
  img1v1Id: number
  briefDesc: string
  picUrl: string
  img1v1Url: string
  albumSize: number
  alias: string[]
  trans: string
  musicSize: number
  topicPerson: number
  picId_str?: string
  transNames?: string[]
  img1v1Id_str?: string
  alia: string[]
}

export interface Artist8 {
  name: string
  id: number
  picId: number
  img1v1Id: number
  briefDesc: string
  picUrl: string
  img1v1Url: string
  albumSize: number
  alias: any[]
  trans: string
  musicSize: number
  topicPerson: number
  img1v1Id_str?: string
}

export interface SimQuery {
  sim_querys: SimQuery2[]
  more: boolean
}

export interface SimQuery2 {
  keyword: string
  alg: string
}

export interface Voicelist {}

export interface User {
  moreText: string
  more: boolean
  users: User2[]
  resourceIds: number[]
}

export interface User2 {
  defaultAvatar: boolean
  province: number
  authStatus: number
  followed: boolean
  avatarUrl: string
  accountStatus: number
  gender: number
  city: number
  birthday: number
  userId: number
  userType: number
  nickname: string
  signature: string
  description: string
  detailDescription: string
  avatarImgId: number
  backgroundImgId: number
  backgroundUrl: string
  authority: number
  mutual: boolean
  expertTags: any
  experts: any
  djStatus: number
  vipType: number
  remarkName: any
  authenticationTypes: number
  avatarDetail: AvatarDetail
  avatarImgIdStr: string
  backgroundImgIdStr: string
  anchor: boolean
  avatarImgId_str: string
  alg: string
}

export interface AvatarDetail {
  userType: number
  identityLevel: number
  identityIconUrl: string
}
