/**
 *  Comments
 */
export interface CommentResponse {
  code: number
  data: CommentData
  message: string
}

export interface CommentData {
  commentsTitle: string
  comments: Comment[]
  currentCommentTitle: string
  currentComment: any
  totalCount: number
  hasMore: boolean
  cursor: string
  sortType: number
  sortTypeList: SortTypeList[]
  style: string
  bottomAction: any
  likeAnimation: LikeAnimation
  newReplyExpGroupName: string
  expandCount: number
}

export interface Comment {
  user: User
  beReplied: any
  commentId: number
  threadId: string
  content: string
  richContent?: string
  status: number
  time: number
  timeStr: string
  needDisplayTime: boolean
  likedCount: number
  replyCount: number
  liked: boolean
  expressionUrl: any
  parentCommentId: number
  repliedMark: boolean
  pendantData?: PendantData
  pickInfo: any
  showFloorComment: ShowFloorComment
  decoration: Decoration
  commentLocationType: number
  musicianSayAirborne: any
  args: any
  tag: Tag
  source: any
  resourceSpecialType: any
  extInfo: ExtInfo
  commentVideoVO: CommentVideoVo
  contentResource: any
  contentPicNosKey: any
  contentPicUrl: any
  grade: any
  userBizLevels: any
  userNameplates: any
  ipLocation: IpLocation
  owner: boolean
  tail: any
  hideSerialComments: any
  hideSerialTips: any
  topicList?: TopicList[]
  privacy: number
  medal: any
  outShowComments: any
  likeAnimationMap: LikeAnimationMap
  bottomTags: any[]
  track: string
}

export interface User {
  avatarDetail: any
  commonIdentity: any
  locationInfo: any
  liveInfo: any
  followed: boolean
  vipRights?: VipRights
  relationTag: any
  anonym: number
  encryptUserId: string
  userId: number
  userType: number
  nickname: string
  avatarUrl: string
  authStatus: number
  expertTags: any
  experts: any
  vipType: number
  remarkName: any
  isHug: boolean
  socialUserId: any
  target: any
}

export interface VipRights {
  associator?: Associator
  musicPackage?: MusicPackage
  redplus?: Redplus
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

export interface ShowFloorComment {
  replyCount: number
  comments: any
  showReplyCount: boolean
  topCommentIds: any
  target: any
}

export interface Decoration {
  repliedByAuthorCount: number
}

export interface Tag {
  datas: any[]
  extDatas: any[]
  contentDatas: any[]
  contentPicDatas: any[]
  relatedCommentIds: any
}

export interface ExtInfo {
  forwardEvent: number
  endpoint: Endpoint
  topicIds?: string
}

export interface Endpoint {
  CLIENT_TYPE: string
  CHANNEL: string
  OS_TYPE: string
  USER_AGENT: string
  CLIENT_VERSION: string
  IP: string
  CLIENT_VERSION_STR: string
  CLIENT_SIGN: string
  X_REMOTE_PORT: string
  DEVICE_ID: string
  OSVER: string
  CLIENT_BUILD_VERSION?: string
}

export interface CommentVideoVo {
  showCreationEntrance: boolean
  allowCreation: boolean
  creationOrpheusUrl: any
  playOrpheusUrl: any
  videoCount: number
  forbidCreationText: string
}

export interface IpLocation {
  ip: any
  location: string
  userId: number
}

export interface TopicList {
  id: string
  name: string
  icon: any
  desc: string
  target: string
  eventCount: number
  pubGuide: boolean
  pubGuideIcon: any
  pubGuideText: any
  pubGuideActionText: any
}

export interface LikeAnimationMap {
  COMMENT_AREA: CommentArea
  INPUT: Input
}

export interface CommentArea {
  activityCode: string
  startTime: number
  endTime: number
  beforeLikeIcon: string
  likeAnimations: string[]
  afterLikeIcon: string
  likeText: string
  sizeType: string
  vibrationParams: any
}

export interface Input {
  activityCode: string
  startTime: number
  endTime: number
  beforeLikeIcon: string
  likeAnimations: string[]
  afterLikeIcon: string
  likeText: string
  sizeType: string
  vibrationParams: any
}

export interface SortTypeList {
  sortType: number
  sortTypeName: string
  target: string
}

export interface LikeAnimation {
  animationConfigMap: AnimationConfigMap
  version: number
}

export interface AnimationConfigMap {
  EVENT_FEED: any[]
  MOMENT: any[]
  INPUT: any[]
  COMMENT_AREA: any[]
}
