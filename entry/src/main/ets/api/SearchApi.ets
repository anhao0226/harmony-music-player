import { httpRequestGet } from '../common/utils/HttpClient';
import { AlbumInter, ArtistInter, SearchResponse, SongInter } from '../view_models/SearchModel';

export function fetchSearchData(keywords: string): Promise<SearchResponse> {
  let accessUrl = '/search/suggest';
  let queryParams = { 'keywords': keywords }
  return new Promise<SearchResponse>((resolve, reject) => {
    httpRequestGet(accessUrl, { queryParams }).then((data: Object) => {
      if (data.hasOwnProperty('code') && data['code'] === 200) {
        resolve(data['result'] as SearchResponse);
      } else {
        reject(new Error(`State code error ${data['code']}`));
      }
    }).catch((err) => {
      console.log(err);
      reject(err);
    });
  })
}