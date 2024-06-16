import effectKit from '@ohos.effectKit';
import { fetchSongs } from '../api/SongApi';
import { fetchSongLyric } from '../api/SongLyricApi';
import { AudioService } from '../common/utils/AudioService';
import { rgbaToHexColor } from '../common/utils/ColorUtil';
import { PlaylistDialogComponent } from '../components/PlaylistDialogComponent';
import { SongInfoDialogComponent } from '../components/SongInfoIDialogContent';
import { Song } from '../models/SongModel';

// @Component
// struct TestComp {
//   bgColor() {
//     return this;
//   }
//
//   build() {
//
//   }
// }
//
//
// @Component
// struct CanvasExample {
//
//   //用来配置CanvasRenderingContext2D对象的参数，包括是否开启抗锯齿，true表明开启抗锯齿。
//   private settings: RenderingContextSettings = new RenderingContextSettings(true)
//   //用来创建CanvasRenderingContext2D对象，通过在canvas中调用CanvasRenderingContext2D对象来绘制。
//   private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
//
//   build() {
//     Canvas(this.context).width(200).aspectRatio(1).onReady(() => {
//       this.context.clearRect(0, 0, 200, 200)
//       for (let index = 0; index < 10; index++) {
//         this.context.fillStyle = '#0000ff'
//         this.context.fillRect(index * 10, 0, 6, Math.round(Math.random() * 100));
//       }
//     })
//   }
// }
//
// @Component
// struct TabBarView {
//   @State items: number[] = [0, 0, 0, 0, 0, 0];
//   @State currentIndex: number = 0;
//   private rowWidth = 0;
//   private itemWidth = 6;
//   private itemMinWidth = 3;
//   private itemMaxHeight = 100;
//   private space: number = 4;
//
//   aboutToAppear() {
//     let itemCount = this.items.length;
//     this.rowWidth = itemCount * this.itemWidth + (this.space * itemCount - 1);
//     this.startAnimate();
//   }
//
//   startAnimate() {
//     animateTo({
//       onFinish: () => this.startAnimate(),
//     }, () => {
//       for (let index = 0; index < 6; index++) {
//         this.items[index] = Math.round(Math.random() * 100);
//       }
//     })
//   }
//
//   @Builder Bar(index: number, itemW: number) {
//     Row().width(itemW).height(this.items[index]).backgroundColor(Color.Black);
//   }
//
//   build() {
//     Row({ space: this.space }) {
//       ForEach(this.items, (_: number, index: number) => {
//         this.Bar(index, this.itemWidth);
//       }, (_: any, index: number) => `${index}_ITEM_BAR`);
//     }.width(this.rowWidth).height(100).borderWidth(2).alignItems(VerticalAlign.Bottom);
//   }
// }
//

