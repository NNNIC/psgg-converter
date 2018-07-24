using System.IO;
using System.Text;
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
    void create_source()
    {
        m_src += G.CreateSource();
        m_src += G.NEWLINECHAR;
    }
    void write_file()
    {
        var path = Path.Combine(m_gendir,G.OUTPUT);
        File.WriteAllText(path,m_src,Encoding.GetEncoding(G.ENC));
    }
    #endregion
}
