package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class FunctionControl extends StateManager
{
    public var G:psggconverterlib.Convert;
    public var m_state:String;
    public function IsEnd():Bool
    {
        return CheckState(S_END);
    }
    public var m_error:String = "";
    var m_OkNG:Bool = false;
    var m_needAgain:Bool = false;
    public var m_result_src:String = null;
    public var m_macro_buf:String = null;
    public var m_useMacroOrTemplate:Bool = false;
    var m_buf:String = "";
    var m_lines:Array<String> = null;
    var m_loopIndex:Int = 0;
    static inline var m_loopMax:Int = 10000;
    function set_buf():Void
    {
        m_buf = G.template_func;
    }
    function set_macrobuf():Void
    {
        m_buf = m_macro_buf;
    }
    function split_buf():Void
    {
        var newlinechar:String = StringUtil.FindNewLineChar(m_buf);
        if (newlinechar != null)
        {
            m_lines = StringUtil.SplitTrimEnd(m_buf, 10);
            m_OkNG = true;
        }
        else if (!system.Cs2Hx.IsNullOrEmpty(m_buf))
        {
            m_lines = new Array<String>();
            m_lines.push(m_buf);
            m_OkNG = true;
        }
        else
        {
            m_error = "buffer not found! {E1BB5578-E9E5-4C46-ABE9-4152D3A1AB1C}";
            m_OkNG = false;
        }
    }
    function loop_init():Void
    {
        m_loopIndex = 0;
    }
    function loop_check():Void
    {
        m_OkNG = m_loopIndex < m_loopMax;
        if (!m_OkNG)
        {
            m_error = "Loop reached max number! {7C91FBD1-C711-488F-983E-EC0E4008D69D}";
        }
    }
    function preprocess():Void
    {
        m_OkNG = true;
        try
        {
            var r:RefListString = new RefListString();
            r.list = m_lines;
            m_needAgain = G.createFunc_prepare(m_state, r);
        }
        catch (e:system.SystemException)
        {
            m_error = e.Message;
            m_OkNG = false;
        }
    }
    function set_value():Void
    {
        m_OkNG = true;
        try
        {
            var r:RefListString = new RefListString();
            r.list = m_lines;
            m_needAgain = G.createFunc_work(m_state, r);
        }
        catch (e:system.SystemException)
        {
            m_error = e.Message;
            m_OkNG = false;
        }
    }
    function convert_macro():Void
    {
        m_OkNG = true;
        var sm:MacroControl = new MacroControl();
        sm.G = G;
        sm.m_state = m_state;
        sm.m_lines = m_lines;
        sm.Start();
        { //for
            var loop:Int = 0;
            while (loop <= 10000)
            {
                if (loop == 10000)
                {
                    throw new system.SystemException("Unexpected! {8C70F7D9-7E73-4E1C-BF94-320DA272DF02}");
                }
                sm.update();
                if (sm.IsEnd())
                {
                    break;
                }
                loop++;
            }
        } //end for
        m_needAgain = sm.m_bNeedCheckAgain;
        m_lines = sm.m_resultlines;
    }
    function postprocess():Void
    {
        m_lines = StringUtil.CutEmptyLines_ListString(m_lines);
        m_result_src = StringUtil.LineToBuf(m_lines, G.NEWLINECHAR);
    }
    function br_OK(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (m_OkNG)
            {
                SetNextState(st);
            }
        }
    }
    function br_NG(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (!m_OkNG)
            {
                SetNextState(st);
            }
        }
    }
    function br_NeedAgain(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (m_needAgain)
            {
                SetNextState(st);
            }
        }
    }
    function br_USE_TEMPFUNC(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (!m_useMacroOrTemplate)
            {
                SetNextState(st);
            }
        }
    }
    function br_USE_MACROBUF(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (m_useMacroOrTemplate)
            {
                SetNextState(st);
            }
        }
    }
    public function Start():Void
    {
        Goto(S_START);
    }
    function S_CVTMACRO(bFirst:Bool):Void
    {
        if (bFirst)
        {
            convert_macro();
        }
        br_NeedAgain(S_LOOPNEXT);
        br_OK(S_POSTPROC);
        br_NG(S_END);
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
    function S_LOOP_INIT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            loop_init();
        }
        if (!HasNextState())
        {
            SetNextState(S_LOOPCHECK);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_LOOPCHECK(bFirst:Bool):Void
    {
        if (bFirst)
        {
            loop_check();
        }
        br_OK(S_PREPROC);
        br_NG(S_END);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_LOOPNEXT(bFirst:Bool):Void
    {
        if (bFirst)
        {
        }
        if (!HasNextState())
        {
            SetNextState(S_LOOPCHECK);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_POSTPROC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            postprocess();
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
    function S_PREPROC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            preprocess();
        }
        br_NeedAgain(S_LOOPNEXT);
        br_OK(S_SETVALUE);
        br_NG(S_END);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SETBUF(bFirst:Bool):Void
    {
        if (bFirst)
        {
            set_buf();
        }
        if (!HasNextState())
        {
            SetNextState(S_SPLITBUF);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SETMACROBUF(bFirst:Bool):Void
    {
        if (bFirst)
        {
            set_macrobuf();
        }
        if (!HasNextState())
        {
            SetNextState(S_SPLITBUF);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SETVALUE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            set_value();
        }
        br_NeedAgain(S_LOOPNEXT);
        br_OK(S_CVTMACRO);
        br_NG(S_END);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SPLITBUF(bFirst:Bool):Void
    {
        if (bFirst)
        {
            split_buf();
        }
        br_OK(S_LOOP_INIT);
        br_NG(S_END);
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
        br_USE_TEMPFUNC(S_SETBUF);
        br_USE_MACROBUF(S_SETMACROBUF);
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
