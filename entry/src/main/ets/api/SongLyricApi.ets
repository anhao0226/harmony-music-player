import { httpRequestGet } from '../common/utils/HttpClient';
import { LyricModel } from '../view_models/LyricModel';

export function fetchSongLyric(songId: number) {
  let accessUrl = '/lyric/new';
  let queryParams = { 'id': songId }
  return new Promise((resolve, reject) => {
    httpRequestGet(accessUrl, { queryParams }).then((result) => {
      const lyric = new LyricModel().fromJson(result);
      if (lyric.code === 200) {
        resolve(lyric.lrc.lyric);
      } else {
        reject(new Error(`State code error ${result['code']}`));
      }
    }).catch((err) =>{
      console.log(err);
      reject(err);
    });
  })
}