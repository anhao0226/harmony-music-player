import { httpRequestGet } from '../common/utils/HttpClient';
import { CommentModel } from '../view_models/CommentsModel';

export function fetchPlaylistComment(playlistId: number) {
  let accessUrl = '/comment/new';
  let queryParams = { 'id': playlistId, type: '2' }
  return new Promise((resolve, reject) => {
    httpRequestGet(accessUrl, { queryParams }).then((result) => {
      if (result['code'] === 200) {
        let commentList: CommentModel[] = [];
        if (result['data'] && Array.isArray(result['data']['comments'])) {
          result['data']['comments'].forEach((item) => {
            commentList.push(new CommentModel().fromJson(item));
          });
        }
        resolve({ comments: commentList });
      } else {
        reject(new Error(`State code error ${result['code']}`));
      }
    }).catch((err) => reject);
  })
}