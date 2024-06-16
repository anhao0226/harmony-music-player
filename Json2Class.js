
const jsonStr = `
   {
            "id": 347230,
            "fee": 1,
            "payed": 0,
            "st": 0,
            "pl": 0,
            "dl": 0,
            "sp": 7,
            "cp": 1,
            "subp": 1,
            "cs": false,
            "maxbr": 999000,
            "fl": 0,
            "toast": false,
            "flag": 1028,
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
                "cannotListenReason": null,
                "playReason": null
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
`

function upperFirstCase(str) {
    var len = str.length;
    if (len === 0)
        return str;
    if (len === 1)
        return str.toUpperCase();
    return str[0].toUpperCase() + str.substring(1);
}
var Value2ClassType = {
    '[object Null]': 'any',
    '[object Number]': 'number',
    '[object Boolean]': 'boolean',
    '[object String]': 'string',
};
var VariableType;
(function (VariableType) {
    VariableType["Null"] = "[object Null]";
    VariableType["Number"] = "[object Number]";
    VariableType["Boolean"] = "[object Boolean]";
    VariableType["String"] = "[object String]";
    VariableType["Object"] = "[object Object]";
    VariableType["Array"] = "[object Array]";
})(VariableType || (VariableType = {}));
function hasOwn(o, key) {
    return Object.prototype.hasOwnProperty.call(o, key);
}
function matchType(valType) {
    return hasOwn(Value2ClassType, valType) ? Value2ClassType[valType] : '';
}
function checkType(value) {
    return Object.prototype.toString.call(value);
}
function helper2(toJson, className, suffix, classMap) {
    var classStr = "class ".concat(className).concat(suffix, " {");
    var fromJsonMethodStr = "fromJson(json:any) {";
    Object.keys(toJson).forEach(function (key) {
        var valType = checkType(toJson[key]);
        switch (valType) {
            case VariableType.Null:
                classStr += "".concat(key, ":").concat(matchType(VariableType.Null), ";\r\n");
                fromJsonMethodStr += "this.".concat(key, "=json['").concat(key, "'];\r\n");
                break;
            case VariableType.Number:
                classStr += "".concat(key, ":").concat(matchType(VariableType.Number), ";\r\n");
                fromJsonMethodStr += "this.".concat(key, "=json['").concat(key, "'];\r\n");
                break;
            case VariableType.Boolean:
                classStr += "".concat(key, ":").concat(matchType(VariableType.Boolean), ";\r\n");
                fromJsonMethodStr += "this.".concat(key, "=json['").concat(key, "'];\r\n");
                break;
            case '[object Object]':
                var suffix_1 = 'Model';
                var _className = upperFirstCase(key);
                classStr += "".concat(key, ":").concat(_className + suffix_1, ";\r\n");
                fromJsonMethodStr += "this.".concat(key, "=new ").concat(_className + suffix_1, "().fromJson(json['").concat(key, "']);\r\n");
                helper2(toJson[key], _className, suffix_1, classMap);
                break;
            case '[object Array]':
                classStr += handleArrayType(toJson, key, classMap);
                break;
            case VariableType.String:
                classStr += "".concat(key, ":").concat(matchType(VariableType.String), ";");
                fromJsonMethodStr += "this.".concat(key, "=json['").concat(key, "'];\r\n");
                break;
        }
    });
    classStr += fromJsonMethodStr + 'return this }';
    classStr += '}';
    classMap[className] = classStr;
}
function classVariableTemplate(key, tpy) {
    return "".concat(key, ":").concat(matchType(tpy), ";\r\n");
}
function classArrayVariableTemplate(key, tpy) {
    return "".concat(key, ":").concat(matchType(tpy), "[];\r\n");
}
function classObjectVariableTemplate(key, className, suffix) {
    return "".concat(key, ":").concat(className).concat(suffix, "[];\r\n");
}
function assignmentTemplate() {
}
// [[[{ name:1 }]]]
function handleArrayType(toJson, key, classMap) {
    var value = toJson[key];
    if (value.length > 0) {
        var tpy = checkType(value[0]);
        switch (tpy) {
            case VariableType.Array:
                // handleArrayType(value, )
                break;
            case VariableType.Object:
                var _className = upperFirstCase(key);
                helper2(value[0], _className, 'Model', classMap);
                return classObjectVariableTemplate(key, _className, 'Model');
            case VariableType.Boolean:
            case VariableType.Null:
            case VariableType.Number:
            case VariableType.String:
                return classArrayVariableTemplate(key, tpy);
        }
    }
    else {
        return classArrayVariableTemplate(key, VariableType.Null);
    }
}
var saveDirectory = './entry/src/main/ets/view_models';
function Json2Class(str, filename) {
    try {
        str = str.replace('\n', '');
        var toJson = JSON.parse(str);
        var classMap = {};
        helper2(toJson, 'Privilege', 'Model', classMap);
        var fs = require('fs');
        var filepath = "".concat(saveDirectory, "/").concat(filename, ".ets");
        fs.writeFile(filepath, Object.values(classMap).join('\r\n'), function (err) {
            if (err) {
                console.error(err);
            }
            // file written successfully
        });
    }
    catch (err) {
        console.log(err);
    }
}
Json2Class(jsonStr, 'PrivilegeModel');
