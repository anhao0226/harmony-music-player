import { readdir, rename, readFile, writeFile, renameSync } from 'fs';
import { join as pathJoin } from 'path';

const svgTemplate = function (title:string, data:string){
    return `<?xml version="1.0" encoding="UTF-8"?>
    <svg xmlns="http://www.w3.org/2000/svg" 
        xmlns:xlink="http://www.w3.org/1999/xlink" 
        width="24"
        height="24"
        viewBox="0 0 24 24"
        version="1.1">
        <title>Public/${title}</title>
        <defs>
            <path
                ${data}
                id="_path-1"/>
        </defs>
        <g
            id="_Public/${title}"
            stroke="none"
            stroke-width="1"
            fill="none"
            fill-rule="evenodd">
            <mask
                id="_mask-2"
                fill="white">
                <use xlink:href="#_path-1"/>
            </mask>
            <use
                id="_形状结合"
                fill="#000000"
                fill-rule="nonzero"
                xlink:href="#_path-1"/>
        </g>
    </svg>`
} 

const dirpath = './entry/src/main/resources/base/media/_icons/';

function handleSvgData(filepath:string, filename: string, callback:() => void) {
    readFile(filepath, (err, data) => {
        if (err) {
            console.error(err);
            return;
        }
        const regStr = /d=".*"/g;
        const res = data.toString().match(regStr)
        console.log(`${filepath} => ${JSON.stringify(res)}`);
        if(res && res.length > 0) {
            const title = filename.split('.');
            const svgData = svgTemplate(title[0], res[0]);
            writeFile(filepath, svgData, (err) => {
                if (err) {
                    console.error(err);
                    return;
                }
                callback();
            })   
        }
    });
}

function handleRename(oldPath:string, newPath:string){
    console.log(`old path ${oldPath} === new path ${newPath}`);
    rename(oldPath, newPath, (err) => {
        if(!err) {
            console.log(err);
            return;
        }
    })
}

function joinFilepath(prefix: string, filename:string):string {
    return pathJoin(dirpath, prefix + filename);
}

function handleIconFile(){
    readdir(dirpath, null, (err, files: string[]) => {
        if (err) {
            console.error(err);
            return;
        }
        files.forEach(filename =>{
             const filepath = dirpath + filename; 
             handleSvgData(filepath, filename, () => {
                const prefix = 'ic_public_';
                const _filename: string = filename.replace(/-/g, '_');
                if(filename !== _filename){
                    handleRename(filepath, joinFilepath(prefix, _filename));
                }
             });
        });
    });
}


handleIconFile();

