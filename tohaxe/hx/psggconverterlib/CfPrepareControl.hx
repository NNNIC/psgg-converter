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
            var s