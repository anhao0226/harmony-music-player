import http from '@ohos.net.http';
import effectKit from '@ohos.effectKit';
import image from '@ohos.multimedia.image';

export function getNetworkImagePixelMap(url: string): Promise<image.PixelMap> {
  let httpRequest = http.createHttp();
  return new Promise(async (resolve, reject) => {
    try {
      console.log(url);
      let response = await httpRequest.request(url);
      if (response.responseCode === 200) {
        let imageData = response.result;
        let imageSource = image.createImageSource(imageData as any);
        let options = { editable: false }
        let pixelMap = await imageSource.createPixelMap(options)
        resolve(pixelMap);
      }
    } catch (err) {
      console.log(`Create network image pixel map error : ${err}`)
      reject(err);
    }
  });
}


export function getImageMainColor(pixelMap: image.PixelMap): Promise<effectKit.Color> {
  return new Promise(async (resolve, reject) => {
    try {
      let colorPicker = await effectKit.createColorPicker(pixelMap);
      resolve(await colorPicker.getMainColor());
    } catch (err) {
      console.log(`GetImageMainColorError : ${err}`)
      reject(err);
    }
  });
}

export function isCloseWhiteColor(color: effectKit.Color) {
  const value = 0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue;
  return value > 245;
}

export function rgbaToHexColor(color: effectKit.Color): string {
  return `#${color.alpha.toString(16)}${color.red.toString(16)}${color.green.toString(16)}${color.blue.toString(16)}`
}

export function rgba(r: number, g: number, b: number, a: number): string {
  return `rgba(${r},${g},${b},${a})`;
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