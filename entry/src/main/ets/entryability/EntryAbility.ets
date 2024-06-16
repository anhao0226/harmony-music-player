import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { WindowsConstant } from '../common/constant/WindowConstant';
import { AudioService } from '../common/utils/AudioService';

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    AppStorage.SetOrCreate('CONTEXT', this.context);
    AudioService.getInstance().loadCache();
    window.getLastWindow(this.context).then((lastWindow) => {
      const avoidArea: window.AvoidArea = lastWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      WindowsConstant.avoidArea = avoidArea;
    })

    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy() {
    AudioService.getInstance().saveCache();
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    AppStorage.SetOrCreate('WINDOW_STAGE', windowStage);
    let windowClass = null;
    windowStage.getMainWindow().then((data) => {
      //
      const { width, height } = data.getWindowProperties().windowRect;
      AppStorage.SetOrCreate('WINDOW_WIDTH', width);
      AppStorage.SetOrCreate('WINDOW_HEIGHT', height);

      //
      let names = [];
      windowClass.setWindowSystemBarEnable(names, (err) => {
        if (err.code) {
          console.error('Failed to set the system bar to be visible. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in setting the system bar to be visible.');
      });
      windowClass = data;
    })

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });

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
    console.log('onBackground');
    AudioService.getInstance().saveCache();
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

