import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
// import { SongPlayMode } from '../common/utils/AudioConfig';
// import { AudioService } from '../common/utils/AudioService';
// import { StorageService } from '../common/utils/StorageService';
// import { defaultSongItem, SongModel } from '../view_models/playlist_song_model';
// import { SongDataSource } from '../view_models/SongDataSource';

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    AppStorage.SetOrCreate('context', this.context);
    // this.loadCache();
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  // async loadCache() {
  //   try {
  //     // handle play model
  //     const playMode = await StorageService.getInstance().get('PLAY_MODE', SongPlayMode.ORDER);
  //     // handle playList
  //     const playList = await StorageService.getInstance().get('PLAY_LIST', []);
  //     let songs = JSON.parse(playList as string) as SongModel[];
  //     // handle playIndex
  //     const playIndex = await StorageService.getInstance().get('PLAY_INDEX', 0);
  //     AudioService.getInstance().initData(songs, playIndex as number);
  //   } catch (err) {
  //
  //   }
  // }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

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
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
