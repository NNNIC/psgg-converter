package psggconverterlib;
using StringTools;
import system.*;
import anonymoustypes.*;

class Convert
{
    public function GetComment(s:String):String
    {
        var commentline_format:String = getMacroValueFunc("commentline");
        if (system.Cs2Hx.IsNullOrEmpty(commentline_format))
        {
            commentline_format = COMMENTLINE_FORMAT;
        }
        return psggconverterlib.MacroWork.Convert_String_String_String_String(commentline_format, s);
    }
    public var BRKGS:Bool = false;
    public var BRKGF:Bool = false;
    public var BRKP:Bool = false;
    public function TEST():Void
    {
        system.Console.WriteLine("psggConvertLib TEST");
    }
    public var ERRMSG:String;
    public function VERSION():String
    {
        return psggconverterlib.ver.version;
    }
    public function GITHASH():String
    {
        return psggconverterlib.githash.hash;
    }
    public function BUILDTIME():String
    {
        return psggconverterlib.ver.datetime;
    }
    public function COPYRIGHT():String
    {
        return "2018 NNNIC / MIT Licence";
    }
    public function DEPOT():String
    {
        return psggconverterlib.ver.depot;
    }
    public var NAME_COL:Int = 2;
    public var STATE_ROW:Int = 2;
    public var NEWLINECHAR:String = "\x0d\x0a";
    public var BASESTATE:String = "basestate";
    public var COMMENTLINE_FORMAT:String = "// {%0}";
    public var LANG:String = "";
    public var OUTPUT:String = "";
    public var ENC:String = "utf-8";
    public var GENDIR:String = "";
    public var XLSDIR:String = "";
    public var INCDIR:String = "";
    public var TEMSRC:String = "";
    public var TEMFUNC:String = "";
    public var PREFIX:String = "";
    public var STATEMACHINE:String = "STATEMACHINENAME";
    public var TEMSRC_save:String = "";
    public var TEMFUNC_save:String = "";
    public var MARK_START:String = "";
    public var MARK_END:String = "";
    public var TGTFILE:String = "";
    public var CVTHEXCHAR:Bool = false;
    public var PSGGFILE:String = "";
    public var CONTENTS1:String = "$contents1$";
    public var CONTENTS1PTN:String = "\\$contents1.*?\\$";
    public var CONTENTS2:String = "$contents2$";
    public var CONTENTS3:String = "$contents3$";
    public var PREFIXMACRO:String = "$prefix$";
    public var STATEMACHINEMACRO:String = "$statemachine$";
    public var REGEXCONT:String = "\\$\\/.+\\/\\$\\s*$";
    public var REGEXCONT2:String = "\\$\\/.+\\/->#.+\\$\\s*$";
    public var template_src:String;
    public var template_func:String;
    public var getChartFunc:(Int -> Int -> String);
    public var getMacroValueFunc:(String -> String);
    public var setting_ini:String;
    public var state_list:Array<String>;
    public var state_col_list:Array<Int>;
    public var name_list:Array<String>;
    public var name_row_list:Array<Int>;
    public function Init(i_template_src:String, i_template_func:String, i_getChartFunc:(Int -> Int -> String), i_getMacroValueFunc:(String -> String) = null):Void
    {
        template_src = i_template_src;
        template_func = i_template_func;
        getChartFunc = i_getChartFunc;
        getMacroValueFunc = i_getMacroValueFunc;
        _init();
    }
    private function _init():Void
    {
        state_list = new Array<String>();
        state_col_list = new Array<Int>();
        name_list = new Array<String>();
        name_row_list = new Array<Int>();
        { //for
            var c:Int = 1;
            while (c < 10000)
            {
                var state:String = getChartFunc(STATE_ROW, c);
                if (!system.Cs2Hx.IsNullOrEmpty(state))
                {
                    if (