// const lyricStr = `[ti:情非得已韩文版]\n[ar:韩文版]\n[by:9181533@网易云音乐_101]\n[#:http://music.163.com/#/song?id=33894312]\n[1501,8465](0,4004)(0,551)二(0,1852)囍(0,850)制(0,558)作(0,650).\n[9966,4010](0,200)终(0,200)到(0,151)么(0,249)几(0,150)南(0,650)杂(0,550)波(0,1860)大\n[13976,4050](0,199)他(0,300)能(0,250)哭(0,600)目(0,850)我(0,300)朴(0,1551)大　　\n[18026,2901](0,749)终(0,301)目(0,550)南(0,249)杂(0,1052)噶\n[20927,2401](0,400)退(0,500)过(0,300)西(0,1201)坡\n[23328,3855](0,1003)呢(0,550)怒(0,500)威(0,1802)海　　\n[27183,4803](0,249)阿(0,300)木(0,250)里(0,251)黑(0,300)滴(0,250)了(0,350)都(0,300)五(0,301)几(0,250)碗(0,2002)考　　\n[31986,4711](0,249)跟(0,251)木(0,249)极(0,608)度(0,550)阿(0,301)能(0,352)那(0,2151)能　　\n[36697,4302](0,300)扑(0,550)到(0,250)为(0,1001)考(0,400)他(0,600)那(0,251)哦(0,950)门　　\n[40999,4103](0,250)内(0,253)给(0,250)他(0,250)那(0,350)那(0,250)也(0,250)故(0,301)名(0,249)高(0,1700)雅　　\n[45102,7164](0,2412)wow~(0,200)那(0,250)闹(0,250)嘛(0,251)你(0,301)寺(0,299)庙(0,350)跟(0,300)那(0,601)都(0,1950)怕　　\n[52266,4401](0,199)一(0,251)即(0,250)大(0,300)都(0,250)怒(0,300)故(0,500)跑(0,350)西(0,2001)嘛　　\n[56667,4457](0,300)卡(0,250)空(0,250)内(0,250)噶(0,300)写(0,250)kei(0,600)多(0,300)哈(0,1957)过\n[61124,4251](0,250)踏(0,251)进(0,299)米(0,250)大(0,350)几(0,300)都(0,250)完(0,300)卡(0,200)急(0,1801)嘛　　\n[65375,4802](0,200)阿(0,300)杜(0,351)那(0,199)那(0,350)达(0,250)噶(0,251)那(0,250)去(0,650)印(0,2001)噶　　\n[70177,4400](0,250)就(0,250)跟(0,250)kei(0,250)大(0,300)料(0,300)酒(0,550)so(0,1) (0,349)in(0,1900)你　　\n[74577,4453](0,350)闹(0,200)都(0,300)撒(0,250)浪(0,300)啊(0,300)能(0,500)哈(0,302)撒(0,1951)浪　　\n[79030,7053](0,251)no(0,350)也(0,250)塔(0,251)那(0,299)那(0,350)也(0,300)南(0,450)杂(0,4552)诺　　\n[86083,4202](0,150)票(0,250)咯(0,250)一(0,301)波(0,300)几(0,450)多(0,550)万(0,1951)扩　　\n[90285,4800](0,250)要(0,300)砸(0,250)他(0,550)气(0,650)那(0,450)那(0,2350)托　　\n[95085,8309](0,200)你(0,200)呀(0,400)内(0,250)马(0,1156)过(0,300)忒(0,601)票(0,250)纳(0,1401)诺(0,700)内(0,601)给(0,500)铺(0,1750)有　　\n[103394,2051](0,300)乔(0,350)凹(0,300)满(0,250)那(0,300)噶(0,250)扑(0,301)起\n[105445,2800](0,250)莫(0,300)忒(0,250)扫(0,2000)扫　　\n[108245,4753](0,249)你(0,300)该(0,250)那(0,600)也(0,550)撒(0,250)浪(0,350)敏(0,2204)高　　\n[112998,4306](0,300)乃(0,600)妈(0,250)哦(0,1001)木(0,351)弄(0,600)度(0,254)改(0,950)哈　　\n[117304,4102](0,200)塞(0,250)上(0,300)噶(0,250)那(0,300)那(0,250)也(0,350)古(0,300)琴(0,200)那(0,1702)搞　　\n[121406,7006](0,2302)wow~(0,250)那(0,250)闹(0,350)嘛(0,251)你(0,250)寺(0,200)庙(0,250)跟(0,200)那(0,651)都(0,2052)怕　　\n[128412,4504](0,251)一(0,300)即(0,351)大(0,300)都(0,301)怒(0,200)故(0,550)跑(0,350)西(0,1901)嘛　　\n[132916,4505](0,300)卡(0,250)空(0,350)内(0,300)噶(0,200)写(0,350)kei(0,451)多(0,402)哈(0,1902)过\n[137421,4256](0,251)踏(0,300)进(0,300)米(0,300)大(0,200)几(0,251)都(0,300)完(0,250)卡(0,303)急(0,1801)嘛　　\n[141677,4701](0,250)阿(0,300)杜(0,250)那(0,251)那(0,249)达(0,300)噶(0,300)那(0,300)去(0,600)印(0,1901)噶　　\n[146378,4455](0,300)就(0,300)跟(0,250)kei(0,301)大(0,250)料(0,353)酒(0,451)so(0,1) (0,299)in(0,1950)你　　\n[150833,4452](0,350)闹(0,300)都(0,251)撒(0,300)浪(0,300)啊(0,250)能(0,500)哈(0,250)撒(0,1951)浪　　\n[155285,25968](0,351)no(0,249)也(0,250)塔(0,300)那(0,300)那(0,300)也(0,301)南(0,599)杂(0,23318)诺　　\n[181253,3801](0,200)阿(0,300)木(0,700)一(0,201)行(0,400)寒(0,300)诺(0,300)那(0,1400)度　　\n[185054,5053](0,150)即(0,200)侨(0,250)胞(0,300)略(0,450)带(0,150)一(0,350)该(0,3203)几　　\n[190107,3953](0,300)苦(0,201)劳(0,800)该(0,200)乃(0,200)该(0,500)鲁(0,902)瓦(0,850)扫　　\n[194060,3451](0,250)乃(0,300)朴(0,201)麻(0,300)乃(0,200)扫(0,350)误(0,300)导(0,200)据(0,1350)来　　\n[197511,7156](0,2354)wow~(0,300)那(0,300)闹(0,350)嘛(0,300)你(0,300)寺(0,250)庙(0,251)跟(0,250)那(0,649)都(0,1852)怕　　\n[204667,4555](0,250)一(0,300)即(0,302)大(0,350)都(0,250)怒(0,252)故(0,500)跑(0,300)西(0,2051)嘛　　\n[209222,4401](0,200)卡(0,300)空(0,300)内(0,250)噶(0,301)写(0,250)kei(0,600)多(0,250)哈(0,1950)过\n[213623,4201](0,250)踏(0,300)进(0,300)米(0,350)大(0,250)几(0,300)都(0,250)完(0,250)卡(0,300)急(0,1651)嘛　　\n[217824,4753](0,301)阿(0,300)杜(0,300)那(0,250)那(0,250)达(0,300)噶(0,250)那(0,250)去(0,700)印(0,1852)噶　　\n[222577,4504](0,301)就(0,299)跟(0,301)kei(0,300)大(0,300)料(0,250)酒(0,451)so(0,1) (0,549)in(0,1752)你　　\n[227081,4450](0,250)闹(0,300)都(0,200)撒(0,350)浪(0,350)啊(0,250)能(0,500)哈(0,300)撒(0,1950)浪　　\n[231531,4551](0,250)no(0,301)也(0,250)塔(0,250)那(0,300)那(0,350)也(0,250)南(0,600)杂(0,2000)诺　　\n[236082,270000](0,250)no(0,350)也(0,250)塔(0,350)那(0,250)那(0,301)也(0,300)南(0,701)杂(0,3553)诺\n`;
//
// const lyricStr2 = `[ti:滚滚红尘]\n[ar:罗大佑]\n[by:7987130@网易云音乐]\n[#:http://music.163.com/#/song?id=108700]\n[17698,3247](0,550)起(0,199)初(0,151)不(0,249)经(0,400)意(0,251)的(0,1447)你\n[20693,4698](0,550)和(0,200)少(0,400)年(0,200)不(0,300)经(0,500)事(0,500)的(0,2048)我\n[25633,8697](0,550)红(0,250)尘(0,399)中(0,250)的(0,350)情(0,450)缘(0,250)只(0,550)因(0,450)那(0,250)生(0,450)命(0,250)匆(0,350)匆(0,300)不(0,250)语(0,300)的(0,900)胶(0,2148)着\n[33673,3748](0,550)想(0,200)是(0,401)人(0,250)世(0,300)间(0,350)的(0,1697)错\n[37618,4497](0,600)或(0,250)前(0,250)世(0,299)流(0,251)传(0,450)的(0,499)因(0,1898)果\n[41638,8898](0,700)终(0,200)生(0,851)的(0,300)所(0,400)有(0,300)也(0,550)不(0,400)惜(0,350)换(0,600)取(0,250)刹(0,250)那(0,350)阴(0,200)阳(0,400)的(0,400)交(0,2397)流\n[49698,4299](0,550)来(0,801)易(0,751)来(0,250)去(0,951)难(0,996)去\n[53699,3998](0,500)数(0,250)十(0,250)载(0,400)的(0,450)人(0,301)世(0,1847)游\n[58619,4045](0,550)分(0,250)易(0,1000)分(0,350)聚(0,1149)难(0,746)聚\n[61694,3951](0,550)爱(0,300)与(0,354)恨(0,300)的(0,550)千(0,350)古(0,1547)愁\n[66639,3147](0,600)本(0,200)应(0,300)属(0,300)于(0,300)你(0,350)的(0,1097)心\n[69650,4699](0,900)它(0,250)依(0,399)然(0,452)护(0,299)紧(0,301)我(0,500)胸(0,1598)口\n[74620,8802](0,702)为(0,200)只(0,250)为(0,250)那(0,350)尘(0,300)世(0,350)转(0,300)变(0,800)的(0,300)面(0,400)孔(0,400)后(0,701)的(0,250)翻(0,250)云(0,301)覆(0,350)雨(0,2348)手\n[82670,4298](0,650)来(0,600)易(0,852)来(0,500)去(0,950)难(0,746)去\n[86670,4100](0,600)数(0,300)十(0,250)载(0,300)的(0,553)人(0,250)世(0,1847)游\n[90651,4507](0,951)分(0,800)易(0,600)分(0,350)聚(0,850)难(0,956)聚\n[94671,4398](0,600)爱(0,250)与(0,500)恨(0,250)的(0,250)千(0,601)古(0,1947)愁\n[98681,4301](0,650)于(0,353)是(0,300)不(0,350)愿(0,300)走(0,451)的(0,1897)你\n[102682,4699](0,551)要(0,199)告(0,300)别(0,251)已(0,300)不(0,349)见(0,551)的(0,2198)我\n[107622,8402](0,650)至(0,251)今(0,450)世(0,250)间(0,250)仍(0,300)有(0,300)隐(0,701)约(0,300)的(0,300)耳(0,651)语(0,250)跟(0,249)随(0,301)我(0,300)俩(0,350)的(0,701)传(0,1848)说\n[131691,4097](0,700)来(0,550)易(0,651)来(0,500)去(0,800)难(0,896)去\n[135671,4497](0,550)数(0,249)十(0,451)载(0,299)的(0,301)人(0,450)世(0,2197)游\n[139691,4196](0,650)分(0,550)易(0,800)分(0,550)聚(0,850)难(0,796)聚\n[143681,4847](0,550)爱(0,250)与(0,350)恨(0,250)的(0,300)千(0,600)古(0,2547)愁\n[148637,2898](0,500)于(0,200)是(0,300)不(0,251)愿(0,249)走(0,401)的(0,997)你\n[150697,5799](0,1401)要(0,200)告(0,199)别(0,251)已(0,250)不(0,300)见(0,450)的(0,2748)我\n[156647,8449](0,600)至(0,200)今(0,350)世(0,451)间(0,250)仍(0,250)有(0,200)隐(0,450)约(0,250)的(0,350)耳(0,750)语(0,250)跟(0,249)随(0,251)我(0,250)俩(0,450)的(0,350)传(0,2548)说\n[164662,13503](0,600)滚(0,200)滚(0,251)红(0,200)尘(0,250)里(0,300)有(0,200)隐(0,300)约(0,800)的(0,250)耳(0,301)语(0,600)跟(0,249)随(0,250)我(0,900)俩(0,701)的(0,4153)传(0,2998)说\n`
//
// const lyricStr3 = `[00:00.000] 作词 : 罗大佑\n[00:01.000] 作曲 : 罗大佑\n[00:16.600]起初不经意的你\n[00:20.600]和少年不经世的我\n[00:24.600]红尘中的情缘\n[00:27.600]只因那生命匆匆不语的胶着\n[00:33.600]想是人世间的错\n[00:36.600]或前世流传的因果\n[00:41.600]终生的所有\n[00:43.600]也不惜换取刹那阴阳的交流\n[00:49.600]来易来 去难去\n[00:53.600]数十载的人世游\n[00:57.600]分易分 聚难聚\n[01:02.600]爱与恨的千古愁\n[01:06.600]本应属于你的心\n[01:10.600]它依然护紧我胸口\n[01:14.600]为只为那尘世转变的面孔后的翻云覆雨手\n[01:22.600]来易来 去难去\n[01:27.600]数十载的人世游\n[01:30.600]分易分 聚难聚\n[01:35.600]爱与恨的千古愁\n[01:39.600]于是不愿走的你\n[01:43.600]要告别已不见的我\n[01:47.600]至今世间仍有隐约的耳语\n[01:51.600]跟随我俩的传说\n[02:12.600]来易来 去难去\n[02:16.600]数十载的人世游\n[02:20.600]分易分 聚难聚\n[02:24.600]爱与恨的千古愁\n[02:29.600]于是不愿走的你\n[02:33.600]要告别已不见的我\n[02:37.600]至今世间仍有隐约的耳语\n[02:41.600]跟随我俩的传说\n[02:45.600]滚滚红尘里有隐约的耳语\n[02:50.600]跟随我俩的传说\n`;
//
//
interface LyricInterface {
  time: number,
  text: string,
  source: string,
}

