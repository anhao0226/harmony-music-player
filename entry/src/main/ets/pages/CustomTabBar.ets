import emitter from '@ohos.events.emitter';
import { CustomTabBar } from '../components/CustomTabBar';

@Entry
@Component
struct TabBarView {
  private items: number[] = [1, 2, 3, 4];
  @State currentIndex: number = 0;

  @Builder TabViewBuilder(index: number) {
    Column() {
      if (index === 0) {
        Column() {
          Text('VVVV1');
        }.width('100%').height('100%');
      } else if (index === 1) {
        Column() {
          Text('VVVV2');
        }.width('100%').height('100%');
      } else if (index === 2) {
        Column() {
          Text('VVVV3');
        }.width('100%').height('100%');
      } else {
        Text('Error');
      }
    }
  }

  build() {
    Column() {
      // CustomTabBar({ items: $items, viewBuilder: this.TabViewBuilder });
    }
  }
}

