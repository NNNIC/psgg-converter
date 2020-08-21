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
        return psggconverterlib.Ver.version;
    }
    public function GITHASH():String
    {
        return psggconverterlib.Githash.hash;
    }
    public function BUILDTIME():String
    {
        return psggconverterlib.Ver.datetime;
    }
    public function COPYRIGHT():String
    {
        return "2018 NNNIC / MIT Licence";
    }
    public function DEPOT():String
    {
        return psggconverterlib.Ver.depot;
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
                    if (RegexUtil.Get1stMatch("^[a-zA-Z_][a-zA-Z_0-9]*$", state) == state)
                    {
                        state_list.push(state);
                        state_col_list.push(c);
                    }
                }
                c++;
            }
        } //end for
        { //for
            var r:Int = 1;
            while (r < 10000)
            {
                var name:String = getChartFunc(r, NAME_COL);
                if (!system.Cs2Hx.IsNullOrEmpty(name))
                {
                    name_list.push(name);
                    name_row_list.push(r);
                }
                r++;
            }
        } //end for
    }
    public function GenerateSource_String_String_String(excel:String, gendir:String, incdir:String):Void
    {
        INCDIR = incdir;
        GenerateSource(excel, gendir);
    }
    public function GenerateSource(excel:String, gendir:String):Void
    {
        if (BRKGS)
        {
            system.diagnostics.Debugger.Break();
        }
        var sm:SourceControl = new SourceControl();
        sm.G = this;
        sm.m_excel = excel;
        sm.m_gendir = gendir;
        sm.m_cvthexchar = CVTHEXCHAR;
        _runSourceControl(sm, SourceControl_MODE.INIT);
        _runSourceControl(sm, SourceControl_MODE.CVT);
        return;
    }
    public function generate_for_inserting_src(excel:String, template_src_for_inserting:String, indent:Int):String
    {
        var sm:SourceControl = new SourceControl();
        sm.G = this;
        sm.m_excel = excel;
        sm.m_insert_template_src = template_src_for_inserting;
        sm.m_cvthexchar = CVTHEXCHAR;
        _runSourceControl(sm, SourceControl_MODE.INSERT, indent);
        return sm.m_insert_output;
    }
    public function Prepare():Void
    {
        if (BRKP)
        {
            system.diagnostics.Debugger.Break();
        }
        var sm:SourceControl = new SourceControl();
        sm.G = this;
        sm.m_excel = null;
        sm.m_gendir = null;
        sm.m_cvthexchar = CVTHEXCHAR;
        _runSourceControl(sm, SourceControl_MODE.INIT);
    }
    private static function _runSourceControl(sm:SourceControl, mode:Int, indent:Int = 0):Void
    {
        sm.mode = mode;
        sm.m_indent = indent;
        sm.Start();
        { //for
            var loop:Int = 0;
            while (loop <= 10000)
            {
                if (loop == 10000)
                {
                    throw new system.SystemException("Unexpected! {96B6D10A-FFF4-4BD4-B9E0-C155CF2C16EB}");
                }
                sm.update();
                if (sm.IsEnd())
                {
                    break;
                }
                loop++;
            }
        } //end for
    }
    public function CreateFunc(state:String, macrobuf:String = null):String
    {
        if (BRKGF)
        {
            system.diagnostics.Debugger.Break();
        }
        var sm:FunctionControl = new FunctionControl();
        sm.G = this;
        sm.m_state = state;
        sm.m_macro_buf = macrobuf;
        sm.m_useMacroOrTemplate = !system.Cs2Hx.IsNullOrEmpty(macrobuf);
        sm.Start();
        { //for
            var loop:Int = 0;
            while (loop <= 10000)
            {
                if (loop == 10000)
                {
                    return throw new system.SystemException("Unexpected! {D5DF7922-8A36-4458-A4F4-7B80A240EB08}");
                }
                sm.update();
                if (sm.IsEnd())
                {
                    break;
                }
                loop++;
            }
        } //end for
        return sm.m_result_src;
    }
    public function createFunc_prepare_obs(state:String, lines:CsRef<Array<String>>):Bool
    {
        if (lines.Value == null)
        {
            return false;
        }
        var findindex:CsRef<Int> = new CsRef<Int>(-1);
        var targetlines:Array<String> = StringUtil.FindMatchedLines(lines.Value, "<<<?", ">>>", findindex);
        if (targetlines == null)
        {
            return false;
        }
        if (targetlines.length < 2)
        {
            return throw new system.SystemException("Unexpected! {A6446D1F-DFD0-4A63-93C7-299265119AC7}");
        }
        var line0:String = targetlines[0];
        var targetname:String = RegexUtil.Get1stMatch("(?!\\<\\<\\<\\?)(\\w+)", line0);
        if (isExist(state, targetname))
        {
            var size:Int = targetlines.length;
            var bEOF:Bool = (system.Cs2Hx.StringContains(targetlines[targetlines.length - 1].toLowerCase(), "eof>>>"));
            targetlines.splice(0, 1);
            targetlines.splice(targetlines.length - 1, 1);
            if (bEOF)
            {
                while (lines.Value.length > findindex.Value + 1)
                {
                    lines.Value.splice(lines.Value.length - 1, 1);
                }
                size = 1;
            }
            lines.Value = StringUtil.ReplaceLines(lines.Value, findindex.Value, size, targetlines);
            return true;
        }
        else
        {
            lines.Value.splice(findindex.Value, targetlines.length);
        }
        return true;
    }
    public function createFunc_prepare_obs2(state:String, lines:CsRef<Array<String>>):Bool
    {
        if (lines.Value == null)
        {
            return false;
        }
        var findindex:CsRef<Int> = new CsRef<Int>(-1);
        var targetlines:Array<String> = StringUtil.FindMatchedLines2(lines.Value, "<<<?", ">>>", findindex);
        if (targetlines == null)
        {
            return false;
        }
        if (targetlines.length < 2)
        {
            return throw new system.SystemException("Unexpected! {A6446D1F-DFD0-4A63-93C7-299265119AC7}");
        }
        var line0:String = targetlines[0];
        var bValid:Bool = false;
        var itemname:String = "";
        var val:String = "";
        var regex:String = "";
        var target:String = RegexUtil.Get1stMatch("\\<\\<\\<\\?.+\\s*$", line0);
        target = system.Cs2Hx.Trim(target.substr(4));
        if (target.charCodeAt(0) == 34)
        {
            var dqw:String = RegexUtil.Get1stMatch("\\x22.*\\x22", target);
            val = system.Cs2Hx.Trim_(dqw, [ 34 ]);
            regex = target.substr(dqw.length);
        }
        else
        {
            itemname = RegexUtil.Get1stMatch("[0-9a-zA-Z_\\-]+", target);
            regex = target.substr(itemname.length);
            val = getString2(state, itemname);
        }
        bValid = !system.Cs2Hx.IsNullOrEmpty(val);
        if (!system.Cs2Hx.IsNullOrEmpty(regex) && regex.length > 2)
        {
            if (regex.charCodeAt(0) == 47 && regex.charCodeAt(regex.length - 1) == 47)
            {
                regex = regex.substr(1);
                regex = regex.substr(0, regex.length - 1);
                var match:String = RegexUtil.Get1stMatch(regex, val);
                bValid = !system.Cs2Hx.IsNullOrEmpty(match);
            }
            else
            {
                bValid = false;
                return throw new system.SystemException("Unexpected! {9280C652-054F-46D2-9340-BC281A2299A7} \n" + system.Cs2Hx.NullCheck(line0));
            }
        }
        if (bValid)
        {
            var size:Int = targetlines.length;
            var bEOF:Bool = (system.Cs2Hx.StringContains(targetlines[targetlines.length - 1].toLowerCase(), "eof>>>"));
            targetlines.splice(0, 1);
            targetlines.splice(targetlines.length - 1, 1);
            if (bEOF)
            {
                while (lines.Value.length > findindex.Value + 1)
                {
                    lines.Value.splice(lines.Value.length - 1, 1);
                }
                size = 1;
            }
            lines.Value = StringUtil.ReplaceLines(lines.Value, findindex.Value, size, targetlines);
            return true;
        }
        else
        {
            lines.Value.splice(findindex.Value, targetlines.length);
        }
        return true;
    }
    public function createFunc_prepare(state:String, r:RefListString):Bool
    {
        var lines:Array<String> = r.list;
        var sm:psggconverterlib.CfPrepareControl = new psggconverterlib.CfPrepareControl();
        sm.m_state = state;
        sm.m_lines = lines;
        sm.m_parent = this;
        sm.Run();
        lines = sm.m_lines;
        r.list = lines;
        return sm.m_bResult;
    }
    public function createFunc_work(state:String, r:RefListString):Bool
    {
        var lines:Array<String> = r.list;
        if (lines == null)
        {
            return false;
        }
        var i:Int = -1;
        while (true)
        {
            i++;
            if (i >= lines.length)
            {
                break;
            }
            var tstate:String = state;
            var line:String = lines[i];
            var targetvalue:String = RegexUtil.Get1stMatch("\\[\\[.*?\\]\\]", line);
            if (system.Cs2Hx.IsNullOrEmpty(targetvalue))
            {
                continue;
            }
            var tmp_targetvalue:String = targetvalue;
            if (system.Cs2Hx.StartsWith(tmp_targetvalue, "[[::"))
            {
                tstate = RegexUtil.Get1stMatch("^" + system.Cs2Hx.NullCheck(RegexUtil.VARNAME_PATTERN), tmp_targetvalue.substr(4));
                if (system.Cs2Hx.IsNullOrEmpty(tstate))
                {
                    continue;
                }
                tmp_targetvalue = tmp_targetvalue.substr(4);
                if (system.Cs2Hx.IsNullOrEmpty(tmp_targetvalue))
                {
                    continue;
                }
                tmp_targetvalue = tmp_targetvalue.substr(tstate.length);
                if (system.Cs2Hx.IsNullOrEmpty(tmp_targetvalue))
                {
                    continue;
                }
                if (tmp_targetvalue.charCodeAt(0) != 58)
                {
                    continue;
                }
                tmp_targetvalue = tmp_targetvalue.substr(1);
                tmp_targetvalue = "[[" + system.Cs2Hx.NullCheck(tmp_targetvalue);
            }
            var name:String = RegexUtil.Get1stMatch("[\\!0-9a-zA-Z_\\-]+", tmp_targetvalue);
            var macroname:String = "";
            var linenum:Int = -1;
            var argnum:Int = -1;
            var num_colon:Int = StringUtil.CountChar(tmp_targetvalue, 58);
            if (num_colon >= 1)
            {
                try
                {
                    var linenumstr:String = RegexUtil.GetNthMatch(":\\d+", tmp_targetvalue, 1);
                    linenumstr = linenumstr.substr(1);
                    linenum = Std.parseInt(linenumstr);
                }
                catch (e:system.SystemException)
                {
                    return throw new system.SystemException("Unpexected! {09F04A64-E5DE-4692-8784-1D0A493715D7} " + system.Cs2Hx.NullCheck(e.Message) + "\n" + system.Cs2Hx.NullCheck(line));
                }
            }
            if (num_colon >= 2)
            {
                try
                {
                    var argnumstr:String = RegexUtil.GetNthMatch(":\\d+", tmp_targetvalue, 2);
                    argnumstr = argnumstr.substr(1);
                    argnum = Std.parseInt(argnumstr);
                }
                catch (e:system.SystemException)
                {
                    return throw new system.SystemException("Unpexected! {68DE5327-ECE6-4241-A2E3-CF9F87C9F5F1} " + system.Cs2Hx.NullCheck(e.Message) + "\n" + system.Cs2Hx.NullCheck(line));
                }
            }
            macroname = name;
            if (system.Cs2Hx.StringContains(tmp_targetvalue, "->@"))
            {
                macroname = RegexUtil.Get1stMatch("->@.+?]", tmp_targetvalue);
                macroname = macroname.substr(3);
                macroname = macroname.substr(0, macroname.length - 1);
                if (argnum != -1)
                {
                    return throw new system.SystemException("Macro cannot use with argnument number. { 68DE5327 - ECE6 - 4241 - A2E3 - CF9F87C9F5F1 } \n" + system.Cs2Hx.NullCheck(line));
                }
                {
                    var s:String = tmp_targetvalue;
                    var idx:Int = s.indexOf("->@");
                    var newname:String = s.substr(0, idx);
                    name = system.Cs2Hx.TrimStart(newname, [ 91 ]);
                }
            }
            if (system.Cs2Hx.IsNullOrEmpty(name))
            {
                continue;
            }
            var val:String = getString2(tstate, name);
            if (!system.Cs2Hx.IsNullOrEmpty(val) && linenum >= 0)
            {
                var tmplines:Array<String> = StringUtil.SplitTrimEnd(val, StringUtil._0a.charCodeAt(0));
                val = linenum < tmplines.length ? tmplines[linenum] : "";
            }
            if (!system.Cs2Hx.IsNullOrEmpty(val) && argnum >= 0)
            {
                var args:Array<String> = StringUtil.SplittComma_And_ApiArges(val);
                val = argnum < args.length ? args[argnum] : "";
            }
            var replacevalue:String = val;
            var replacevalue3:String = get_line_macro_value(macroname, replacevalue);
            var tmplines2:Array<String> = StringUtil.ReplaceWordsInLine(line, targetvalue, replacevalue3);
            lines.splice(i, 1);
            system.Cs2Hx.InsertRange(lines, i, tmplines2);
            r.list = lines;
            return true;
        }
        r.list = lines;
        return false;
    }
    public function InsertOutputToFile(excel:String, targetfile:String, incdir:String):Void
    {
        if (BRKGS)
        {
            system.diagnostics.Debugger.Break();
        }
        INCDIR = incdir;
        TGTFILE = targetfile;
        var sm:InsertCodeControl = new InsertCodeControl();
        sm.G = this;
        sm.m_excel = excel;
        sm.m_filepath = targetfile;
        sm.MARK_START = MARK_START;
        sm.MARK_END = MARK_END;
        sm.Start();
        { //for
            var loop:Int = 0;
            while (loop < 10000)
            {
                if (sm.IsEnd())
                {
                    break;
                }
                sm.update();
                loop++;
            }
        } //end for
        return;
    }
    public function isExist(state:String, name:String):Bool
    {
        var v:String = getString2(state, name);
        return !Cs2Hx.IsNullOrWhiteSpace(v);
    }
    public function getCol(state:String):Int
    {
        var index:Int = system.Cs2Hx.IndexOf(state_list, state);
        if (index >= 0)
        {
            return state_col_list[index];
        }
        return -1;
    }
    public function getRow(name:String):Int
    {
        var index:Int = system.Cs2Hx.IndexOf(name_list, name);
        if (index >= 0)
        {
            return name_row_list[index];
        }
        return -1;
    }
    public function _getString(state:String, name:String):String
    {
        var col:Int = getCol(state);
        var row:Int = getRow(name);
        return getChartFunc(row, col);
    }
    public function getString2(state:String, name:String):String
    {
        var new_state:String = state;
        var loop:Int = -1;
        while (true)
        {
            loop++;
            if (loop >= 10)
            {
                break;
            }
            var val:String = _getString(new_state, name);
            if (system.Cs2Hx.IsNullOrEmpty(val))
            {
                var next_state:String = _getString(new_state, BASESTATE);
                if (system.Cs2Hx.IsNullOrEmpty(next_state))
                {
                    return val;
                }
                else
                {
                    new_state = next_state;
                    continue;
                }
            }
            return val;
        }
        return throw new system.SystemException("Unexpected! {A91F45A0-6C2D-42B9-A23D-B8A71F56F1A2}");
    }
    public function get_line_macro_value(macroname:String, s:String):String
    {
        if (system.Cs2Hx.IsNullOrEmpty(s))
        {
            return s;
        }
        var macrovalue:String = getMacroValueFunc("@" + system.Cs2Hx.NullCheck(macroname));
        if (system.Cs2Hx.IsNullOrEmpty(macrovalue))
        {
            return s;
        }
        var lines:Array<String> = StringUtil.SplitTrim(s, 10);
        var result:Array<String> = new Array<String>();
        var linenum:Int = 0;
        for (l in lines)
        {
            if (system.Cs2Hx.IsNullOrEmpty(l))
            {
                continue;
            }
            var args:Array<String> = StringUtil.SplittComma_And_ApiArges(l);
            var text:String = psggconverterlib.MacroWork.Convert(macrovalue, linenum, args, true);
            result.push(text);
            linenum++;
        }
        return StringUtil.LineToBuf(result, NEWLINECHAR);
    }
    public function new()
    {
    }
}
