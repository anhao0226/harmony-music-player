export interface Comment {
  user: User
  beReplied: any[]
  pendantData: PendantData
  showFloorComment: any
  status: number
  commentId: number
  content: string
  richContent: any
  contentResource: any
  time: number
  timeStr: string
  needDisplayTime: boolean
  likedCount: number
  expressionUrl: any
  commentLocationType: number
  parentCommentId: number
  decoration: Decoration
  repliedMark: any
  grade: any
  userBizLevels: any
  ipLocation: IpLocation
  owner: boolean
  medal: any
  liked: boolean
}

export interface User {
  locationInfo: any
  liveInfo: any
  anonym: number
  avatarDetail: any
  userType: number
  avatarUrl: string
  followed: boolean
  mutual: boolean
  remarkName: any
  socialUserId: any
  vipRights: VipRights
  nickname: string
  authStatus: number
  expertTags: any
  experts: any
  vipType: number
  commonIdentity: any
  userId: number
  target: any
}

export interface VipRights {
  associator: Associator
  musicPackage: MusicPackage
  redplus: Redplus
  redVipAnnualCount: number
  redVipLevel: number
  relationType: number
}

export interface Associator {
  vipCode: number
  rights: boolean
  iconUrl: string
}

export interface MusicPackage {
  vipCode: number
  rights: boolean
  iconUrl: string
}

export interface Redplus {
  vipCode: number
  rights: boolean
  iconUrl: string
}

export interface PendantData {
  id: number
  imageUrl: string
}

export interface Decoration {}

export interface IpLocation {
  ip: any
  location: string
  userId: any
}
