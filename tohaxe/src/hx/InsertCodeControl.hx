package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class InsertCodeControl extends StateManager
{
    public var G:psggconverterlib.Convert;
    public var m_excel:String;
    function read_file():Void
    {
        try
        {
            m_enc = system.text.Encoding.UTF8;
            if (!system.Cs2Hx.IsNullOrEmpty(G.ENC))
            {
                try
                {
                    m_enc = psgg.HxEncoding.GetEncoding_String(G.ENC);
                }
                catch (e:system.SystemException)
                {
                    m_error = "Error Encoding :" + system.Cs2Hx.NullCheck(e.Message);
                    m_enc = system.text.Encoding.UTF8;
                }
            }
            if (m_enc == system.text.Encoding.UTF8)
            {
                var bom:Bool = false;
                var bytes:haxe.io.Bytes = system.io.File.ReadAllBytes(m_filepath);
                if (bytes.length > 3)
                {
                    if ((bytes.get(0) == 0xef) && (bytes.get(1) == 0xbb) && (bytes.get(2) == 0xbf))
                    {
                        bom = true;
                    }
                }
                m_enc = new psgg.HxUTF8Encoding(bom);
            }
            m_src = psgg.HxFile.ReadAllText_String_Encoding(m_filepath, m_enc);
            m_bl = StringUtil.FindNewLineChar(m_src);
            m_lines = StringUtil.SplitTrimKeepSpace(m_src, m_bl.charCodeAt(0));
        }
        catch (e:system.SystemException)
        {
            m_error = "error read_file. " + system.Cs2Hx.NullCheck(e.Message);
        }
    }
    function find_start_mark():Int
    {
        { //for
            var index:Int = m_cur;
            while (index < m_lines.length)
            {
                var l:String = m_lines[index];
                if (l != null && system.Cs2Hx.StringContains(l, MARK_START))
                {
                    m_cur = index;
                    return index;
                }
                index++;
            }
        } //end for
        return -1;
    }
    function find_end_mark():Int
    {
        { //for
            var index:Int = m_cur;
            while (index < m_lines.length)
            {
                var l:String = m_lines[index];
                if (l != null && system.Cs2Hx.StringContains(l, MARK_END))
                {
                    return index;
                }
                index++;
            }
        } //end for
        return -1;
    }
    function get_param(s:String):Void
    {
        var markindex:Int = s.indexOf(MARK_START);
        var ns:String = s.substr(markindex + MARK_START.length);
        var indentstr:String = RegexUtil.Get1stMatch("indent\\(\\d+\\)", ns);
        if (!system.Cs2Hx.IsNullOrEmpty(indentstr))
        {
            var numstr:String = RegexUtil.Get1stMatch("\\d+", indentstr);
            m_indent = Std.parseInt(numstr);
            ns = ns.replace(indentstr, "");
        }
        m_command = RegexUtil.Get1stMatch("\\$.+\\$\\s*$", ns);
        if (system.Cs2Hx.IsNullOrEmpty(m_command))
        {
            m_error = "Cannot find command : " + system.Cs2Hx.NullCheck(s);
        }
    }
    function convert(indent:Int, command:String):String
    {
        var buf:String = indent > 0 ? Cs2Hx.NewString(32, indent) : "";
        buf += command;
        var output:String = G.generate_for_inserting_src(m_excel, buf, indent);
        return output;
    }
    function insert_output():Void
    {
        var tmp:Array<String> = new Array<String>();
        { //for
            var i:Int = 0;
            while (i <= m_mark_start)
            {
                tmp.push(m_lines[i]);
                i++;
            }
        } //end for
        {
            var outlines:Array<String> = StringUtil.SplitTrimKeepSpace(m_output, m_bl.charCodeAt(0));
            system.Cs2Hx.AddRange(tmp, outlines);
        }
        { //for
            var i:Int = m_mark_end;
            while (i < m_lines.length)
            {
                tmp.push(m_lines[i]);
                i++;
            }
        } //end for
        m_lines = null;
        m_lines = tmp;
    }
    function save():Void
    {
        var s:String = null;
        for (l in m_lines)
        {
            if (s != null)
            {
                s += m_bl;
            }
            s += l;
        }
        psgg.HxFile.WriteAllText_String_String_Encoding(G.TGTFILE, s, m_enc);
    }
    public function Start():Void
    {
        Goto(S_START);
    }
    public function IsEnd():Bool
    {
        return CheckState(S_END);
    }
    var m_enc:system.text.Encoding = system.text.Encoding.UTF8;
    var m_bl:String;
    var m_cur:Int = 0;
    var m_error:String;
    public var m_filepath:String;
    var m_lines:Array<String>;
    public var MARK_START:String;
    public var MARK_END:String;
    function is_null(s:String):Bool
    {
        return system.Cs2Hx.IsNullOrEmpty(s);
    }
    function S_CHECK_EXIST_NEXTLINE(bFirst:Bool):Void
    {
        if (m_cur < m_lines.length)
        {
            SetNextState(S_FIND_STARTMARK);
        }
        else
        {
            SetNextState(S_SAVE);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    var m_output:String;
    function S_CONVERT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_output = convert(m_indent, m_command);
        }
        if (is_null(m_error))
        {
            SetNextState(S_INSERT);
        }
        else
        {
            SetNextState(S_ERORR);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_END(bFirst:Bool):Void
    {
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_ERORR(bFirst:Bool):Void
    {
        if (bFirst)
        {
            throw new system.SystemException(m_error);
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
    function S_FIND_ENDMARK(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_cur = m_mark_start + 1;
            m_mark_end = find_end_mark();
            if (m_mark_end < 0)
            {
                m_error = "No end mark";
            }
        }
        if (is_null(m_error))
        {
            SetNextState(S_GET_PARAM);
        }
        else
        {
            SetNextState(S_ERORR);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    var m_mark_start:Int = 0;
    var m_mark_end:Int = 0;
    function S_FIND_STARTMARK(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_mark_start = find_start_mark();
        }
        if (m_mark_start >= 0)
        {
            SetNextState(S_FIND_ENDMARK);
        }
        else
        {
            SetNextState(S_SAVE);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    var m_indent:Int = 4;
    var m_command:String;
    function S_GET_PARAM(bFirst:Bool):Void
    {
        if (bFirst)
        {
            var l:String = m_lines[m_mark_start];
            get_param(l);
        }
        if (is_null(m_error))
        {
            SetNextState(S_CONVERT);
        }
        else
        {
            SetNextState(S_ERORR);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_INSERT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            insert_output();
        }
        if (!HasNextState())
        {
            SetNextState(S_NEXT);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_NEXT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_cur = m_mark_end + 1;
        }
        if (!HasNextState())
        {
            SetNextState(S_CHECK_EXIST_NEXTLINE);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    var m_src:String;
    function S_READSRC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            m_error = null;
            m_cur = 0;
            read_file();
        }
        if (is_null(m_error))
        {
            SetNextState(S_CHECK_EXIST_NEXTLINE);
        }
        else
        {
            SetNextState(S_ERORR);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SAVE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            save();
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
    function S_START(bFirst:Bool):Void
    {
        if (!HasNextState())
        {
            SetNextState(S_READSRC);
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
