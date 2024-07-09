import { httpRequestGet } from '../common/utils/HttpClient';
import { Album, AlbumDetailResponse } from '../models/AlbumDetailModel';
import { ArtistAlbumResponse, HotAlbum } from '../models/ArtistAlbumModel';
import { ArtistDetail, ArtistDetailResponse } from '../models/ArtistDetailModel';
import { ArtistMvResponse, Mv as ArMV } from '../models/ArtistMvModel';
import { ArtistSongsResponse } from '../models/ArtistSongModel';
import { HotSearchDetailResponse, SearchDetail } from '../models/HotSearchDetailModel';
import { MvModel } from '../models/MvDataModel';
import { MvDetail, MvDetailResponse, MvUrlResponse } from '../models/MvModel';
import { FetchMvResponse } from '../models/MvDataModel';
import { Privilege, Song } from '../models/SongModel';
import { SongUrl, SongUrlResponse } from '../models/SongUrlModel';
import { SuggestSearchResponse, SuggestSearchResult } from '../models/SuggestSearchModel';
/**
 *
 */
enum AccessUrls {
  Songs = '/song/detail',
  ArtistDetail = '/artist/detail',
  ArtistSongs = '/artist/songs',
  ArtistAlbum = '/artist/album',
  ArtistMv = '/artist/mv',
  AlbumDetail = '/album',
  MvDetail = '/mv/detail',
  MvUrl = '/mv/url',
  ExclusiveMv = '/mv/exclusive/rcmd',
  MvAll = '/mv/all',
  SongUrl = '/song/url/v1',
  Search = '/search',
  HotSearchDetail = '/search/hot/detail',
  SuggestSearch = '/search/suggest',
}

/**
 * fetchSongs
 */
interface SongsResponse {
  songs?: Song[]
  privileges?: Privilege[]
  code?: number
  message?: string
}

interface SongsResult {
  songs: Song[]
  privileges: Privilege[]
}

export function fetchSongs(songIds: number[]) {
  const params = { ids: songIds.join(',') };
  return new Promise<SongsResult>((resolve, reject) => {
    httpRequestGet<SongsResponse>(AccessUrls.Songs, { queryParams: params }).then((res) => {
      if (res.code === 200) {
        resolve({ songs: res.songs || [], privileges: res.privileges || [] })
      } else {
        reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
      }
    }).catch((err) => {
      console.log(err);
      reject(err);
    })
  })
}

/**
 * fetchArtistDetail
 */
export function fetchArtistDetail(artistId: number) {
  const params = { id: artistId };
  return new Promise<ArtistDetail | null>((resolve, reject) => {
    httpRequestGet<ArtistDetailResponse>(AccessUrls.ArtistDetail,
      { queryParams: params }).then((res) => {
      if (res.code === 200) {
        resolve(res.data)
      } else {
        reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
      }
    }).catch((err) => {
      console.log(err);
      reject(err);
    })
  });
}

/**
 * fetchArtistSongs
 */
interface ArtistSongsResult {
  more: boolean
  total: number
  songs: Song[]
}

export function fetchArtistSongs(artistId: number, order: 'hot' | 'time' = 'hot', limit: number = 25, offset: number = 0) {
  const params = { id: artistId, order, limit, offset };
  return new Promise <ArtistSongsResult>((resolve, reject) => {
    httpRequestGet<ArtistSongsResponse>(AccessUrls.ArtistSongs,
      { queryParams: params }).then((res) => {
      if (res.code === 200) {
        resolve({ more: res.more, total: res.total, songs: res.songs });
      } else {
        reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
      }
    }).catch((err) => {
      console.log(err);
      reject(err);
    })
  });
}

/**
 * fetchArtistAlbums
 */

interface ArtistAlbumResult {
  more: boolean
  hotAlbums: HotAlbum[]
}

export function fetchArtistAlbums(artistId: number, limit: number = 25, offset: number = 0) {
  const params = { id: artistId, limit, offset };
  return new Promise <ArtistAlbumResult>((resolve, reject) => {
    httpRequestGet<ArtistAlbumResponse>(AccessUrls.ArtistAlbum,
      { queryParams: params }).then((res) => {
      if (res.code === 200) {
        resolve({ more: res.more, hotAlbums: res.hotAlbums || [] });
      } else {
        reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
      }
    }).catch((err) => {
      console.log(err);
      reject(err);
    })
  });
}


/**
 * fetchArtistMv
 */

interface ArtistMvsResult {
  mvs: ArMV[]
  hasMore: boolean
}

