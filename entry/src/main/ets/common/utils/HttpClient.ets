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

  if(options && options.queryParams){
    finalUrl = finalUrl + transformQueryParameters(options.queryParams);
  }

  let requestOptions = {
    method: http.RequestMethod.GET,
    readTimeout: Const.HTTP_READ_TIMEOUT,
    header: { 'Content-Type': ContentType.JSON },
    connectTimeout: Const.HTTP_READ_TIMEOUT,
    extraData: {}
  };

  try {
    const responseResult = await httpRequest.request(encodeURI(finalUrl), requestOptions)
    if (responseResult.responseCode === Const.HTTP_CODE_200) {
      return JSON.parse(responseResult.result as string) as T;
    } else {
      return;
    }
  } catch (err) {
    console.log("Error: " + JSON.stringify(err))
    return err;
  }
}


function transformQueryParameters(parameters: any): string {
  if (!parameters) return '';
  let formatArr: string[] = [];
  Object.keys(parameters).forEach((key: string) => {
    formatArr.push(`${key}=${parameters[key]}`);
  });
  return formatArr.length > 0 ? `?${formatArr.join('&')}` : '';
}