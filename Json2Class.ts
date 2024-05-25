const jsonStr = `{
  "user": {
      "locationInfo": null,
      "liveInfo": null,
      "anonym": 0,
      "commonIdentity": null,
      "followed": false,
      "mutual": false,
      "remarkName": null,
      "socialUserId": null,
      "vipRights": {
          "associator": null,
          "musicPackage": null,
          "redplus": null,
          "redVipAnnualCount": -1,
          "redVipLevel": 0,
          "relationType": 0
      },
      "nickname": "何处有祢",
      "authStatus": 0,
      "expertTags": null,
      "experts": null,
      "vipType": 0,
      "userType": 0,
      "avatarDetail": null,
      "avatarUrl": "http://p4.music.126.net/7TbJ_sHvB1yMTXyiLO8MNg==/109951164546273368.jpg",
      "userId": 341199929,
      "target": null
  },
  "beReplied": [],
  "pendantData": null,
  "showFloorComment": null,
  "status": 0,
  "commentId": 366198751,
  "content": "这个强迫症歌单还是做得不够全面啊，作为一个强迫症晚期患者，你这个歌名，怎么能不按拼音来排序呢！！！！！🌚🌚",
  "richContent": null,
  "contentResource": null,
  "time": 1493165122763,
  "timeStr": "2017-04-26",
  "needDisplayTime": true,
  "likedCount": 1018,
  "expressionUrl": null,
  "commentLocationType": 0,
  "parentCommentId": 0,
  "decoration": {
      "repliedByAuthorCount": 0
  },
  "repliedMark": null,
  "grade": null,
  "userBizLevels": null,
  "ipLocation": {
      "ip": null,
      "location": "",
      "userId": null
  },
  "owner": false,
  "medal": null,
  "liked": false
}`;

function upperFirstCase(str: string): string {
  const len = str.length;
  if (len === 0) return str;
  if (len === 1) return str.toUpperCase();
  return str[0].toUpperCase() + str.substring(1);
}

const Value2ClassType: Record<string, string> = {
  '[object Null]': 'any',
  '[object Number]': 'number',
  '[object Boolean]': 'boolean',
  '[object String]': 'string',
}

enum VariableType {
  Null = '[object Null]',
  Number = '[object Number]',
  Boolean = '[object Boolean]',
  String = '[object String]',
}

function hasOwn(o: unknown, key: string): boolean {
  return Object.prototype.hasOwnProperty.call(o, key);
}

function matchType(valType: string) {
  return hasOwn(Value2ClassType, valType) ? Value2ClassType[valType] : '';
}

function checkType(value: any):string{
  return Object.prototype.toString.call(value);
}

function helper2(toJson: any, className: string, suffix: string, classMap: Record<string, any>) {
  let classStr: string = `class ${className}${suffix} {`;
  let fromJsonMethodStr: string = `fromJson(json:any) {`

  Object.keys(toJson).forEach((key) => {
    let valType = checkType(toJson[key]);
    switch (valType) {
      case VariableType.Null:
        classStr += `${key}:${matchType(VariableType.Null)};\r\n`;
        fromJsonMethodStr += `this.${key}=json['${key}'];\r\n`;
        break;
      case VariableType.Number:
        classStr += `${key}:${matchType(VariableType.Number)};\r\n`;
        fromJsonMethodStr += `this.${key}=json['${key}'];\r\n`;
        break;
      case VariableType.Boolean:
        classStr += `${key}:${matchType(VariableType.Boolean)};\r\n`;
        fromJsonMethodStr += `this.${key}=json['${key}'];\r\n`;
        break;
      case '[object Object]':
        let suffix: string = 'Model';
        let _className: string = upperFirstCase(key);
        classStr += `${key}:${_className + suffix};\r\n`;
        fromJsonMethodStr += `this.${key}=new ${_className + suffix}().fromJson(json['${key}']);\r\n`;
        helper2(toJson[key], _className, suffix, classMap);
        break;
      case '[object Array]':
        classStr += `${key}:any[];\r\n`;
        break;
      case VariableType.String:
        classStr += `${key}:${matchType(VariableType.String)};`;
        fromJsonMethodStr += `this.${key}=json['${key}'];\r\n`;
        break;
    }
  });
  classStr += fromJsonMethodStr + 'return this }';
  classStr += '}';
  classMap[className] = classStr;
}


const saveDirectory = './entry/src/main/ets/view_models';

function Json2Class(str: string, filename:string) {
  try {
    str = str.replace('\n', '\\n');
    let toJson = JSON.parse(str);
    let classMap = {};
    helper2(toJson, 'Comment', 'Model', classMap);
    const fs = require('fs');
    const filepath = `${saveDirectory}/${filename}.ets`;
    fs.writeFile(filepath, Object.values(classMap).join('\r\n'), err => {
      if (err) {
        console.error(err);
      }
      // file written successfully
    });

  } catch (err) {
    
  }
}


Json2Class(jsonStr, 'CommentsModel');
