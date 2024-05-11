import { httpRequestGet } from '../common/utils/HttpClient';

export class AlbumModel {
  id: number;
  name: string;
  picUrl: string;

  constructor(id: number, name: string, picUrl: string) {
    this.name = name;
    this.id = id;
    this.picUrl = picUrl;
  }
}

export class ArtistModel {
  id: number;
  name: string;

  constructor(id: number, name: string) {
    this.name = name;
    this.id = id;
  }
}

export class SongModel {
  id: number;
  name: string;
  mv: number;
  fee: number;
  al: AlbumModel;
  ar: ArtistModel[];
  dt: number;

  constructor() {}

  formJson(json: any): SongModel {
    this.id = json['id'];
    this.name = json['name'];
    this.mv = json['mv'];
    this.fee = json['fee'];
    this.dt = json['dt'];
    // Album
    if (json['al'] !== null) {
      const album = json['al'];
      this.al = new AlbumModel(album['id'], album['name'], album['picUrl']);
    }
    //Artists
    if (json['ar'] !== null && Array.isArray(json['ar'])) {
      let artists = json['ar'];
      let ars: ArtistModel[] = [];
      artists.forEach((item) => {
        ars.push(new ArtistModel(item['id'], item['name']));
      })
      this.ar = ars;
    }
    return this;
  }
}

export class PlaylistModel {
  id: number;
  name: string;
  trackCount: number;
  playCount: number;
  coverImgUrl: string;
  subscribedCount: number;
  description: string;
  createTime: number;
  updateTime: number;

  formJson(json: any): PlaylistModel {
    this.id = json['id'];
    this.name = json['name'];
    this.trackCount = json['trackCount'];
    this.playCount = json['playCount'];
    this.coverImgUrl = json['coverImgUrl'];
    this.subscribedCount = json['subscribedCount'];
    this.description = json['description'];
    this.createTime = json['createTime'];
    this.updateTime = json['updateTime'];
    return this;
  }
}

export class CategoryModel {
  name: string;
  id: number;
  type: number;
  activity: boolean;
  createTime: number;
  usedCount: number;
  hot: boolean;
  position: number;
  category: number;

  formJson(json: any): CategoryModel {
    this.name = json['name'];
    this.id = json['id'];
    this.type = json['type'];
    this.activity = json['activity'];
    this.createTime = json['createTime'];
    this.usedCount = json['usedCount'];
    this.hot = json['hot'];
    this.position = json['position'];
    this.category = json['category'];
    return this;
  }
}

export const defaultSongItem = new SongModel().formJson({
  id: -1,
  name: 'Unknown',
  mv: 0,
  ar: [{ id: -1, name: 'unknown' }],
  al: {},
  dt: 0,
  fee: 0
});

/*
 * standard => 标准
 * higher => 较高
 * exhigh=>极高,
 * lossless=>无损,
 * hires=>Hi-Res,
 * jyeffect => 高清环绕声,
 * sky => 沉浸环绕声,
 * jymaster => 超清母带
 */
interface SongUrlInter {
  id: number,
  url: string,
  time: number,
}
//
export function getSongUrl(songId: number): Promise<SongUrlInter> {
  let queryParams = {};
  queryParams["id"] = songId;
  queryParams["level"] = 'standard';

  return new Promise(async (resolve, reject) => {
    try {
      const result = await httpRequestGet('/song/url/v1', { queryParams });
      if (result['code'] !== 200) {
        reject(new Error(''));
      } else if (!Array.isArray(result['data']) || result['data'].length == 0) {
        reject(new Error('Data is error'));
      } else {
        const song = result['data'][0];
        if (song['url'] !== null) {
          resolve({ id: song['id'], url: song['url'], time: song['time'] });
        } else reject(new Error(''));
      }
    } catch (err) {
      reject(err);
    }
  })

}
//
export function getPlaylistSongs(playlistId: number, offset: number): Promise<SongModel[]> {
  let queryParams = {};
  queryParams['id'] = playlistId;
  queryParams['limit'] = 30;
  queryParams['offset'] = offset;

  return httpRequestGet('/playlist/track/all', { queryParams }).then((result) => {
    if (result['code'] !== 200) return Error('');
    let songs: SongModel[] = [];
    if (Array.isArray(result['songs'])) {
      (result['songs'] as []).forEach((item: any) => {
        songs.push(new SongModel().formJson(item));
      });
    }
    return songs;
  }).catch((err) => {
    return err;
  });

}
//
export function getSongDetail(songId: number): Promise<SongModel[]> {

  let queryParams = {};
  queryParams['ids'] = songId;

  const accessUrl = '/song/detail';

  return httpRequestGet(accessUrl, { queryParams }).then((result) => {
    console.log(JSON.stringify(result));
    if (result['code'] !== 200) return Error('');
    let songs: SongModel[] = [];
    if (Array.isArray(result['songs'])) {
      (result['songs'] as []).forEach((item: any) => {
        songs.push(new SongModel().formJson(item));
      });
    }
    return songs;
  }).catch((err) => {
    return err;
  });

}
//
export function getPlaylistDetails(playlistId: number): Promise<PlaylistModel> {
  let queryParams = {};
  queryParams['id'] = playlistId;
  return httpRequestGet<any>('/playlist/detail', { queryParams }).then((result) => {
    if (result['code'] !== 200) return Error();
    return new PlaylistModel().formJson(result['playlist']);
  }).catch((err) => err);

}
//
export function getPlaylistCategory(): Promise<CategoryModel[]> {
  const accessUrl = '/playlist/hot';
  return httpRequestGet(accessUrl).then((result) => {
    let categories: CategoryModel[] = [];
    if (Array.isArray(result['tags'])) {
      result['tags'].forEach((item) => {
        categories.push(new CategoryModel().formJson(item));
      })
    }
    return categories;
  }).catch((err) => err);
}
//
export function getHighQualityPlaylist(cat: string, before: number) {
  const accessUrl = '/top/playlist/highquality';
  const queryParams = { 'cat': cat, 'before': before, 'limit': 20 };
  return httpRequestGet(accessUrl, { queryParams }).then((result) => {
    if (result['code'] !== 200) return Error('');
    let playlists: PlaylistModel[] = [];
    if (Array.isArray(result['playlists'])) {
      result['playlists'].forEach((item) => {
        playlists.push(new PlaylistModel().formJson(item));
      })
    }
    return playlists;
  }).catch((err) => err);
}

export function formatArtists(ars: ArtistModel[]): string {
  if (ars.length === 0) return '';
  if (ars.length === 1) return ars[0].name;
  let str: string = '';
  let length = ars.length;
  str = ars[0].name;
  for (let index = 1; index < length - 1; index++) {
    str += '/' + ars[index].name;
  }
  return str;
}
