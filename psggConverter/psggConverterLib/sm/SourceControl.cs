using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

public partial class SourceControl  {

    public psggConverterLib.Convert G;
    public bool IsEnd() { return CheckState(S_END);}

    #region generate
    public string m_excel;
    public string m_gendir;
    void load_setting()
    {
        var lines = StringUtil.SplitTrimEnd(G.template_src,'\x0a');
        foreach(var i in lines)
        {
            //                012345678
            if (i.StartsWith(":output="))
            {
                G.OUTPUT = i.Substring(8).Trim();
            }
            //                012345
            if (i.StartsWith(":enc="))
            {
                G.ENC = i.Substring(5).Trim();
            }
            //                0123456
            if (i.StartsWith(":lang="))
            {
                G.LANG= i.Substring(6).Trim();
            }
            if (i.StartsWith(":end"))
            {
                break;
            }
        }
    }
    void set_lang()
    {
        if (G.LANG=="vba")
        {
            G.COMMMENTLINE = "'";
        }
        else if (G.LANG=="bat")
        {
            G.COMMMENTLINE = "::";
        }
    }
    #endregion
    #region creating source
    string m_src = string.Empty;
    void write_header()
    {
        m_src = G.COMMMENTLINE + " psggConverterLib.dll converted from " + m_excel + ". "+ G.NEWLINECHAR;
    }
    //void create_source()
    //{
    //    m_src += G.CreateSource();
    //    m_src += G.NEWLINECHAR;
    //}
    void escape_to_char()
    {
        //バッファ内の\xXXを変換
        for(var loop = 0; loop <= 1000000; loop++)
        {
            if (loop == 1000000) throw new SystemException("Unexpected! {08D607FC-C96E-4AF8-B216-9B1A58F10E7A}"); 
            var find = RegexUtil.Get1stMatch(@"\\x[0-9a-fA-F]{2}",m_src);
            if (string.IsNullOrEmpty(find))
            {
                break;
            }
            try
            {
                var code = Convert.ToInt32(find.Substring(2),16);
                var chr  = new string((char)code, 1);
                m_src = m_src.Replace(find,chr);
            } catch (SystemException e)
            {
                throw new SystemException("Unexpected! {AD63884A-1E3C-4EB8-BE49-984CFF655D03}:" + e.Message);
            }
        }
    }
    void write_file()
    {
        var path = Path.Combine(m_gendir,G.OUTPUT);
        File.WriteAllText(path,m_src,Encoding.GetEncoding(G.ENC));
    }
    #endregion
    #region create_source
    string m_contents1=string.Empty;
    string m_contents2=string.Empty;
    void create_contents1()
    {
        var s = string.Empty;
        foreach(var state in G.state_list)
        {
            s += state + ",";
        }
        m_contents1 = s;
    }
    void create_contents2()
    {
        var s = string.Empty;
        foreach(var state in G.state_list)
        {
            s += G.CreateFunc(state) + G.NEWLINECHAR;
        }
        m_contents2 = s;
    }
    #endregion
    #region line convert
    
    string       m_targetsrc        = null;
    List<string> m_resultlist       = null;
    List<string> m_lines            = null;
    bool         m_needCheckAgain   = false;
    bool         m_bHeadColonIsCode = false;
    int          m_line_index       = 0;
    string       m_line             = null;
    bool         m_bContinue        = false;
    bool         m_bOkNg            = false;
    bool         m_bYesNo           = false;
    void setup_buffer_lc()
    {
        m_targetsrc = G.template_src;
    }
    void setup_split_lc()
    {
        m_resultlist = new List<string>();
        m_lines      = StringUtil.SplitTrimEnd(m_targetsrc,'\x0a');
        m_line_index = 0;
        m_needCheckAgain = false;
    }
    void checkcount_lc()
    {
        m_bOkNg = m_line_index < m_lines.Count;
    }
    void lines_to_buf()
    {
        m_targetsrc = StringUtil.LineToBuf(m_resultlist, G.NEWLINECHAR);
    }
    void br_OK(Action<bool> st)
    {
        if (m_bOkNg)
        {
            SetNextState(st);
        }
    }
    void br_NG(Action<bool> st)
    {
        if (!m_bOkNg)
        {
            SetNextState(st);
        }
    }
    void check_again_lc()
    {
        m_bYesNo = m_needCheckAgain;
    }
    void br_YES(Action<bool> st)
    {
        if (m_bYesNo)
        {
            SetNextState(st);
        }
    }
    void br_NO(Action<bool> st)
    {
        if (!m_bYesNo)
        {
            SetNextState(st);
        }
    }
    void bind_src_lc()
    {
        m_src += m_targetsrc;
        m_src += G.NEWLINECHAR;
    }
    void set_check_again()
    {
        m_needCheckAgain = true;
    }
    void next_lc()
    {
        m_line_index++;
    }
    void getline_lc()
    {
        m_line = m_lines[m_line_index];
        m_bContinue = false;
    }
    void is_end_lc()
    {
        if (m_line.StartsWith(":end"))
        {
            m_bHeadColonIsCode = true;
            m_bContinue        = true;
        }
    }
    void br_CONTINUE(Action<bool> st)
    {
        if (m_bContinue)
        {
            SetNextState(st);
        }
    }
    void br_NOTABOVE(Action<bool> st)
    {
        if (!HasNextState())
        {
            SetNextState(st);
        }
    }
    void is_comment()
    {
        if (!m_bHeadColonIsCode)
        {
            if (m_line.StartsWith(":"))
            {
                m_bContinue = true;
            }
        }
    }
    void is_contents_1_lc()
    {
        if (m_line.Contains(G.CONTENTS1))
        {
            var tmplines = StringUtil.ReplaceWordsInLine(m_line,G.CONTENTS1,m_contents1);
            m_resultlist.AddRange(tmplines);
            m_bContinue = true;
        }
    }
    void is_contents_2_lc()
    {
        if (m_line.Contains(G.CONTENTS2))
        {
            var tmplines = StringUtil.ReplaceWordsInLine(m_line,G.CONTENTS2,m_contents2);
            m_resultlist.AddRange(tmplines);
            m_bContinue = true;
        }
    }
    void is_include_lc()
    {
        var include_file_str = RegexUtil.Get1stMatch(G.INCLUDEFILE,m_line);
        if (!string.IsNullOrEmpty(include_file_str))
        {
            var text = string.Empty;
            var file = include_file_str.Substring(/*$include:*/9).TrimEnd('$');
            try {
                text = File.ReadAllText(Path.Combine(G.INCDIR,file),Encoding.GetEncoding(G.ENC));
            } catch (SystemException e){
                throw new SystemException("Cannot read file (" + file +") because " + e.Message);
            }

            m_resultlist.Add(G.COMMMENTLINE + " #start include -" + file);

            var tmplines = StringUtil.ReplaceWordsInLine(m_line,include_file_str,text);
            m_resultlist.AddRange(tmplines);

            m_resultlist.Add(G.COMMMENTLINE + " #end include -" + file);

            m_bContinue      = true;
        }
    }
    void is_macro_lc()
    {
        var macro_str = RegexUtil.Get1stMatch(G.MACRO,m_line);
        if (!string.IsNullOrEmpty(macro_str))
        {
            //TODO
            m_bContinue      = false;
        }
    }
    void add_line_lc()
    {
        m_resultlist.Add(m_line);
    }
    #endregion
}
