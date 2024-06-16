export interface ArtistMvResponse {
  mvs: Mv[]
  time: number
  hasMore: boolean
  code: number
  message: string
}

export interface Mv {
  id: number
  name: string
  status: number
  imgurl16v9: string
  artist: Artist
  imgurl: string
  artistName: string
  duration: number
  playCount: number
  publishTime: string
  subed: boolean
}

export interface Artist {
  img1v1Id: number
  topicPerson: number
  alias: any[]
  briefDesc: string
  picUrl: string
  img1v1Url: string
  albumSize: number
  trans: string
  musicSize: number
  picId: number
  name: string
  id: number
  img1v1Id_str: string
}