import { WindowsConstant } from '../common/constant/WindowConstant';

@Component
export struct SafeAreaComponent {
  @BuilderParam closer: () => any;

  build() {
    Column() {
      this.closer();
    }.margin({ top: 0 });
  }
}