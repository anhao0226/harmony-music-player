import { Song } from './SongModel';
/**
 *
 */
export interface ArtistSongsResponse {
  songs: Song[]
  more: boolean
  total: number
  code: number
  message: string
}
