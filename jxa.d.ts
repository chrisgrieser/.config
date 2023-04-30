// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking

interface _ObjC {
   import: function(string);
}
interface _Application {
   currentApplication: function;
}

declare var ObjC: _ObjC;
declare var Application: _Application;
