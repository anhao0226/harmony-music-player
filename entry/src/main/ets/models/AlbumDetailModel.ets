import { Song } from './SongModel';

export interface AlbumDetailResponse {
  resourceState: boolean
  songs: Song[]
  code: number
  album: Album
  message: string
}

export interface Album {
  songs: any[]
  paid: boolean
  onSale: boolean
  mark: number
  awardTags: any
  publishTime: number
  company: string
  briefDesc: string
  picUrl: string
  artists: Artist[]
  copyrightId: number
  picId: number
  artist: Artist
  commentThreadId: string
  blurPicUrl: string
  companyId: number
  pic: number
  status: number
  subType: string
  alias: any[]
  description: string
  tags: string
  name: string
  id: number
  type: string
  size: number
  picId_str: string
  info: Info
}

export interface Artist {
  img1v1Id: number
  topicPerson: number
  briefDesc: string
  musicSize: number
  albumSize: number
  picUrl: string
  picId: number
  img1v1Url: string
  followed: boolean
  trans: string
  alias: string[]
  name: string
  id: number
  picId_str: string
  img1v1Id_str: string
}

export interface Info {
  commentThread: CommentThread
  latestLikedUsers: any
  liked: boolean
  comments: any
  resourceType: number
  resourceId: number
  commentCount: number
  likedCount: number
  shareCount: number
  threadId: string
}

export interface CommentThread {
  id: string
  resourceInfo: ResourceInfo
  resourceType: number
  commentCount: number
  likedCount: number
  shareCount: number
  hotCount: number
  latestLikedUsers: any
  resourceId: number
  resourceOwnerId: number
  resourceTitle: string
}

export interface ResourceInfo {
  id: number
  userId: number
  name: string
  imgUrl: string
  creator: any
  encodedId: any
  subTitle: any
  webUrl: any
}
