/**
 *
 */
export interface ArtistAlbumResponse {
  artist: Artist
  hotAlbums: HotAlbum[]
  more: boolean
  code: number
  message: string
}

export interface Artist {
  img1v1Id: number
  topicPerson: number
  picId: number
  briefDesc: string
  musicSize: number
  albumSize: number
  picUrl: string
  followed: boolean
  img1v1Url: string
  trans: string
  alias: string[]
  name: string
  id: number
  picId_str: string
  img1v1Id_str: string
}

export interface HotAlbum {
  songs: any[]
  paid: boolean
  onSale: boolean
  mark: number
  awardTags: any
  artists: Artist[]
  copyrightId: number
  picId: number
  artist: Artist
  publishTime: number
  company: string
  briefDesc: string
  picUrl: string
  commentThreadId: string
  blurPicUrl: string
  companyId: number
  pic: number
  status: number
  subType: string
  description: string
  tags: string
  alias: string[]
  name: string
  id: number
  type: string
  size: number
  picId_str: string
}
