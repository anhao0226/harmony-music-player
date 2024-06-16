/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import http from '@ohos.net.http';
import { CommonConstant as Const, ContentType } from '../constant/CommonConstant';

const baseUrl = "http://192.168.31.151:3000";

interface Option {
  queryParams: any
}

export async function httpRequestGet<T>(url: string, options?: Option): Promise<T> {
  let httpRequest = http.createHttp();
  // handle request url
  let finalUrl = baseUrl.concat(url);

  if (options && options.queryParams) {
    finalUrl = finalUrl + transformQueryParameters(options.queryParams);
  }

  let requestOptions = {
    method: http.RequestMethod.GET,
    readTimeout: Const.HTTP_READ_TIMEOUT,
    header: { 'Content-Type': ContentType.JSON },
    connectTimeout: Const.HTTP_READ_TIMEOUT,
    extraData: {}
  };

  return new Promise((resolve, reject) => {
    httpRequest.request(encodeURI(finalUrl), requestOptions, (err, data: http.HttpResponse) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析
        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + JSON.stringify(data.responseCode));
        // data.header为HTTP响应头，可根据业务需要进行解析
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies));
        // 处理响应内容
        let result = JSON.parse(data.result as string) as T;
        resolve(result);
      } else {
        console.log('')
        reject(err);
      }

      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    })
  })
}


function transformQueryParameters(parameters: any): string {
  if (!parameters) return '';
  let formatArr: string[] = [];
  Object.keys(parameters).forEach((key: string) => {
    formatArr.push(`${key}=${parameters[key]}`);
  });
  return formatArr.length > 0 ? `?${formatArr.join('&')}` : '';
}