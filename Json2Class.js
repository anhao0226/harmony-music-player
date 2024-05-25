var jsonStr = `
{
    "sgc": false,
    "sfy": false,
    "qfy": false,
    "transUser": {
        "id": 18129897,
        "status": 99,
        "demand": 1,
        "userid": 411380049,
        "nickname": "dumb_eraser",
        "uptime": 1615259404144
    },
    "lyricUser": {
        "id": 18128402,
        "status": 99,
        "demand": 0,
        "userid": 3237397719,
        "nickname": "北川春彦",
        "uptime": 1615246609516
    },
    "lrc": {
        "version": 6,
        "lyric": ""
    },
    "klyric": {
        "version": 0,
        "lyric": ""
    },
    "tlyric": {
        "version": 13,
        "lyric": ""
    },
    "romalrc": {
        "version": 5,
        "lyric": ""
    },
    "code": 200
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
                classStr += "".concat(key, ":any[];\r\n");
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
var saveDirectory = './entry/src/main/ets/view_models';
function Json2Class(str, filename) {
    try {
        str = str.replace(/[\r\n\s+]/g, '');
        console.log(JSON.stringify(str));
        var toJson = JSON.parse(str);
        var classMap = {};
        helper2(toJson, 'Lyric', 'Model', classMap);
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
Json2Class(jsonStr, 'LyricModel');
