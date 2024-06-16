import http from '@ohos.net.http';
import effectKit from '@ohos.effectKit';
import image from '@ohos.multimedia.image';

export function getNetworkImagePixelMap(url: string): Promise<image.PixelMap> {
  let httpRequest = http.createHttp();
  return new Promise(async (resolve, reject) => {
    httpRequest.request(url, {}, (err, data: http.HttpResponse) => {
      if (!err && data.responseCode === 200) {
        let imageSource = image.createImageSource(data.result as any);
        let options = { editable: false };
        imageSource.createPixelMap(options).then((pixelMap: image.PixelMap) => {
          resolve(pixelMap);
        }).catch((err) => {
          // console.log(`Create network image pixel map error : ${err}`);
          reject(err);
        })
      } else {
        // console.log(`Create network image pixel map error : ${err}`);
        reject(err);
      }
      httpRequest.destroy();
    });
  });
}

/**
 *
 * @param url
 * @returns
 */
export function createNetworkImagePixelMap(url: string): Promise<image.PixelMap> {
  let httpRequest = http.createHttp();
  return new Promise(async (resolve, reject) => {
    httpRequest.request(url, {}, (err, data: http.HttpResponse) => {
      if (!err && data.responseCode === 200) {
        let imageSource = image.createImageSource(data.result as any);
        let options = { editable: false };
        imageSource.createPixelMap(options).then((pixelMap: image.PixelMap) => {
          resolve(pixelMap);
        }).catch((err) => {
          console.log(`Create network image pixel map error : code ${err.code} message ${err.message}`);
          reject(err);
        })
      } else {
        console.log(`Create network image pixel map error : code ${err.code} message ${err.message}`);
        reject(err);
      }
      httpRequest.destroy();
    });
  });
}

/**
 *
 * @param pixelMap
 * @returns
 */
export function getImageMainColor(pixelMap: image.PixelMap): Promise<effectKit.Color> {
  return new Promise((resolve, reject) => {
    effectKit.createColorPicker(pixelMap).then((colorPicker) => {
      colorPicker.getMainColor().then((color: effectKit.Color) => {
        resolve(color);
      }).catch((err) => {
        console.log(`getMainColor error code: ${err.code} message: ${err.message}`);
        reject(err);
      })
    }).catch((err) => {
      console.log(`createColorPicker error code: ${err.code} message: ${err.message}`);
      reject(err);
    })
  });
}

export function isCloseWhiteColor(color: effectKit.Color) {
  const value = 0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue;
  console.log(value.toString());
  return value > 203;
}

export function rgbaToHexColor(color: effectKit.Color): string {
  return `#${color.alpha.toString(16)}${color.red.toString(16)}${color.green.toString(16)}${color.blue.toString(16)}`
}

export function rgba(r: number, g: number, b: number, a: number): string {
  return `rgba(${r},${g},${b},${a})`;
}

export function rgbToHsl(color: effectKit.Color) {
  let r = color.red / 255;
  let g = color.green / 255;
  let b = color.blue / 255;
  let max = Math.max(r, g, b), min = Math.min(r, g, b);
  let h, s, l = (max + min) / 2;
  if (max == min) {
    h = s = 0; // achromatic
  } else {
    let d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    switch (max) {
      case r:
        h = (g - b) / d + (g < b ? 6 : 0);
        break;
      case g:
        h = (b - r) / d + 2;
        break;
      case b:
        h = (r - g) / d + 4;
        break;
    }
    h /= 6;
  }
  return { h, s, l };
}


export function getLightColor(color: effectKit.Color, level: number): effectKit.Color {
  const red = Math.floor((255 - color.red) * level + color.red);
  const green = Math.floor((255 - color.green) * level + color.green);
  const blue = Math.floor((255 - color.blue) * level + color.blue);
  return { red, green, blue, alpha: 255 }
}

export function getDarkColor(color: effectKit.Color, level: number): effectKit.Color {
  const red = Math.floor(color.red - level * color.red);
  const green = Math.floor(color.green - level * color.green);
  const blue = Math.floor(color.blue - level * color.blue);
  return { red, green, blue, alpha: 255 }
}