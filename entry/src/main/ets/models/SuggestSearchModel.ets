export interface SuggestSearchResponse {
  result: SuggestSearchResult
  code: number
  message?: string
}

export interface SuggestSearchResult {
  albums: Album[]
  artists: Artist[]
  songs: Song[]
  order: string[]
}

export interface Album {
  id: number
  name: string
  artist: Artist
  publishTime: number
  size: number
  copyrightId: number
  status: number
  picId: number
  mark: number
}

export interface Artist {
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
  trans?: string
  alia?: string[]
}

export interface Song {
  id: number
  name: string
  artists: Artist[]
  album: Album
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

