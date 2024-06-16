var jsonStr = `
{
                "name": "",
                "id": 1357375695,
                "pst": 0,
                "t": 0,
                "ar": [
                    {
                        "id": 11127,
                        "name": "Beyond",
                        "tns": [
                            ""
                        ],
                        "alias": []
                    }
                ],
                "alia": [],
                "pop": 100,
                "st": 0,
                "rt": "",
                "fee": 1,
                "v": 12,
                "crbt": null,
                "cf": "",
                "al": {
                    "id": 78372827,
                    "name": "",
                    "picUrl": "",
                    "tns": [],
                    "pic_str": "109951163984013003",
                    "pic": 109951163984013010
                },
                "dt": 239560,
                "h": {
                    "br": 320000,
                    "fid": 0,
                    "size": 9584893,
                    "vd": 3991,
                    "sr": 44100
                },
                "m": {
                    "br": 192000,
                    "fid": 0,
                    "size": 5750953,
                    "vd": 6570,
                    "sr": 44100
                },
                "l": {
                    "br": 128000,
                    "fid": 0,
                    "size": 3833983,
                    "vd": 8220,
                    "sr": 44100
                },
                "sq": {
                    "br": 1508256,
                    "fid": 0,
                    "size": 45164780,
                    "vd": 4001,
                    "sr": 44100
                },
                "hr": null,
                "a": null,
                "cd": "01",
                "no": 1,
                "rtUrl": null,
                "ftype": 0,
                "rtUrls": [],
                "djId": 0,
                "copyright": 1,
                "s_id": 0,
                "mark": 17179877376,
                "originCoverType": 0,
                "originSongSimpleData": null,
                "tagPicList": null,
                "resourceState": true,
                "version": 12,
                "songJumpInfo": null,
                "entertainmentTags": null,
                "single": 0,
                "noCopyrightRcmd": null,
                "rtype": 0,
                "rurl": null,
                "mst": 9,
                "cp": 7002,
                "mv": 5501497,
                "publishTime": 737308800000,
                "privilege": {
                    "id": 1357375695,
                    "fee": 1,
                    "payed": 0,
                    "st": 0,
                    "pl": 0,
                    "dl": 0,
                    "sp": 0,
                    "cp": 0,
                    "subp": 1,
                    "cs": false,
                    "maxbr": 999000,
                    "fl": 0,
                    "toast": false,
                    "flag": 260,
                    "preSell": false,
                    "playMaxbr": 999000,
                    "downloadMaxbr": 999000,
                    "maxBrLevel": "lossless",
                    "playMaxBrLevel": "lossless",
                    "downloadMaxBrLevel": "lossless",
                    "plLevel": "none",
                    "dlLevel": "none",
                    "flLevel": "none",
                    "rscl": null,
                    "freeTrialPrivilege": {
                        "resConsumable": true,
                        "userConsumable": false,
                        "listenType": null,
                        "cannotListenReason": null
                    },
                    "rightSource": 0,
                    "chargeInfoList": [
                        {
                            "rate": 128000,
                            "chargeUrl": null,
                            "chargeMessage": null,
                            "chargeType": 1
                        },
                        {
                            "rate": 192000,
                            "chargeUrl": null,
                            "chargeMessage": null,
                            "chargeType": 1
                        },
                        {
                            "rate": 320000,
                            "chargeUrl": null,
                            "chargeMessage": null,
                            "chargeType": 1
                        },
                        {
                            "rate": 999000,
                            "chargeUrl": null,
                            "chargeMessage": null,
                            "chargeType": 1
                        }
                    ]
                }
            }
`;

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
  Object = '[object Object]',
  Array = '[object Array]',
}

function hasOwn(o: unknown, key: string): boolean {
  return Object.prototype.hasOwnProperty.call(o, key);
}

function matchType(valType: string) {
  return hasOwn(Value2ClassType, valType) ? Value2ClassType[valType] : '';
}

function checkType(value: any): string {
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
        classStr += handleArrayType(toJson, key, classMap);
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

function classVariableTemplate(key:string, tpy: VariableType):string{
  return `${key}:${matchType(tpy)};\r\n`;
}

function classArrayVariableTemplate(key:string, tpy: VariableType):string{
  return `${key}:${matchType(tpy)}[];\r\n`;
}

function classObjectVariableTemplate(key:string, className: string, suffix: string):string{
  return `${key}:${className}${suffix}[];\r\n`;
}

function assignmentTemplate(){
  
}

// [[[{ name:1 }]]]

function handleArrayType(toJson: any, key: string, classMap: Record<string, any>){
  const value = toJson[key];
  if (value.length > 0) {
    const tpy = checkType(value[0]);
    switch (tpy) {
      case VariableType.Array:
        // handleArrayType(value, )
        break;
      case VariableType.Object:
        let _className: string = upperFirstCase(key);
        helper2(value[0], _className, 'Model', classMap);
        return classObjectVariableTemplate(key, _className, 'Model');
      case VariableType.Boolean:
      case VariableType.Null:
      case VariableType.Number:
      case VariableType.String:
        return classArrayVariableTemplate(key, tpy);
    }
  } else {
    return classArrayVariableTemplate(key, VariableType.Null);
  }
}

const saveDirectory = './entry/src/main/ets/view_models';

function Json2Class(str: string, filename: string) {
  try {
    str = str.replace('\n', '');
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
    console.log(err);
  }
}


Json2Class(jsonStr, 'CommentsModel');
