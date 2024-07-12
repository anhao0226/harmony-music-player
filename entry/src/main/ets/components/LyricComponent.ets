import { fetchSongLyric } from '../api/SongLyricApi';
import { AudioService } from '../common/utils/AudioService';

interface LyricInterface {
  time: number
  text: string
  source: string
}

@Component
export struct LyricComponent {
  @State _lyricList: LyricInterface[] = [];
  @State _activeIndex: number = 0;
  private _ItemAreas: Area[] = [];
  private _regExp = new RegExp(/\[(\d{2}):(\d{2})(\.(\d{2,3}))?]/);
  private _scroller: Scroller = new Scroller();
  @StorageProp('PROGRESS') @Watch('onProgressChange') progress: number = 0;
  @StorageProp('CURRENT_AUDIO_ID') @Watch('onAudioChange') currAudioId: number = 0

  _reset() {
    this._activeIndex = 0;
    this._lyricList = []
    this._scroller.scrollTo({ xOffset: 0, yOffset: 0 });
  }

  onAudioChange() {
    this._reset();
    this.handleSongLyric(this.currAudioId);
  }

  aboutToAppear() {
    console.log(`aboutToAppear === ${this.currAudioId.toString()}`);
    this.onProgressChange()
    this.handleSongLyric(AudioService.getInstance().getAudioId());
  }

  formatTime(str: string): number {
    let mSec = 2;
    let time = 0;
    const timeArr = this._regExp.exec(str)?.map((item, index) => {
      if (index === 4) mSec = item?.length ?? mSec;
      return Number(item);
    });
    time = timeArr[1] * 60 + timeArr[2] + (timeArr[4] / (mSec === 2 ? 100 : 1000) ?? 0);
    return time
  }

  matchLyric(source: string) {
    const regValues = this._regExp.exec(source);
    if (!regValues) return null;
    let newStr: string = source.replace(regValues[0], '').trim();
    newStr = newStr.length > 0 ? newStr : '...';
    let time = this.formatTime(regValues[0]);
    return { text: newStr, time, source }
  }

  // 27646198
  handleSongLyric(songId: number) {
    console.log(`handleSongLyric === ${songId.toString()}`);
    fetchSongLyric(songId).then((value: string) => {
      //
      let lyrics: LyricInterface[] = [];
      value.split('\n').forEach((str: string) => {
        const regValue = this.matchLyric(str);
        if (regValue) lyrics.push(regValue);
      });

      if(lyrics.length){
        this._ItemAreas = new Array(lyrics.length);
        this._lyricList = lyrics;
        this.updateActiveIndex();
      }else{

      }
    }).catch((err) => {
      console.log(`Error =========> ${err}`);
      this._lyricList = [];
    })
  }

  scrollTo(yOffset: number) {
    this._scroller.scrollTo({ xOffset: 0, yOffset: yOffset,
      animation: { duration: 625, curve: Curve.Ease } });
  }

  updateActiveIndex() {
    if (this._lyricList.length > 0) {
      let i = this._activeIndex;
      while (i < this._lyricList.length) {
        if (this.progress > this._lyricList[i].time * 1000) i++;
        else break;
      }
      let index: number = i > 0 ? i - 1 : 0;
      if (index !== this._activeIndex) {
        this._activeIndex = index;
        const area: Area = this._ItemAreas[index];
        this.scrollTo(area ? area.position.y as number : 0);
      }
    }
  }

  onProgressChange() {
    this.updateActiveIndex();
  }

  build() {
    Column() {
      if (this._lyricList.length) {
        Scroll(this._scroller) {
          Column() {
            ForEach(this._lyricList, (item: LyricInterface, index: number) => {
              /**
               *
               */
                LyricItemComponent({
                  text: item.text,
                  isActive: this._activeIndex === index,
                }).onAreaChange((_: Area, newVal: Area) => {
                  if (!this._ItemAreas[index]) {
                    this._ItemAreas[index] = newVal;
                  }
                });
            }, (_, index: number) => `${index}_LYRIC_ITEM`);
          };
        }.scrollBar(BarState.Off).padding({ top: 20 });
      } else {
        Text('The song has no lyrics');
      }
    }.width('100%').height('100%');
  }
}


@Component
struct LyricItemComponent {
  private text: string = '';
  @Prop isActive: boolean;

  aboutToAppear() {

  }

  build() {
    Text(this.text)
      .width('100%')
      .fontSize(this.isActive ? 25 : 22)
      .fontColor(this.isActive ? '#DBFFFFFF' : '#66FFFFFF')
      .textAlign(TextAlign.Center)
      .padding({ bottom: 20 })
      .animation({ duration: 625, curve: Curve.EaseInOut });
  }
}