using System;
using System.Text;
using System.IO;
using System.Collections.Generic;
public partial class InsertCodeControl  {

    // write your code 

    public psggConverterLib.Convert G;
    public string                   m_excel;

    void read_file()
    {
        try
        {
            m_src = File.ReadAllText(m_filepath);
            m_bl = StringUtil.FindNewLineChar(m_src);
            m_lines = StringUtil.SplitTrimKeepSpace(m_src,m_bl[0]);
        }
        catch (SystemException e)
        {
            m_error = "error read_file. " + e.Message;
        }
    }

    int find_start_mark()
    {
        for (var index = m_cur; index < m_lines.Count; index++)
        {
            var l = m_lines[index];
            if (l!=null &&l.Contains(MARK_START))
            {
                m_cur = index;
                return index;
            }
        }
        return -1;
    }

    int find_end_mark()
    {
        for (var index = m_cur; index < m_lines.Count; index++)
        {
            var l = m_lines[index];
            if (l!=null && l.Contains(MARK_END))
            {
                return index;
            }
        }
        return -1;
    }
    void get_param(string s)
    {
        var markindex = s.IndexOf(MARK_START);
        var ns = s.Substring(markindex + MARK_START.Length); //マークより後のバッファ

        var indentstr = RegexUtil.Get1stMatch(@"indent\(\d+\)",ns);
        if (!string.IsNullOrEmpty(indentstr))
        {
            var numstr = RegexUtil.Get1stMatch(@"\d+",indentstr);
            m_indent = int.Parse(numstr);

            ns = ns.Replace(indentstr, ""); //インデント部分除去
        }

        m_command = RegexUtil.Get1stMatch(@"\$.+\$\s*$",ns);

        if (string.IsNullOrEmpty(m_command))
        {
            m_error = "Cannot find command : " + s;
        }
    }

    string convert(int indent, string command)
    {
        var buf =  indent > 0 ? new string(' ', indent) : string.Empty;

        buf += command;
        var output = G.generate_for_inserting_src(m_excel,buf);
        return output;
    }

    void insert_output()
    {
        var tmp = new List<string>();

        // m_mark_startラインまでコピー
        for (var i = 0; i <= m_mark_start; i++)
        {
            tmp.Add(m_lines[i]);
        }
        //outputをコピー
        {
            var outlines = StringUtil.SplitTrimKeepSpace(m_output,m_bl[0]);
            tmp.AddRange(outlines);
        }
        //最後まで
        for (var i = m_mark_end; i < m_lines.Count; i++)
        {
            tmp.Add(m_lines[i]);
        }
        
        //入れ替える
        m_lines = null;
        m_lines = tmp;
    }

    void save()
    {
        string s = null;
        foreach (var l in m_lines)
        {
            if (s != null)
            {
                s += m_bl;
            }
            s+= l;
        }
        File.WriteAllText(G.TGTFILE,s,Encoding.GetEncoding(G.ENC));
    }

}
