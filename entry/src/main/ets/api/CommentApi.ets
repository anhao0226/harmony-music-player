import { httpRequestGet } from '../common/utils/HttpClient';
import { CommentData, CommentResponse } from '../models/CommentModel';

// 资源类型
export enum CommentType {
  MUSIC,
  MV,
  PLAYLIST,
  ALBUM,
  VIDEO,
  DYNAMIC,
  DJ,
}

// 排序方式
export enum SortType {
  RECOMMEND = 1,
  HOT = 2,
  TIME = 3,
}


enum AccessUrl {
  CommentNew = '/comment/new',
}

interface CommentParamsInterface {
  id: number,
  type: CommentType,
  sortType: SortType,
  pageNo?: number,
  pageSize?: number,
  cursor?: number,
}

export function fetchComments(params: CommentParamsInterface): Promise<CommentData> {
  let queryParams = params;
  console.log(JSON.stringify(params));
  return new Promise<CommentData>((resolve, reject) => {
    httpRequestGet<CommentResponse>(AccessUrl.CommentNew, { queryParams }).then((result) => {
      if (result.code === 200) {
        resolve(result.data);
      } else {
        reject(new Error(`Response error, code: ${result.code} message ${result.message}`));
      }
    }).catch((err) => reject);
  })
}
