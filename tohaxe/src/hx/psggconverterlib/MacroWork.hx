package psggconverterlib;
using StringTools;
import system.*;
import anonymoustypes.*;

class MacroWork
{
    public static inline var m_includepattern:String = "\\$include:.+?\\$";
    public static inline var m_macropattern:String = "\\$macro:.+?\\$";
    public static inline var m_argpattern:String = "\\{%(~{0,1})\\d+\\}";
    public static inline var m_numpattern:String = "\\{%[Nn]\\}";
    public var m_prefixpattern:String = "\\$prefix\\$";
    public var m_statemachinepattern:String = "\\$statemachine\\$";
    public var m_state_machinepattern:String = "\\$state_machine\\$";
    public var m_stateMachinePattern:String = "\\$stateMachine\\$";
    public var m_StateMachinePattern:String = "\\$StateMachine\\$";
    public var m_error:String;
    var m_bValid:Bool = false;
    var m_bInclude:Bool = false;
    var m_bPrefix:Bool = false;
    var m_bStatemachine:Bool = false;
    var m_b_state_machine:Bool = false;
    var m_b_stateMachine:Bool = false;
    var m_b_StateMachine:Bool = false;
    var m_matchstr:String;
    var m_filename:String;
    var m_fileenc:String;
    var m_macrovalue:String;
    var m_api:String;
    var m_args:Array<String>;
    public function Init():Void
    {
        m_error = null;
        m_bValid = false;
        m_bInclude = false;
        m_bPrefix = false;
        m_matchstr = null;
        m_filename = null;
        m_fileenc = null;
        m_macrovalue = null;
        m_api = null;
        m_args = null;
    }
    public function CheckMacro(buf:String):Bool
    {
        var match:String = RegexUtil.Get1stMatch(m_includepattern, buf);
        if (!system.Cs2Hx.IsNullOrEmpty(match))
        {
            m_bValid = true;
            m_bInclude = true;
            m_matchstr = match;
            analyze_include();
        }
        if (!m_bValid)
        {
            match = RegexUtil.Get1stMatch(m_prefixpattern, buf);
            if (!system.Cs2Hx.IsNullOrEmpty(match))
            {
                m_bValid = true;
                m_bPrefix = true;
                m_matchstr = match;
            }
        }
        if (!m_bValid)
        {
            match = RegexUtil.Get1stMatch(m_statemachinepattern, buf);
            if (!system.Cs2Hx.IsNullOrEmpty(match))
            {
                m_bValid = true;
                m_bStatemachine = true;
                m_matchstr = match;
            }
        }
        if (!m_bValid)
        {
            match = RegexUtil.Get1stMatch(m_state_machinepattern, buf);
            if (!system.Cs2Hx.IsNullOrEmpty(match))
            {
                m_bValid = true;
                m_b_state_machine = true;
                m_matchstr = match;
            }
        }
        if (!m_bValid)
        {
            match = RegexUtil.Get1stMatch(m_stateMachinePattern, buf);
            if (!system.Cs2Hx.IsNullOrEmpty(match))
            {
                m_bValid = true;
                m_b_stateMachine = true;
                m_matchstr = match;
            }
        }
        if (!m_bValid)
        {
            match = RegexUtil.Get1stMatch(m_StateMachinePattern, buf);
            if (!system.Cs2Hx.IsNullOrEmpty(match))
            {
                m_bValid = true;
                m_b_StateMachine = true;
                m_matchstr = match;
            }
        }
        if (!m_bValid)
        {
            match = RegexUtil.Get1stMatch(m_macropattern, buf);
            if (!system.Cs2Hx.IsNullOrEmpty(match))
            {
                m_bValid = true;
                m_bInclude = false;
                m_matchstr = match;
                analyze_macro();
            }
        }
        return m_bValid;
    }
    function analyze_include():Void
    {
        var str:String = system.Cs2Hx.TrimEnd(m_matchstr.substr(9), [ 36 ]);
        if (system.Cs2Hx.Contains(Cs2Hx.ToCharArray(str), 44))
        {
            var tokens:Array<String> = system.Cs2Hx.Split(str, [ 44 ]);
            if (tokens != null && tokens.length >= 2)
            {
                m_filename = tokens[0];
                m_fileenc = tokens[1];
            }
            else
            {
                throw new system.SystemException("Unexpected! {A496CE7C-9F74-4D7A-A105-B9B469A349D0}");
            }
        }
        else
        {
            m_filename = str;
        }
    }
    function analyze_macro():Void
    {
        m_macrovalue = system.Cs2Hx.TrimEnd(m_matchstr.substr(7), [ 36 ]);
        var api:CsRef<String> = new CsRef<String>(null);
        var args:CsRef<Array<String>> = new CsRef<Array<String>>(null);
        var error:CsRef<String> = new CsRef<String>(null);
        StringUtil.SplitApiArges(m_macrovalue, api, args, error);
        m_api = api.Value;
        if (args.Value == null)
        {
            args.Value = new Array<String>();
        }
        if (args.Value != null)
        {
            args.Value.insert(0, api.Value);
        }
        m_args = args.Value;
        m_error = error.Value;
    }
    public function IsValid():Bool
    {
        return m_bValid;
    }
    public function IsPrefix():Bool
    {
        return m_bPrefix;
    }
    public function IsStatemachine():Bool
    {
        return m_bStatemachine;
    }
    public function Is_state_machine():Bool
    {
        return m_b_state_machine;
    }
    public function Is_stateMachine():Bool
    {
        return m_b_stateMachine;
    }
    public function Is_StateMachine():Bool
    {
        return m_b_StateMachine;
    }
    public function IsInclude():Bool
    {
        return m_bInclude;
    }
    public function GetIncludFilename():String
    {
        return m_filename;
    }
    public function GetIncludeFileEnc():String
    {
        return m_fileenc;
    }
    public function GetMatchStr():String
    {
        return m_matchstr;
    }
    public function GetMacroname():String
    {
        return m_api;
    }
    public function GetArgValueList():Array<String>
    {
        return m_args;
    }
    public static function GetArgValue(argstr:String, args:Array<String>, bAcceptNullArg:Bool = false):String
    {
        if (args == null)
        {
            return "<!!" + system.Cs2Hx.NullCheck(system.Cs2Hx.Trim_(argstr.replace("{%", "//"), [ 60, 62 ])) + "(error:no args in macro)!!>";
        }
        if (!RegexUtil.IsMatch(m_argpattern, argstr))
        {
            return throw new system.SystemException("Unexpected! {0A4A6F44-838E-44D4-8CCA-873C26573E6B}");
        }
        var numstr:String = RegexUtil.Get1stMatch("\\d+", argstr);
        var num:Int = Std.parseInt(numstr);
        var bDqOff:Bool = system.Cs2Hx.StringContains(argstr, "~");
        var v:String = "";
        if (bAcceptNullArg)
        {
            if (num < args.length)
            {
                v = args[num];
            }
        }
        else
        {
            if (num >= args.length)
            {
                return "<!!" + system.Cs2Hx.NullCheck(system.Cs2Hx.Trim_(argstr.replace("{%", "//"), [ 60, 62 ])) + "(error: arg num is grater than args count)!!>";
            }
            v = args[num];
        }
        if (bDqOff)
        {
            v = system.Cs2Hx.Trim_(v, [ 34 ]);
        }
        if (!bAcceptNullArg && system.Cs2Hx.IsNullOrEmpty(v))
        {
            v = "<!!" + system.Cs2Hx.NullCheck(system.Cs2Hx.Trim_(argstr.replace("{%", "//"), [ 60, 62 ])) + "(error: arg is null)!!>";
        }
        return v;
    }
    public static function Convert(text:String, num:Int, args:Array<String>, bAcceptNullArg:Bool = false):String
    {
        var src:String = text;
        var loop:Int = -1;
        while (true)
        {
            loop++;
            if (loop == 100)
            {
                return throw new system.SystemException("Unexpected! {710FA2E8-7740-43F9-8A26-703AF71085C6}\n" + system.Cs2Hx.NullCheck(src) + " #" + Std.string(num));
            }
            var match:String = RegexUtil.Get1stMatch(m_argpattern, src);
            if (!system.Cs2Hx.IsNullOrEmpty(match))
            {
                var val:String = GetArgValue(match, args, bAcceptNullArg);
                src = src.replace(match, val);
                continue;
            }
            match = RegexUtil.Get1stMatch(m_numpattern, src);
            if (!system.Cs2Hx.IsNullOrEmpty(match))
            {
                var val:String = Std.string(num);
                src = src.replace(match, val);
                continue;
            }
            break;
        }
        return src;
    }
    public static function Convert_String_String_String_String(text:String, arg0:String, arg1:String = null, arg2:String = null):String
    {
        if (system.Cs2Hx.IsNullOrEmpty(arg0))
        {
            return "(error: arg0 is null {2145EA6E-3B45-47FC-B9FD-B82F56E47D89})";
        }
        var args:Array<String> = new Array<String>();
        args.push(arg0);
        if (arg1 != null)
        {
            args.push(arg1);
        }
        if (arg2 != null)
        {
            args.push(arg2);
        }
        return Convert(text, 0, args);
    }
    public function new()
    {
    }
}