@Component
export struct LyComponent {
  @State lyricList: LyricInterface[] = [];
  @State currTime: number = 0;
  @State currIndex: number = 0;
  private scroller: Scroller = new Scroller();

  formatTime(str: string): number {
    let mSec = 2;
    let time = 0;
    const timeArr = /\[(\d{2}):(\d{2})(\.(\d{2,3}))?]/.exec(str)?.map((item, index) => {
      if (index === 4) {
        mSec = item?.length ?? mSec;
      }
      return Number(item)
    });
    time = timeArr[1] * 60 + timeArr[2] + (timeArr[4] / (mSec === 2 ? 100 : 1000) ?? 0)
    return time
  }

  aboutToAppear() {
    fetchSongLyric(238346).then((str: string) => {

      try {
        let lyricStrList = str.split('\n');
        lyricStrList.pop();
        let renderLyricList: LyricInterface[] = [];

        lyricStrList.forEach(((item: string) => {
          let timeMatchArr = item.match(/\[(\d{2}):(\d{2})(\.(\d{2,3}))?]/g);
          if (timeMatchArr) {
            let text = item.replace(timeMatchArr[0], '');
            renderLyricList.push({ time: this.formatTime(timeMatchArr[0]), text, source: item });
          }
        }));
        this.lyricList = renderLyricList;
      } catch (err) {
        console.log(err);
      }
      // let lyricStrList = str.split('\n');
      // lyricStrList.pop();
      // let renderLyricList: LyricInterface[] = [];
      //
      // lyricStrList.forEach((item => {
      //   let timeStr = item.match(/\[(\d{2}):(\d{2})(\.(\d{2,3}))?]/g)[0];
      //   let text = item.replace(timeStr, '');
      //   renderLyricList.push({ time: this.formatTime(timeStr), text, source: item });
      // }));
      // this.lyricList = lyricStrList.map((item: string) => {
      //   let timeStr = item.match(/\[(\d{2}):(\d{2})(\.(\d{2,3}))?]/g)[0];
      //   let text = item.replace(timeStr, '');
      //   return { time: this.formatTime(timeStr), text, source: item };
      // });
      // console.log(renderLyricList.length.toString());
    })
  }