export function fetchArtistMvs(artistId: number) {
  const params = { id: artistId };
  return new Promise <ArtistMvsResult>((resolve, reject) => {
    httpRequestGet<ArtistMvResponse>(AccessUrls.ArtistMv, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve({ hasMore: res.hasMore, mvs: res.mvs || [] });
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}

/**
 *
 */
interface AlbumDetailResult {
  songs: Song[]
  album: Album
}

/**
 *
 * @param artistId
 * @returns
 */
export function fetchAlbumDetail(albumId: number) {
  const params = { id: albumId };
  return new Promise <AlbumDetailResult>((resolve, reject) => {
    httpRequestGet<AlbumDetailResponse>(AccessUrls.AlbumDetail, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve({ songs: res.songs, album: res.album });
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}

/**
 * 获取mv地址
 * @param mvId
 * @returns
 */
export function fetchMovieUrl(mvId: number) {
  const params = { id: mvId };
  return new Promise <{ url: string }>((resolve, reject) => {
    httpRequestGet<MvUrlResponse>(AccessUrls.MvUrl, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve({ url: res.data.url });
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}


/**
 * 获取mv详情
 * @param mvId
 * @returns
 */
export function fetchMovieDetail(mvId: number) {
  const params = { mvid: mvId };
  return new Promise <MvDetail>((resolve, reject) => {
    httpRequestGet<MvDetailResponse>(AccessUrls.MvDetail, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve(res.data);
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}


/**
 *
 */
type SongLevel = 'standard' | 'higher' | 'exhigh' | 'lossless' | 'hires' | 'jyeffect' | 'sky' | 'jymaster';

/**
 *
 * @param songIds
 * @param level
 */
export function fetchSongUrl(songIds: number[], level: SongLevel) {
  const params = { id: songIds.join(',') };
  return new Promise <SongUrl[]>((resolve, reject) => {
    httpRequestGet<SongUrlResponse>(AccessUrls.SongUrl, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve(res.data);
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}

/**
 * fetchHotSearchDetail
 * @returns
 */
export function fetchHotSearchDetail() {
  return new Promise <SearchDetail[]>((resolve, reject) => {
    httpRequestGet<HotSearchDetailResponse>(AccessUrls.HotSearchDetail)
      .then((res) => {
        if (res.code === 200) {
          resolve(res.data);
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}

/**
 * fetchSuggestSearchResult
 * @returns
 */
export function fetchSuggestSearchResult(keywords: string) {
  const params = { keywords: keywords };
  return new Promise <SuggestSearchResult>((resolve, reject) => {
    httpRequestGet<SuggestSearchResponse>(AccessUrls.SuggestSearch, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve(res.result);
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}

/**
 * fetchSuggestSearchResult
 * @returns
 */
export function fetchSearchResult(keywords: string) {
  const params = { keywords: keywords, type: 1018 };
  return new Promise <SuggestSearchResult>((resolve, reject) => {
    httpRequestGet<SuggestSearchResponse>(AccessUrls.SuggestSearch, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve(res.result);
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}

/**
 * fetchExclusiveMv
 * @param keywords
 * @returns
 */
export function fetchExclusiveMv(limit: number, offset: number) {
  const params = { limit, offset };
  return new Promise <MvModel[]>((resolve, reject) => {
    httpRequestGet<FetchMvResponse>(AccessUrls.ExclusiveMv, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve(res.data);
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}

/**
 * fetchMvs
 * @param limit
 * @param offset
 * @returns
 */

// 全部,内地,港台,欧美,日本,韩国
export enum MvArea {
  All = '全部',
  ChineseMainland = '内地',
  HongKongAndTaiwan = '港台',
  EuropeAndAmerica = '欧美',
  Japan = '日本',
  korea = '韩国',
}

// 全部,官方版,原生,现场版,网易出品
export enum MvType {
  All = '全部',
  Official = '官方版',
  Original = '原生',
  Live = '现场版',
  NetEase = '网易出品',
}

export function fetchMvs(params: {
  limit?: number,
  offset?: number,
  area?: MvArea,
  type?: MvType
}) {
  params.limit = params.limit || 10;
  params.offset = params.offset || 0;
  params.area = params.area || MvArea.All;
  params.type = params.type || MvType.All;
  return new Promise <MvModel[]>((resolve, reject) => {
    httpRequestGet<FetchMvResponse>(AccessUrls.MvAll, { queryParams: params })
      .then((res) => {
        if (res.code === 200) {
          resolve(res.data);
        } else {
          reject(new Error(`Response error: code ${res.code}, message: ${res.message}`));
        }
      })
      .catch((err) => {
        console.log(err);
        reject(err);
      })
  });
}
