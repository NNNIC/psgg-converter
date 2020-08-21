package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class SourceControl extends StateManager
{
    public var G:psggconverterlib.Convert;
    public function IsEnd():Bool
    {
        return CheckState(S_END);
    }
    public var mode:Int = 0;
    public var m_insert_template_src:String;
    public var m_insert_output:String;
    function br_INIT(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (mode == SourceControl_MODE.INIT)
            {
                SetNextState(st);
            }
        }
    }
    function br_CVT(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (mode == SourceControl_MODE.CVT)
            {
                SetNextState(st);
            }
        }
    }
    function br_INSERT(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            if (mode == SourceControl_MODE.INSERT)
            {
                SetNextState(st);
            }
        }
    }
    public var m_excel:String;
    public var m_gendir:String;
    function load_setting():Void
    {
        G.TEMSRC = null;
        G.TEMFUNC = null;
        if (!system.Cs2Hx.IsNullOrEmpty(G.template_src))
        {
            var lines:Array<String> = StringUtil.SplitTrimEnd(G.template_src, 10);
            if (lines == null)
            {
                throw new system.SystemException("Unexpected! {F794458F-407A-490F-9666-B96369567B4C}");
            }
            for (i in lines)
            {
                if (system.Cs2Hx.StartsWith(i, ":output="))
                {
                    G.OUTPUT = system.Cs2Hx.Trim(i.substr(8));
                }
                if (system.Cs2Hx.StartsWith(i, ":enc="))
                {
                    G.ENC = system.Cs2Hx.Trim(i.substr(5));
                }
                if (system.Cs2Hx.StartsWith(i, ":lang="))
                {
                    G.LANG = system.Cs2Hx.Trim(i.substr(6));
                }
                if (system.Cs2Hx.StartsWith(i, ":tempsrc="))
                {
                    G.TEMSRC = system.Cs2Hx.Trim(i.substr(9));
                }
                if (system.Cs2Hx.StartsWith(i, ":tempfunc="))
                {
                    G.TEMFUNC = system.Cs2Hx.Trim(i.substr(10));
                }
                if (system.Cs2Hx.StartsWith(i, ":prefix="))
                {
                    G.PREFIX = system.Cs2Hx.Trim(i.substr(8));
                }
                if (system.Cs2Hx.StartsWith(i, ":end"))
                {
                    break;
                }
            }
        }
        if (!system.Cs2Hx.IsNullOrEmpty(G.TEMSRC))
        {
            try
            {
                G.template_src = psgg.HxFile.ReadAllText_String_Encoding(system.io.Path.Combine_String_String(G.XLSDIR, G.TEMSRC), system.text.Encoding.UTF8);
                if (!system.Cs2Hx.IsNullOrEmpty(G.PREFIX))
                {
                    G.template_src = G.template_src.replace("__PREFIX__", G.PREFIX);
                }
            }
            catch (e:system.SystemException)
            {
                throw new system.SystemException("Error! Template Sourec File not found! " + system.Cs2Hx.NullCheck(e.Message));
            }
        }
        if (!system.Cs2Hx.IsNullOrEmpty(G.TEMFUNC))
        {
            try
            {
                G.template_func = psgg.HxFile.ReadAllText_String_Encoding(system.io.Path.Combine_String_String(G.XLSDIR, G.TEMFUNC), system.text.Encoding.UTF8);
                if (!system.Cs2Hx.IsNullOrEmpty(G.PREFIX))
                {
                    G.template_func = G.template_func.replace("__PREFIX__", G.PREFIX);
                }
            }
            catch (e:system.SystemException)
            {
                throw new system.SystemException("Error! Template Function File not found! " + system.Cs2Hx.NullCheck(e.Message));
            }
        }
    }
    function need_check_again():Void
    {
        m_bYesNo = false;
        if (!system.Cs2Hx.IsNullOrEmpty(G.TEMSRC))
        {
            G.TEMSRC_save = G.TEMSRC;
            G.TEMSRC = null;
            m_bYesNo = true;
        }
        if (!system.Cs2Hx.IsNullOrEmpty(G.TEMFUNC))
        {
            G.TEMFUNC_save = G.TEMFUNC;
            G.TEMFUNC = null;
        }
    }
    function set_lang():Void
    {
        if (G.LANG == "vba")
        {
            G.COMMENTLINE_FORMAT = "' {%0}";
        }
    }
    var m_src:String = "";
    function write_header():Void
    {
        var sp:(Int -> String) = function (i:Int):String { return (Cs2Hx.NewString(32, i)); } ;
        if (!system.Cs2Hx.IsNullOrEmpty(G.PSGGFILE))
        {
            m_src = system.Cs2Hx.NullCheck(sp(m_indent)) + system.Cs2Hx.NullCheck(G.GetComment(system.Cs2Hx.NullCheck(sp(12)) + "psggConverterLib.dll converted from psgg-file:")) + system.Cs2Hx.NullCheck(G.PSGGFILE) + system.Cs2Hx.NullCheck(G.NEWLINECHAR) + system.Cs2Hx.NullCheck(G.NEWLINECHAR);
        }
        else
        {
            m_src = system.Cs2Hx.NullCheck(sp(m_indent)) + system.Cs2Hx.NullCheck(G.GetComment(system.Cs2Hx.NullCheck(sp(12)) + "psggConverterLib.dll converted from " + system.Cs2Hx.NullCheck(m_excel) + ".")) + system.Cs2Hx.NullCheck(G.NEWLINECHAR) + system.Cs2Hx.NullCheck(G.NEWLINECHAR);
        }
    }
    function escape_to_char():Void
    {
        var res:String = "";
        var getstr4:(Int -> String) = function (i:Int):String
        {
            if (i < m_src.length - 4)
            {
                return m_src.substr(i, 4);
            }
            return null;
        }
        ;
        { //for
            var index:Int = 0;
            while (index < m_src.length)
            {
                var c:Int = m_src.charCodeAt(index);
                if (c == 92)
                {
                    var sample:String = getstr4(index);
                    if (!system.Cs2Hx.IsNullOrEmpty(sample))
                    {
                        if (RegexUtil.IsMatch("\\\\x[0-9a-fA-F]{2}", sample))
                        {
                            var code:Int = system.Convert.ToInt32_String_Int32(sample.substr(2), 16);
                            c = code;
                            index += 3;
                        }
                    }
                }
                res += Cs2Hx.CharToString(c);
                index++;
            }
        } //end for
        m_src = res;
    }
    function write_file():Void
    {
        var path:String = system.io.Path.Combine_String_String(m_gendir, G.OUTPUT);
        var dir:String = system.io.Path.GetDirectoryName(path);
        if (!system.io.Directory.Exists(dir))
        {
            system.io.Directory.CreateDirectory(dir);
        }
        psgg.HxFile.WriteAllText_String_String_Encoding(path, m_src, psgg.HxEncoding.GetEncoding_String(G.ENC));
    }
    function write_insertbuf():Void
    {
        m_insert_output = m_src;
    }
    var m_contents1:String = "";
    var m_contents2:String = "";
    function create_contents1():Void
    {
        var state_list:Array<String> = new Array<String>();
        system.Cs2Hx.AddRange(state_list, G.state_list);
        state_list = SortUtil.Sort(state_list);
        var s:String = "";
        for (state in state_list)
        {
            s += system.Cs2Hx.NullCheck(state) + "," + system.Cs2Hx.NullCheck(G.NEWLINECHAR);
        }
        m_contents1 = s;
    }
    function create_contents2():Void
    {
        var state_list:Array<String> = new Array<String>();
        system.Cs2Hx.AddRange(state_list, G.state_list);
        state_list = SortUtil.Sort(state_list);
        var s:String = "";
        for (state in state_list)
        {
            s += system.Cs2Hx.NullCheck(G.CreateFunc(state)) + system.Cs2Hx.NullCheck(G.NEWLINECHAR);
        }
        m_contents2 = s;
    }
    function create_regex_contents(regex:String, macrobuf:String = null):String
    {
        var state_list:Array<String> = new Array<String>();
        system.Cs2Hx.ForEach(G.state_list, function (i:String):Void
        {
            var a:String = RegexUtil.Get1stMatch(regex, i);
            if (!system.Cs2Hx.IsNullOrEmpty(a))
            {
                state_list.push(i);
            }
        }
        );
        state_list = SortUtil.Sort(state_list);
        var s:String = "";
        for (state in state_list)
        {
            var o:String = G.CreateFunc(state, macrobuf);
            if (!system.Cs2Hx.IsNullOrEmpty(o))
            {
                s += system.Cs2Hx.NullCheck(o) + system.Cs2Hx.NullCheck(G.NEWLINECHAR);
            }
        }
        return s;
    }
    var m_targetsrc:String = null;
    var m_resultlist:Array<String> = null;
    var m_lines:Array<String> = null;
    var m_needCheckAgain:Bool = false;
    var m_bHeadColonIsCode:Bool = false;
    var m_line_index:Int = 0;
    var m_line:String = null;
    var m_bContinue:Bool = false;
    var m_bOkNg:Bool = false;
    var m_bYesNo:Bool = false;
    function setup_buffer_lc():Void
    {
        m_targetsrc = G.template_src;
    }
    function setup_buffer_lc_insert():Void
    {
        m_targetsrc = m_insert_template_src;
    }
    function setup_split_lc():Void
    {
        m_resultlist = new Array<String>();
        m_lines = StringUtil.SplitTrimEnd(m_targetsrc, 10);
        m_line_index = 0;
        m_needCheckAgain = false;
    }
    function checkcount_lc():Void
    {
        m_bOkNg = m_line_index < m_lines.length;
    }
    function lines_to_buf():Void
    {
        m_targetsrc = StringUtil.LineToBuf(m_resultlist, G.NEWLINECHAR);
    }
    function br_OK(st:(Bool -> Void)):Void
    {
        if (m_bOkNg)
        {
            SetNextState(st);
        }
    }
    function br_NG(st:(Bool -> Void)):Void
    {
        if (!m_bOkNg)
        {
            SetNextState(st);
        }
    }
    function check_again_lc():Void
    {
        m_bYesNo = m_needCheckAgain;
    }
    function br_YES(st:(Bool -> Void)):Void
    {
        if (m_bYesNo)
        {
            SetNextState(st);
        }
    }
    function br_NO(st:(Bool -> Void)):Void
    {
        if (!m_bYesNo)
        {
            SetNextState(st);
        }
    }
    function bind_src_lc():Void
    {
        m_src += m_targetsrc;
        m_src += G.NEWLINECHAR;
    }
    function set_check_again():Void
    {
        m_needCheckAgain = true;
    }
    function next_lc():Void
    {
        m_line_index++;
    }
    function getline_lc():Void
    {
        m_line = m_lines[m_line_index];
        m_bContinue = false;
    }
    function is_end_lc():Void
    {
        if (system.Cs2Hx.StartsWith(m_line, ":end"))
        {
            m_bHeadColonIsCode = true;
            m_bContinue = true;
        }
    }
    function br_CONTINUE(st:(Bool -> Void)):Void
    {
        if (m_bContinue)
        {
            SetNextState(st);
        }
    }
    function br_NOTABOVE(st:(Bool -> Void)):Void
    {
        if (!HasNextState())
        {
            SetNextState(st);
        }
    }
    function is_comment():Void
    {
        if (!m_bHeadColonIsCode)
        {
            if (system.Cs2Hx.StartsWith(m_line, ":"))
            {
                m_bContinue = true;
            }
        }
    }
    function is_contents_1_lc():Void
    {
        var match:String = RegexUtil.Get1stMatch(G.CONTENTS1PTN, m_line);
        if (!system.Cs2Hx.IsNullOrEmpty(match))
        {
            var macrov:String = "";
            if (system.Cs2Hx.StringContains(match, "->@"))
            {
                var index:Int = match.indexOf("->@");
                if (index >= 0)
                {
                    macrov = system.Cs2Hx.Trim_(match.substr(index + 3), [ 36 ]);
                }
            }
            var replacevalue:String = G.get_line_macro_value(macrov, m_contents1);
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, match, replacevalue);
            system.Cs2Hx.AddRange(m_resultlist, tmplines);
            m_bContinue = true;
        }
    }
    function is_contents_2_lc():Void
    {
        if (system.Cs2Hx.StringContains(m_line, G.CONTENTS2))
        {
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, G.CONTENTS2, m_contents2);
            system.Cs2Hx.AddRange(m_resultlist, tmplines);
            m_bContinue = true;
        }
    }
    function is_regex_contents_lc():Void
    {
        var match:String = RegexUtil.Get1stMatch(G.REGEXCONT, m_line);
        if (!system.Cs2Hx.IsNullOrEmpty(match))
        {
            var regex:String = system.Cs2Hx.Trim(match).substr(2);
            regex = regex.substr(0, regex.length - 2);
            var c:String = create_regex_contents(regex);
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, match, c);
            system.Cs2Hx.AddRange(m_resultlist, tmplines);
            m_bContinue = true;
        }
    }
    function is_regex_contents2_lc():Void
    {
        var match:String = RegexUtil.Get1stMatch(G.REGEXCONT2, m_line);
        if (!system.Cs2Hx.IsNullOrEmpty(match))
        {
            var regex:String = RegexUtil.Get1stMatch("\\$\\/.+\\/->#", match);
            regex = regex.substr(2);
            regex = regex.substr(0, regex.length - 4);
            var macroname:String = RegexUtil.Get1stMatch("#.+\\$$", match);
            macroname = system.Cs2Hx.TrimEnd(macroname, [ 36 ]);
            var macrobuf:String = G.getMacroValueFunc(macroname);
            if (system.Cs2Hx.IsNullOrEmpty(macrobuf))
            {
                throw new system.SystemException("Macro is not defined. : " + system.Cs2Hx.NullCheck(macroname));
            }
            var c:String = create_regex_contents(regex, macrobuf);
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, match, c);
            system.Cs2Hx.AddRange(m_resultlist, tmplines);
            m_bContinue = true;
        }
    }
    function is_prefix_lc():Void
    {
        if (system.Cs2Hx.StringContains(m_line, G.PREFIXMACRO))
        {
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, G.PREFIXMACRO, G.PREFIX);
            system.Cs2Hx.AddRange(m_resultlist, tmplines);
            m_bContinue = true;
        }
    }
    var m_mw:psggconverterlib.MacroWork;
    function is_include_lc():Void
    {
        if (m_mw == null)
        {
            m_mw = new psggconverterlib.MacroWork();
        }
        m_mw.Init();
        m_mw.CheckMacro(m_line);
        if (m_mw.IsValid() && m_mw.IsInclude())
        {
            var matchstr:String = m_mw.GetMatchStr();
            var file:String = m_mw.GetIncludFilename();
            var enc:String = m_mw.GetIncludeFileEnc();
            var text:String = IncludeFile.readfile(G, matchstr, file, enc);
            m_resultlist.push(G.GetComment(" #start include -" + system.Cs2Hx.NullCheck(file)));
            var tmplines:Array<String> = StringUtil.ReplaceWordsInLine(m_line, matchstr, text);
            system.Cs2Hx.AddRange(m_resultlist, tmplines);
            m_resultlist.push(G.GetComment(" #end include -" + system.Cs2Hx.NullCheck(file)));
            m_bContinue = true;
        }
    }
    function is_macro_lc():Void
    {
        if (m_mw.IsValid() && !m_mw.IsInclude())
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
            system.Cs2Hx.AddRange(m_resultlist, tmplines);
            m_bContinue = true;
        }
    }
    function add_line_lc():Void
    {
        m_resultlist.push(m_line);
    }
    public function Start():Void
    {
        Goto(S_START);
    }
    public var m_cvthexchar:Bool = false;
    public var m_indent:Int = 0;
    function S_ADDLINE_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            add_line_lc();
        }
        if (!HasNextState())
        {
            SetNextState(S_NEXT_LC);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_BIND_SRC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            bind_src_lc();
        }
        if (!HasNextState())
        {
            SetNextState(S_ESCAPE_TO_CHAR);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_CHECK_AGAIN(bFirst:Bool):Void
    {
        if (bFirst)
        {
            check_again_lc();
        }
        br_YES(S_SETUP2_LC);
        br_NO(S_BIND_SRC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_CHECKCOUNT_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            checkcount_lc();
        }
        br_OK(S_GETLINE_LC);
        br_NG(S_LINESTOBUF_LC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_CHECKMODE(bFirst:Bool):Void
    {
        if (bFirst)
        {
        }
        br_INIT(S_LOADSETTING);
        br_CVT(S_WRITEHEDDER);
        br_INSERT(S_WRITEHEDDER);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_CONTENTS_1(bFirst:Bool):Void
    {
        if (bFirst)
        {
            create_contents1();
        }
        if (!HasNextState())
        {
            SetNextState(S_CONTENTS_2);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_CONTENTS_2(bFirst:Bool):Void
    {
        if (bFirst)
        {
            create_contents2();
        }
        if (!HasNextState())
        {
            SetNextState(S_SETUP_LC);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_CREATESOURCE(bFirst:Bool):Void
    {
        if (bFirst)
        {
        }
        if (!HasNextState())
        {
            SetNextState(S_CONTENTS_1);
        }
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
    function S_ESCAPE_TO_CHAR(bFirst:Bool):Void
    {
        if (bFirst)
        {
            if (m_cvthexchar)
            {
                escape_to_char();
            }
        }
        if (!HasNextState())
        {
            SetNextState(S_OUTPUTCHECK);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_GETLINE_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            getline_lc();
        }
        if (!HasNextState())
        {
            SetNextState(S_IS_END_LC);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_COMMENT(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_comment();
        }
        br_CONTINUE(S_NEXT_LC);
        br_NOTABOVE(S_IS_CONTENTS_1_LC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_CONTENTS_1_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_contents_1_lc();
        }
        br_CONTINUE(S_NEXT_LC);
        br_NOTABOVE(S_IS_CONTENTS_2_LC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_CONTENTS_2_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_contents_2_lc();
        }
        br_CONTINUE(S_NEXT_LC);
        br_NOTABOVE(S_IS_REGEX_LC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_END_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_end_lc();
        }
        br_CONTINUE(S_NEXT_LC);
        br_NOTABOVE(S_IS_COMMENT);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_INCLUDE_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_include_lc();
        }
        br_CONTINUE(S_SET_CHECKAGAIN);
        br_NOTABOVE(S_IS_MACRO_LC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_MACRO_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_macro_lc();
        }
        br_CONTINUE(S_SET_CHECKAGAIN);
        br_NOTABOVE(S_ADDLINE_LC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_PREFIX(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_prefix_lc();
        }
        br_CONTINUE(S_SET_CHECKAGAIN);
        br_NOTABOVE(S_IS_INCLUDE_LC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_REGEX_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_regex_contents_lc();
        }
        br_CONTINUE(S_NEXT_LC);
        br_NOTABOVE(S_IS_REGEX2_LC);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_IS_REGEX2_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            is_regex_contents2_lc();
        }
        br_CONTINUE(S_NEXT_LC);
        br_NOTABOVE(S_IS_PREFIX);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_LINESTOBUF_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            lines_to_buf();
        }
        if (!HasNextState())
        {
            SetNextState(S_CHECK_AGAIN);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_LOADSETTING(bFirst:Bool):Void
    {
        if (bFirst)
        {
            load_setting();
        }
        need_check_again();
        br_YES(S_LOADSETTING);
        br_NO(S_SETLANG);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_NEXT_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            next_lc();
        }
        if (!HasNextState())
        {
            SetNextState(S_CHECKCOUNT_LC);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_OUTPUT_INSERTBUF(bFirst:Bool):Void
    {
        if (bFirst)
        {
            write_insertbuf();
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
    function S_OUTPUTCHECK(bFirst:Bool):Void
    {
        if (bFirst)
        {
        }
        br_CVT(S_WRITEFILE);
        br_INSERT(S_OUTPUT_INSERTBUF);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SET_CHECKAGAIN(bFirst:Bool):Void
    {
        if (bFirst)
        {
            set_check_again();
        }
        if (!HasNextState())
        {
            SetNextState(S_NEXT_LC);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SETLANG(bFirst:Bool):Void
    {
        if (bFirst)
        {
            set_lang();
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
    function S_SETUP_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
        }
        br_CVT(S_USE_G_TEMPLSRC);
        br_INSERT(S_USE_INSERT_TEMP);
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_SETUP2_LC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            setup_split_lc();
        }
        if (!HasNextState())
        {
            SetNextState(S_CHECKCOUNT_LC);
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
            SetNextState(S_CHECKMODE);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_USE_G_TEMPLSRC(bFirst:Bool):Void
    {
        if (bFirst)
        {
            setup_buffer_lc();
        }
        if (!HasNextState())
        {
            SetNextState(S_SETUP2_LC);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_USE_INSERT_TEMP(bFirst:Bool):Void
    {
        if (bFirst)
        {
            setup_buffer_lc_insert();
        }
        if (!HasNextState())
        {
            SetNextState(S_SETUP2_LC);
        }
        if (HasNextState())
        {
            GoNextState();
        }
    }
    function S_WRITEFILE(bFirst:Bool):Void
    {
        if (bFirst)
        {
            write_file();
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
    function S_WRITEHEDDER(bFirst:Bool):Void
    {
        if (bFirst)
        {
            write_header();
        }
        if (!HasNextState())
        {
            SetNextState(S_CREATESOURCE);
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