  findIndex() {
    let i = this.currIndex;
    while (i < this.lyricList.length) {
      if (this.currTime > this.lyricList[i].time * 1000) i++;
      else break;
    }
    if (i - 1 !== this.currIndex) {
      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: this.currIndex * 50,
        animation: { duration: 325, curve: Curve.EaseInOut }
      })
    }
    this.currIndex = i - 1;
  }

  build() {
    Column() {
      Text(this.currIndex.toString());
      Button('Start').onClick(() => {
        setInterval(() => {
          this.currTime += 16;
          this.findIndex();
        }, 16)
      })
      Text(this.lyricList.length.toString());
      List({ scroller: this.scroller }) {
        ListItem().height(100);
        ForEach(this.lyricList, (item: LyricInterface, index: number) => {
          ListItem() {
            Row() {
              Text(item.text)
                .fontSize(22)
                .fontColor((this.currIndex === index) ? Color.Green : Color.Black)
                .textAlign(TextAlign.Center);
              Text(item.time.toString());
            }
          }.align(Alignment.Center).width('100%').height(50);
        }, (_, index: number) => index.toString().concat('_LYRIC_ITEM'))
      }.height('100%').width('100%');
    }
  }
}

// let lyricList = lyricStr2.split('\n');
// lyricList.forEach((item) => {
//   console.log(item);
//   const lrcItem: any = {}
//   lrcItem.time = item.match(/\([0-9]+,[0-9]+\)/g);
//   lrcItem.text = item.match(/(?<=\))\S\s?(?=\()/g);
//   console.log(JSON.stringify(lrcItem));
// });

class Example {
  private _name: string;

  get name(): string {
    return this._name;
  }

  set name(value: string) {
    AppStorage.SetOrCreate('NAME', value);
    console.log(value);
    this._name = value;
  }
}

@Entry
@Component
struct ExPage {
  @StorageProp('NAME') name: string = 'aaa'
  private _toStr: string = '';
  @State _song: Song = null;
  @State vals: number[] = [1, 2, 3, 4, 5, 6, 7];
  @State copyValues: number[] = [];

  aboutToAppear() {
    this.copyValues = [...this.vals].reverse();
  }

  toJson() {

  }

  build() {
    Column() {

      ForEach(this.copyValues, (item: number, index: number) => {
        Text(item.toString())
          .height(56)
          .width('100%')
          .textAlign(TextAlign.Center)
          .borderWidth(1)
          .onClick(() => {
            const endIndex = this.vals.length - 1 - index
            this.copyValues = [...this.copyValues.slice(endIndex)];
          });
      }, (item, index) => `${item.toString()}_ITEM`);


    }
  }
}