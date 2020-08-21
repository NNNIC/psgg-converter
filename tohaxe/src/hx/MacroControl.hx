package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class MacroControl extends StateManager
{
    public function IsEnd():Bool
    {
        return CheckState(S_END);
    }
    public var G:psggconverterlib.Convert;
    public var m_bOkNg:Bool = false;
    public var m_bYesNo:Bool = false;
    public var m_bDone:Bool = false;
    public var m_state:String;
    public var m_lines:Array<String>;
    public var m_resultlines:Array<String>;
    var m_lineIndex:Int = 0;
    var m_line:String;
    var m_mw:psggconverterlib.MacroWork;
    public var m_bNeedCheckAgain:Bool = false;
    function lineloop_init():Void
    {
        m_resultlines = new Array<String>();
        m_lineIndex = 0;
    }
    function lineloop_check():Void
    {
        m_bOkNg = m_lineIndex < m_lines.length;
    }
    function lineloop_next():Void
    {
        m_lineIndex++;
    }
    function set_line():Void
    {
        m_line = m_lines[m_lineIndex];
        m_bNeedCheckAgain = false;
    }
    function check_macro():Void
    {
        if (m_mw == null)
        {
            m_mw = new psggconverterlib.MacroWork();
        }
        m_mw.Init();
        m_bYesNo = m_mw.CheckMacro(m_line);
    }
    function set_checkagain():Void
    {
        m_bNeedCheckAgain = true;
    }
    function do_if_include():Void
    {
        m_bDone = false;
        if (m_mw.IsInclude())
        {
            var matchstr:String = m_mw.GetMatchStr();
            var file:String = m_mw.GetIncludFilename();
            var enc:String = m_mw.GetIncludeFileEnc();
            var text:String = IncludeFile.readfile(G, matchstr, file, enc);
            m_resultlines.push(G.GetComment(" #start include -" + system.Cs2Hx.NullCheck(file)));
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, matchstr, text);
            system.Cs2Hx.AddRange(m_resultlines, tmplines);
            m_resultlines.push(G.GetComment(" #end include -" + system.Cs2Hx.NullCheck(file)));
            m_bDone = true;
        }
    }
    function do_if_prefix():Void
    {
        m_bDone = false;
        if (m_mw.IsPrefix())
        {
            var matchstr:String = m_mw.GetMatchStr();
            var text:String = G.PREFIX;
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, matchstr, text);
            system.Cs2Hx.AddRange(m_resultlines, tmplines);
            m_bDone = true;
        }
    }
    function do_if_statemachine():Void
    {
        m_bDone = false;
        if (m_mw.IsStatemachine())
        {
            var matchstr:String = m_mw.GetMatchStr();
            var text:String = G.STATEMACHINE;
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, matchstr, text);
            system.Cs2Hx.AddRange(m_resultlines, tmplines);
            m_bDone = true;
        }
        else if (m_mw.Is_state_machine())
        {
            var matchstr:String = m_mw.GetMatchStr();
            var text:String = StringUtil.convert_to_snake_word_and_lower(G.STATEMACHINE);
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, matchstr, text);
            system.Cs2Hx.AddRange(m_resultlines, tmplines);
            m_bDone = true;
        }
        else if (m_mw.Is_stateMachine())
        {
            var matchstr:String = m_mw.GetMatchStr();
            var text:String = StringUtil.convert_to_camel_word(G.STATEMACHINE, false);
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, matchstr, text);
            system.Cs2Hx.AddRange(m_resultlines, tmplines);
            m_bDone = true;
        }
        else if (m_mw.Is_StateMachine())
        {
            var matchstr:String = m_mw.GetMatchStr();
            var text:String = StringUtil.convert_to_camel_word(G.STATEMACHINE, true);
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, matchstr, text);
            system.Cs2Hx.AddRange(m_resultlines, tmplines);
            m_bDone = true;
        }
    }
    function do_macro():Void
    {
        var matchstr:String = m_mw.GetMatchStr();
        var text:String = "";
        var macroname:String = m_mw.GetMacroname();
        if (system.Cs2Hx.IsNullOrEmpty(macroname))
        {
            text = "(error: macroname is null)";
        }
        else
        {
            text = G.getMacroValueFunc(macroname);
            if (system.Cs2Hx.IsNullOrEmpty(text))
            {
                text = "(error: no value for " + system.Cs2Hx.NullCheck(macroname) + " )";
            }
            else
            {
                text = psggconverterlib.MacroWork.Convert(text, 0, m_mw.GetArgValueList());
            }
        }
        var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, matchstr, text);
        system.Cs2Hx.AddRange(m_resultlines, tmplines);
    }
    function add_restlines():Void
    {
        { //for
            var index:Int = m_lineIndex + 1;
            while (index < m_lines.length)
            {
                var line:String = m_lines[index];
                m_resultlines.push(line);
                index++;
            }
        } //end for
    }
    function add_line():Void
    {
        m_resultlines.push(m_line);
    }
    function br_OK(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (m_bOkNg)
            {
                SetNextState(st);
            }
        }
    }
    function br_NG(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (!m_bOkNg)
            {
                SetNextState(st);
            }
        }
    }
    function br_YES(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (m_bYesNo)
            {
                SetNextState(st);
            }
        }
    }
    function br_NO(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (!m_bYesNo)
            {
                SetNextState(st);
            }
        }
    }
    function br_Done(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (m_bDone)
            {
                SetNextState(st);
            }
        }
    }
    function br_NotAbove(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            SetNextState(st);
        }
    }
    public function Start():Void
    {
        Goto(S_START);
    }
    function S_ADDLINE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            add_line();
        }
        if (!HasNextState())
        {
            SetNextState(S_LINELOOP_NEXT);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_ADDRESTLINES(bFirst:Bool):Void
    {
        if (bFirst)
        {
            add_restlines();
        }
        if (!HasNextState())
        {
            SetNextState(S_END);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_CHECKMACRO(bFirst:Bool):Void
    {
        if (bFirst)
        {
            check_macro();
        }
        br_YES(S_SET_CHECKAGAIN);
        br_NO(S_ADDLINE);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_DO_INCLUDE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            do_if_include();
        }
        br_Done(S_ADDRESTLINES);
        br_NotAbove(S_DO_MACRO);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_DO_MACRO(bFirst:Bool):Void
    {
        if (bFirst)
        {
            do_macro();
        }
        if (!HasNextState())
        {
            SetNextState(S_ADDRESTLINES);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_DO_PREFIX(bFirst:Bool):Void
    {
        if (bFirst)
        {
            do_if_prefix();
        }
        br_Done(S_ADDRESTLINES);
        br_NotAbove(S_DO_STATEMACHINE);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_DO_STATEMACHINE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            do_if_statemachine();
        }
        br_Done(S_ADDRESTLINES);
        br_NotAbove(S_DO_INCLUDE);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_END(bFirst:Bool):Void
    {
        if (bFirst)
        {
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_LINELOOP_CHECK(bFirst:Bool):Void
    {
        if (bFirst)
        {
            lineloop_check();
        }
        br_OK(S_SET_LINE);
        br_NG(S_END);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_LINELOOP_INIT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            lineloop_init();
        }
        if (!HasNextState())
        {
            SetNextState(S_LINELOOP_CHECK);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_LINELOOP_NEXT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            lineloop_next();
        }
        if (!HasNextState())
        {
            SetNextState(S_LINELOOP_CHECK);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SET_CHECKAGAIN(bFirst:Bool):Void
    {
        if (bFirst)
        {
            set_checkagain();
        }
        if (!HasNextState())
        {
            SetNextState(S_DO_PREFIX);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SET_LINE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            set_line();
        }
        if (!HasNextState())
        {
            SetNextState(S_CHECKMACRO);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_START(bFirst:Bool):Void
    {
        if (bFirst)
        {
        }
        if (!HasNextState())
        {
            SetNextState(S_LINELOOP_INIT);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    public function new()
    {
        super();
    }
}
