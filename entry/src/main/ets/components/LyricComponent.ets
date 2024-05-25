import { fetchSongLyric } from '../api/SongLyricApi';

interface LyricInterface {
  time: number,
  text: string,
  source: string,
}

@Component
export struct LyricComponent {
  @State lyricList: LyricInterface[] = [];
  @State currIndex: number = 0;
  private scroller: Scroller = new Scroller();
  @StorageProp('PROGRESS') @Watch('onProgressChange') duration: number = 0;
  @StorageProp('CURR_AUDIO_ID') @Watch('onCurrAudioChange') currAudioId: number = 0;

  aboutToAppear() {
    this.handleSongLyric();
  }

  onCurrAudioChange() {
    this.lyricList = [];
    this.currIndex = 0;
    this.handleSongLyric();
  }

  formatTime(str: string): number {
    let mSec = 2;
    let time = 0;
    const timeArr = /\[(\d{2}):(\d{2})(\.(\d{2,3}))?]/.exec(str)?.map((item, index) => {
      if (index === 4) mSec = item?.length ?? mSec;
      return Number(item);
    });
    time = timeArr[1] * 60 + timeArr[2] + (timeArr[4] / (mSec === 2 ? 100 : 1000) ?? 0)
    return time
  }

  handleSongLyric() {
    fetchSongLyric(this.currAudioId).then((lyricStr: string) => {
      let lyricSplitList = lyricStr.split('\n');
      let listCount = lyricSplitList.length;
      let renderLyricList: LyricInterface[] = [];
      for (let i = 0; i < listCount; i++) {
        let timeMatchArr = lyricSplitList[i].match(/\[(\d{2}):(\d{2})(\.(\d{2,3}))?]/g);
        if (timeMatchArr !== null) {
          let text = lyricSplitList[i].replace(timeMatchArr[0], '');
          const item = { time: this.formatTime(timeMatchArr[0]), text, source: lyricSplitList[i] };
          renderLyricList.push(item);
        }
      }
      this.lyricList = renderLyricList;

      this.updateCurrIndex();
    }).catch((err) => {

    })
  }

  updateCurrIndex() {
    if(this.lyricList.length > 0){
      let i = this.currIndex;
      while (i < this.lyricList.length) {
        if (this.duration > this.lyricList[i].time * 1000) i++;
        else break;
      }
      const index = i > 0 ? i - 1 : 0;
      if (index !== this.currIndex) {
        this.currIndex = index;
        this.scroller.scrollTo({
          xOffset: 0,
          yOffset: this.currIndex * 50,
          animation: { duration: 325, curve: Curve.EaseInOut }
        });
      }
    }
  }

  onProgressChange() {
    console.log(this.duration.toString());
    this.updateCurrIndex();
  }

  build() {
    Column() {
      List({ scroller: this.scroller }) {
        ListItem().height(150);
        ForEach(this.lyricList, (item: LyricInterface, index: number) => {
          ListItem() {
            Row() {
              Text(item.text)
                .fontSize(20)
                .fontColor((this.currIndex === index) ? '#DBFFFFFF' : '#66FFFFFF')
                .textAlign(TextAlign.Center);
            }
          }.align(Alignment.Center).width('100%').height(50);
        }, (_, index: number) => index.toString().concat('_LYRIC_ITEM'))
      }.height('100%').width('100%');
    }
  }
}