export interface ArtistInter {
  id: number
  name: string
  picUrl: string
  alias: any[]
  albumSize: number
  picId: number
  fansGroup: any
  img1v1Url: string
  img1v1: number
  transNames: string[]
  trans: string
}

export interface AlbumInter {
  id: number
  name: string
  artist: ArtistInter
  publishTime: number
  size: number
  copyrightId: number
  status: number
  picId: number
  mark: number
}

export interface SongInter {
  id: number
  name: string
  artists: ArtistInter[]
  album: AlbumInter
  duration: number
  copyrightId: number
  status: number
  alias: any[]
  rtype: number
  ftype: number
  mvid: number
  fee: number
  rUrl: any
  mark: number
}

export interface SearchResponse {
  albums: AlbumInter[];
  artists: ArtistInter[];
  songs: SongInter[];
  order: string[];
}