import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';


let sub_windowClass = null;

export default class MyCustomDialog_ extends UIAbility {

  onCreate(want, launchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {

    windowStage.createSubWindow("mySubWindow", (err, data) => {
      if (err.code) {
        console.error('Failed to create the subwindow. Cause: ' + JSON.stringify(err));
        return;
      }
      sub_windowClass = data;

      console.info('Succeeded in creating the subwindow. Data: ' + JSON.stringify(data));
      // 2.子窗口创建成功后，设置子窗口的位置、大小及相关属性等。
      sub_windowClass.moveWindowTo(0, 0, (err) => {
        if (err.code) {
          console.error('Failed to move the window. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in moving the window.');
      });
      sub_windowClass.resize(500, 500, (err) => {
        if (err.code) {
          console.error('Failed to change the window size. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in changing the window size.');
      });
      // 3.为子窗口加载对应的目标页面。
      sub_windowClass.setUIContent("pages/SongPlayerPage", (err) => {
        if (err.code) {
          console.error('Failed to load the content. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in loading the content.');
        // 3.显示子窗口。
        sub_windowClass.showWindow((err) => {
          if (err.code) {
            console.error('Failed to show the window. Cause: ' + JSON.stringify(err));
            return;
          }
          console.info('Succeeded in showing the window.');
        });
      });
    })
  }

  onWindowStageDestroy() {
      // Main window is destroyed, release UI related resources
      hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
      // Ability has brought to foreground
      hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
      // Ability has back to background
      hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
