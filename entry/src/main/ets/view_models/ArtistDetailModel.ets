import { httpRequestGet } from '../common/utils/HttpClient';
import { AlbumModel, ArtistModel, SongModel } from './playlist_song_model';

/**
 * ArtistDetailModel
 */
export class ArtistDetailModel {
  id: number;
  name: string;
  picUrl: string;
  musicSize: number;
  albumSize: number;
  briefDesc: string;

  formJson(json: any): ArtistDetailModel {
    this.id = json['id'];
    this.name = json['name'];
    this.picUrl = json['picUrl'];
    this.musicSize = json['musicSize'];
    this.albumSize = json['albumSize'];
    this.briefDesc = json['briefDesc'];
    return this;
  }
}

/**
 * HotAlbumModel
 */
export class ArtistAlbumModel {
  id: number;
  name: string;
  picUrl: string;
  publishTime: number;
  blurPicUrl: string;
  type: string;
  size: number;
  description: string;

  formJson(json: any): ArtistAlbumModel {
    this.id = json['id'];
    this.name = json['name'];
    this.picUrl = json['picUrl'];
    this.publishTime = json['publishTime'];
    this.blurPicUrl = json['blurPicUrl'];
    this.type = json['type'];
    this.size = json['size'];
    this.description = json['description'];
    return this;
  }
}

/**
 * ArtistMvModel
 */
export class ArtistMvModel {
  id: number;
  name: string;
  imgurl: string;
  duration: number;
  publishTime: number;
  imgurl16v9: string;

  formJson(json: any): ArtistMvModel {
    this.id = json['id'];
    this.name = json['name'];
    this.imgurl = json['imgurl'];
    this.duration = json['duration'];
    this.publishTime = json['duration'];
    this.imgurl16v9 = json['imgurl16v9'];
    return this;
  }
}

export interface ArtistDetailData {
  artist: ArtistDetailModel;
  hotSongs: SongModel[]
}

/**
 *
 * @param artistId
 * @returns
 */
export function fetchArtistData(artistId: number): Promise<ArtistDetailData> {
  let queryParams = { 'id': artistId };
  return new Promise(async (resolve, reject) => {
    try {
      const result = await httpRequestGet('/artists', { queryParams });
      if (result['code'] === 200) {
        let artist = new ArtistDetailModel().formJson(result['artist']);
        let hotSongs: SongModel[] = [];
        const hotSongsJson = result['hotSongs'];
        if (hotSongsJson && Array.isArray(hotSongsJson)) {
          hotSongsJson.forEach((item) => {
            hotSongs.push(new SongModel().formJson(item));
          })
        }
        resolve({ artist, hotSongs });
      } else {
        reject(new Error(`State code error ${result['code']}`));
      }
    } catch (err) {
      reject(err);
    }
  })
}

/**
 *
 * @param artistId
 * @returns
 */
export function fetchArtistAlbums(artistId: number): Promise<ArtistAlbumModel[]> {
  let queryParams = { 'id': artistId };
  return new Promise(async (resolve, reject) => {
    try {
      const result = await httpRequestGet('/artist/album', { queryParams });
      if (result['code'] === 200) {
        let hotAlbums: ArtistAlbumModel[] = [];
        const hotAlbumsJson = result['hotAlbums'];
        if (hotAlbumsJson && Array.isArray(hotAlbumsJson)) {
          hotAlbumsJson.forEach((item) => {
            hotAlbums.push(new ArtistAlbumModel().formJson(item));
          })
        }
        resolve(hotAlbums);
      } else {
        reject(new Error(`State code error ${result['code']}`));
      }
    } catch (err) {
      reject(err);
    }
  })
}

/**
 *
 * @param artistId
 * @returns
 */
export function fetchArtistMv(artistId: number): Promise<ArtistMvModel[]> {
  let queryParams = { 'id': artistId };
  return new Promise(async (resolve, reject) => {
    try {
      const result = await httpRequestGet('/artist/mv', { queryParams });
      if (result['code'] === 200) {
        let mvs: ArtistMvModel[] = [];
        const mvsJson = result['mvs'];
        if (mvsJson && Array.isArray(mvsJson)) {
          mvsJson.forEach((item) => {
            mvs.push(new ArtistMvModel().formJson(item));
          })
        }
        resolve(mvs);
      } else {
        reject(new Error(`State code error ${result['code']}`));
      }
    } catch (err) {
      reject(err);
    }
  })
}


export function fetchAlbumDetail(albumId: number): Promise<{
  songs: SongModel[],
  album: ArtistAlbumModel
}> {
  let queryParams = { 'id': albumId };
  return new Promise(async (resolve, reject) => {
    try {
      const result = await httpRequestGet('/album', { queryParams });
      if (result['code'] === 200) {
        // album
        let album = new ArtistAlbumModel().formJson(result['album']);
        // songs
        let songs: SongModel[] = [];
        const songsJson = result['songs'];
        if (songsJson && Array.isArray(songsJson)) {
          songsJson.forEach((item) => songs.push(new SongModel().formJson(item)));
        }
        resolve({ songs, album });
      } else {
        reject(new Error(`State code error ${result['code']}`));
      }
    } catch (err) {
      reject(err);
    }
  })
}