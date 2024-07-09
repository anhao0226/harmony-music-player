import window from '@ohos.window'

export class WindowsConstant {
  static _avoidArea: window.AvoidArea

  static set avoidArea(value: window.AvoidArea) {
    this._avoidArea = value;
  }

  static get avoidArea(): window.AvoidArea {
    return this._avoidArea;
  }

  static statusBarHeight(): number {
    return px2vp(this._avoidArea.topRect.height);
  }
}