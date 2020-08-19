package psggconverterlib;
using StringTools;
import system.*;
import anonymoustypes.*;

class CfPrepareControl
{
    var m_curfunc:(Bool -> Void);
    var m_nextfunc:(Bool -> Void);
    var m_noWait:Bool = false;
    public function Update():Void
    {
        while (true)
        {
            var bFirst:Bool = false;
            if (m_nextfunc != null)
            {
                m_curfunc = m_nextfunc;
                m_nextfunc = null;
                bFirst = true;
            }
            m_noWait = false;
            if (m_curfunc != null)
            {
                m_curfunc(bFirst);
            }
            if (!m_noWait)
            {
                break;
            }
        }
    }
    function Goto(func:(Bool -> Void)):Void
    {
        m_nextfunc = func;
    }
    function CheckState(func:(Bool -> Void)):Bool
    {
        return m_curfunc == func;
    }
    function HasNextState():Bool
    {
        return m_nextfunc != null;
    }
    function NoWait():Void
    {
        m_noWait = true;
    }
    var m_callstack:Array<(Bool -> Void)> = new Array<(Bool -> Void)>();
    function GoSubState(nextstate:(Bool -> Void), returnstate:(Bool -> Void)):Void
    {
        m_callstack.insert(0, returnstate);
        Goto(nextstate);
    }
    function ReturnState():Void
    {
        var nextstate:(Bool -> Void) = m_callstack[0];
        m_callstack.splice(0, 1);
        Goto(nextstate);
    }
    public function Start():Void
    {
        Goto(S_START);
    }
    public function IsEnd():Bool
    {
        return CheckState(S_END);
    }
    public function Run():Void
    {
        var LOOPMAX:Int = Std.int(1E+5);
        Start();
        { //for
            var loop:Int = 0;
            while (loop <= LOOPMAX)
            {
                if (loop >= LOOPMAX)
                {
                    throw new system.SystemException("Unexpected.");
                }
                if (IsEnd())
                {
                    break;
                }
                Update();
                loop++;
            }
        } //end for
    }
    var m_findindex:Int = 0;
    var m_targetlines:Array<String> = null;
    var m_line0:String;
    var m_bValid:Bool = false;
    var m_itemname:String;
    var m_regex:String;
    var m_val:String;
    var m_target:String;
    public var m_state:String;
    public var m_lines:Array<String>;
    public var m_bResult:Bool = false;
    public var m_parent:psggconverterlib.Convert;
    var m_newway:Bool = true;
    function S_CHECK_BOT(bFirst:Bool):Void
    {
        var c:Int = m_target.charCodeAt(0);
        if (c == 34)
        {
            Goto(S_STR_W_REGEX);
        }
        else
        {
            Goto(S_ITEM_W_REGEX);
        }
    }
    function S_CHECK_BOT1(bFirst:Bool):Void
    {
        var c:Int = m_target.charCodeAt(0);
        if (c == 34)
        {
            Goto(S_STR_W_REGEX1);
        }
        else
        {
            Goto(S_ITEM_W_REGEX1);
        }
    }
    var m_bEOF:Bool = false;
    function S_CHECK_EOF(bFirst:Bool):Void
    {
        m_bEOF = (system.Cs2Hx.StringContains(m_targetlines[m_targetlines.length - 1].toLowerCase(), "eof>>>"));
        if (!HasNextState())
        {
            Goto(S_REMOVE_TOPBOT);
        }
    }
    function S_CHECK_EQSTR(bFirst:Bool):Void
    {
        if (m_eqstr != null)
        {
            Goto(S_COMPARE_EQSTR);
        }
        else
        {
            Goto(S_CHECK_ESTR);
        }
    }
    var m_eqstr:String;
    var m_exstr:String;
    function S_CHECK_EQUALS(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_exstr = null;
            var s:String = RegexUtil.Get1stMatch("==\\x22[^\\x22]*?\\x22$", m_target);
            if (!system.Cs2Hx.IsNullOrEmpty(s))
            {
                m_eqstr = system.Cs2Hx.Trim_(s.substr(2), [ 34 ]);
                m_target = m_target.substr(0, m_target.length - s.length);
            }
        }
        if (!HasNextState())
        {
            Goto(S_CHECK_BOT1);
        }
    }
    function S_CHECK_ESTR(bFirst:Bool):Void
    {
        var bOk:Bool = !system.Cs2Hx.IsNullOrEmpty(m_exstr);
        if (bOk)
        {
            Goto(S_GET_SIZE);
        }
        else
        {
            Goto(S_REMOVE);
        }
    }
    function S_CHECK_EXCEPTION(bFirst:Bool):Void
    {
        if (bFirst)
        {
            if (m_targetlines.length < 2)
            {
                throw new system.SystemException("Unexpected! {A6446D1F-DFD0-4A63-93C7-299265119AC7}");
            }
        }
        if (!HasNextState())
        {
            Goto(S_INIT2);
        }
    }
    function S_CHECK_LINES(bFirst:Bool):Void
    {
        if (m_lines == null)
        {
            Goto(S_RETURN_FALSE);
        }
        else
        {
            Goto(S_FIND_MATCHLINES);
        }
    }
    function S_CHECK_VALID_VAL(bFirst:Bool):Void
    {
        m_bValid = !system.Cs2Hx.IsNullOrEmpty(m_val);
        if (m_bValid)
        {
            Goto(S_IS_VALID_REGEX);
        }
        else
        {
            Goto(S_REMOVE);
        }
    }
    function S_COMPARE_EQSTR(bFirst:Bool):Void
    {
        var bEq:Bool = false;
        if (bFirst)
        {
            if (system.Cs2Hx.IsNullOrEmpty(m_exstr) && system.Cs2Hx.IsNullOrEmpty(m_eqstr))
            {
                bEq = true;
            }
            else if (m_exstr == m_eqstr)
            {
                bEq = true;
            }
        }
        if (bEq)
        {
            Goto(S_GET_SIZE);
        }
        else
        {
            Goto(S_REMOVE);
        }
    }
    function S_END(bFirst:Bool):Void
    {
    }
    function S_EXEC_REGEX(bFirst:Bool):Void
    {
        if (bFirst)
        {
            if (m_regex.charCodeAt(0) == 47 && m_regex.charCodeAt(m_regex.length - 1) == 47)
            {
                m_regex = m_regex.substr(1);
                m_regex = m_regex.substr(0, m_regex.length - 1);
                var match:String = RegexUtil.Get1stMatch(m_regex, m_val);
                m_bValid = !system.Cs2Hx.IsNullOrEmpty(match);
            }
            else
            {
                m_bValid = false;
                throw new system.SystemException("{59858294-6BCF-45B6-B441-076A5A6041D8}\n" + system.Cs2Hx.NullCheck(m_line0));
            }
        }
        if (m_bValid)
        {
            Goto(S_GET_SIZE);
        }
        else
        {
            Goto(S_REMOVE);
        }
    }
    function S_EXTRUCT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            if (system.Cs2Hx.IsNullOrEmpty(m_regex) || system.Cs2Hx.IsNullOrEmpty(m_val))
            {
                m_exstr = m_val;
            }
            else
            {
                m_exstr = RegexUtil.Get1stMatch(m_regex, m_val);
            }
        }
        if (!HasNextState())
        {
            Goto(S_CHECK_EQSTR);
        }
    }
    function S_FIND_MATCHLINES(bFirst:Bool):Void
    {
        if (bFirst)
        {
            var findindex:CsRef<Int> = new CsRef<Int>(-1);
            m_targetlines = StringUtil.FindMatchedLines2(m_lines, "\x3c\x3c\x3c\x3f", "\x3e\x3e\x3e", findindex);
            m_findindex = findindex.Value;
        }
        if (m_targetlines == null)
        {
            Goto(S_RETURN_FALSE);
        }
        else
        {
            Goto(S_CHECK_EXCEPTION);
        }
    }
    var m_size:Int = 0;
    function S_GET_SIZE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_size = m_targetlines.length;
        }
        if (!HasNextState())
        {
            Goto(S_CHECK_EOF);
        }
    }
    function S_GOTO_FALSE(bFirst:Bool):Void
    {
        if (!HasNextState())
        {
            Goto(S_RETURN_FALSE);
        }
    }
    function S_IF_EOF(bFirst:Bool):Void
    {
        if (m_bEOF)
        {
            Goto(S_REMOVE_REST);
        }
        else
        {
            Goto(S_REPLACE);
        }
    }
    function S_INIT2(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_line0 = m_targetlines[0];
            m_bValid = false;
            m_itemname = "";
            m_val = "";
            m_regex = "";
        }
        if (!HasNextState())
        {
            Goto(S_TARGET);
        }
    }
    function S_IS_VALID_REGEX(bFirst:Bool):Void
    {
        var b:Bool = !system.Cs2Hx.IsNullOrEmpty(m_regex) && m_regex.length > 2;
        if (b)
        {
            Goto(S_EXEC_REGEX);
        }
        else
        {
            Goto(S_REMOVE);
        }
    }
    function S_ITEM_W_REGEX(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_itemname = RegexUtil.Get1stMatch("[0-9a-zA-Z_\\-]+", m_target);
            m_regex = m_target.substr(m_itemname.length);
            m_val = m_parent.getString2(m_state, m_itemname);
        }
        if (!HasNextState())
        {
            Goto(S_CHECK_VALID_VAL);
        }
    }
    function S_ITEM_W_REGEX1(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_itemname = RegexUtil.Get1stMatch("[0-9a-zA-Z_\\-]+", m_target);
            m_regex = m_target.substr(m_itemname.length);
            m_val = m_parent.getString2(m_state, m_itemname);
        }
        if (!HasNextState())
        {
            Goto(S_NORMALIZE_REGEX);
        }
    }
    function S_NORMALIZE_REGEX(bFirst:Bool):Void
    {
        var bOk:Bool = false;
        if (bFirst)
        {
            if (system.Cs2Hx.IsNullOrEmpty(m_regex))
            {
                bOk = true;
            }
            else if (m_regex.length > 2)
            {
                if (m_regex.charCodeAt(0) == 47 && m_regex.charCodeAt(m_regex.length - 1) == 47)
                {
                    m_regex = m_regex.substr(1);
                    m_regex = m_regex.substr(0, m_regex.length - 1);
                    bOk = true;
                }
            }
        }
        if (bOk)
        {
            Goto(S_EXTRUCT);
        }
        else
        {
            Goto(S_GOTO_FALSE);
        }
    }
    function S_REMOVE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_lines.splice(m_findindex, m_targetlines.length);
        }
        if (!HasNextState())
        {
            Goto(S_RETURN_TRUE);
        }
    }
    function S_REMOVE_REST(bFirst:Bool):Void
    {
        if (bFirst)
        {
            while (m_lines.length > m_findindex + 1)
            {
                m_lines.splice(m_lines.length - 1, 1);
            }
            m_size = 1;
        }
        if (!HasNextState())
        {
            Goto(S_REPLACE);
        }
    }
    function S_REMOVE_TOPBOT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_targetlines.splice(0, 1);
            m_targetlines.splice(m_targetlines.length - 1, 1);
        }
        if (!HasNextState())
        {
            Goto(S_IF_EOF);
        }
    }
    function S_REPLACE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_lines = StringUtil.ReplaceLines(m_lines, m_findindex, m_size, m_targetlines);
        }
        if (!HasNextState())
        {
            Goto(S_RETURN_TRUE);
        }
    }
    function S_RETURN_FALSE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_bResult = false;
        }
        if (!HasNextState())
        {
            Goto(S_END);
        }
    }
    function S_RETURN_TRUE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_bResult = true;
        }
        if (!HasNextState())
        {
            Goto(S_END);
        }
    }
    function S_START(bFirst:Bool):Void
    {
        if (!HasNextState())
        {
            Goto(S_CHECK_LINES);
        }
    }
    function S_STR_W_REGEX(bFirst:Bool):Void
    {
        if (bFirst)
        {
            var dqw:String = RegexUtil.Get1stMatch("\\x22.*\\x22", m_target);
            m_val = system.Cs2Hx.Trim_(dqw, [ 34 ]);
            m_regex = m_target.substr(dqw.length);
        }
        if (!HasNextState())
        {
            Goto(S_CHECK_VALID_VAL);
        }
    }
    function S_STR_W_REGEX1(bFirst:Bool):Void
    {
        if (bFirst)
        {
            var dqw:String = RegexUtil.Get1stMatch("\\x22.*\\x22", m_target);
            m_val = system.Cs2Hx.Trim_(dqw, [ 34 ]);
            m_regex = m_target.substr(dqw.length);
        }
        if (!HasNextState())
        {
            Goto(S_NORMALIZE_REGEX);
        }
    }
    function S_TARGET(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_target = RegexUtil.Get1stMatch("\\<\\<\\<\\?.+\\s*$", m_line0);
            m_target = system.Cs2Hx.Trim(m_target.substr(4));
        }
        if (!HasNextState())
        {
            Goto(S_USE_NEWWAY);
        }
    }
    function S_USE_NEWWAY(bFirst:Bool):Void
    {
        if (m_newway)
        {
            Goto(S_CHECK_EQUALS);
        }
        else
        {
            Goto(S_CHECK_BOT);
        }
    }
    public function new()
    {
    }
}
