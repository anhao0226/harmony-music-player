import { httpRequestGet } from '../common/utils/HttpClient';
import { Playlist, PlaylistResponse } from '../view_models/playlist_mode';

enum AccessUrl {
  PlaylistDetail = '/playlist/detail',
}

interface PlaylistResult extends Playlist {}

export function fetchPlaylistDetail(playlistId: number): Promise<PlaylistResult> {
  let queryParams = {};
  queryParams['id'] = playlistId;
  return new Promise<PlaylistResult>((resolve, reject) => {
    return httpRequestGet<PlaylistResponse>(AccessUrl.PlaylistDetail, { queryParams }).then((result) => {
      if (result.code === 200 && result.playlist !== null) {
        resolve(result.playlist);
      } else {
        reject(`Response error code: ${result.code}, message: ${result.message}`);
      }
    }).catch((err) => {
      console.log(err);
      reject(err);
    });
  });
}