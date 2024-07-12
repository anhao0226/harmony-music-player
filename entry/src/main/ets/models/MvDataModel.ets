/**
 *
 */
export interface FetchMvResponse {
  data: MvModel[]
  more: boolean
  code: number
  message?: string
}

export interface MvModel {
  id: number
  cover: string
  name: string
  playCount: number
  briefDesc: any
  desc: any
  artistName: string
  artistId: number
  duration: number
  mark: number
  subed: boolean
  artists: Artist[]
}

export interface Artist {
  id: number
  name: string
}
